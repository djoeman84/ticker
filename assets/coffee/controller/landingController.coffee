MAX_YEARS = 20

IS_TESTING_GAME = false	
BT = 
	years:(1970)
	months:(0)
	days:(1)
	hours:(0)
	minutes:(0)
	seconds:(0)
	milliseconds:(0)
DUR =
	years:(BT.years + 0)
	months:(BT.months + 0)
	days:(BT.days + 0)
	hours:(BT.hours + 0)
	minutes:(BT.minutes + 1)
	seconds:(BT.seconds + 0)
	milliseconds:(BT.milliseconds + 0)
SIM =
	years:(BT.years + 1)
	months:(BT.months + 0)
	days:(BT.days + 0)
	hours:(BT.hours + 0)
	minutes:(BT.minutes + 0)
	seconds:(BT.seconds + 0)
	milliseconds:(BT.milliseconds + 0)
TEST_DATA = 
	players:[
		{
			cash:(10 * 1000)
			name:"Sam"
			orders:[
				{
					quantity:10
					ticker:"AAPL"
					data:
						description:"Apple Inc."
						label:"Apple"
						name:"Apple"
						ppe:12
						previous_close:560
						quantity:"3"
						riskRating:70
						ticker_symbol:"AAPL"
						value:"AAPL"
					quantity:3
				}
				{
					quantity:2
					ticker:"SPOEK"
					data:
						description:"S"
						label:"Spokeo"
						name:"Spokeo"
						ppe:5
						previous_close:30
						quantity:"2"
						riskRating:40
						ticker_symbol:"SPOEK"
						value:"SPOEK"
				}
			]
		}
	]
	settings:
		duration:         Date.UTC(DUR.years,DUR.months,DUR.days,DUR.hours,DUR.minutes,DUR.seconds,DUR.milliseconds)
		simulatedDuration:Date.UTC(SIM.years,SIM.months,SIM.days,SIM.hours,SIM.minutes,SIM.seconds,SIM.milliseconds)

class LandingConrtoller
	constructor: () ->
	run: () ->
		_this = @
		@runIntro ->
			_this.doPlayerSetup()
	runIntro: (after) ->
		FADE_TIME = 1.2 * seconds #constant
		PAUSETIME = _.normalRandom(FADE_TIME,FADE_TIME*0.8) #constant


		intro = _.element
			id:'intro-logo'
			type:'div'
			parent:document.body
			children:[
				_.element
					type:'div'
					classList:['spinner']
				_.element
					type:'h1'
					innerHTML:'Ticker'
			]
			classList:['hide']
		$(intro).fadeIn(FADE_TIME/2).delay(PAUSETIME).fadeOut(FADE_TIME, after)
	doPlayerSetup: () ->
		(new PlayerSetupUI(@wrapper, @)).run()


class PlayerSetupUI
	constructor: (wrapper, controller) ->
		@wrapper = wrapper
		@controller = controller
		@players = []
	run: () ->
		console.log "IS TESTING:::::::" if IS_TESTING_GAME
		console.log {aux:{playerData:TEST_DATA}}
		@controller.delegate.toController('gameController', {aux:{playerData:TEST_DATA}}) if IS_TESTING_GAME
		return if IS_TESTING_GAME
		@settingsWrapper = @getSettingsWrapper()
		@playersWrapper = @getPlayersWrapper()
		@innerWrapper = _.element(
					type:'div'
					classList:['inner-wrapper']
					parent:@wrapper
					children:[
						@getTitle('Settings')
						@settingsWrapper
						@getTitle('Players')
						@playersWrapper
						@getSubmit()
					]
				)
	getTitle: (text) -> _.element(
				type:'h2'
				innerHTML:text
			)
	getSubmit:() -> 
		submit = _.element(
			type:'div'
			classList:['button', 'transition','center','inline-block']
			innerHTML:'Start'
		)
		_this = @
		submit.addEventListener('click',->_this.playGame())
		submit
	getSettingsWrapper: () ->
		@realDurationInput = new DurationInput('Simulated Duration', 'hms')
		@simulatedDurationInput = new DurationInput('Simulated Duration', 'yMd')
		_.element(
			type:'div'
			id:'settings-wrapper'
			children:[
				@getSubHeader('Length of game for you', 'Duration of Simulation')
				@realDurationInput.getElem()
				@getSubHeader('Length of game for stocks','Simulated Duration')
				@simulatedDurationInput.getElem()
			]
		)
	getSubHeader: (text, hover = '') -> _.element(
			type:'h5'
			innerHTML:text
			attributes:[
				{name:'title',value:hover}
			]
		)
	getPlayersWrapper:() -> 
		_this = @
		handleTyped = (e) -> _this.playerNameTyped(e,@,handleTyped)
		firstPlayer = new PlayerInfoHandler handleTyped, ((e)->_this.playerNameTypedCheckEmpty(e,@))
		@players.push(firstPlayer)
		_.element(
			type:'div'
			id:'player-wrapper'
			children:[firstPlayer.getElem()]
		)
	playerNameTyped: (e,caller,handler) ->
		_this = @
		caller.removeEventListener('keyup', handler)
		handleTyped = (e) -> _this.playerNameTyped(e,@,handleTyped)
		newPlayer = new PlayerInfoHandler handleTyped, ((e)->_this.playerNameTypedCheckEmpty(e,@))
		@players.push(newPlayer)
		@playersWrapper.appendChild(newPlayer.getElem())
	playerNameTypedCheckEmpty: (e) ->
		if e.keyCode of keyToStr and keyToStr[e.keyCode] == 'delete'
			console.log 'delete'
	playGame: () ->
		status = {status:'success',canPlay:true}
		data = @reapAllData(status)
		alert "#{status.status}!" unless status.canPlay
		return unless status.canPlay
		
		shouldPlay = if status.status != 'success' then confirm "#{status.status}, are you sure you'd like to play?" else true

		@controller.delegate.toController('gameController', {aux:{playerData:data}}) if shouldPlay
	reapAllData: (status) ->
		data = {players:[],settings:{}}
		data.settings.duration = @realDurationInput.value(status)
		data.settings.simulatedDuration = @simulatedDurationInput.value(status)
		for p in @players
			data.players.push p.reap(status) 
		data.players = data.players.filter (elem) -> (elem != null and typeof elem.name) == 'string' and elem.name != ''
		status.status = 'You don\'t have any players' if data.players.length == 0 and status.status == 'success'
		status.canPlay = false if data.players.length == 0 and status.canPlay == true
		data

class DurationInput
	constructor: (title,format) ->
		@children = []
		@children.push({type:'years',elem:@rangeElem('years',0,365)}) if (format.search 'y') != -1
		@children.push({type:'months',elem:@rangeElem('months',0,12)}) if (format.search 'M') != -1
		@children.push({type:'days',elem:@rangeElem('days',0,31)}) if (format.search 'd') != -1
		@children.push({type:'hours',elem:@rangeElem('hours',0,23)}) if (format.search 'h') != -1
		@children.push({type:'minutes',elem:@rangeElem('minutes',0,59)}) if (format.search 'm') != -1
		@children.push({type:'seconds',elem:@rangeElem('seconds',0,59)}) if (format.search 's') != -1
		@elem = _.element(
			type:'div'
			classList:['duration-input']
			children:(c.elem for c in @children)
		)
	rangeElem: (placeholder,min,max) ->
		_.element(
			type:'input'
			attributes:[
				{name:'type',value:'number'}
				{name:'placeholder',value:placeholder}
				{name:'min',value:min}
				{name:'max',value:max}
			]
		)
	getElem: () -> @elem
	value: (status) ->
		elements = {years:BT.years,months:BT.months,days:BT.days,hours:BT.hours,minutes:BT.minutes,seconds:BT.seconds,milliseconds:BT.milliseconds}
		before = Date.UTC(elements.years, elements.months, elements.days, elements.hours, elements.minutes, elements.seconds, elements.milliseconds)
		for c in @children
			elements[c.type] += parseInt(c.elem.value) if c and c.elem and c.type and (c.elem.value) and (c.type of elements) and (c.elem.value isnt "")
		after = Date.UTC(elements.years, elements.months, elements.days, elements.hours, elements.minutes, elements.seconds, elements.milliseconds)
		status.status = "Please fill in all of your dates!" if before is after
		status.canPlay = false if before is after
		Date.UTC(elements.years, elements.months, elements.days, elements.hours, elements.minutes, elements.seconds, elements.milliseconds)


class PlayerInfoHandler
	constructor: (onKeyTyped, onDelete) ->
		PLAYER_INITIAL_CASH = 10 * thousand


		_this = @
		@onKeyTyped = onKeyTyped
		@onDelete = onDelete
		@initialCash = PLAYER_INITIAL_CASH
		@cash = @initialCash
		@orders = []
	getElem: () -> _.element(
			type:'div'
			classList:['player-option-wrapper']
			children:[
				@getPlayerNameElem()
				@getOrderWrapper()
			]
		)
	getPlayerNameElem: () -> 
		_this = @
		@available_funds_label = _.element(
			type:'span'
			classList:['cash-available-label']
		)
		@playerName = _.element(
			type:'input'
			attributes:[
				{name:'type',value:'text'}
				{name:'placeholder',value:'Player Name'}
			]
		)
		playerInfo = _.element(
			type:'div'
			children:[
				@playerName
				@available_funds_label
			]
		)
		@updateCashAvailable()
		playerInfo.addEventListener('keyup', _this.onKeyTyped)
		playerInfo.addEventListener('keyup', _this.onDelete)
		playerInfo
	addNewOrderWrapperAfterSearch: () ->
		_this = @
		new_stock_order = new StockOrder(_this,(-> _this.addNewOrderWrapperAfterSearch()))
		_this.orders.push(new_stock_order)
		_this.orderWrapper.appendChild(new_stock_order.getElem())
	getOrderWrapper: () ->
		_this = @
		new_stock_order = new StockOrder(@,(->_this.addNewOrderWrapperAfterSearch()))
		@orders.push(new_stock_order)
		@orderWrapper = _.element(
				type:'div'
				classList:['order-wrapper']
				children:[new_stock_order.getElem()]
			)
	update: () ->
		subtract_cash = 0
		for order in @orders
			subtract_cash += order.getCost()
		@cash = @initialCash - subtract_cash
		@updateCashAvailable()
	getCashAvailable: () -> @cash
	updateCashAvailable: () ->
		@available_funds_label.innerHTML = "$#{(@cash).toFixed(2)}"
		overspent = @cash < 0
		@available_funds_label.classList.add(if overspent then 'over' else 'under')
		@available_funds_label.classList.remove(if overspent then 'under' else 'over')

	reap: (status) ->
		@update()
		name = @playerName.value
		alert "#{name} spent #{Math.abs(@cash)} more than the #{@initialCash} available" if @cash < 0
		orders = ((o.reap() for o in @orders).filter ((elem) -> elem != null))
		if @cash < 0 or orders.length == 0
			if ((name and name != '') and (orders.length == 0))
				status.status = "#{name} does not have any orders"
			else if (((not name) or (name == '')) and orders.length != 0)
				status.status = 'One of your players doesn\'t have a name'
			null
		else
			{
				name:name
				orders:orders
				cash:@cash
			}


class StockOrder
	constructor: (ih,onSearched) ->
		@infoHandler = ih
		@onSearched = onSearched
		
	getElem: () -> 
		_this = @
		@order = _.element(
			type:'input'
			attributes:[
				{name:'type',value:'text'}
				{name:'placeholder',value:'Search for a company'}
			]
		)
		@quantity = _.element(
			type:'input'
			attributes:[
				{name:'type',value:'number'}
				{name:'placeholder',value:'order quantity'}
				{name:'min',value:0}
				{name:'step',value:1}
			]
		)
		handler = -> _this.quantityChange(handler)
		@quantity.addEventListener 'change',handler
		wrp = _.element(
			type:'div'
			children:[@order,@quantity,@updateStatisticsWrapper({})]
		)
		$(@order).autocomplete({
			source:'/stockAutoComplete'
			select:(event, ui) -> _this.autocompleteChange(event, ui)
		})
		wrp
	updateStatisticsWrapper: (data) ->
		cols  = [
			{header:'Name',value:data.name || "-"}
			{header:'Ticker',value:data.ticker_symbol || "-"}
			{header:'Yesterday\'s Close',value:if data.previous_close then "#{data.previous_close} USD" else "-"}
			{header:'Projected Cost',value:if data.quantity and data.previous_close then "#{data.quantity * data.previous_close} USD" else "-"}
			{header:'P/E',value:data.ppe || "-"}
			{header:'Rating',value:(data.riskRating/100) || "-"}
		]
		
		head_cols  = (_.element({type:'td',innerHTML:c.header}) for c in cols)
		value_cols = (_.element({type:'td',innerHTML:c.value}) for c in cols)


		rows = [
			#headers
			_.element(
				type:'tr'
				children:head_cols
			)
			#data
			_.element(
				type:'tr'
				children:value_cols
			)
		]

		if @statisticsWrapper
			@statisticsWrapper.innerHTML = ""
			@statisticsWrapper.title = data.description || "no description available"
			for r in rows
				@statisticsWrapper.appendChild r
			
		else
			@statisticsWrapper = _.element(
				type:'table'
				children:rows
				classList:['summary-table']
			)
		@statisticsWrapper
	autocompleteChange: (event, ui) ->
		@data = ui.item
		@data.quantity = @quantity.value
		@updateStatisticsWrapper(@data)
		if @onSearched
			@onSearched()
			@onSearched = undefined
	quantityChange: () ->
		if @data
			@data.quantity = @quantity.value
			@updateStatisticsWrapper(@data)
		@infoHandler.update()
	getCost: () -> if @data then @quantity.value * @data.previous_close else 0
	reap: () ->
		if (@order and @data and @order.value == @data.ticker_symbol) and (@quantity and @quantity.value and @quantity.value > 0)
			{
				ticker:@order.value
				quantity:Math.floor(@quantity.value)
				data:@data
			}	
		else
			null


	

