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