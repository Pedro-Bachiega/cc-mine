local functionAPI = require('functionAPI.lua')

function create(text)
	local this = {
		x = 1,
		y = 1,
		width = 0,
		height = 1,
		horizontalPadding = 0,
		verticalPadding = 0,
		text = tostring(text) or "None",
		bgcol = colors.lime,
		alignment = "c",
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
  
	function this.setAlignment(alignment)
		if alignment == "center" then
			this.alignment = "c"
		elseif alignment == "left" then
			this.alignment = "l"
		elseif alignment == "right" then
			this.alignment = "r"
		else 
			error('Incorrect alignment set! ')
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
		if this.callback then this.callback(this) end
	end
  
	function this.drawWrapper(bgcol)
		local computerInfo = computerAPI.findComputer()

		local paddedWidth = this.getWidth()
		local paddedHeight = this.getHeight()

		local monitor = peripheral.wrap(computerInfo.monitorSide)

		if monitor == nil then error("Monitor not set!") end

		local xpos = this.x + (paddedWidth / 2) - (#this.text / 2)
		local t = this.text
		local bg = monitor.getBackgroundColor()
		local tc = monitor.getTextColor()

		if this.alignment == "l" then
			xpos = this.x + (this.horizontalPadding / 2)
		elseif this.alignment == "r" then
			xpos = this.x + paddedWidth - #this.text - (this.horizontalPadding / 2)
		end

		if #this.text > paddedWidth then
			print(string.format('Size %d width %d', #this.text, paddedWidth))
			xpos = this.x
			t = string.sub(t, 1, paddedWidth - 3)..".."..string.sub(t, -1)
		end

		monitor.setTextColor(this.textColor)

		if this.active then
			monitor.setBackgroundColor(bgcol)
		else
			monitor.setBackgroundColor(colors.gray)
		end

		local f = string.rep(" ", paddedWidth)
		for i = 1, paddedHeight do
			monitor.setCursorPos(this.x, this.y + (i - 1))
			monitor.write(f)
		end

		monitor.setCursorPos(xpos, this.y + (paddedHeight / 2))
		monitor.write(t)
		monitor.setBackgroundColor(bg)
		monitor.setTextColor(tc)
	end
  
	function this.draw()
		this.drawWrapper(this.bgcol)
	end

	function this.blink(blinkColor)
		this.drawWrapper(blinkColor)
		sleep(0.2)
		this.draw()
	end

	return this
end

local function isButton(element)
	if functionAPI.isTable(element) and element.text then return true end
	return false
end

local function mergeTables(tab1, tab2)
	for i in pairs(tab2) do tab1[#tab1 + 1] = tab2[i] end
end

function await(...)
	array = {}
	for i in pairs(arg) do
		if i ~= "n" then
			if functionAPI.isTable(arg[i]) and not isButton(arg[i]) then
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
			if button.ret then return button.ret end
			button.fireEvent()
		end
	end
end
