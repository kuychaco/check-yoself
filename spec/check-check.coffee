assert = require "assert"

describe "check-yoself", ->

  describe "tests", ->
    it "works", ->
      assert.equal true, true
    it "fails appropriately", ->
      assert.equal true, false
    xit "doesn't run this", ->
      throw new Error("You should't see this")

  describe "multiple beforeEaches and afterEaches", ->
    ops = []
    beforeEach ->
      ops.push 1
    beforeEach ->
      ops.push 2
    afterEach ->
      ops.pop()
    afterEach ->
      ops.push 3

    it "spec1", ->
      assert.deepEqual ops, [1, 2]

    it "spec2", ->
      assert.deepEqual ops, [1, 3, 1, 2]

  describe "super nested describe blocks", ->
    beforeOps = []
    afterOps = []
    beforeEach ->
      beforeOps.push 1
    afterEach ->
      afterOps.push 1

    describe "more nested", ->
      beforeEach ->
        beforeOps.push 2
      afterEach ->
        afterOps.push 2
      describe "even more nested", ->
        beforeEach ->
          beforeOps.push 3
        afterEach ->
          afterOps.push 3
        describe "even MORE nested", ->
          beforeEach ->
            beforeOps.push 4
          afterEach ->
            afterOps.push 4
            assert.deepEqual afterOps, [1,2,3,4]

          it "works", ->
            assert.deepEqual beforeOps, [1,2,3,4]

  describe "error in beforeEach", ->
    beforeEach ->
      throw new Error('This should fail')

    it "should fail", ->
        throw new Error("You should't see this")
    describe "propagated failures", ->
      it "should fail", ->
        throw new Error("You should't see this")

  describe "error in afterEach", ->
    afterEach ->
      throw new Error('This should fail')

    it "should fail", ->
        throw new Error("You should't see this")
    describe "propagated failures", ->
      it "should fail", ->
        throw new Error("You should't see this")

  xdescribe "pending tests", ->
    beforeEach ->
      throw new Error("You should't see this")
    afterEach ->
      throw new Error("You should't see this")
    xdescribe "even more nested", ->
      beforeEach ->
        throw new Error("You should't see this")
      afterEach ->
        throw new Error("You should't see this")
      describe "even MORE nested", ->
        beforeEach ->
          throw new Error("You should't see this")
        afterEach ->
          throw new Error("You should't see this")

        it "should be yellow", ->
          throw new Error("You should't see this")

describe "when describe is inside of an it block", ->
  it "throws an error", ->
    describe "this shouldn't work", ->
