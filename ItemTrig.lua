ItemTrig = {}
ItemTrig.name = "ItemTrig"

local function TriggerTest()
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
   
   t:exec()
   CHAT_SYSTEM:AddMessage("ABOUT TO LOG SERIALIZED TRIGGER")
   local s = t:serialize()
   CHAT_SYSTEM:AddMessage(s)
   CHAT_SYSTEM:AddMessage("LOGGED SERIALIZED TRIGGER")
   CHAT_SYSTEM:AddMessage("ABOUT TO PARSE TRIGGER")
   local tparsed = ItemTrig.parseTrigger(s)
   CHAT_SYSTEM:AddMessage(tparsed:debugDump())
   CHAT_SYSTEM:AddMessage("LOGGED PARSED TRIGGER")
   if tparsed then
      CHAT_SYSTEM:AddMessage("THE NESTED TRIGGER IS:")
      CHAT_SYSTEM:AddMessage(tparsed.actions[2].args[1]:debugDump())
      CHAT_SYSTEM:AddMessage("LOGGED PARSED NESTED TRIGGER")
   end
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
   
   local s
   local t2 = os.clock()
   local t1 = os.clock()
   for i = 1, testcount do
      s = t:serialize()
   end
   t2 = os.clock()
   CHAT_SYSTEM:AddMessage("Serializating " .. testcount .. " times took " .. (t2 - t1) .. " seconds.")
   --
   local tparsed
   s = t:serialize()
   d(s)
   t1 = os.clock()
   for i = 1, testcount do
      tparsed = ItemTrig.parseTrigger(s)
   end
   t2 = os.clock()
   CHAT_SYSTEM:AddMessage("Parsing " .. testcount .. " times took " .. (t2 - t1) .. " seconds.")
end

local function ShowWin()
   ItemTrig.UIMain.Toggle()
end
local function WinTest01()
   local tList = {}
   do
      local t = ItemTrig.Trigger:new()
      t.name = "Test trigger 01\n   LINE BREAK FUN"
      table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
      table.insert(t.conditions, ItemTrig.Condition:new(2, {true}))  -- Set And/Or
      table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
      table.insert(t.conditions, ItemTrig.Condition:new(3, {false})) -- Always/Never
      table.insert(t.actions, ItemTrig.Action:new(2, {"Hello, world!"})) -- Log Message
      --
      table.insert(tList, t)
   end
   do
      local t = ItemTrig.Trigger:new()
      t.name = "Test trigger 02"
      table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
      table.insert(t.actions, ItemTrig.Action:new(2, {"Hello, world!"})) -- Log Message
      --
      table.insert(tList, t)
   end
   ItemTrig.UIMain.RenderTriggers(tList)
end
local function WinTest02()
   ItemTrig.TrigEditWindow:showView("trigger")
end
local function ShowTestMenu()
   SCENE_MANAGER:ToggleTopLevel(ItemTrig_TestMenu)
   local pane = ItemTrig_TestMenu:GetNamedChild("vScrollListTest")
end

local function Initialize()
   ItemTrig.UIMain.Setup()
   SLASH_COMMANDS["/cobbtrigtest"]  = TriggerTest
   SLASH_COMMANDS["/cobbperftest"]  = PerfTest
   SLASH_COMMANDS["/cobbshowwin"]   = ShowWin
   SLASH_COMMANDS["/cobbwintest01"] = WinTest01
   SLASH_COMMANDS["/cobbwintest02"] = WinTest02
   SLASH_COMMANDS["/cobbshowtestmenu"]  = ShowTestMenu
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