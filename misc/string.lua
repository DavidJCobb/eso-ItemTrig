if not ItemTrig then return end

function ItemTrig.split(s, delim) -- delim is a set of chars, not a substring, and can include regex codes
   local fields = {}
   s:gsub("([^"..delim.."]+)", function(c) fields[#fields+1] = c end)
   return fields
end
function ItemTrig.splitByCount(s, count)
   if s:len() <= count then
      return { [1] = s }
   end
   local chunks = {}
   while s:len() > count do
      table.insert(chunks, s:sub(0, count))
      s = s:sub(count + 1)
   end
   if s:len() > 0 then
      table.insert(chunks, s)
   end
   return chunks
end