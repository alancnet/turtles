os.loadAPI('turtles/turtle.lua')

local goodBlocks = {
	"minecraft:iron_ore",
	"minecraft:diamond_ore",
	"minecraft:redstone_ore",
	"minecraft:lit_redstone_ore",
	"minecraft:coal_ore",
}

local directionTable = {
	up = {Turtle.lookUp, function () Turtle.move('up',1,digUp) end , function () Turtle.move('down',1,digDown) end},
	down = {Turtle.lookDown, function () Turtle.move('down',1,digDown) end, function() Turtle.move('up',1,digUp) end},
	forward = {Turtle.lookForward, function ()  Turtle.move('forward',1,dig) end, function() Turtle.move('back',1) end}
}

function digDown()
  turtle.digDown();
end

function dig()
  turtle.dig()
end

function digUp()
	turtle.digUp();
end
local digDirection;
local mineVein;

digDirection = function (dirStr)
	local block = directionTable[dirStr][1]()
	for k,v in pairs(goodBlocks) do
		if (v == block) then
			directionTable[dirStr][2]()
			mineVein()
			directionTable[dirStr][3]()
		end
	end
end
-- assume we touching ore we want to follow
mineVein = function ()
	-- check all direction
	digDirection("up")
	digDirection("down")
	for i=1,4 do
		digDirection("forward")
		turtle.turnRight()
	end
end

function upAndVein()
	digUp()
	mineVein()
end

Turtle.move("up",64,nil,upAndVein)
