os.loadAPI('functional.lua');
os.loadAPI('turtle.lua');


-- print(List.range(10,20).filter(gt(15)).toString());

-- error('done');
local logSlot = findSlot('minecraft:log');
local saplingSlot = findSlot('minecraft:sapling');

if isNil(logSlot) then print('ERROR') error('Could not find log in inventory.'); end
if isNil(saplingSlot) then error('Could not find sapling in inventory.') end
