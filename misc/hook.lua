function ItemTrig.screenFunction(context, target, condition)
   local original = context[target]
   context[target] =
      function(...)
         if not condition(...) then
            return nil
         end
         return original(...)
      end
end
function ItemTrig.wrapFunction(context, target, pre, post)
   local original = context[target]
   context[target] =
      function(...)
         if pre(...) == false then
            return nil
         end
         local result = original(...)
         post(...)
         return result
      end
end