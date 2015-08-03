os.loadAPI('turtles/functional.lua');
_G.Turtle = (function()
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
    return turtle.refuel(1)
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

  -- Performs a move action a number of times. Will continue trying until it succeeds.
  -- This prevents the turtle from getting lost when someone stands in front of it.
  function move(action, length)
    local fn = turtle[action];
    if not (type(fn) == 'function') then error('Could not find turtle.' .. action); end
    Stream.range(1, length).forEach(function()
      while not fn() do end
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

  return {
    inventory = inventory,
    findSlot = findSlot,
    selectSlotWith = selectSlotWith,
    refuel = refuel,
    refuelFrom = refuelFrom,
    move = move,
    lookForward = lookForward,
    lookUp = lookUp
  }
end)()
