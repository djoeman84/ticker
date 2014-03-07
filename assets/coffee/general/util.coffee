Node::prependChild = (elem) ->
	if this.firstChild?
		this.insertBefore(elem, this.firstChild)
	else
		this.appendChild(elem)

Date::format = (str) ->
	msLong  = ['January','February','March','April','May','June','July','August','September','October','November','December']
	msShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
	dyLong  = ['Sunday','Monday','Tuesday','Wednsday','Thursday','Friday','Saturday']
	dyShort = ['Sun','Mon','Tue','Wed','Thr','Fri','Sat']
	yearlong   = new RegExp("%YYYY")
	yearShort  = new RegExp("%YY")
	monthLong  = new RegExp("%MM")
	monthShort = new RegExp("%M")
	date       = new RegExp("%D")
	dayLong    = new RegExp("%dd")
	dayShort   = new RegExp("%d")
	hourShort  = new RegExp("%h")
	str = str.replace(yearlong,  @getFullYear()) if str.match(yearlong)
	str = str.replace(yearShort, (@getFullYear()) % 100) if str.match(yearShort)
	str = str.replace(monthLong, (msLong[@getMonth()])) if str.match(monthLong)
	str = str.replace(monthShort, (msShort[@getMonth()])) if str.match(monthShort)
	str = str.replace(date, @getDate()) if str.match(date)
	str = str.replace(dayLong, dyLong[@getDay()]) if str.match(dayLong)
	str = str.replace(dayShort, dyShort[@getDay()]) if str.match(dayShort)
	str = str.replace(hourShort, "#{((@getHours())%12)+1}#{if @getHour/2 then 'pm' else 'am'}")

seconds = 1000
minutes = seconds * 60
hours   = minutes * 60
days    = hours * 24
weeks   = days * 7
months  = days * 30
years   = days * 365

hundred  = 100
thousand = 1000
million  = thousand * thousand
billion  = thousand * million

keyToStr = 
	37:'left', 39:'right'
	38:'up',   40:'down'
	13:'enter',8:'delete'

strToKey = 
	'left':37, 'right':39
	'up':38,   'down':40
	'enter':13, 'delete':8


Node::setCSS3Attr = (attr, val, isDoublyCSS = false) ->
	css3_kits = ['webkit','Moz','O','ms','']
	for prefix in css3_kits
		this.style[prefix+attr.capitalizeFirst()] = (if isDoublyCSS then "-#{prefix}-#{val}" else val)


String::capitalizeFirst = () ->
	this.charAt(0).toUpperCase() + this.slice(1)

class _
	@id: (elemid) ->
		document.getElementById(elemid)

	@captureArrowKeys: (fn) ->
		window.addEventListener('keyup', (e) -> fn(keyToStr[e.keyCode]) if e.keyCode of keyToStr)

	@className: (name) ->
		document.getElementsByClassName(name)

	@blockingSleep: (ms) ->
		s = new Date()
		while (new Date() - s < ms)
			n = [0..2]

	@element: (options) ->
		new_elem = document.createElement(options.type)
		if 'id' of options
			new_elem.id = options.id
		if 'attributes' of options
			new_elem.setAttribute(at.name,at.value) for at in options.attributes
		if 'classList' of options
			new_elem.classList.add(cl) for cl in options.classList
		if 'children' of options
			new_elem.appendChild(ch) for ch in options.children
		if 'objectAttributes' of options
			new_elem[oa.name] = oa.value for oa in options.objectAttributes
		if 'innerHTML' of options
			new_elem.innerHTML = options.innerHTML
		if 'parent' of options
			if ('prepend' of options) and options.prepend == true
				options.parent.prependChild(new_elem)
			else
				options.parent.appendChild(new_elem)
		new_elem


	@min: (a, b , comp = (a,b) -> a - b) -> if comp(a,b) < 0 then a else b
	@max: (a, b , comp = (a,b) -> a - b) -> if comp(a,b) > 0 then a else b

	@uniformWithProbability: (probability) -> Math.random() < probability
	@randomFromRange: (floor, ceil) -> @scale(Math.random(), floor, ceil)
	@normalRandom: (mean = 0, std = 1) ->
		loop
			x = 2 * Math.random() - 1
			y = 2 * Math.random() - 1
			rad = x * x + y * y
			break unless ((rad >= 1) or (rad is 0))

		c = Math.sqrt(-2 * Math.log(rad)/rad)
		mean+(std*(x * c))

	@normalizeFloat: (num, floor, ceil) -> (num - floor)/(ceil - floor)
	@scale: (num, floor, ceil) -> num * (ceil - floor) + floor











