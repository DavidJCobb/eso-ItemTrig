if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WEditbox = ItemTrig.UI.WidgetClass:makeSubclass("WEditbox", "numberEditbox")
local WEditbox       = ItemTrig.UI.WEditbox

local function _onChange(control)
   local widget = WEditbox:cast(control)
   if widget then
      local valid = widget:validate()
      if valid ~= widget.state.lastValid then
         widget.state.lastValid = valid
         widget:onValidationStateChanged(widget:value(), valid)
      end
   end
end

function WEditbox:_construct(options)
   if not options then
      options = {}
   end
   self.state = {
      lastValid = nil
   }
   ZO_PreHookHandler(self:asControl(), "OnTextChanged", function(self) _onChange(self) end)
end
function WEditbox:GetText() -- make it easier to swap things in
   return self:text()
end
function WEditbox:resetValidationConstraints()
end
function WEditbox:SetText(v) -- make it easier to swap things in
   return self:text(v)
end
function WEditbox:setValidationConstraints(constraints)
end
function WEditbox:text(v)
   if v then
      self:asControl():SetText(v)
      return v
   end
   return self:asControl():GetText()
end
function WEditbox:validate()
   local n = self:value()
   if not n then
      return false
   end
   return true
end
function WEditbox:value()
   local text = self:text()
   return text, text
end
do -- events; classes or instances can override them
   function WEditbox:onValidationStateChange(value, isNowValid)
   end
end

--

ItemTrig.UI.WNumberEditbox = ItemTrig.UI.WEditbox:makeSubclass("WNumberEditbox")
local WNumberEditbox       = ItemTrig.UI.WNumberEditbox
function WNumberEditbox:_construct(options)
   if not options then
      options = {}
   end
   self.validation = {}
   self:setValidationConstraints(options)
end
function WNumberEditbox:resetValidationConstraints()
   local v = self.validation
   v.max = nil
   v.min = nil
   v.requireInteger = false
end
function WEditbox:setValidationConstraints(options)
   ItemTrig.assign(self.validation, {
      max            = options.max or nil,
      min            = options.min or nil,
      requireInteger = options.requireInteger or false,
   })
end
function WNumberEditbox:validate()
   local n = self:value()
   if not n then
      return false
   end
   local v = self.validation
   if v.max and n > v.max then
      return false
   end
   if v.min and n < v.min then
      return false
   end
   if v.requireInteger and math.floor(n) ~= n then
      return false
   end
   return true
end
function WNumberEditbox:value()
   local text = self:asControl():GetText()
   return tonumber(text), text
end