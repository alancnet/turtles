_G.Stream = (function()
  local empty;

  function toString(list)
    local str = "";
    list.map(function(x)
      if type(x) == 'table' then
        return table.tostring(x)
      else
        return tostring(x)
      end
    end)
    .forEach(function(x)
      str = str .. x .. ", "
    end)
    return str;
  end

  function cons(head, tail)
    if not (type(tail) == 'function') then error('tail must be a function.'); end
    return asList({head = head, tail = tail});
  end

  function map(list, mapper)
    if list.empty then return list end
    return cons(mapper(list.head), function() return map(list.tail(), mapper) end)
  end

  function foldLeft(list, initial)
    return function(folder)
      local loop; loop = function(list, accum)
        if list.empty then return accum end
        return loop(list.tail(), folder(accum, list.head))
      end
      return loop(list, initial)
    end
  end

  function reduce(list, reducer)
    local tail = list.tail();
    if tail.empty then return list.head end
    return foldLeft(tail, list.head)(reducer);
  end

  function count(list)
    return foldLeft(list, 0)(function(i) return i + 1; end);
  end

  function zipWithIndex(list)
    local loop; loop = function(list, i)
      if list.empty then return list end
      return cons({list.head, i}, function() return loop(list.tail(), i + 1) end)
    end
    return loop(list, 0)
  end

  function from(number, step)
    if step == nil then
      step = 1
    end
    return cons(number, function() return from(number + step, step) end)
  end

  function fromTable(tbl)
    local max = table.getn(tbl);
    local loop; loop = function(i)
      if (i > max) then return empty end;
      return cons(tbl[i], function()
        return loop(i + 1);
      end)
    end
    return loop(1);
  end

  function ofLength(i, initialValue)
    if i == 0 then return empty end;
    return cons(initialValue, function() return ofLength(i - 1, initialValue) end)
  end

  function take(list, n)
    if n <= 0 then return empty
    else return cons(list.head, function() return take(list.tail(), n - 1) end); end
  end

  function drop(list, n)
    if n > 0 then return drop(list.tail(), n - 1);
    else return list; end
  end

  function filter(list, predicate)
    if list.empty then return list; end
    if (predicate(list.head)) then
      return cons(list.head, function() return filter(list.tail(), predicate) end);
    else
      return filter(list.tail(), predicate);
    end
  end

  function new(...)
    return fromTable({...});
  end

  function range(start, finish)
    return ofLength(finish - start + 1)
      .zipWithIndex()
      .map(function(a) return a[2] + start; end)
  end

  function forEach(list, action)
    if list.empty then return end;
    action(list.head);
    forEach(list.tail(), action)
    return list;
  end

  function slow(list, delay)
    return list.map(function(value)
      sleep(delay);
      return value;
    end)
  end
  function asList(list)
    list.map = function(mapper)
      return map(list, mapper);
    end
    list.toString = function()
      return toString(list);
    end
    list.foldLeft = function(initial)
      return foldLeft(list, initial);
    end
    list.reduce = function(reducer)
      return reduce(list, reducer);
    end
    list.zipWithIndex = function()
      return zipWithIndex(list);
    end
    list.take = function(n)
      return take(list, n);
    end
    list.drop = function(n)
      return drop(list, n);
    end
    list.filter = function(predicate)
      return filter(list, predicate);
    end
    list.forEach = function(action)
      return forEach(list, action);
    end;
    list.slow = function(delay)
      return slow(list, delay);
    end
    list.count = function()
      return count(list);
    end
    return list;
  end
  empty = asList({ empty = true });
  return {
    toString = toString,
    cons = cons,
    map = map,
    foldLeft = foldLeft,
    reduce = reduce,
    new = new,
    ofLength = ofLength,
    range = range,
    zipWithIndex = zipWithIndex,
    filter = filter,
    empty = empty,
    forEach = forEach,
    count = count,
    from = from
  }
end)();
