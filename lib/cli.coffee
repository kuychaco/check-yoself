path = require 'path'

filePaths = process.argv.slice(2).map((filePath) -> path.resolve(filePath))

console.log filePaths[0]
{describe, it, beforeEach, afterEach, evaluate, xit, xdescribe} = require './check'
global.describe = describe
global.it = it
global.beforeEach = beforeEach
global.afterEach = afterEach
global.xit = xit
global.xdescribe = xdescribe
require file for file in filePaths
evaluate()
