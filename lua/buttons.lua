local component = require "component"
local event = require "event"
local term = require "term"
local gpu = component.gpu

local w, h = gpu.getResolution()

run = true

endMessage = nil

toolbarRect = {
	x = 1,
	y = h - 1,
	w = w,
	h = 2
}

startRect = {
	x = 1,
	y = h - 1,
	w = 4,
	h = 2
}

menuRect = {
	x = 1,
	y = h - 4,
	w = 10,
	h = 3
}

windowRect = {
	x = w / 2 - w / 4,
	y = h / 2 - h / 4,
	w = w / 2,
	h = h / 2
}

windowToolbarRect = {
	x = math.floor(w / 2 - w / 4),
	y = math.floor(h / 2 - h / 4),
	w = math.floor(w / 2),
	h = 1
}

messageRect = {
	x = 1,
	y = 1,
	w = 30,
	h = 3
}

menu, drawedMenu = false, false
window, drawedWindow = nil, nil
mesage, drawedMessage = nil, nil
messageTimer = 0

local function quit()
	run = false
end

local function fill(rect)
	gpu.fill(rect.x, rect.y, rect.w, rect.h, " ")
end

local function firstDraw()
	gpu.fill(1, 1, w, h, " ")
	
	gpu.setBackground(0x0000AF)
	fill(toolbarRect)
	
	gpu.setBackground(0xFFFFFF)
	fill(startRect)
end

local function updateDraw()
	if menu == true and drawedMenu == false then
		gpu.setBackground(0xAAAAAA)
		fill(menuRect)
		
		gpu.setForeground(0x000000)
		term.setCursor(2, menuRect.y)
		print("Computer")
		print("Settings")
		print("Exit")
		
		drawedMenu = menu
	elseif menu == false and drawedMenu == true then
		gpu.setBackground(0x000000)
		fill(menuRect)
		drawedMenu = menu
	end
	
	if window ~= nil and drawedWindow == nil then
		gpu.setBackground(0xFFFFFF)
		fill(windowRect)
		gpu.setBackground(0xAAAAAA)
		fill(windowToolbarRect)
		
		gpu.setForeground(0x000000)
		gpu.set(windowRect.x + windowRect.w - 1, windowRect.y, "X")
		
		drawedWindow = window
	elseif window == nil and drawedWindow ~= nil then
		gpu.setBackground(0x000000)
		fill(windowRect)
		drawedWindow = window
	end
	
	if drawedMessage == nil and message ~= nil then
		gpu.setBackground(0xFFFFFF)
		fill(messageRect)
		term.setCursor(1, 1)
		gpu.setForeground(0x000000)
		print(message)
		drawedMessage = message
	elseif message == nil and drawedMessage ~= nil then
		gpu.setBackground(0x000000)
		fill(messageRect)
		drawedMessage = message
	end
end

local function collide(rect, e)
	return e[3] >= rect.x and
		e[4] >= rect.y and
		e[3] < rect.x + rect.w and
		e[4] < rect.y + rect.h
end

local function click(e)
	if drawedWindow ~= nil then
		if e[3] == windowToolbarRect.x + windowToolbarRect.w - 1 and e[4] == windowToolbarRect.y then
			window = nil
			return
		end
	end
	
	if drawedMenu then
		if collide(menuRect, e) then
			if e[4] == menuRect.y + 2 then
				quit()
			elseif e[4] == menuRect.y + 1 then
				window = "settings"
			elseif e[4] == menuRect.y then
				
			end
			menu = false
			return
		end
	end
	
	if collide(startRect, e) then
		if menu == true then
			menu = false
		else
			menu = true
		end
		return
	end
end

local function update()
	local e = {event.pull(0.05)}
	if e[1] == "key_down" then
		if e[3] == 113 then
			quit()
		end
	elseif e[1] == "touch" then
		click(e)
	elseif e[1] == "component_added" then
		messageTimer = 10000
		message = e[1]
	else
		messageTimer = 1000
		message = e[1]
	end
	updateDraw()
	if messageTimer > 0 then
		messageTimer = messageTimer - 1
	else
		message = nil
	end
end

firstDraw()

while run do
	update()
end

gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()

if endMessage ~= nil then
	print(endMessage)
end