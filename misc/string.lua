if not ItemTrig then return end

function ItemTrig.split(s, delim) -- delim is a set of chars, not a substring, and can include regex codes
   local fields = {}
   s:gsub("([^"..delim.."]+)", function(c) fields[#fields+1] = c end)
   return fields
end