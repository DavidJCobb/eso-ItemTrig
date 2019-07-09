local ISavedataForAccount = {}
local ISavedataCharacter  = {}
ItemTrig.ISavedata = ISavedataForAccount

--[[--
   ISAVEDATA
   
   An interface for working with savedata, comparable to ZO_SavedVars. It's 
   somewhat less complex -- the result of omitting some legacy functionality; 
   ZO_SavedVars used to index character savedata by character name, switched 
   to using character IDs as a more stable key, and retained name keys for 
   backward-compatibility. (Zenimax also seems to just have a tendency to 
   completely overengineer everything in general...)
   
   Practical differences include:
   
    - Savedata that is out-of-date won't be automatically deleted; instead, 
      you can register "update routines" to run when out-of-date savedata is 
      loaded.
   
    - Per-character savedata is indexed as a nested table; the outer table 
      contains metadata about the character, such as the name, which we will 
      automatically maintain. ZO_SavedVars also maintains the last-known 
      name for each character in the form of the "$LastCharacterName" key, 
      but this key is less convenient to access and isn't "advertised" as 
      a part of the API that we're meant to use.
   
   A usage example:
   
      --
      -- Declare our savedata variable, an optional namespace to nest things 
      -- under, and the current data version.
      --
      local savedata = ISavedataForAccount("MyVarName", nil, 3)
      
      savedVars:addUpdateRoutine(function(cdata, version)
         if version < 2 then
            -- do your updates here
            return 2
         end
      end)
      savedVars:addUpdateRoutine(function(cdata, version)
         if version < 3 then
            -- do your updates here
            return 3
         end
      end)
      
      savedata.defaults = { foo = "bar" }
      
      --
      -- Let's operate on the saved data for a character!
      --
      local cdata = savedata:character() -- no arg means current character ID
      d(cdata:data().foo) -- "bar"
      d(cdata.name) -- "John Zenimax"
      
      local allChars = savedata:characterIDs() -- returns an array
      
      --
      -- You can store account-wide data, too.
      --
      local adata = savedata:accountWide()
      d(adata:data().foo) -- "bar"
--]]--

ISavedataForAccount.__index = ISavedataForAccount
function ISavedataForAccount:new(globalName, namespace, version, account)
   assert(self == ISavedataForAccount, "This method must be called on the class, not an instance.")
   account   = account   or GetDisplayName()
   namespace = namespace or "Default"
   if not _G[globalName] then
      _G[globalName] = {}
   end
   assert(type(_G[globalName]) == "table", "Cannot wrap a non-table in ISavedataForAccount.")
   if not _G[globalName][namespace] then
      _G[globalName][namespace] = {}
   end
   assert(type(_G[globalName][namespace]) == "table", "Cannot wrap a non-table in ISavedataForAccount.")
   if not _G[globalName][namespace][account] then
      _G[globalName][namespace][account] = {}
   end
   --local result = setmetatable({}, self)
   local result = setmetatable({}, {
      __index =
         function(t, k, v)
            if k == "wrapped" then
               --
               -- We SHOULD be able to just assign this to a key on (result) 
               -- and have that function as a reference, but for some reason,  
               -- that actually copies the table instead. Something odd about 
               -- the native implementation of saved globals, perhaps.
               --
               return _G[globalName][namespace][account]
            end
            if not v then
               return self[k]
            end
            return v
         end
   })
   ItemTrig.assign(result, {
      defaults       = {},
      version        = version or 0,
    --wrapped        = _G[globalName][namespace][account],
      updateRoutines = {},
   })
   return result
end
function ISavedataForAccount:accountWide()
   local id  = "$AccountWide"
   local raw = self.wrapped[id]
   if not raw then
      self.wrapped[id] = {
         name    = "",
         version = self.version,
         data    = ItemTrig.assignDeep({}, self.defaults or {}),
      }
      raw = self.wrapped[id]
   end
   local interface = ISavedataCharacter:new(self, id, raw)
   if interface:isOutOfDate() then
      for i = 1, #self.updateRoutines do
         interface:tryUpdateRoutine(self.updateRoutines[i])
         if not interface:isOutOfDate() then
            break
         end
      end
   end
   return interface
end
function ISavedataForAccount:addUpdateRoutine(functor)
   table.insert(self.updateRoutines, functor)
end
function ISavedataForAccount:character(id)
   --
   -- This function returns an ISavedataCharacter object for 
   -- the specified character ID. If no character ID is given, 
   -- then it returns an ISavedataCharacter object for the 
   -- current character.
   --
   -- Before returning the ISavedataCharacter object, this 
   -- function checks whether the character data is out of 
   -- date; if so, it runs all registered update routines 
   -- on it, stopping early if one of them brings the data 
   -- up to date.
   --
   assert(id == nil or type(id) == "string", "A character ID cannot be a " .. type(id) .. ".")
   local currentID = GetCurrentCharacterId()
   if id == nil then
      id = currentID
   end
   local created = false
   local raw     = self.wrapped[id]
   if not raw then
      assert(id == currentID, "Cannot retrieve data for the requested character ID (" .. tostring(id) .. ").")
      self.wrapped[id] = {
         name    = GetUnitName("player"),
         version = self.version,
         data    = ItemTrig.assignDeep({}, self.defaults or {}),
      }
      raw = self.wrapped[id]
      created = true
   elseif id == currentID then
      if NAME_CHANGE:DidNameChange() then
         raw.name = GetUnitName("player")
      end
   end
   local interface = ISavedataCharacter:new(self, id, raw)
   if interface:isOutOfDate() then
      for i = 1, #self.updateRoutines do
         interface:tryUpdateRoutine(self.updateRoutines[i])
         if not interface:isOutOfDate() then
            break
         end
      end
   end
   return interface
end
function ISavedataForAccount:characterIDs()
   local list = {}
   for k, _ in pairs(self.wrapped) do
      if k ~= "$AccountWide" then
         table.insert(list, k)
      end
   end
   return list
end

ISavedataCharacter.__index = ISavedataCharacter
function ISavedataCharacter:new(root, id, struct)
   local result = setmetatable({}, self)
   ItemTrig.assign(result, {
      id      = id,
      name    = struct.name,
      root    = root,
      version = tonumber(struct.version) or 0,
      wrapped = struct.data,
      _initiallyLoadedVersion = tonumber(struct.version) or 0,
   })
   return result
end
function ISavedataCharacter:is(x)
   if type(x) ~= "table" then
      return false
   end
   return getmetatable(x) == self
end
function ISavedataCharacter:data()
   return self.wrapped
end
function ISavedataCharacter:isOutOfDate()
   return self.version < self.root.version
end
function ISavedataCharacter:setIsUpToDate()
   self:setVersion(self.root.version)
end
function ISavedataCharacter:setVersion(v)
   self.version = v
   self.wrapped.version = v
end
function ISavedataCharacter:tryUpdateRoutine(functor)
   --
   -- An update routine receives, as arguments, the ISavedataCharacter 
   -- instance and its version. If the routine returns true, then the 
   -- instance is flagged as being whatever the current savedata version 
   -- is. If the routine returns a number and that number is higher than 
   -- the instance's version, then the instance's version is set to that 
   -- number; this allows you to create successive update routines (e.g. 
   -- one to update from v1 to v2; another to update from v2 to v3; and 
   -- so on).
   --
   if not self:isOutOfDate() then
      return true
   end
   local result = functor(self, self.version)
   if result == true then
      self:setVersion(self.root.version)
      return true
   elseif type(result) == "number" and result > self.version then
      self:setVersion(result)
   end
   return false
end