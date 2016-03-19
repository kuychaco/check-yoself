path = require 'path'

filePaths = process.argv.slice(2).map((filePath) -> path.resolve(filePath))

console.log filePaths[0]
check = require './check'

Object.keys(check).forEach (key) -> global[key] = check[key]

require file for file in filePaths
evaluate()
