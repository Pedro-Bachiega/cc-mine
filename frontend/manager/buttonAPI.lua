local computerAPI = require('computerAPI')
local functionAPI = require('functionAPI')
local peripheralAPI = require('peripheralAPI')

-- Where all buttons are born
local buttonAPI = {}

-- Creates a button
function buttonAPI.create(text)
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

	-- Sets button text
	function this.setText(text, resize)
		this.text = tostring(text)
		if resize and this.width < #this.text then
			this.width = #this.text
		end
		return this
	end

	-- Sets button text color
	function this.setTextColor(color)
		this.textColor = color
		return this
	end

	-- Sets button's arguments
	function this.setArgs(args)
		this.args = args
		return this
	end

	-- Sets button text alignment
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

	-- Sets button position on screen
	function this.setPos(x, y)
		this.x = x
		this.y = y
		return this
	end

	-- Sets button size
	function this.setSize(w, h)
		this.width = w
		this.height = h
		return this
	end

	-- Sets button horizontal padding
	function this.setHorizontalPadding(padding)
		this.horizontalPadding = padding
		return this
	end

	-- Sets button vertical padding
	function this.setVerticalPadding(padding)
		this.verticalPadding = padding
		return this
	end

	-- Sets button width
	function this.getWidth()
		return this.width + this.horizontalPadding
	end

	-- Sets button height
	function this.getHeight()
		return this.height + this.verticalPadding
	end

	-- Sets button background color
	function this.setColor(color)
		this.bgcol = color
		return this
	end

	-- Sets button state
	function this.setActive(state)
		this.active = state
		return this
	end

	-- Checks if area clicked was inside the button's x and y
	function this.wasClicked(x, y)
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

	-- Sets button click callback
	function this.onClick(callback)
		this.callback = callback
		return this
	end

	-- Sets button return value on click
	function this.onClickReturn(value)
		this.ret = value
		return this
	end

	-- Calls callback if it exists
	function this.fireEvent()
		if this.callback then this.callback(this) end
	end

	-- Draws button on screen
	function this.draw(bgcol)
		local computer = computerAPI.findComputer()
		if not computer then
			print('Computer not registered')
			return
		end

		local paddedWidth = this.getWidth()
		local paddedHeight = this.getHeight()

		local monitor = peripheralAPI.requirePeripheral('monitor')

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
			t = string.sub(t, 1, paddedWidth - 3) .. ".." .. string.sub(t, -1)
		end

		monitor.setTextColor(this.textColor)

		if this.active then
			monitor.setBackgroundColor(bgcol or this.bgcol)
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

	-- Blinks button with desired color
	function this.blink(blinkColor)
		this.draw(blinkColor)
		sleep(0.2)
		this.draw()
	end

	return this
end

-- Checks if table is a button
local function isButton(element)
	if functionAPI.isTable(element) and element.text then return true end
	return false
end

-- Merges 2 tables
local function mergeTables(tab1, tab2)
	for i in pairs(tab2) do tab1[#tab1 + 1] = tab2[i] end
end

-- Awaits for click and fires callback or returns value if set
function buttonAPI.await(...)
	local array = {}
	for i in pairs(arg) do
		if i ~= "n" then
			if functionAPI.isTable(arg[i]) and not isButton(arg[i]) then
				mergeTables(array, arg[i])
			else
				array[#array + 1] = arg[i]
			end
		end
	end

	for i in pairs(array) do array[i].draw() end

	---@diagnostic disable-next-line: undefined-field
	local _, _, x, y = os.pullEvent("monitor_touch")

	for i in pairs(array) do
		local button = array[i]
		if button.wasClicked(x, y) then
			if button.ret then return button.ret end
			button.fireEvent()
		end
	end
end

return buttonAPI
