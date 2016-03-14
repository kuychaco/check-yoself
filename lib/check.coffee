require "colors"

root =
  beforeEaches: []
  afterEaches: []
  description: null
  callback: null
  its: []
  describes: []
  parent: null
pointer = root

module.exports.describe = (description, callback) ->
  describeNode =
    beforeEaches: []
    afterEaches: []
    description: description
    callback: callback
    its: []
    describes: []
    parent: pointer
    active: true
  pointer.describes.push(describeNode)
  pointer = describeNode
  callback()
  pointer = pointer.parent

module.exports.xdescribe = (description, callback) ->
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

module.exports.xit = (description, callback) ->
  pointer.its.push({description, callback, parent: pointer, active: false})

module.exports.it = (description, callback) ->
  pointer.its.push({description, callback, parent: pointer, active: true})

module.exports.beforeEach = (callback) ->
  pointer.beforeEaches.push(callback)

module.exports.afterEach = (callback) ->
  pointer.afterEaches.push(callback)

module.exports.evaluate = ->
  indentation = []
  inactive = null

  evaluateIt = (itNode) ->
    evaluateBeforeEaches = (describe) ->
      evaluateBeforeEaches(describe.parent) if describe.parent
      describe.beforeEaches.forEach((beforeEach) -> beforeEach())

    evaluateAfterEaches = (describe) ->
      evaluateAfterEaches(describe.parent) if describe.parent
      describe.afterEaches.forEach((afterEach) -> afterEach())

    try
      if itNode.active and not inactive
        evaluateBeforeEaches(itNode.parent)
        itNode.callback()
        evaluateAfterEaches(itNode.parent)
        console.log indentation.join('') + itNode.description.green
      else
        console.log indentation.join('') + itNode.description.yellow
    catch error
      console.log indentation.join('') + itNode.description.red
      console.log indentation.join('') + error.message.gray

  evaluateDescribe = (describeNode) ->
    previousInactiveStatus = inactive
    if describeNode.active and not inactive
      console.log indentation.join('') + describeNode.description
    else
      inactive = true
      console.log indentation.join('') + describeNode.description.yellow
    indentation.push('  ')
    describeNode.its.forEach((it) -> evaluateIt(it))

    describeNode.describes.forEach((describe) -> evaluateDescribe(describe))
    indentation.pop()
    inactive = previousInactiveStatus

  root.describes.forEach((describe) -> evaluateDescribe(describe))
