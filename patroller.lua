function logLoad(file)
  return "Loading: " .. file .. " : " .. tostring(os.loadAPI(file))
end

-- print(logLoad("turtles/functional.lua"))
-- print(logLoad("turtles/turtle.lua"))

function undoIf(fun, check, undo)
  if not check(fun()) then
    undo()
    return false
  else
    return true
  end
end

function frontIsClear()
        local s,v = turtle.inspect()
        return s == false
end
function frontIsName(name)
	local s,v = turtle.inspect()
	return s == true and v.name == name
end
function isOnBlockName(name) 
	local r, v = turtle.inspectDown()
        if (r and v.name == name) then
		return true
	else
		return false
	end
end
function isNotOnBlock(name)
        return not isOnBlock(name)
end
function isOnAnyBlock()
	local r, v = turtle.inspectDown()
	return r
end
function isNotOnBlock()
        local r, v = turtle.inspectDown()
        return not r
end

function forwardOnName(name)
        return undoIf(turtle.forward,
                        function() return isOnBlockName(name) end,
                        turtle.back)
end

function downOnBlock()
	return undoIf(turtle.down, isOnAnyBlock, turtle.up)
end

function downOnName(name)
        return undoIf(turtle.down,
                        function() return isOnBlockName(name) end,
                        turtle.up)
end



function forwardDownOnName(name)
  return undoIf(
           function()
             turtle.forward()
             if isNotOnBlock() then
                downOnName(name)
             end
           end
              ,function()
                return isOnBlockName(name) 
               end
              ,turtle.back)
end

function forwardUpDownOnName(name)
	if frontIsName(name) then
		turtle.up()
		if not forwardDownOnName(name) then
			turtle.down()
			return false
		else
			return true
		end
	else
		return forwardDownOnName(name)
	end
			
end



  while (true) do
  	while (turtle.attack()) do end
  	while (turtle.attackUp()) do end

  	if not forwardUpDownOnName("minecraft:redstone_block") then
	  turtle.turnRight()
  	end
  end

