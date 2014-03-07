class ContainerView
	constructor: (controller, wrapper) ->
		@controller = controller
		@wrapper = wrapper
		@build()
	build: () ->
		@wrapper.innerHTML = ''
		@body = _.element({
			type:'div'
			classList:['inner-wrapper']
			parent:@wrapper
		})
	addChild: (child) ->
		@body.appendChild child.getElement()
