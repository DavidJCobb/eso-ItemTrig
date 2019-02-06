if not ItemTrig then return end
if not ItemTrig.UI then
   ItemTrig.UI = {}
end

--[[--
   WHAT IS THIS STUFF?
   
      Widget classes can be attached to UI controls, in order to add additional 
      functionality to them. Each widget class has a "cast" method that can be 
      passed a control to retrieve the class itself, and an "install" method 
      that actually creates a class instance and binds it to the control.
      
      As an example:
      
         local instance = MyClass:cast(control)
         if instance then
            instance:doSomeExpandedFunctionality()
         end
         --
         -- control.doSomeExpandedFunctionality == nil
   
   HOW TO MAKE A WIDGET CLASS:
   
      ScrollList = ItemTrig.UI.WidgetClass:makeSubclass("ScrollList", "scrollList")
      function ScrollList:_construct()
         self:callSuper("_construct")
         --
         -- ...
         --
      end
      
      --
      -- Now, if we initialize a control, then:
      --
      --    control[CONTROL_STORAGE_KEY_NAME].scrollList -- instanceof ScrollList
      --
      -- You're not actually supposed to access it that way (use the "cast" static 
      -- method!), but that's how instances are bound to their controls.
      --
      
      ScrollSelectList = ScrollList:makeSubclass("ScrollSelectList")
      function ScrollSelectList:_construct()
         self:callSuper("_construct")
         --
         -- ...
         --
      end
   
   HOW TO LINK IT TO XML:
   
      <OnInitialized> ScrollList:install(self) </OnInitialized>
   
--]]--

--
-- When linking controls and class instances together, we want to use field 
-- names that are prefixed with spaces, so that they're less likely to conflict 
-- with other systems and with field names that classes may want to use.
--
local CONTROL_PRIVATE_KEY_NAME = " control"
local CONTROL_STORAGE_KEY_NAME = " widgets"
local CONTROL_CLASS_KEY_NAME   = " storeAs"
local CLASSNAME_KEY_NAME       = " name"

ItemTrig.UI.WidgetClass = {}
local WClass = ItemTrig.UI.WidgetClass
WClass[CONTROL_CLASS_KEY_NAME] = "abstract"
WClass[CLASSNAME_KEY_NAME]     = "WClass"

function WClass:_construct(...)
   --
   -- Override me! This is where you should construct your instance 
   -- based on the additional arguments (if any) you can receive.
   --
end
function WClass:install(control, ...)
   local instance = setmetatable({}, { __index = self })
   local meta     = getmetatable(instance)
   do
      local cname = self[CONTROL_CLASS_KEY_NAME]
      if not control[CONTROL_STORAGE_KEY_NAME] then
         control[CONTROL_STORAGE_KEY_NAME] = {}
      end
      control[CONTROL_STORAGE_KEY_NAME][cname] = instance
   end
   instance[CONTROL_PRIVATE_KEY_NAME] = control
   do
      --
      -- Call superclass constructors in order from supermost to submost.
      --
      -- We use rawget(table, key) to get the constructors without using 
      -- the metatable; this ensures that if a superclass doesn't define 
      -- its own constructor, we don't call its superclass's constructor 
      -- multiple times.
      --
      local superclasses = {}
      local class = self:getSuperclass()
      while class do
         table.insert(superclasses, class)
         class = class:getSuperclass()
      end
      for i = #superclasses, 1, -1 do
         local constructor = rawget(superclasses[i], "_construct")
         if constructor then
            constructor(instance, ...)
         end
      end
   end
   if rawget(self, "_construct") then
      instance:_construct(...)
   end
   return instance
end
function WClass:makeSubclass(name, keyOnControl) -- static method
   assert(name ~= nil, "When creating a widget class, you must specify the classname, for error reporting purposes.")
   if self == WClass then
      assert(keyOnControl ~= nil, "When creating a widget base class, you must specify the key that will be used to store the class instance on the control.")
   else
      --
      -- If you're defining a subclass and choose to omit keyOnControl, then 
      -- your subclass will use the same key as its superclass. This means 
      -- that the subclass and superclass cannot both exist on the same 
      -- control, and that casting the control to either class will retrieve 
      -- the most "sub" class instance attached to it.
      --
      if keyOnControl == nil then
         keyOnControl = self[CONTROL_CLASS_KEY_NAME]
      end
   end
   local subclass = setmetatable({}, {__index = self})
   subclass[CONTROL_CLASS_KEY_NAME] = keyOnControl
   subclass[CLASSNAME_KEY_NAME]     = name
   return subclass
end
function WClass:asControl()
   return self[CONTROL_PRIVATE_KEY_NAME]
end
function WClass:getClass()
   local meta = getmetatable(self)
   assert(meta ~= nil)
   return meta.__index
end
function WClass:getSuperclass() -- static method
   local meta = getmetatable(self)
   if meta == nil or type(meta.__index) ~= "table" then
      return nil
   end
   return meta.__index
end
function WClass:getInstanceSuperclass()
   return self:getClass():getSuperclass()
end
function WClass:callSuper(methodName, ...)
   if methodName == "_construct" then
      --
      -- TODO: log a warning somewhere so we can go and clean this up; 
      -- older code required you to manually call-super in constructors
      --
      return
   end
   local super = self:getInstanceSuperclass()[methodName]
   assert(type(super) == "function", "This method does not exist, or was overridden with a non-function, on the superclass.")
   return super(self, ...)
end
function WClass:cast(control) -- static method
   local cname = self[CONTROL_CLASS_KEY_NAME]
   assert(control ~= nil, "Cannot cast a nil to " .. self[CLASSNAME_KEY_NAME] ..  ".")
   local t = type(control)
   if t == "userdata" then -- is control
      local widgets = control[CONTROL_STORAGE_KEY_NAME]
      if not widgets then
         return nil
      end
      return widgets[cname]
   elseif t == "table" then
      local class = control:getClass()
      while class do
         if class == self then
            return control
         end
         class = class:getSuperclass()
      end
      return nil
   end
   assert(false, "Cannot cast a " .. type(control) .. " to " .. self[CLASSNAME_KEY_NAME] ..  ".")
end
function WClass:GetNamedChild(name)
   return GetControl(self:asControl(), name)
end