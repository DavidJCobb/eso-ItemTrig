if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local ItemInterface = ItemTrig.ItemInterface

local _s = GetString

local ConditionBase = {}
ConditionBase.__index = ConditionBase
function ConditionBase:new(name, formatString, args, func)
   return ItemTrig.OpcodeBase:new(name, formatString, args, func)
end

ItemTrig.Condition = {}
ItemTrig.Condition.__index = ItemTrig.Condition
function ItemTrig.Condition:new(base, args)
   return ItemTrig.Opcode:new(base, args, ItemTrig.tableConditions, "condition")
end

ItemTrig.tableConditions = {
   [1] = ConditionBase:new( -- Comment
      _s(ITEMTRIG_STRING_CONDITIONNAME_COMMENT),
      _s(ITEMTRIG_STRING_CONDITIONDESC_COMMENT),
      {
         [1] = { type = "string", multiline = true, placeholder = _s(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT) },
      },
      function(state, context, args)
         return nil
      end
   ),
   [2] = ConditionBase:new( -- Set And/Or
      _s(ITEMTRIG_STRING_CONDITIONNAME_SETANDOR),
      _s(ITEMTRIG_STRING_CONDITIONDESC_SETANDOR),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_SETANDOR_AND), [2] = _s(ITEMTRIG_STRING_OPCODEARG_SETANDOR_OR)} },
      },
      function(state, context, args)
         if state.using_or == args[1] then
            return nil
         end
         if state.using_or then
            state.using_or = false
            if not state.matched_or then
               --
               -- None of the "OR" conditions matched, so the 
               -- trigger should fail.
               --
               return false
            end
         else
            state.using_or = true
         end
         return nil
      end
   ),
   [3] = ConditionBase:new( -- Always/Never
      _s(ITEMTRIG_STRING_CONDITIONNAME_ALWAYS),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ALWAYS),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_ALWAYS_NEVER), [2] = _s(ITEMTRIG_STRING_OPCODEARG_ALWAYS_ALWAYS)} },
      },
      function(state, context, args)
         return args[1]
      end
   ),
   [4] = ConditionBase:new( -- Stolen
      _s(ITEMTRIG_STRING_CONDITIONNAME_STOLEN),
      _s(ITEMTRIG_STRING_CONDITIONDESC_STOLEN),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_STOLEN_NO), [2] = _s(ITEMTRIG_STRING_OPCODEARG_STOLEN_YES)} },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.stolen
         end
         return not context.stolen
      end
   ),
   [5] = ConditionBase:new( -- Level
      _s(ITEMTRIG_STRING_CONDITIONNAME_LEVEL),
      _s(ITEMTRIG_STRING_CONDITIONDESC_LEVEL),
      {
         [1] = { type = "quantity" },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         return ItemTrig.testQuantity(args[1], context.level)
      end
   ),
   [6] = ConditionBase:new( -- Rarity
      _s(ITEMTRIG_STRING_CONDITIONNAME_RARITY),
      _s(ITEMTRIG_STRING_CONDITIONDESC_RARITY),
      {
         [1] = {
            type = "quantity",
            enum = {
               [ITEM_QUALITY_TRASH]     = GetString(SI_ITEMQUALITY0),
               [ITEM_QUALITY_NORMAL]    = GetString(SI_ITEMQUALITY1),
               [ITEM_QUALITY_MAGIC]     = GetString(SI_ITEMQUALITY2),
               [ITEM_QUALITY_ARCANE]    = GetString(SI_ITEMQUALITY3),
               [ITEM_QUALITY_ARTIFACT]  = GetString(SI_ITEMQUALITY4),
               [ITEM_QUALITY_LEGENDARY] = GetString(SI_ITEMQUALITY5),
            },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         return ItemTrig.testQuantity(args[1], context.quality)
      end
   ),
   [7] = ConditionBase:new( -- Base Type
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMTYPE),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMTYPE),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_YES)
            },
            default = true,
         },
         [2] = {
            type = "number",
            default = ITEMTYPE_TREASURE,
            enum = {
               [ITEMTYPE_ADDITIVE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_ADDITIVE),
               [ITEMTYPE_ARMOR]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR),
               [ITEMTYPE_ARMOR_BOOSTER]              = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR_BOOSTER),
               [ITEMTYPE_ARMOR_TRAIT]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR_TRAIT),
               [ITEMTYPE_AVA_REPAIR]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_AVA_REPAIR),
               [ITEMTYPE_BLACKSMITHING_BOOSTER]      = GetString(SI_ITEMTYPE0 + ITEMTYPE_BLACKSMITHING_BOOSTER),
               [ITEMTYPE_BLACKSMITHING_MATERIAL]     = GetString(SI_ITEMTYPE0 + ITEMTYPE_BLACKSMITHING_MATERIAL),
               [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = GetString(SI_ITEMTYPE0 + ITEMTYPE_BLACKSMITHING_RAW_MATERIAL),
               [ITEMTYPE_CLOTHIER_BOOSTER]           = GetString(SI_ITEMTYPE0 + ITEMTYPE_CLOTHIER_BOOSTER),
               [ITEMTYPE_CLOTHIER_MATERIAL]          = GetString(SI_ITEMTYPE0 + ITEMTYPE_CLOTHIER_MATERIAL),
               [ITEMTYPE_CLOTHIER_RAW_MATERIAL]      = GetString(SI_ITEMTYPE0 + ITEMTYPE_CLOTHIER_RAW_MATERIAL),
               [ITEMTYPE_COLLECTIBLE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_COLLECTIBLE),
               [ITEMTYPE_CONTAINER]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_CONTAINER),
               [ITEMTYPE_COSTUME]                    = GetString(SI_ITEMTYPE0 + ITEMTYPE_COSTUME),
               [ITEMTYPE_CROWN_ITEM]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_CROWN_ITEM),
               [ITEMTYPE_CROWN_REPAIR]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_CROWN_REPAIR),
               [ITEMTYPE_DEPRECATED]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_DEPRECATED),
               [ITEMTYPE_DISGUISE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_DISGUISE),
               [ITEMTYPE_DRINK]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_DRINK),
               [ITEMTYPE_DYE_STAMP]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_DYE_STAMP),
               [ITEMTYPE_ENCHANTING_RUNE_ASPECT]     = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_ASPECT),
               [ITEMTYPE_ENCHANTING_RUNE_ESSENCE]    = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
               [ITEMTYPE_ENCHANTING_RUNE_POTENCY]    = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_POTENCY),
               [ITEMTYPE_ENCHANTMENT_BOOSTER]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTMENT_BOOSTER),
               [ITEMTYPE_FISH]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_FISH),
               [ITEMTYPE_FLAVORING]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_FLAVORING),
               [ITEMTYPE_FOOD]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_FOOD),
               [ITEMTYPE_FURNISHING]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_FURNISHING),
               [ITEMTYPE_FURNISHING_MATERIAL]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_FURNISHING_MATERIAL),
               [ITEMTYPE_GLYPH_ARMOR]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_ARMOR),
               [ITEMTYPE_GLYPH_JEWELRY]              = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_JEWELRY),
               [ITEMTYPE_GLYPH_WEAPON]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_WEAPON),
               [ITEMTYPE_INGREDIENT]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_INGREDIENT),
               [ITEMTYPE_LOCKPICK]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_LOCKPICK),
               [ITEMTYPE_LURE]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_LURE),
               [ITEMTYPE_MASTER_WRIT]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_MASTER_WRIT),
               [ITEMTYPE_MOUNT]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_MOUNT),
               [ITEMTYPE_NONE]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_NONE),
               [ITEMTYPE_PLUG]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_PLUG),
               [ITEMTYPE_POISON]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_POISON),
               [ITEMTYPE_POISON_BASE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_POISON_BASE),
               [ITEMTYPE_POTION]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_POTION),
               [ITEMTYPE_POTION_BASE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_POTION_BASE),
               [ITEMTYPE_RACIAL_STYLE_MOTIF]         = GetString(SI_ITEMTYPE0 + ITEMTYPE_RACIAL_STYLE_MOTIF),
               [ITEMTYPE_RAW_MATERIAL]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_RAW_MATERIAL),
               [ITEMTYPE_REAGENT]                    = GetString(SI_ITEMTYPE0 + ITEMTYPE_REAGENT),
               [ITEMTYPE_RECIPE]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_RECIPE),
               [ITEMTYPE_SIEGE]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_SIEGE),
               [ITEMTYPE_SOUL_GEM]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_SOUL_GEM),
               [ITEMTYPE_SPELLCRAFTING_TABLET]       = GetString(SI_ITEMTYPE0 + ITEMTYPE_SPELLCRAFTING_TABLET),
               [ITEMTYPE_SPICE]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_SPICE),
               [ITEMTYPE_STYLE_MATERIAL]             = GetString(SI_ITEMTYPE0 + ITEMTYPE_STYLE_MATERIAL),
               [ITEMTYPE_TABARD]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_TABARD),
               [ITEMTYPE_TOOL]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_TOOL),
               [ITEMTYPE_TRASH]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_TRASH),
               [ITEMTYPE_TREASURE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_TREASURE),
               [ITEMTYPE_TROPHY]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_TROPHY),
               [ITEMTYPE_WEAPON]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON),
               [ITEMTYPE_WEAPON_BOOSTER]             = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON_BOOSTER),
               [ITEMTYPE_WEAPON_TRAIT]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON_TRAIT),
               [ITEMTYPE_WOODWORKING_BOOSTER]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_WOODWORKING_BOOSTER),
               [ITEMTYPE_WOODWORKING_MATERIAL]       = GetString(SI_ITEMTYPE0 + ITEMTYPE_WOODWORKING_MATERIAL),
               [ITEMTYPE_WOODWORKING_RAW_MATERIAL]   = GetString(SI_ITEMTYPE0 + ITEMTYPE_WOODWORKING_RAW_MATERIAL),
            },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.type == args[2]
         else
            return context.type ~= args[2]
         end
      end
   ),
   [8] = ConditionBase:new( -- Crafted
      _s(ITEMTRIG_STRING_CONDITIONNAME_CRAFTED),
      _s(ITEMTRIG_STRING_CONDITIONDESC_CRAFTED),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_CRAFTED_NO), [2] = _s(ITEMTRIG_STRING_OPCODEARG_CRAFTED_YES)} },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local isCrafted = (type(context.creator) == "string" and context.creator ~= "")
         if args[1] then
            return isCrafted
         end
         return not isCrafted
      end
   ),
   [9] = ConditionBase:new( -- Added Item Cause
      _s(ITEMTRIG_STRING_CONDITIONNAME_ADDEDITEMCAUSE),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ADDEDITEMCAUSE),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_YES)
            }
         },
         [2] = {
            type = "number",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_PURCHASED),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_MAILGIFT),
               [3] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_BANKWITHDRAWAL),
               [4] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_CRAFTING),
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context.entryPoint ~= ItemTrig.ENTRY_POINT_ITEM_ADDED then
            return false
         end
         local result = false
         if args[2] == 1 then
            result = context.entryPointData.purchased or false
         elseif args[2] == 2 then
            result = context.entryPointData.takenFromMail or false
         elseif args[2] == 3 then
            result = context.entryPointData.withdrawn or false
         elseif args[2] == 4 then
            result = context.entryPointData.crafting or false
         end
         if args[1] then
            return result
         end
         return not result
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      }
   ),
}
ItemTrig.countConditions = table.getn(ItemTrig.tableConditions)
for i = 1, ItemTrig.countConditions do
   ItemTrig.tableConditions[i].opcode = i
end

ItemTrig.TRIGGER_CONDITION_COMMENT = ItemTrig.tableConditions[1]