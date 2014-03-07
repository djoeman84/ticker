class GraphView
	constructor: (controller) ->
		@controller = controller
		@selector = new SelectorView(@)
		@graphHolder = _.element({
			type:'div'
		})
		@frame = _.element({
			type:'div'
			id:'graph-view-frame'
			children:[@selector.getElement(),@graphHolder]
		})

	getElement: () -> @frame

	# As SelectorView Controller #
	selectionClicked: (selection) ->
		@displayData selection.data
	# End As SelectorView Controller #
	displayData: (data) ->
		@graphHolder.innerHTML = ''
		@options = 
			data:
				x:data.x
				y:data.y
		@graph = new Aristochart(
			@graphHolder, @options, Aristochart.themes.ticker
		)
		@graph.update()
		@graph.refreshBounds()
	
	updateData: (data) ->
		tickers = ({label:d.data.ticker,data:d} for d in data)
		@selector.refresh(tickers)
			