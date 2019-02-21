if not ItemTrig then return end

function ItemTrig.posformat(f, ...)
   --
   -- Allows you to reorder tokens within a format string, e.g. 
   -- posformat("This %2 a %1.", "test", "is"). The results of 
   -- mixing numbered tokens with standard ones (i.e. "%2 %s") 
   -- are undefined.
   --
   -- Note that this is equivalent to calling the ZOS-provided 
   -- native method:
   --
   -- LocalizeString("This <<2>> a <<1>>", "test", "is")
   --
   -- and LocalizeString is wrapped by zo_strformat, which 
   -- checks for and applies handling to numeric arguments and 
   -- whatnot.
   --
   local args      = {...}
   local reordered = {}
   local pattern   = "%%(%d+)"
   if not f:find("^%%%d") then
      pattern = "([^%%])" .. pattern
   end
   f = f:gsub(pattern,
      function (c1, c2)
         if c2 then
            table.insert(reordered, args[tonumber(c2)])
            return c1 .. "%s"
         end
         table.insert(reordered, args[tonumber(c1)])
         return "%s"
      end
   )
   return string.format(f, unpack(reordered))
end
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
function ItemTrig.truncateString(s, length, tail)
   if s:len() <= length then
      return s
   end
   if not tail then
      tail = GetString(ITEMTRIG_STRING_GENERIC_TRUNCATION_MARKER)
   end
   return string.sub(s, 1, length) .. tail
end