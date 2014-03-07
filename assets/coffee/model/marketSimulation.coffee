class MarketSimulation
	AVG_INFLATION = 0.022
	AVG_RISK      = 0.004
	STD_RISK      = 0.001
	DATA_POINTS   = 4000
	AVG_PPE       = 20
	PROBABILITY_OF_REVERSAL = 0.01
	INFLATION_WEIGHT = 0.3
	constructor: (simulatedDuration, stocks, period) ->
		@simulatedDuration = simulatedDuration
		@period = if period then period else @getPeriod()
		@stocks = stocks
		@market = @simulateMarket()
		@simulateStock(data) for ticker,data of @stocks
	simulateMarket: () ->
		market = []
		risk = _.normalRandom(AVG_RISK,STD_RISK)
		last = _.normalRandom(AVG_INFLATION,risk)
		bias = 0
		period_weight = (@period) / (1*weeks)
		# console.log "period_weight: #{period_weight}"
		for i in [0...DATA_POINTS]
			avg = ((last + bias)*(1-INFLATION_WEIGHT) + INFLATION_WEIGHT*AVG_INFLATION)
			last = _.normalRandom(avg,risk)
			bias -= _.normalRandom(bias*(1-period_weight)*.05,STD_RISK)
			bias *= -1 if _.uniformWithProbability(PROBABILITY_OF_REVERSAL * period_weight)
			risk = Math.abs(risk + _.normalRandom(0,STD_RISK))
			market.push last
		# console.log "market avg: #{market.reduce(((p,v,i,a) -> p + (v/a.length)), 0)}"
		market
		
	simulateStock: (s) ->
		#ppe and riskRating
		startValue = s.previous_close
		history = []
		last = startValue
		rate = (20/s.ppe) * AVG_INFLATION
		earnings = s.previous_close/s.ppe
		market_weight = s.riskRating/100 * 0.1
		time = @period/years
		for i in [0...DATA_POINTS]
			r = ((1-market_weight)*rate + market_weight * @market[i])
			rate = _.normalRandom(r,(s.riskRating/500))
			last = last * Math.pow(Math.E, time * rate)
			history.push Math.abs(last) # can never be negative
		s.history = history
	getHistory: (ticker, complete = 1) ->
		complete = Math.min(complete,1)
		hist = @stocks[ticker].history.slice(0)
		hist = hist.filter((v,i,a) -> i%2) if complete > 0.25 #remove if too computationally intense
		hist = hist.filter((v,i,a) -> i%2) if complete > 0.5 #remove if too computationally intense
		sub = hist.splice(0,Math.ceil((hist.length - 1) * complete)) if ticker of @stocks
		sub
		# @market
	getQuote: (ticker, complete = 1) ->
		complete = Math.min(complete,1)
		return unless @stocks[ticker]
		hist = @stocks[ticker].history
		index = Math.ceil((hist.length - 1) * complete)
		hist[index] if (ticker of @stocks) and (index < hist.length)
	getSimulatedDuration: () -> @simulatedDuration
	getPeriod: () -> (@simulatedDuration) / DATA_POINTS
	getDataPoints: () -> DATA_POINTS