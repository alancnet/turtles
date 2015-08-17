os.loadAPI('turtles/functional.lua');
_G.Turtle = (function()
  function checkFuel(level)
    while (turtle.getFuelLevel() < level) do
      Turtle.refuel();
    end
  end

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

  function refuelFrom(index, amount)
    if (amount == nil) then amount = 1; end
    turtle.select(index)
    local details = turtle.getItemDetail();
    if notNil(details) then
      if not (details.name == "minecraft:sapling") then
        return turtle.refuel(1)
      end
    end
  end
  function refuel(amount)
    if (amount == nil) then amount = 1; end
    return notNil(
      Stream.range(1, 16)
      .map(refuelFrom)
      .filter(equals(true))
      .take(1)
      .head
    );
  end
  function deposit(item, count)
    print('deposit ' .. item .. ' of ' .. tostring(count))
    if count < 0 then
      deposit(
        item,
        inventory()
          .filter(function(slot)
            return equals(item)(slot.item.name);
          end)
          .map(function(slot)
            return slot.item.count;
          end)
          .foldLeft(0)(sum)
          + count
      )
    else
      if (count > 0) then
        if selectSlotWith(item) then
          local qty = turtle.getItemDetail().count;
          local delta;
          if (qty > count) then delta = count else delta = qty; end
          if turtle.dropDown(delta) then
            deposit(item, count - delta);
          end
        end
      end
    end
  end
  -- Performs a move action a number of times. Will continue trying until it succeeds.
  -- This prevents the turtle from getting lost when someone stands in front of it.
  function move(action, length, blockFn, eachFn)
    print('Move ' .. action .. ' x ' .. tostring(length))
    local fn = turtle[action];
    if not (type(fn) == 'function') then error('Could not find turtle.' .. action); end
    Stream.range(1, length).forEach(function(i)
      print('iteration ' .. tostring(i) .. ' of ' .. tostring(length))
      while not fn() do
        if notNil(blockFn) then blockFn(action) end;
      end
      if notNil(eachFn) then eachFn() end;
    end);
    return Turtle;
  end

  function lookForward()
    local success, item = turtle.inspect();
    if (success) then
      return item.name
    else
      return success;
    end
  end
  function lookUp()
    local success, item = turtle.inspectUp();
    if (success) then return item.name end
  end

  function lookDown()
    local success, item = turtle.inspectDown();
    if (success) then return item.name end
  end

  function suck()
    turtle.suckUp()
    turtle.suckDown();
    turtle.suck();
    turtle.turnRight();
    turtle.suck();
    turtle.turnRight();
    turtle.suck();
    turtle.turnRight();
    turtle.suck();
    turtle.turnRight();
  end

  function circle(r, blockFn, eachFn)
    turtle.turnRight();
    move('forward', r, blockFn, eachFn);
    turtle.turnRight();
    move('forward', r * 2, blockFn, eachFn);
    turtle.turnRight();
    move('forward', r * 2, blockFn, eachFn);
    turtle.turnRight();
    move('forward', r * 2, blockFn, eachFn);
    turtle.turnRight();
    move('forward', r, blockFn, eachFn);
    turtle.turnLeft();
  end

  function digHole(r, blockFn, eachFn, eachRadiiFn)
    local dig = function()
      if not isNil(blockFn) then
        blockFn()
      end
      turtle.dig();
    end
    local digDown = function()
      turtle.digDown()
    end
    local digAround = function()
      if not isNil(eachFn) then
        eachFn()
      end
      turtle.digUp();
      turtle.digDown();
    end

    Turtle
      .move('turnRight', 2)

    Stream.range(1, r).forEach(function(radius)
      if not isNil(eachRadiiFn) then
        eachRadiiFn()
      end
      circle(r - radius, dig, digAround)
      Turtle
        .move('turnRight', 2)
        .move('forward', 1, dig, digAround)
        .move('turnRight', 2)
    end)

    Turtle
      .move('forward', r)
      .move('turnRight', 2)
  end
  return {
    inventory = inventory,
    findSlot = findSlot,
    selectSlotWith = selectSlotWith,
    refuel = refuel,
    refuelFrom = refuelFrom,
    move = move,
    lookForward = lookForward,
    lookUp = lookUp,
    lookDown = lookDown,
    suck = suck,
    circle = circle,
    deposit = deposit,
    digHole = digHole,
    checkFuel = checkFuel
  }
end)()
