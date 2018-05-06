local component = require "component"
local event = require "event"
local term = require "term"
local computer = require "computer"
local gpu = component.gpu

local qKey = 113
local wKey = 119
local sKey = 115
local aKey = 97
local dKey = 100
local enterKey = 32

--[[while true do
	e = {event.pull()}
	if e[1] == "key_down" then
		print(e[3])
	end
end]]

local w, h = gpu.getResolution()

local direction = 0
local rotY = 0

local fov = math.pi / 1

run = true

local function quit()
	run = false
end

camPos = {0, 0, 0}
camAuto = false

local function toCamPos(pos)
	rPos = {pos[1] - camPos[1], pos[2] - camPos[2], pos[3] - camPos[3]}
	
	rx = rPos[1]
	ry = rPos[2]
	rz = rPos[3]
	
	rPos[1] = rx * math.cos(-direction) - ry * math.sin(-direction)
	rPos[2] = rx * math.sin(-direction) + ry * math.cos(-direction)
	
	rx = rPos[1]
	rz = rPos[3]
	
	rPos[1] = rx * math.cos(-rotY) + rz * math.sin(-rotY)
	rPos[3] = rz * math.cos(-rotY) + rx * math.sin(-rotY)
	
	return rPos
end

local function toScreenPos(pos)
	ah = math.atan2(pos[2], pos[1])
	av = math.atan2(pos[3], pos[1])
	
	ah = ah / math.abs(math.cos(ah))
	av = av / math.abs(math.cos(av))
	
	return {w / 2 - ah * w / fov, h / 2 - av * w / fov, 0}
	
	--return {w / 2 - pos[1], h / 2 - pos[2], 0}
end

local function point(x, y)
	gpu.set(math.floor(x), math.floor(y), " ")
end

drawTime = computer.uptime()

local function draw()

	drawTime = computer.uptime()
	
	poss = {}
	
	poss[#poss + 1] = {-5 + 30, -5, -5}
	poss[#poss + 1] = {5 + 30, -5, -5}
	poss[#poss + 1] = {-5 + 30, -5, 5}
	poss[#poss + 1] = {5 + 30, -5, 5}
	poss[#poss + 1] = {-5 + 30, 5, -5}
	poss[#poss + 1] = {5 + 30, 5, -5}
	poss[#poss + 1] = {-5 + 30, 5, 5}
	poss[#poss + 1] = {5 + 30, 5, 5}
	
	poss[#poss + 1] = {-5 - 30, -5, -5}
	poss[#poss + 1] = {5 - 30, -5, -5}
	poss[#poss + 1] = {-5 - 30, -5, 5}
	poss[#poss + 1] = {5 - 30, -5, 5}
	poss[#poss + 1] = {-5 - 30, 5, -5}
	poss[#poss + 1] = {5 - 30, 5, -5}
	poss[#poss + 1] = {-5 - 30, 5, 5}
	poss[#poss + 1] = {5 - 30, 5, 5}
	
	poss[#poss + 1] = {-5, -5 - 30, -5}
	poss[#poss + 1] = {5, -5 - 30, -5}
	poss[#poss + 1] = {-5, -5 - 30, 5}
	poss[#poss + 1] = {5, -5 - 30, 5}
	poss[#poss + 1] = {-5, 5 - 30, -5}
	poss[#poss + 1] = {5, 5 - 30, -5}
	poss[#poss + 1] = {-5, 5 - 30, 5}
	poss[#poss + 1] = {5, 5 - 30, 5}
	
	poss[#poss + 1] = {-5, -5 + 30, -5}
	poss[#poss + 1] = {5, -5 + 30, -5}
	poss[#poss + 1] = {-5, -5 + 30, 5}
	poss[#poss + 1] = {5, -5 + 30, 5}
	poss[#poss + 1] = {-5, 5 + 30, -5}
	poss[#poss + 1] = {5, 5 + 30, -5}
	poss[#poss + 1] = {-5, 5 + 30, 5}
	poss[#poss + 1] = {5, 5 + 30, 5}
	
	gpu.setBackground(0x000000)
	gpu.fill(1, 1, w, h, " ")
	
	gpu.setBackground(0xFF0000)
	for i = 1, #poss do
		p = toScreenPos(toCamPos(poss[i]))
		point(p[1], p[2])
	end
	
	term.setCursor(1, 1)
	print(computer.uptime() - drawTime)
	drawTime = computer.uptime()
end

gpu.setForeground(0x000000)
draw()

while run do
	local e = {event.pull(0.05)}
	if e[1] == "key_down" then
		if e[3] == qKey then
			quit()
		end
		
		if e[3] == enterKey then
			camAuto = true
		end
		
		if not camAuto then
			if e[3] == wKey then
				d = direction + math.rad(270)
				camPos[1] = camPos[1] + math.sin(-d) * 0.5
				camPos[2] = camPos[2] + math.cos(-d) * 0.5
			elseif e[3] == sKey then
				d = direction + math.rad(270)
				camPos[1] = camPos[1] - math.sin(-d) * 0.5
				camPos[2] = camPos[2] - math.cos(-d) * 0.5
			elseif e[3] == aKey then
				direction = direction + math.rad(1)
			elseif e[3] == dKey then
				direction = direction - math.rad(1)
			end
		end
		draw()
	end
	if camAuto then
		direction = direction + math.rad(1)
		draw()
	end
end

gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()