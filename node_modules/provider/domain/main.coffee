# Provider handles dependency injection on a project wide basis.
#
# In development this lets you easily swap out third party dependencies.  In
# testing, this lets you swap in mock dependencies so that you can isolate the
# code you're testing.
#
# In order to do this it must assume responsibility for the application's
# execution.  Provider should therefore be referenced in package.json:main and
# the dependencyConfiguration should include an entry point.
#
# Contract:
#
#   given:
#
#   services:
#     loadApp:
#       in:
#         dependencyConfiguration: fileName
#         applicationStructure: Nomad root node
#
#       out:
#         app: Executable #app.execute()
#
given = {}

services =
  setup: (dependencies, appRoot, next) ->
    app =
      execute: () -> return null

    next null, app

loader = (dependencies) ->
  @given = dependencies if dependencies?
  return services

module.exports = loader
