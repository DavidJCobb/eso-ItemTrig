if not ItemTrig then return end

--[[--
   PERFORMANCE TEST FUNCTIONS
   
   You should probably just inline this; among other things, that would allow 
   you to nest performance tests and remove the need for these asserts. Mainly 
   these exist just so I can easily look up the timing getter when I need it.
--]]--
local _perfteststart = nil
function ItemTrig.perfTestStart()
   assert(_perfteststart == nil, "A perf test is already in progress.")
   _perfteststart = GetGameTimeMilliseconds()
end
function ItemTrig.perfTestEnd()
   assert(_perfteststart ~= nil, "A perf test isn't in progress.")
   local done  = GetGameTimeMilliseconds()
   local start = _perfteststart
   _perfteststart = nil
   return done - start
end

function ItemTrig.wait(ms)
   --
   -- There isn't *much* utility to this function. The UI will hang for however 
   -- long you force a wait; the game doesn't continue "underneath" the wait. 
   -- If you want to have something run later without jamming up the game, use 
   -- zo_callLater.
   --
   -- I guess if you were to find a good event to use, you could call this 
   -- function to create a hitstop effect? I'm mainly just keeping it here as 
   -- an excuse to document why it's not terribly useful.
   --
   local final = GetGameTimeMilliseconds() + ms
   while GetGameTimeMilliseconds() < final do end
end