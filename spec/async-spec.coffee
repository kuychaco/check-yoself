assert = require "assert"

count2 = 0
describe "async", ->
  it "waits for done callback to get invoked", (done) ->
    setTimeout(() ->
      count2++
      done()
    , 2000)

  it "runs after waiting", () ->
    assert.equal count2, 1

  it "works", () ->
    count2++
    assert.equal count2, 2

describe "more", ->
  it "works", ->
    assert.equal ++count2, 3
