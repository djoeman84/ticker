class SelectorView
	constructor: (controller) ->
		@class_identifier = 'selector-view'
		@controller = controller
		@selectionElem = _.element({
			type:'div'
			classList:["#{@class_identifier}-container"]
		})

	getElement: () -> @selectionElem
	selectElement: (element) ->
		selection = element.selection
		e.classList.remove('selected') for e in @elements if e isnt element
		element.classList.add('selected')
		@selectedIndex = element.selectionIndex
		@controller.selectionClicked(selection)
	refresh: (selections) ->
		_this = @
		@selectionElem.innerHTML = ''
		@elements = []
		for i in [0...selections.length]
			s = selections[i]
			e = _.element(
					type:'div'
					classList:["#{@class_identifier}-selection",'transition']
					innerHTML:s.label
				)
			e.selection = s
			e.selectionIndex = i
			e.addEventListener('click', (() -> _this.selectElement(@)))
			@selectionElem.appendChild(e)
			@elements.push e
		if @selectedIndex and @selectedIndex < @elements.length
			@selectElement(@elements[@selectedIndex])
		else if @elements.length > 0
			@selectElement(@elements[0])

		

	
