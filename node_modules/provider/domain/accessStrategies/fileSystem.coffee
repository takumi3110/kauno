given =
  fs: require 'fs'
  path: require 'path'

augment = (obj, name, fn) ->
  Object.defineProperty obj

services =
  # load a path spec
  load: (pathSpec, next) ->

    @given.fs.stat pathSpec, (err, data) ->
      fsNode = {}

load = (dependencies) ->
  @given = dependencies if dependencies?
  return services

module.exports = load
