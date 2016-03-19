require "colors"

focusLevel = 0
evaluating = false
indentation = []
inactive = null

failures = []

root =
  beforeEaches: []
  afterEaches: []
  description: null
  callback: null
  its: []
  describes: []
  parent: null
pointer = root

describe = (description, callback, focusLevel=0) ->
  throw new Error('Cannot use describe inside of an it block') if evaluating
  describeNode =
    beforeEaches: []
    afterEaches: []
    description: description
    callback: callback
    its: []
    describes: []
    parent: pointer
    active: true
    focusLevel: focusLevel
  pointer.describes.push(describeNode)
  pointer = describeNode
  callback()
  pointer = pointer.parent

it = (description, callback, focusLevel=0) ->
  pointer.its.push({description, callback, parent: pointer, active: true, focusLevel})

beforeEach = (callback) ->
  pointer.beforeEaches.push(callback)

afterEach = (callback) ->
  pointer.afterEaches.push(callback)


xdescribe = (description, callback) ->
  describeNode =
    beforeEaches: []
    afterEaches: []
    description: description
    callback: callback
    its: []
    describes: []
    parent: pointer
    active: false
  pointer.describes.push(describeNode)
  pointer = describeNode
  callback()
  pointer = pointer.parent

xit = (description, callback) ->
  pointer.its.push({description, callback, parent: pointer, active: false})


generate = (fn, level) ->
  (description, callback) ->
    focusLevel = Math.max(focusLevel, level)
    fn(description, callback, level)

fit = generate(it, 1)
ffit = generate(it, 2)
fffit = generate(it, 3)
fdescribe = generate(describe, 1)
ffdescribe = generate(describe, 2)
fffdescribe = generate(describe, 3)


logSuccess = (indentation, itNode) ->
  console.log indentation.join('') + itNode.description.green

logPending = (indentation, node) ->
  if node.describes?
    console.log indentation.join('') + node.description.bold.yellow
  else
    console.log indentation.join('') + node.description.yellow

logFailure = (indentation, itNode, error) ->
  failures.push({error, description: itNode.description, parent: itNode.parent})
  console.log indentation.join('') + itNode.description.red
  console.log indentation.join('') + error.message.bold.gray

evaluateBeforeEaches = (describe) ->
  evaluateBeforeEaches(describe.parent) if describe.parent
  describe.beforeEaches.forEach((beforeEach) -> beforeEach())

evaluateAfterEaches = (describe) ->
  evaluateAfterEaches(describe.parent) if describe.parent
  describe.afterEaches.forEach((afterEach) -> afterEach())

tryAfterEach = (indentation, itNode) ->
  try
    evaluateAfterEaches(itNode.parent)
  catch error
    logFailure(indentation, itNode, error)

logErrors = ->
  console.log()
  failures.forEach((failure) ->
    stack = failure.error.stack
    stack = stack.split('\n').map((line) -> line = '  '+line).join('\n')
    console.log failure.description.red
    console.log failure.error.message
    console.log stack
  )

recurse = (fn, array, index, callback) ->
  value = array[index]
  if value
    fn(value, -> recurse(fn, array, ++index, callback))
  else
    callback()

evaluateDescribe = (describeNode, next) ->
  previousInactiveStatus = inactive
  if describeNode.active and not inactive
    console.log indentation.join('') + describeNode.description.bold
  else
    inactive = true
    logPending(indentation, describeNode)
  indentation.push('  ')
  if describeNode.focusLevel is focusLevel
    describeNode.its.map((it) -> it.focusLevel = focusLevel)
    describeNode.describes.map((describe) -> describe.focusLevel = focusLevel)

  recurse(evaluateIt, describeNode.its, 0, ->
    recurse(evaluateDescribe, describeNode.describes, 0, ->
      indentation.pop()
      inactive = previousInactiveStatus
      next()
    )
  )

evaluateIt = (itNode, next) ->
  itNode.active = false unless itNode.focusLevel is focusLevel

  proceed = (error, success) ->
    if (error) # error passed from spec
      logError(indentation, itNode, error)
    else
      logSuccess(indentation, itNode)
    tryAfterEach(indentation, itNode)
    next()

  try
    if itNode.active and not inactive
      evaluateBeforeEaches(itNode.parent)
      itNode.callback(proceed)
      proceed() unless itNode.callback.length > 0
    else
      logPending(indentation, itNode)
      next()
  catch error # errors thrown by it callbacks
    logFailure(indentation, itNode, error)
    tryAfterEach(indentation, itNode)
    next()


evaluate = ->
  evaluating = true

  recurse(evaluateDescribe, root.describes, 0, ->
    # logErrors()
  )


module.exports.evaluate = evaluate

module.exports.describe = describe
module.exports.it = it
module.exports.beforeEach = beforeEach
module.exports.afterEach = afterEach

module.exports.xdescribe = xdescribe
module.exports.xit = xit

module.exports.fdescribe = fdescribe
module.exports.ffdescribe = ffdescribe
module.exports.fffdescribe = fffdescribe
module.exports.fit = fit
module.exports.ffit = ffit
module.exports.fffit = fffit
