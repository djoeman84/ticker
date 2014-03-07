class LeaderBoardView
	constructor: (controller) ->
		@controller = controller
		@table = _.element({
			type:'table'
			classList:['tablesorter']
		})
		@thead = _.element({
			type:'thead'
			parent:@table
		})
		@tbody = _.element({
			type:'tbody'
			parent:@table
		})
	getElement: () -> @table
	update: (data) ->
		@thead.innerHTML = ''
		@tbody.innerHTML = ''

		headrow = _.element({
			type:'tr'
			parent:@thead
			children:(_.element({type:'th',innerHTML:h}) for h in data.headers)
		})
		
		for r in data.rows
			_.element({
				type:'tr'
				parent:@tbody
				children:(_.element({type:'td',innerHTML:c}) for c in r)
			})
		$(@table).tablesorter(sortList:[[1,0]]) unless @didInit
		@didInit = true