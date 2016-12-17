_G.Array = (function()

  function fromTable(tbl)
    return asArray(tbl)
  end

  function new(...)
    if (arg) then return fromTable(arg) else return fromTable({}) end
  end

  function asArray(array)
    local update = function(ret)
      array.length = table.getn(array)
      return ret;
    end
    array.push = function(v)
      table.insert(array, v);
      update()
      return table.getn(array)
    end
    array.pop = function()
      return update(table.remove(array))
    end
    array.peek = function()
      return array[table.getn(array)]
    end
    array.shift = function()
      return update(table.remove(array, 1))
    end
    array.unshift = function(v)
      table.insert(array, 1, v)
      return update(table.getn(array))
    end
    array.toTable = function()
      local ret = {}
      local i, v
      for i, v in ipairs(array) do
        ret[i] = array[i];
      end
      return ret;
    end
    array.toJson = function()
      return textutils.serializeJSON(array.toTable())
    end
    array.toList = function()
      return List.new(unpack(array.toTable()));
    end
    array.slice = function(start, fin)
      if not fin then fin = array.length + 1 end
      local ret = Array.new();
      local i = start
      while i < fin do
        ret.push(array[i])
        i = i + 1
      end
      return ret;
    end
    array.splice = function(start, fin)
      if not fin then fin = array.length + 1 end
      local ret = Array.new();
      local i = start
      while i < fin do
        ret.push(table.remove(array, start))
        i = i + 1
      end
      return update(ret);
    end
    array.forEach = function(doer)
      local i, v
      for i, v in ipairs(array) do
        doer(v, i)
      end
    end
    array.map = function(mapper)
      local ret = Array.new()
      local i, v
      for i, v in ipairs(array) do
        ret.push(mapper(v, i))
      end
      return ret;
    end
    array.filter = function(predicate)
      local ret = Array.new()
      local i, v
      for i, v in ipairs(array) do
        if (predicate(v,i)) then
          ret.push(v)
        end
      end
      return ret;
    end
    array.find = function(predicate)
      local i, v
      for i, v in ipairs(array) do
        if predicate(v, i) then
          return v, i
        end
      end
      return nil
    end
    array.findLast = function(predicate)
      local i, v, ret, reti
      for i, v in ipairs(array) do
        if predicate(v, i) then
          ret, reti = v, i
        end
      end
      return ret, reti
    end
    array.reverse = function()
      local ret = Array.new()
      local i, v
      for i, v in ipairs(array) do
        ret.unshift(v, i)
      end
      return ret;
    end
    array.reduce = function(reducer, initial)
      local start = 1
      if type(initial) == "nil" then
        start = 2
        initial = array[1]
      end
      local i, accumulator = start, initial
      while i <= array.length do
        accumulator = reducer(accumulator, array[i])
        i = i + 1
      end
      return accumulator
    end
    array.indexOf = function(other)
      local i, v
      for i, v in ipairs(array) do
        if v == other then
          return i
        end
      end
      return nil
    end
    array.contains = function(other)
      return not not array.indexOf(other)
    end
    return update(array)
  end

  return {
    fromTable = fromTable,
    new = new
  }
end)()
