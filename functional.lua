_G.TableUtils = (function()
  function table.val_to_str ( v )
    if "string" == type( v ) then
      v = string.gsub( v, "\n", "\\n" )
      if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
        return "'" .. v .. "'"
      end
      return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
      return "table" == type( v ) and table.tostring( v ) or
        tostring( v )
    end
  end

  function table.key_to_str ( k )
    if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
      return k
    else
      return "[" .. table.val_to_str( k ) .. "]"
    end
  end

  function table.tostring( tbl )
    local result, done = {}, {}
    for k, v in ipairs( tbl ) do
      table.insert( result, table.val_to_str( v ) )
      done[ k ] = true
    end
    for k, v in pairs( tbl ) do
      if not done[ k ] then
        table.insert( result,
          table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
      end
    end
    return "{" .. table.concat( result, "," ) .. "}"
  end
end)()

_G.List = (function()
  local empty;

  function toString(list)
    function loop(list, i)
      if list.empty then return "" end
      local comma = ''
      local headStr
      if type(list.head) == 'table' then
        headStr = table.tostring(list.head)
      else
        headStr = tostring(list.head)
      end
      if (i > 0) then comma = ', ' end
      return comma .. headStr .. loop(list.tail, i + 1)
    end
    return loop(list, 0)
  end

  function cons(head, tail)
    return asList({head = head, tail = tail});
  end

  function map(list, mapper)
    if list.empty then return list end
    return cons(mapper(list.head), map(list.tail, mapper))
  end

  function foldLeft(list, initial)
    return function(folder)
      function loop(list, accum)
        if list.empty then return accum end
        return loop(list.tail, folder(accum, list.head))
      end
      return loop(list, initial)
    end
  end

  function reduce(list, reducer)
    if list.tail.empty then return list.head end
    return foldLeft(list.tail, list.head)(reducer);
  end

  function zipWithIndex(list)
    function loop(list, i)
      if list.empty then return list end
      return cons({list.head, i}, loop(list.tail, i + 1))
    end
    return loop(list, 0)
  end

  function fromTable(tbl)
    local list = empty;
    for x=table.getn(tbl),1,-1 do
      list = cons(tbl[x], list);
    end
    return list;
  end

  function ofLength(i, initialValue)
    if i == 0 then return empty end;
    return cons(initialValue, ofLength(i - 1, initialValue))
  end

  function take(list, n)
    if n <= 0 then return empty
    else return cons(list.head, take(list.tail, n - 1)); end
  end

  function drop(list, n)
    if n > 0 then return drop(list.tail, n - 1);
    else return list; end
  end

  function filter(list, predicate)
    if list.empty then return list; end
    if (predicate(list.head)) then
      return cons(list.head, filter(list.tail, predicate));
    else
      return filter(list.tail, predicate);
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
    forEach(list.tail, action)
    return list;
  end

  function asList(list)
    list.map = function(mapper)
      return map(list, mapper);
    end
    list.toString = function()
      return toString(list);
    end
    list.foldLeft = function(folder)
      return foldLeft(list, folder);
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
    forEach = forEach
  }
end)();

function _G.sum(a, b) return a + b end;
function _G.product(a, b) return a + b end;
function _G.notNil(a) return not (a == nil) end;
function _G.isNil(a) return (a == nil) end;
function _G.equals(b) return function(a) return a == b end end;
function _G.gt(b) return function(a) return a > b end end;
function _G.lt(b) return function(a) return a < b end end;
function _G.gte(b) return function(a) return a >= b end end;
function _G.lte(b) return function(a) return a <= b end end;
