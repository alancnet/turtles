recording = nil

local function wrap()
  return function() return 5; end
end

local function switchDir(forward, up, down, back, left, right)
  return function(dir, ...)
    return switch(dir){
      forward = function() return forward(unpack(arg)) end,
      up = function() return up(unpack(arg)) end,
      down = function() return down(unpack(arg)) end,
      back = function()
        if back then return back(unpack(arg)) end
        turnAround();
        local ret = forward(unpack(arg))
        turnAround();
        return ret;
      end,
      left = function()
        if left then return left(unpack(arg)) end
        turnLeft();
        local ret = forward(unpack(arg))
        turnRight();
        return ret;
      end,
      right = function()
        if right then return right(unpack(arg)) end
        turnRight();
        local ret = forward(unpack(arg))
        turnLeft();
        return ret;
      end,
      default = function()
        print("Unknown direction", dir);
      end
    }
  end
end

function turnRight()
  turtle.turnRight()
  if (recording) then recording.push({
    dd = 1, dx = 0, dy = 0, dz = 0, r = turnLeft
  }) end
end
function turnLeft()
  turtle.turnLeft()
  if (recording) then recording.push({
    dd = -1, dx = 0, dy = 0, dz = 0, r = turnRight
  }) end
end
function turnAround() turnRight() turnRight() end
function turnBack() turnAround() end
turnDir = switchDir(void, void, void, turnBack, turnLeft, turnRight)

function detect() return turtle.detect() end
function detectUp() return turtle.detectUp() end
function detectDown() return turtle.detectDown() end
detectDir = switchDir(detect, detectUp, detectDown)

function look()
  local success, item = turtle.inspect();
  if (success) then return item.name end
end
function lookUp()
  local success, item = turtle.inspectUp();
  if (success) then return item.name end
end
function lookDown()
  local success, item = turtle.inspectDown();
  if (success) then return item.name end
end
lookDir = switchDir(look, lookUp, lookDown);

function suck()
  return turtle.suck();
end
function suckUp()
  return turtle.suckUp();
end
function suckDown()
  return turtle.suckDown();
end
suckDir = switchDir(suck, suckUp, suckDown);

function drop()
  return turtle.drop();
end
function dropUp()
  return turtle.dropUp();
end
function dropDown()
  return turtle.dropDown();
end
dropDir = switchDir(drop, dropUp, dropDown);

function dig()
  if look() then return turtle.dig() end
end
function digUp()
  if lookUp() then return turtle.digUp() end
end
function digDown()
  if lookDown() then return turtle.digDown() end
end
digDir = switchDir(dig, digUp, digDown)

function record()
  local rotate = function(loc, d)
    if d == 0 then -- North(ish)
      -- Nothing
    elseif d == 1 then -- East(ish)
      loc.dx = -loc.dz;
      loc.dz = 0;
    elseif d == 2 then -- South(ish)
      loc.dz = -loc.dz;
    elseif d == 3 then -- West(ish)
      loc.dx = loc.dz;
      loc.dz = 0
    end
    return loc;
  end
  local rec
  rec = {
    moves = Array.new({ dd = 0, dx = 0, dy = 0, dz = 0, d = 0, x = 0, y = 0, z = 0, r = void }),
    push = function(move)
      local last = rec.moves.peek()
      rotate(move, last.d)
      move.x = last.x + move.dx;
      move.y = last.y + move.dy;
      move.z = last.z + move.dz;
      move.d = (last.d + move.dd) % 4;
      rec.moves.push(move);
    end,
    backtrace = function(optimize)
      local moves = rec.moves;
      if (optimize) then
        local i = 1
        while i < moves.length do
          local c = moves[i];
          local dup, dupi = moves.findLast(function(o)
            return c.d == o.d and c.x == o.x and c.y == o.y and c.z == o.z
          end)
          if dup then
            moves.splice(i + 1, dupi + 1)
          end
          i = i + 1
        end
      end
      moves.reverse().forEach(function(move)
        move.r()
      end);
    end
  }
  recording = rec;
  return rec;
end

function move(count)
  if (count < 0) then return -moveBack(-count) end
  if (count == 0) then return 0 end
  if turtle.forward() then
    if (recording) then recording.push({
      dd = 0, dx = 0, dy = 0, dz = -1, r = function() moveBack(1) end
    }) end
    return 1 + move(count - 1)
  else
    return 0
  end
end
function moveUp(count)
  if (count < 0) then return -moveDown(-count) end
  if (count == 0) then return 0 end
  if turtle.up() then
    if (recording) then recording.push({
      dd = 0, dx = 0, dy = 1, dz = 0, r = function() moveDown(1) end
    }) end
    return 1 + moveUp(count - 1)
  else
    return 0
  end
end
function moveDown(count)
  if (count < 0) then return -moveUp(-count) end
  if (count == 0) then return 0 end
  if turtle.down() then
    if (recording) then recording.push({
      dd = 0, dx = 0, dy = -1, dz = 0, r = function() moveUp(1) end
    }) end
    return 1 + moveDown(count - 1)
  else
    return 0
  end
end
function moveBack(count)
  if (count < 0) then return -move(-count) end
  if (count == 0) then return 0 end
  if turtle.back() then
    if (recording) then recording.push({
      dd = 0, dx = 0, dy = 0, dz = 1, r = function() move(1) end
    }) end
    return 1 + moveBack(count - 1)
  else
    return 0
  end
end
function moveRight(count)
  if (count < 0) then return -moveLeft(-count) end
  turnRight()
  local ret = move(count)
  turnLeft()
  return ret;
end
function moveLeft(count)
  if (count < 0) then return -moveRight(-count) end
  turnLeft()
  local ret = move(count)
  turnRight()
  return ret;
end
moveForward = move;
moveDir = switchDir(move, moveUp, moveDown)

function mine(count)
  if (count > 0) then
    dig();
    move(1);
    mine(count - 1);
  end
end

function mineUp(count)
  if (count > 0) then
    digUp();
    moveUp(1);
    mineUp(count - 1);
  end
end

function mineDown(count)
  if (count > 0) then
    digDown();
    moveDown(1);
    mineDown(count - 1);
  end
end
mineDir = switchDir(mine, mineUp, mineDown)


function inventory()
  return Stream.range(1,16)
  .map(function(index)
    return {
      index = index,
      item = turtle.getItemDetail(index)
    }
  end)
  .filter(function(slot) return notNil(slot.item) end)

end
function findSlot(name)
  return inventory()
  .filter(function(slot) return equals(slot.item.name)(name) end)
  .take(1)
  .head;
end

function selectSlotWith(name)
  local slot = findSlot(name);
  if notNil(slot) then
    return turtle.select(slot.index);
  else
    return false;
  end
end

function refuel(number)
  if number ~= nil then
  	if number == "all" then
  		nLimit = 64 * 16
  	else
  		nLimit =  number
  	end
  end

  if turtle.getFuelLevel() ~= "unlimited" then
  	for n=1,16 do
  		local nCount = turtle.getItemCount(n)
  		if nLimit > 0 and nCount > 0 and turtle.getFuelLevel() < turtle.getFuelLimit() then
  		    local nBurn = math.min( nLimit, nCount )
  			turtle.select( n )
  			if turtle.refuel( nBurn ) then
  			    local nNewCount = turtle.getItemCount(n)
      			nLimit = nLimit - (nCount - nNewCount)
      		end
  		end
  	end
      print( "Fuel level is "..turtle.getFuelLevel() )
      if turtle.getFuelLevel() == turtle.getFuelLimit() then
          print( "Fuel limit reached" )
      end
  else
      print( "Fuel level is unlimited" )
  end
end
