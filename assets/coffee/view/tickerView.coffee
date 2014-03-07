class TickerView
	constructor: (controller) ->
		@controller = controller
		@container = _.element({
			type:'ticker'
		})
		@tape = _.element({
			type:'tape'
			parent:@container
		})
		@tape.l = 0
		@tape.style.left = "#{@tape.l}px"
		@quotes = {}
		@fps = seconds / 30
		@animate()
	getElement: () -> @container
	move: () ->
		@tape.l = if (@tape.l > -(@tape.clientWidth)) then @tape.l - 4 else document.body.clientWidth
		@tape.style.left = "#{@tape.l}px"
	animate: () ->
		_this = @
		setInterval (->_this.move()), @fps
	refreshChange: () ->
		for t, q of @quotes
			if q.move > 0
				q.elem.classList.add('up')
				q.elem.classList.remove('down')
			else
				q.elem.classList.add('down')
				q.elem.classList.remove('up')
		
	updateTicker: (data) ->
		for d in data
			if d.ticker of @quotes
				@quotes[d.ticker].move = d.move
			else
				new_quote_elem = _.element({
					type:'quote'
					parent:@tape
				})
				nameElem = _.element({type:'name',innerHTML:d.ticker,parent:new_quote_elem})
				changeElem = _.element({type:'change',parent:new_quote_elem})
				@quotes[d.ticker] = {move:d.move,elem:new_quote_elem,nameElem:nameElem,changeElem:changeElem}
			@quotes[d.ticker].changeElem.innerHTML = (d.move*100).toFixed(2)
		@refreshChange()
