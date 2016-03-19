require "colors"

focusLevel = 0
evaluating = false

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


fit = (description, callback) ->
  focusLevel = Math.max(focusLevel, 1)
  it(description, callback, 1)

ffit = (description, callback) ->
  focusLevel = Math.max(focusLevel, 2)
  it(description, callback, 2)

fffit = (description, callback) ->
  focusLevel = Math.max(focusLevel, 3)
  it(description, callback, 3)

fdescribe = (description, callback) ->
  focusLevel = Math.max(focusLevel, 1)
  describe(description, callback, 1)

ffdescribe = (description, callback) ->
  focusLevel = Math.max(focusLevel, 2)
  describe(description, callback, 2)

fffdescribe = (description, callback) ->
  focusLevel = Math.max(focusLevel, 3)
  describe(description, callback, 3)

evaluate = ->
  indentation = []
  inactive = null
  complete = false
  evaluating = true

  evaluateIt = (itNode) ->
    itNode.active = false unless itNode.focusLevel is focusLevel
    evaluateBeforeEaches = (describe) ->
      evaluateBeforeEaches(describe.parent) if describe.parent
      describe.beforeEaches.forEach((beforeEach) -> beforeEach())

    evaluateAfterEaches = (describe) ->
      evaluateAfterEaches(describe.parent) if describe.parent
      describe.afterEaches.forEach((afterEach) -> afterEach())

    done = (error, success) ->
      if (error)
        return throw new Error(error.message)
      complete = true
      success?()

    try
      if itNode.active and not inactive
        evaluateBeforeEaches(itNode.parent)
        itNode.callback(done)
        evaluateAfterEaches(itNode.parent)
        console.log indentation.join('') + itNode.description.green
      else
        console.log indentation.join('') + itNode.description.yellow
    catch error
      console.log indentation.join('') + itNode.description.red
      console.log indentation.join('') + error.message.bold.gray

  evaluateDescribe = (describeNode) ->
    previousInactiveStatus = inactive
    if describeNode.active and not inactive
      console.log indentation.join('') + describeNode.description.bold
    else
      inactive = true
      console.log indentation.join('') + describeNode.description.yellow
    indentation.push('  ')
    if describeNode.focusLevel is focusLevel
      describeNode.its.map((it) -> it.focusLevel = focusLevel)
      describeNode.describes.map((describe) -> describe.focusLevel = focusLevel)

    describeNode.its.forEach((it) -> evaluateIt(it))
    describeNode.describes.forEach((describe) -> evaluateDescribe(describe))
    indentation.pop()
    inactive = previousInactiveStatus

  root.describes.forEach((describe) -> evaluateDescribe(describe))

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
