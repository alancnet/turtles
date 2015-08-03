os.loadAPI('turtles/functional.lua');
os.loadAPI('turtles/turtle.lua');

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

function plantSapling()
  if (Turtle.selectSlotWith('minecraft:sapling')) then
    turtle.place()
  end
end

function checkFuel()
  while (turtle.getFuelLevel() < 100) do
    Turtle.refuel();
  end
end
Stream.range(1, 3).
forEach(function()
  Turtle.move('forward', 6)
  Stream.range(1, 3)
  .forEach(function(t)
    Turtle.move('turnLeft', 1)
    .move('forward', 6)
    .move('turnRight', 1)
    turtle.suck();
    checkFuel();
    switch(Turtle.lookForward()){
      ['minecraft:log'] = fellTree,
      ['minecraft:sapling'] = void,
      default = plantSapling
    }
  end)
  .forEach(function(t)
    Turtle.move('turnRight', 1)
    .move('forward', 6)
    .move('turnLeft', 1)
  end)
end)
.forEach(function()
  Turtle.move('back', 6)
end)
