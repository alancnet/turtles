local NUMBER_OF_COLUMNS = 2;
local NUMBER_OF_ROWS = 2;
local NUMBER_OF_STACKS = 2;

os.loadAPI('turtles/functional.lua')
os.loadAPI('turtles/turtle.lua')

function clearLeaves(dir)
  local up = Turtle.lookUp()
  local down = Turtle.lookDown()
  if (up == 'minecraft:leaves') then turtle.digUp();
  elseif (down == 'minecraft:leaves') then turtle.digDown();
  end -- else print("Blocked"); end
end

function plantSapling()
  if (Turtle.selectSlotWith('minecraft:sapling')) then
    turtle.place()
  end
  return 0;
end

function checkFuel()
  while (turtle.getFuelLevel() < 300) do
    Turtle.refuel();
  end
end


function fellTree2(log)
  function climbFell(height)
    if Turtle.lookUp() == log then
      turtle.digUp();
      turtle.suck();
      turtle.up();
      prune();
      return climbFell(height + 1);
    else
      return height;
    end
  end
  local ret;
  if (Turtle.lookForward() == log) then
    turtle.dig();
    Turtle.move('forward', 1);
    ret = climbFell(0);
    Turtle.move('back', 1);
  else
    ret = 0;
  end
  return ret;
end

function fellTree(log)
  print('Chopping tree');
  turtle.dig()
  turtle.suck()
  turtle.forward()
  local i=0
  while (Turtle.lookUp() == log) do
    turtle.digUp()
    turtle.up()
    i=i+1
  end
  while (i>0) do
    turtle.down()
    i=i-1
  end
  turtle.suck()
  turtle.back()
  plantSapling()
  print('Done!');
end

function prune()
  local loop; loop = function(r)
    if Turtle.lookForward()=='minecraft:leaves' then
      Turtle.move('forward', 1, function() turtle.dig() end);
      Turtle.circle(r + 1, function() print('Block') turtle.dig() turtle.suck() end, function() print('Each') turtle.digUp() turtle.suckUp() end)
      return loop(r + 1);
    else
      return r;
    end
  end
  Turtle.move('back', loop(0));
end

function doStack()
  local y = Stream.range(1, NUMBER_OF_STACKS);
  local ny = y.foldLeft(nil)(function(skip)
    checkFuel()
    if notNil(skip) then
      Turtle.move('up', 7 - skip, clearLeaves);
    end
    if not (Turtle.lookForward() == 'minecraft:dirt') then
      if Turtle.selectSlotWith('minecraft:dirt') then
        turtle.place();
        if (Turtle.selectSlotWith('minecraft:torch')) then
          turtle.turnLeft();
          Turtle.move('forward', 1);
          turtle.turnRight();
          turtle.place();
          turtle.turnRight();
          Turtle.move('forward', 1);
          turtle.turnLeft();
        end
      end
    end
    Turtle.move('up', 1, clearLeaves);
    return switch(Turtle.lookForward()){
      ['minecraft:log'] = fellTree2,
      ['minecraft:sapling'] =  function() return 0 end,
      default = function() return 0 end
    }
  end)
  Turtle.move('down', ny, clearLeaves);
  plantSapling();
  y.drop(1).forEach(function()
    checkFuel();
    Turtle.move('down', 8, clearLeaves);
    plantSapling();
  end)
  Turtle.move('down', 1, clearLeaves);
  plantSapling();
end

function doRow()
  Stream.range(1, NUMBER_OF_ROWS).forEach(function(r)
    checkFuel();
    if (r > 1) then
      turtle.turnLeft();
      Turtle.move('forward', 7);
      turtle.turnRight();
    end
    doStack();
  end).forEach(function(r)
    if (r > 1) then
      turtle.turnRight();
      Turtle.move('forward', 7);
      turtle.turnLeft();
    end
  end)
end

function doCol()
  local cols = Stream.range(1, NUMBER_OF_COLUMNS)
  cols.forEach(function(c)
    checkFuel();
    if (c > 1) then
      turtle.turnRight();
      Turtle.move('forward', 1);
      turtle.turnLeft();
      Turtle.move('forward', 7);
      turtle.turnLeft();
      Turtle.move('forward', 1);
      turtle.turnRight();
    end
    doRow();
  end)
  turtle.turnRight();
  Turtle.move('forward', 1);
  turtle.turnLeft();
  cols.forEach(function(c)
    if (c > 1) then
      Turtle.move('back', 7)
    end
  end)
  turtle.turnLeft();
  Turtle.move('forward', 1);
  turtle.turnRight();

end
function harvest()
  Turtle.move('up', 7)
  doCol();
  Turtle.move('down', 7)
end

function main()
  while (true) do
    checkFuel();
    Turtle.deposit('minecraft:log', -64);
    Turtle.deposit('minecraft:sapling', -64);
    harvest();
  end
end

main();
