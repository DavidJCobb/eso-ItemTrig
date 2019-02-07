ItemTrig = {
   name    = "ItemTrig",
   windows = {},
   windowClasses = {},
}

--[[--
   System for handling windows such that the window classes don't need to 
   be in the global scope.
--]]--
function ItemTrig:registerWindow(name, class)
   assert(type(name) == "string", "Bad window name.")
   assert(self.windowClasses[name] == nil, "Window " .. name .. " is already registered.")
   self.windowClasses[name] = class
end
function ItemTrig:setupWindow(name, control)
   assert(self.windows[name] == nil, "The " .. name .. " window already exists.")
   self.windows[name] = self.windowClasses[name]:install(control)
end

local function PerfTest(extra)
   local testcount = 100
   if extra ~= "" and extra ~= " " then
      if tonumber(extra) then
         testcount = tonumber(extra)
         if testcount > 1000000 then
            testcount = 1000000
         elseif testcount < 0 then
            testcount = 10
         end
      end
   end
   
   -------------
   
   local t = ItemTrig.Trigger:new()
   t.name = "Test trigger"
   table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(t.conditions, ItemTrig.Condition:new(2, {true}))  -- Set And/Or
   table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(t.conditions, ItemTrig.Condition:new(3, {false})) -- Always/Never
   table.insert(t.actions, ItemTrig.Action:new(2, {"Hello, world!"})) -- Log Message
   
   local n = ItemTrig.Trigger:new()
   n.name = "Nested test trigger"
   table.insert(n.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(n.actions, ItemTrig.Action:new(2, {"I am nested!"})) -- Log Message
   table.insert(n.actions, ItemTrig.Action:new(1)) -- Return
   
   table.insert(t.actions, ItemTrig.Action:new(3, {n})) -- Run Nested Trigger
   table.insert(t.actions, ItemTrig.Action:new(2, {"After nested!"})) -- Log Message
   
   -------------
   
   local diff
   ItemTrig.pertTestStart()
   for i = 1, testcount do
      s = t:serialize()
   end
   diff = ItemTrig.perfTestEnd()
   CHAT_SYSTEM:AddMessage("Serializating " .. testcount .. " times took " .. diff .. " ms.")
   --
   local tparsed
   s = t:serialize()
   d(s)
   ItemTrig.pertTestStart()
   for i = 1, testcount do
      tparsed = ItemTrig.parseTrigger(s)
   end
   diff = ItemTrig.perfTestEnd()
   CHAT_SYSTEM:AddMessage("Parsing " .. testcount .. " times took " .. diff .. " ms.")
end

local function ShowWin()
   ItemTrig.windows.triggerList:show()
end

local function Initialize()
   ItemTrig.Savedata:load()
   SLASH_COMMANDS["/cobbperftest"] = PerfTest
   SLASH_COMMANDS["/cobbshowwin"]  = ShowWin
end
local function OnAddonLoaded(eventCode, addonName)
   if addonName == ItemTrig.name then
      --
      -- Setup our own add-on. This is our entry point.
      --
      Initialize()
   end
end

EVENT_MANAGER:RegisterForEvent(ItemTrig.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)