os.loadAPI('turtles/turtle.lua')

local X = 32
local Y = 32;

function checkFuel()
  while (turtle.getFuelLevel() < 30) do
    Turtle.refuel();
  end
end


function placeSlab()
  checkFuel()
  Turtle.selectSlotWith('minecraft:wooden_slab');
  turtle.placeDown();
end

checkFuel()
Stream.range(1, X / 2)
.forEach(function (r)
  Turtle
    .move('forward', Y, nil, placeSlab)
    .move('turnLeft', 1)
    .move('forward', 1, nil, placeSlab)
    .move('turnLeft', 1)
    .move('forward', Y, nil, placeSlab)
    .move('turnRight', 1)
    .move('forward', 1, nil, placeSlab)
    .move('turnRight', 1)
end)
