local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("ImportListWindow")
ItemTrig:registerWindow("importList", WinCls)

local TriggerListEntry  = ItemTrig.UI.TriggerListEntry
local WCombobox         = ItemTrig.UI.WCombobox
local WScrollSelectList = ItemTrig.UI.WScrollSelectList

function WinCls:_construct()
   self:pushActionLayer("ItemTrigBlockMostKeys")
   self:setTitle(GetString(ITEMTRIG_STRING_UI_IMPORTLIST_TITLE))
   self:setResizeThrottle(5) -- throttle resize frame handler to every five frames
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      lists = {},
      ui    = {},
      pendingResults = {
         outcome = false, -- true to resolve; false to reject
         results = nil,   -- param to send back
      },
   })
   --
   self.ui.fragment  = ItemTrig.registerTrigeditWindowFragment(control)
   self.ui.emptyText = self:controlByPath("Body", "ShowIfEmpty")
   do -- source select
      local combobox = WCombobox:cast(ItemTrig_TriggerImportSourceSelect)
      self.ui.select = combobox
      combobox.onChange =
         function()
            self:onSourceChange()
         end
   end
   do -- trigger list view
      local pane = WScrollSelectList:cast(self:controlByPath("Body", "Col2"))
      self.ui.pane = pane
      pane.element.template = "ItemTrig_TrigEdit_Template_TriggerOuter"
      pane.element.toConstruct =
         function(control, data, extra)
            local widget =  TriggerListEntry:cast(control)
            local trigger = data.trigger
            widget:makeReadOnly()
            widget:setSelected(extra and extra.selected)
            do
               --
               -- We want to show the trigger's entry point, too, not just 
               -- its name, so we need some extra logic.
               --
               local topLine = trigger.name
               local epLine
               do
                  epLine = GetString(ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINT)
                  local sep = GetString(ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINTSEPARATOR)
                  --
                  local count = #trigger.entryPoints
                  if count > 0 then
                     local list = {}
                     for i = 1, count do
                        list[#list + 1] = ItemTrig.ENTRY_POINT_NAMES[trigger.entryPoints[i]] or "?????"
                     end
                     list = table.concat(list, sep)
                     epLine = LocalizeString(epLine, list)
                  else
                     epLine = GetString(ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINTNONE)
                  end
               end
               --
               widget:setText(topLine .. "\n" .. epLine, trigger:getDescription())
            end
            widget:renderContents(trigger)
         end
      pane.element.onSelect =
         function(index, control, pane)
            TriggerListEntry:cast(control):setSelected(true)
         end
      pane.element.onDeselect =
         function(index, control, pane)
            TriggerListEntry:cast(control):setSelected(false)
         end
      pane.element.onDoubleClick =
         function(index, control, pane)
            local editor  = WinCls:getInstance()
            local trigger = editor:getTriggerByPaneIndex(index)
            if trigger then
               --
               -- TODO
               --
            end
         end
   end
end

function WinCls:handleModalDeferredOnHide(deferred)
   if self.pendingResults.outcome then
      deferred:resolve(self.pendingResults.results)
   else
      deferred:reject(self.pendingResults.results)
   end
end
function WinCls:onShow()
   self:buildTriggerLists()
   self.ui.select:select(nil) -- ensure that the next call changes the selection, so onChange fires and we redraw
   self.ui.select:select(1)
end
function WinCls:onHide()
   self.pendingResults.results = nil
   self.pendingResults.outcome = false
   self.lists = {}
   self.ui.pane:clear()
   self.ui.select:clear()
end
function WinCls:onCloseClicked()
   self:hide()
end
function WinCls:onResizeFrame()
   self.ui.pane:redraw()
end

function WinCls:onSourceChange()
   if self:isHidden() then
      return
   end
   local combobox = self.ui.select
   local data     = combobox:getSelectedData()
   if data then
      self:renderTriggers(data.triggers)
   end
end

--
-- We should keep this consistent with the trigger list window.
--
function WinCls:getTriggerByPaneIndex(index)
   local pane = self.ui.pane
   if not index then
      index = pane:getFirstSelectedIndex()
      if not index then
         return nil
      end
   end
   local data = pane:at(index)
   if not data then
      return nil
   end
   assert(data.triggerIndex ~= nil, "Bad trigger index!")
   return data.trigger, data.triggerIndex
end
function WinCls:getPaneIndexForTrigger(trigger)
   local pane  = self.ui.pane
   local index = nil
   pane:forEach(function(i, data)
      if data.trigger == trigger then
         index = i
         return true
      end
   end)
   return index
end

function WinCls:buildTriggerLists()
   local lists = {}
   lists[1] = {
      name     = "Trigger Gallery",
      triggers = ItemTrig.retrieveTriggerGallery(),
   }
   do
      local savedata   = ItemTrig.Savedata.interface
      local ids        = savedata:characterIDs()
      local characters = {}
      local currentID  = GetCurrentCharacterId()
      local count      = 0
      for i = 1, #ids do
         local id = ids[i]
         if id ~= currentID then
            count = count + 1
            --
            local interface = savedata:character(id)
            characters[count] = { name = interface.name, id = id, interface = interface }
         end
      end
      table.sort(characters, function(a, b) return (a.name or "") < (b.name or "") end)
      for i = 1, count do
         lists[1 + i] = {
            name     = characters[i].name,
            triggers = ItemTrig.Savedata:loadTriggersFor(characters[i].id)
         }
      end
   end
   self.lists = lists
   do -- combobox
      local combobox = self.ui.select
      combobox:clear()
      for i = 1, #self.lists do
         local entry = self.lists[i]
         combobox:push(entry, false)
      end
      combobox:redraw()
   end
end
function WinCls:shouldShowTrigger(trigger)
   return true
end
function WinCls:renderTriggers(tList)
   self.currentTriggerList = tList
   self:refresh()
end
function WinCls:refresh()
   --
   -- We should keep this consistent with the trigger list window.
   --
   local tList = self.currentTriggerList or {}
   local scrollPane = self.ui.pane
   scrollPane:clear(false)
   for i = 1, #tList do
      local trigger = tList[i]
      if self:shouldShowTrigger(trigger) then
         scrollPane:push({ trigger = trigger, triggerIndex = i }, false)
      end
   end
   scrollPane:redraw()
   do
      local text = self.ui.emptyText
      local hide = scrollPane:count() > 0
      text:SetHidden(hide)
      if not hide then
         if #tList > 0 then
            text:SetText(GetString(ITEMTRIG_STRING_UI_IMPORTLIST_ALL_TRIGGERS_FILTERED))
         else
            text:SetText(GetString(ITEMTRIG_STRING_UI_IMPORTLIST_HAS_NO_TRIGGERS))
         end
      end
   end
end

function WinCls:requestImport(opener)
   assert(opener ~= nil, "The trigger import window must be aware of its opener.")
   assert(self:getModalOpener() == nil, "The trigger import window is already showing!")
   return opener:showModal(self)
end
function WinCls:doImport()
   local trigger = self:getTriggerByPaneIndex()
   if not trigger then
      return
   end
   self.pendingResults.outcome = true
   self.pendingResults.results = trigger:clone(true) -- return a deep copy; may not always be necessary, but it'll always be safe
   self:hide()
end