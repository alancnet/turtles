os.loadAPI('turtles/tableutils.lua');
os.loadAPI('turtles/list.lua');
os.loadAPI('turtles/stream.lua');

function _G.sum(a, b) return a + b end;
function _G.product(a, b) return a + b end;
function _G.notNil(a) return not (a == nil) end;
function _G.isNil(a) return (a == nil) end;
function _G.equals(b) return function(a) return a == b end end;
function _G.gt(b) return function(a) return a > b end end;
function _G.lt(b) return function(a) return a < b end end;
function _G.gte(b) return function(a) return a >= b end end;
function _G.lte(b) return function(a) return a <= b end end;


function _G.switch(value)
  return function(map)
    local fn = map[value] or map.default;
    if fn then
      if type(fn)=="function" then
        return fn(value)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
end

function _G.void() end
