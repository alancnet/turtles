function _G.inventory()
  return List.range(1,16)
  .map(function(index)
    return {
      index = index,
      item = turtle.getItemDetail(index)
    }
  end)
  .filter(function(slot) return notNil(slot.item) end)

end
function _G.findSlot(name)
  return inventory()
  .filter(function(slot) return equals(slot.item.name)(name) end)
  .take(1)
  .head;
end

function _G.selectSlotWith(name)
  local slot = findSlot(name);
  if notNil(slot) then
    return turtle.select(slot.index);
  else
    return false;
  end
end
