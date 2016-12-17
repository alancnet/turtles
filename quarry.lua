os.loadAPI('turtles/turtle.lua')

function doFuel()
  Turtle.checkFuel(300);
end

function digDown()
  turtle.digDown();
end

function dig()
  turtle.dig()
end

function shaft()
  -- Level 0
  turtle.turnLeft();
  turtle.turnLeft();
  Turtle.move('down', 1, digDown);

  -- Level -1
  turtle.dig();
  turtle.turnRight();
  turtle.dig();
  if Turtle.selectSlotWith('minecraft:ladder') then
    turtle.place()
  end
  turtle.turnLeft();
  turtle.turnLeft();
  turtle.dig();
  if Turtle.selectSlotWith('minecraft:torch') then
    turtle.place()
  end
  turtle.turnRight();
  Turtle.move('down', 1, digDown);

  -- Level -2
  turtle.dig();
  turtle.turnRight();
  turtle.dig();
  if Turtle.selectSlotWith('minecraft:ladder') then
    turtle.place()
  end
  turtle.turnLeft();
  turtle.turnLeft();
  turtle.dig();
  turtle.turnRight();
  Turtle.move('down', 1, digDown);

  -- Level -3
  if not (Turtle.lookForward() == 'minecraft:chest') then
    turtle.dig();
  end
  turtle.turnRight();
  turtle.dig();
  if Turtle.selectSlotWith('minecraft:ladder') then
    turtle.place()
  end
  turtle.turnLeft();
  turtle.turnLeft();
  turtle.dig();
  turtle.turnRight();
  if Turtle.selectSlotWith('minecraft:chest') then
    turtle.place()
  end

  turtle.turnLeft();
  turtle.turnLeft();

end

function depositAllTheThings()
  turtle.turnRight();
  turtle.turnRight();

  Turtle.inventory().forEach(function(slot)
    switch (slot.item.name) {
      ['minecraft:planks'] = function() end,
      ['minecraft:chest'] = function() end,
      ['minecraft:ladder'] = function() end,
      ['minecraft:torch'] = function() end,
      default = function()
        turtle.select(slot.index)
        turtle.drop()
      end
    }
  end)

  turtle.turnRight();
  turtle.turnRight();

end

function goDepositThings()
  if Turtle.inventory().count() > 8 then

    local loop; loop = function()
      if (Turtle.lookForward() == 'minecraft:chest') then
        turtle.turnRight();
        turtle.turnRight();
        depositAllTheThings()
        turtle.turnRight();
        turtle.turnRight();
      else
        Turtle.move('forward', 1);
        loop();
        Turtle.move('back', 1);
      end
    end

    loop();

  end
end

function digBigHole(r)
  doFuel();
  shaft();
  Turtle.move('forward', 1, dig)
  Turtle.digHole(r, doFuel, nil, goDepositThings);
  Turtle.move('back', 1);
  depositAllTheThings()

end
Stream.range(1, 3).forEach(function()
  digBigHole(16)

end)
