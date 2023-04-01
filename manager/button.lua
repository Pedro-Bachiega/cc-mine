os.loadAPI('constants.lua')

local _locales = {
	mon = peripheral.wrap(constants.MONITOR_SIDE)
}

function create(text)
	local this = {
		x = 1,
		y = 1,
		width = 0,
		height = 1,
		horizontalPadding = 2,
		verticalPadding = 2,
		text = tostring(text) or "None",
		bgcol = colors.lime,
		blinkCol = colors.red,
		align = "c",
		active = true,
		callback = nil,
		ret = nil,
		textColor = colors.black,
		args = nil
	}
  
	if text then this.width = #tostring(text) end
  
	function this.setText(text, resize)
		this.text = tostring(text)
		if resize and this.width < #this.text then
			this.width = #this.text
		end
		return this
	end
  
	function this.setTextColor(color)
		this.textColor = color
		return this
	end

	function this.setArgs(args)
		this.args = args
		return this
	end
  
	function this.setAlign(align)
		if align == "center" then
			this.align = "c"
		elseif align == "left" then
			this.align = "l"
		elseif align == "right" then
			this.align = "r"
		else 
			error('Incorrect slign set! ')
		end
		return this
	end
  
	function this.setPos(x, y)
		this.x = x
		this.y = y
		return this
	end
  
	function this.setSize(w, h)
		this.width = w
		this.height = h
		return this
	end
  
	function this.setHorizontalPadding(padding)
		this.horizontalPadding = padding
		return this
	end
  
	function this.setVerticalPadding(padding)
		this.verticalPadding = padding
		return this
	end

	function this.getWidth()
		return this.width + this.horizontalPadding
	end

	function this.getHeight()
		return this.height + this.verticalPadding
	end
  
	function this.setColor(color)
		this.bgcol = color
		return this
	end
  
	function this.setBlinkColor(color)
		this.blinkCol = color
		return this
	end
  
	function this.setActive(state)
		this.active = state
		return this
	end
  
	function this.wasClicked(x,y)
		if 
			x >= this.x and
			x < this.x + this.getWidth() and
			y >= this.y and
			y < this.y + this.getHeight() and
			this.active
		then
			return true
		end
		return false
	end
  
	function this.onClick(callback)
		this.callback = callback
		return this
	end
  
	function this.onClickReturn(value)
		this.ret = value
		return this
	end
  
	function this.fireEvent()
		if this.callback then this.callback() end
	end
  
	function this.drawWrapper(bgcol)
		local paddedWidth = this.getWidth()
		local paddedHeight = this.getHeight()

		if _locales.mon == nil then error("Monitor not set!") end

		local xpos = this.x + (paddedWidth / 2) - (#this.text / 2)
		local t = this.text
		local bg = _locales.mon.getBackgroundColor()
		local tc = _locales.mon.getTextColor()

		if this.align == "l" then
			xpos = this.x
		end
		if this.align == "r" then
			xpos = this.x + paddedWidth - #this.text
		end

		if #this.text > paddedWidth then
			xpos = this.x
			t = string.sub(t, 1, paddedWidth - 3)..".."..string.sub(t, -1)
		end

		_locales.mon.setTextColor(this.textColor)

		if this.active then
			_locales.mon.setBackgroundColor(bgcol)
		else
			_locales.mon.setBackgroundColor(colors.gray)
		end

		local f = string.rep(" ", paddedWidth)
		for i = 1, paddedHeight do
			_locales.mon.setCursorPos(this.x, this.y + (i - 1))
			_locales.mon.write(f)
		end

		_locales.mon.setCursorPos(xpos, this.y + (paddedHeight / 2))
		_locales.mon.write(t)
		_locales.mon.setBackgroundColor(bg)
		_locales.mon.setTextColor(tc)
	end
  
	function this.draw()
		for line = this.y, this.getHeight() do
			_locales.mon.setCursorPos(this.x, line)
			_locales.mon.clearLine()
		end

		this.drawWrapper(this.bgcol)
	end

	function this.blink()
		this.drawWrapper(this.blinkCol)
		sleep(0.2)
		this.draw()
	end

	return this
end

local function isTable(element)
	return type(element) == "table"
end

local function isButton(element)
	if isTable(element) and element.text then return true end
	return false
end

local function mergeTables(tab1, tab2)
	for i in pairs(tab2) do tab1[#tab1 + 1] = tab2[i] end
end

function await(...)
	array = {}
	for i in pairs(arg) do
		if i ~= "n" then
			if isTable(arg[i]) and not isButton(arg[i]) then
				mergeTables(array, arg[i])
			else
				array[#array+1] = arg[i]
			end
		end
	end

	for i in pairs(array) do array[i].draw() end

	e, s, x, y = os.pullEvent("monitor_touch")

	for i in pairs(array) do
		local button = array[i]
		if button.wasClicked(x, y) then
			button.blink()
			if button.ret then return button.ret end
			button.fireEvent()
		end
	end
end
