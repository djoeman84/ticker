class GameController
	constructor: () ->
	run: (aux) ->
		console.log aux
		@aux = aux
		@players = aux.playerData.players
		@stocks = @getStocksFromPlayers()
		@buildUI()
		@startGame(aux.playerData.settings.duration, aux.playerData.settings.simulatedDuration)
	buildUI: () ->
		@containerView = new ContainerView(@, _.id('content'))
		@graphView     = new GraphView(@)
		@containerView.addChild @graphView
		@leaderBoardView = new LeaderBoardView(@)
		@containerView.addChild @leaderBoardView
		@tickerView = new TickerView(@)
		document.body.appendChild @tickerView.getElement()
	getStocksFromPlayers: () ->
		stocks = {}
		for p in @players
			for o in p.orders
				d = o.data
				stocks[o.ticker] = {name:d.name,description:d.description,ticker:d.ticker_symbol,ppe:d.ppe,previous_close:d.previous_close,riskRating:d.riskRating} unless o.ticker in stocks
		stocks

	signalEndSimulation: () ->
		clearInterval @interval
		alert 'Simulation Ended! Thanks for playing'
	pushDataToGraphView: () -> # 0 = just started, 1 = game complete
		completion = @getCompletion()
		refreshDuration(@simulatedDuration*completion)
		d = ({data:data,x:@simulatedDuration*completion,y:@marketSim.getHistory(ticker,completion)} for ticker, data of @stocks)
		@graphView.updateData(d)
	pushDataToTickerView: () ->
		completion = @getCompletion()
		d = ({ticker:ticker,move:(@marketSim.getQuote(ticker,completion)-data.previous_close)/data.previous_close} for ticker, data of @stocks)
		@tickerView.updateTicker(d)
	pushDataToLeaderBoardView: () ->
		rowData = []
		completion = @getCompletion()
		for p in @players
			stockWorths = (s.quantity * @marketSim.getQuote(s.ticker,completion) for s in p.orders)
			worth = stockWorths.reduce(((p,c)->p+c),0) + p.cash
			rowData.push [p.name,"$#{worth.toFixed(2)}",p.orders.length]
		tableData =
			headers:['Name','Worth','Quantity Stocks']
			rows:rowData
		@leaderBoardView.update(tableData)
	signalStepSimulation: () ->
		@pushDataToGraphView()
		@pushDataToTickerView()
		@pushDataToLeaderBoardView()
	startGame: (duration, simulatedDuration) ->
		_this = @
		@simulatedDuration = simulatedDuration
		@duration = duration
		@start = new Date()
		setStartTimeForLabelRenderer(simulatedDuration)

		@marketSim = new MarketSimulation(simulatedDuration, @stocks)
		@pushDataToGraphView()
		#interval
		@interval = setInterval (-> _this.signalStepSimulation()), 1*seconds
		#end
		setTimeout (-> _this.signalEndSimulation()), duration
	getCompletion: () ->
		(((new Date()).getTime()) - (@start.getTime())) / @duration