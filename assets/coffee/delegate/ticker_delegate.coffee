#coffee -w -j ./js/tickerlanding.js -c ./coffee/*/*

document.body.onload = -> 
	landingConrtoller = new LandingConrtoller()
	(new Delegate({
		default:landingConrtoller
		landingConrtoller:landingConrtoller
		gameController:(new GameController())
	}, _.id("content"))).run()

class Delegate
	constructor: (controllerTable, wrapper) ->
		alert "Delegate must be initialized with controllerTable, see docs for more info" unless controllerTable
		@controllerTable = controllerTable
		@wrapper = if wrapper then wrapper else document.body
		for k, v of controllerTable
			v.delegate = @
			v.wrapper = wrapper
	run: () -> @controllerTable.default.run(@wrapper)
	toController: (controllerName, options = {}, withWrapper = @wrapper) ->
		withWrapper.innerHTML = ''
		@controllerTable[controllerName].run((if 'aux' of options then options.aux else {}))
	getModel: (modelName) -> @models[modelName] if @models and modelName of @models
	
