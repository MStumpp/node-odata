mongoose = require 'mongoose'

isField = (obj) ->
  return true  if typeof obj is 'function'
  if typeof obj is 'object'
    if obj.type and typeof obj.type is 'function'
      return true

isArray = (obj) ->
  Array.isArray obj and obj.length >= 0

isComplexArray = (obj) ->
  isArray obj and isField(obj[0])

isObject = (obj) ->
  obj and typeof obj is 'object' and !isArray(obj) and !isField(obj)


module.exports =
  toMongoose: (obj) ->
    convert = (obj, name) ->
      if isComplexArray(obj[name])
        convert(obj[name][0], childName) for childName of obj[name][0]
        obj[name] = [new mongoose.Schema(obj[name][0])]
      else if isObject(obj[name])
        convert(obj[name], childName) for childName of obj[name]
    convert obj: obj, 'obj'
    return obj


  toMetadata: (obj) ->
    convert = (obj, name) ->
      LEN = 'function '.length
      if isField(obj[name])
        if typeof obj[name] is 'function'
          obj[name] = obj[name].toString()
          obj[name] = obj[name].substr(LEN, obj[name].indexOf('(') - LEN)
        else if typeof obj[name] is 'object'
          obj[name].type = obj[name].type.toString()
          obj[name].type = obj[name].type.substr(LEN, obj[name].type.indexOf('(') - LEN)
      else if isComplexArray(obj[name])
        convert(obj[name][0], childName)  for childName of obj[name][0]
      else if isArray(obj[name])
        obj[name][0] = obj[name][0].toString()
        obj[name][0] = obj[name][0].substr(LEN, obj[name][0].indexOf('(') - LEN)
      else if isObject(obj[name])
        convert(obj[name], childName)  for childName of obj[name]

    convert obj: obj, 'obj'
    return obj
