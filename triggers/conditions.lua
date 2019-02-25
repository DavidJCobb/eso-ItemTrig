if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local ItemInterface = ItemTrig.ItemInterface
local Set           = ItemTrig.Set

local _s = GetString

local ConditionBase = {}
ConditionBase.__index = ConditionBase
function ConditionBase:new(name, formatString, args, func, extra)
   return ItemTrig.OpcodeBase:new(name, formatString, args, func, extra)
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
               return false, ItemTrig.NO_OR_CONDITIONS_HIT
            end
         else
            state.using_or   = true
            state.matched_or = false
         end
         return nil
      end,
      {
         neverSkip = true,
      }
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
               [-1] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYSOLVENT),
               [-2] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYFOODORDRINK),
               [-3] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYGLYPH),
               [-4] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYRUNE),
               [-5] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYCRAFTMAT),
               [-6] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYTRAITMAT),
               [-7] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYUNREFINED),
               [-8] = GetString(ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYREFINED),
               --
               -- Some of the built-in categories below appear to be unused; UESP's 
               -- database lists zero items in the categories, and some of them appear 
               -- to have been scrapped (e.g. "enchanting boosters," which would've 
               -- been comparable to boosters in smithing; the functionality has been 
               -- incorporated into one of the three runestones). These unused 
               -- categories have been commented out; there is no point in letting 
               -- the player select them.
               --
               -- The exceptions I'm making are:
               --
               -- COSTUME
               --    Contains an obviously unused item named "WARDENCOSPREV," which 
               --    has a "missing" icon and no data.
               --
               -- PLUG
               --    Contains one item which is obviously an early version of glyphs, 
               --    and which has no Google hits outside of UESP's database.
               --
               -- Those are hidden as well.
               --
               --[ITEMTYPE_ADDITIVE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_ADDITIVE), -- Category is unused?
               [ITEMTYPE_ARMOR]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR),
               --[ITEMTYPE_ARMOR_BOOSTER]              = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR_BOOSTER),
               [ITEMTYPE_ARMOR_TRAIT]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_ARMOR_TRAIT),
               [ITEMTYPE_AVA_REPAIR]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_AVA_REPAIR),
               [ITEMTYPE_BLACKSMITHING_BOOSTER]      = GetString(SI_ITEMTYPE0 + ITEMTYPE_BLACKSMITHING_BOOSTER),
               [ITEMTYPE_BLACKSMITHING_MATERIAL]     = GetString(ITEMTRIG_STRING_ITEMTYPE_REFINEDMATSMITHING),
               [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = GetString(ITEMTRIG_STRING_ITEMTYPE_RAWMATSMITHING),
               [ITEMTYPE_CLOTHIER_BOOSTER]           = GetString(SI_ITEMTYPE0 + ITEMTYPE_CLOTHIER_BOOSTER),
               [ITEMTYPE_CLOTHIER_MATERIAL]          = GetString(ITEMTRIG_STRING_ITEMTYPE_REFINEDMATCLOTHING),
               [ITEMTYPE_CLOTHIER_RAW_MATERIAL]      = GetString(ITEMTRIG_STRING_ITEMTYPE_RAWMATCLOTHING),
               [ITEMTYPE_COLLECTIBLE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_COLLECTIBLE),
               [ITEMTYPE_CONTAINER]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_CONTAINER),
               --[ITEMTYPE_COSTUME]                    = GetString(SI_ITEMTYPE0 + ITEMTYPE_COSTUME),
               [ITEMTYPE_CROWN_ITEM]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_CROWN_ITEM),
               [ITEMTYPE_CROWN_REPAIR]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_CROWN_REPAIR),
               [ITEMTYPE_DEPRECATED]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_DEPRECATED),
               [ITEMTYPE_DISGUISE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_DISGUISE),
               [ITEMTYPE_DRINK]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_DRINK),
               [ITEMTYPE_DYE_STAMP]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_DYE_STAMP),
               [ITEMTYPE_ENCHANTING_RUNE_ASPECT]     = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_ASPECT),
               [ITEMTYPE_ENCHANTING_RUNE_ESSENCE]    = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
               [ITEMTYPE_ENCHANTING_RUNE_POTENCY]    = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTING_RUNE_POTENCY),
               --[ITEMTYPE_ENCHANTMENT_BOOSTER]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_ENCHANTMENT_BOOSTER),
               [ITEMTYPE_FISH]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_FISH),
               --[ITEMTYPE_FLAVORING]                  = GetString(SI_ITEMTYPE0 + ITEMTYPE_FLAVORING),
               [ITEMTYPE_FOOD]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_FOOD),
               [ITEMTYPE_FURNISHING]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_FURNISHING),
               [ITEMTYPE_FURNISHING_MATERIAL]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_FURNISHING_MATERIAL),
               [ITEMTYPE_GLYPH_ARMOR]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_ARMOR),
               [ITEMTYPE_GLYPH_JEWELRY]              = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_JEWELRY),
               [ITEMTYPE_GLYPH_WEAPON]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_GLYPH_WEAPON),
               [ITEMTYPE_INGREDIENT]                 = GetString(SI_ITEMTYPE0 + ITEMTYPE_INGREDIENT),
               [ITEMTYPE_JEWELRYCRAFTING_BOOSTER]      = GetString(SI_ITEMTYPE0 + ITEMTYPE_JEWELRYCRAFTING_BOOSTER),
               [ITEMTYPE_JEWELRYCRAFTING_MATERIAL]     = GetString(ITEMTRIG_STRING_ITEMTYPE_REFINEDMATJEWELRY),
               [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER]  = GetString(SI_ITEMTYPE0 + ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER),
               [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = GetString(ITEMTRIG_STRING_ITEMTYPE_RAWMATJEWELRY),
               [ITEMTYPE_JEWELRY_RAW_TRAIT]          = GetString(SI_ITEMTYPE0 + ITEMTYPE_JEWELRY_RAW_TRAIT),
               [ITEMTYPE_JEWELRY_TRAIT]              = GetString(SI_ITEMTYPE0 + ITEMTYPE_JEWELRY_TRAIT),
               --[ITEMTYPE_LOCKPICK]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_LOCKPICK),
               [ITEMTYPE_LURE]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_LURE),
               [ITEMTYPE_MASTER_WRIT]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_MASTER_WRIT),
               [ITEMTYPE_MOUNT]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_MOUNT),
               --[ITEMTYPE_NONE]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_NONE),
               --[ITEMTYPE_PLUG]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_PLUG),
               [ITEMTYPE_POISON]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_POISON),
               [ITEMTYPE_POISON_BASE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_POISON_BASE),
               [ITEMTYPE_POTION]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_POTION),
               [ITEMTYPE_POTION_BASE]                = GetString(SI_ITEMTYPE0 + ITEMTYPE_POTION_BASE),
               [ITEMTYPE_RACIAL_STYLE_MOTIF]         = GetString(SI_ITEMTYPE0 + ITEMTYPE_RACIAL_STYLE_MOTIF),
               [ITEMTYPE_RAW_MATERIAL]               = GetString(ITEMTRIG_STRING_ITEMTYPE_RAWSTYLEMATERIAL),
               [ITEMTYPE_REAGENT]                    = GetString(SI_ITEMTYPE0 + ITEMTYPE_REAGENT),
               [ITEMTYPE_RECIPE]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_RECIPE),
               [ITEMTYPE_SIEGE]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_SIEGE),
               [ITEMTYPE_SOUL_GEM]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_SOUL_GEM),
               --[ITEMTYPE_SPELLCRAFTING_TABLET]       = GetString(SI_ITEMTYPE0 + ITEMTYPE_SPELLCRAFTING_TABLET),
               --[ITEMTYPE_SPICE]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_SPICE),
               [ITEMTYPE_STYLE_MATERIAL]             = GetString(SI_ITEMTYPE0 + ITEMTYPE_STYLE_MATERIAL),
               [ITEMTYPE_TABARD]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_TABARD), -- Only used for one item: the Guild Tabard, which lets you wear your guild's heraldry crest
               [ITEMTYPE_TOOL]                       = GetString(SI_ITEMTYPE0 + ITEMTYPE_TOOL), -- includes non-crown repair kits
               [ITEMTYPE_TRASH]                      = GetString(SI_ITEMTYPE0 + ITEMTYPE_TRASH),
               [ITEMTYPE_TREASURE]                   = GetString(SI_ITEMTYPE0 + ITEMTYPE_TREASURE),
               [ITEMTYPE_TROPHY]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_TROPHY),
               [ITEMTYPE_WEAPON]                     = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON),
               --[ITEMTYPE_WEAPON_BOOSTER]             = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON_BOOSTER),
               [ITEMTYPE_WEAPON_TRAIT]               = GetString(SI_ITEMTYPE0 + ITEMTYPE_WEAPON_TRAIT),
               [ITEMTYPE_WOODWORKING_BOOSTER]        = GetString(SI_ITEMTYPE0 + ITEMTYPE_WOODWORKING_BOOSTER),
               [ITEMTYPE_WOODWORKING_MATERIAL]       = GetString(ITEMTRIG_STRING_ITEMTYPE_REFINEDMATWOODWORKING),
               [ITEMTYPE_WOODWORKING_RAW_MATERIAL]   = GetString(ITEMTRIG_STRING_ITEMTYPE_RAWMATWOODWORKING),
            },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.type == args[2]
         if args[2] < 0 then -- Custom categories -- generally, aggregates of multiple built-ins.
            local t = context.type
            result = false
            if args[2] == -1 then -- any alchemy solvent
               result = (t == ITEMTYPE_POISON_BASE) or (t == ITEMTYPE_POTION_BASE)
            elseif args[2] == -2 then -- any food or drink
               result = (t == ITEMTYPE_FOOD) or (t == ITEMTYPE_DRINK)
            elseif args[2] == -3 then -- any enchanting glyph
               result = (t == ITEMTYPE_GLYPH_ARMOR) or (t == ITEMTYPE_GLYPH_JEWELRY) or (t == ITEMTYPE_GLYPH_WEAPON)
            elseif args[2] == -4 then -- any enchanting rune
               result = (t == ITEMTYPE_ENCHANTING_RUNE_ASPECT) or (t == ITEMTYPE_ENCHANTING_RUNE_ESSENCE) or (t == ITEMTYPE_ENCHANTING_RUNE_POTENCY)
            elseif args[2] == -5 then -- any crafting material
               if result == ITEMTYPE_ARMOR_TRAIT
               or result == ITEMTYPE_BLACKSMITHING_BOOSTER
               or result == ITEMTYPE_BLACKSMITHING_MATERIAL
               or result == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
               or result == ITEMTYPE_CLOTHIER_BOOSTER
               or result == ITEMTYPE_CLOTHIER_MATERIAL
               or result == ITEMTYPE_CLOTHIER_RAW_MATERIAL
               or result == ITEMTYPE_ENCHANTING_RUNE_ASPECT
               or result == ITEMTYPE_ENCHANTING_RUNE_ESSENCE
               or result == ITEMTYPE_ENCHANTING_RUNE_POTENCY
               or result == ITEMTYPE_FURNISHING_MATERIAL
               or result == ITEMTYPE_INGREDIENT
               or result == ITEMTYPE_JEWELRYCRAFTING_BOOSTER
               or result == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
               or result == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER
               or result == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL
               or result == ITEMTYPE_JEWELRY_RAW_TRAIT
               or result == ITEMTYPE_JEWELRY_TRAIT
               or result == ITEMTYPE_POISON_BASE
               or result == ITEMTYPE_POTION_BASE
               or result == ITEMTYPE_RAW_MATERIAL
               or result == ITEMTYPE_REAGENT
               or result == ITEMTYPE_WEAPON_TRAIT
               or result == ITEMTYPE_WOODWORKING_BOOSTER
               or result == ITEMTYPE_WOODWORKING_MATERIAL
               or result == ITEMTYPE_WOODWORKING_RAW_MATERIAL
               then
                  result = true
               end
            elseif args[2] == -6 then -- any trait material
               if result == ITEMTYPE_ARMOR_TRAIT
               or result == ITEMTYPE_JEWELRY_TRAIT
               or result == ITEMTYPE_WEAPON_TRAIT
               then
                  result = true
               end
            elseif args[2] == -7 then -- any unrefined material
               if result == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
               or result == ITEMTYPE_CLOTHIER_RAW_MATERIAL
               or result == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER
               or result == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL
               or result == ITEMTYPE_JEWELRY_RAW_TRAIT
               or result == ITEMTYPE_WOODWORKING_RAW_MATERIAL
               or result == ITEMTYPE_RAW_MATERIAL -- raw style material
               then
                  result = true
               end
            elseif args[2] == -8 then -- any refined material
               if result == ITEMTYPE_BLACKSMITHING_MATERIAL
               or result == ITEMTYPE_CLOTHIER_MATERIAL
               or result == ITEMTYPE_JEWELRYCRAFTING_BOOSTER
               or result == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
               or result == ITEMTYPE_JEWELRY_TRAIT
               or result == ITEMTYPE_WOODWORKING_MATERIAL
               then
                  result = true
               end
            end
         end
         if args[1] then
            return result
         else
            return not result
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
            },
            disabledEnumIndices = Set:new({
               --
               -- If changing this, update the trigger gallery as well.
               --
               3, -- Feb. 20 2019: API limitations prevent us from responding to bank withdrawals unless we also respond to stack splits, which we really super definitely don't want
            }),
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
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
   [10] = ConditionBase:new( -- Added Item Is New Stack
      _s(ITEMTRIG_STRING_CONDITIONNAME_ADDEDITEMISNEWSTACK),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ADDEDITEMISNEWSTACK),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMISNEWSTACK_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ADDEDITEMISNEWSTACK_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.entryPointData.countAdded == context.count
         if args[1] then
            return result
         end
         return not result
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      }
   ),
   [11] = ConditionBase:new( -- Total Count
      _s(ITEMTRIG_STRING_CONDITIONNAME_TOTALCOUNT),
      _s(ITEMTRIG_STRING_CONDITIONDESC_TOTALCOUNT),
      {
         [1] = {
            type = "number",
            enum = {
               [BAG_BACKPACK]        = _s(ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_BACKPACK),
               [BAG_BANK]            = _s(ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_BANK),
               [BAG_SUBSCRIBER_BANK] = _s(ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_CRAFTBAG),
            }
         },
         [2] = { type = "quantity" },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local count = context:totalForBag(args[1])
         if not count then
            return ItemTrig.OPCODE_FAILED, {}
         end
         return ItemTrig.testQuantity(args[2], count)
      end
   ),
   [12] = ConditionBase:new( -- Item Name
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMNAME),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMNAME),
      {
         [1] = {
            type = "string",
            placeholder = "name",
            autocompleteSet =
               function()
                  ItemTrig.gameEnums.commonItems:generate()
                  return ItemTrig.gameEnums.commonItems
               end,
         },
         [2] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMNAME_WHOLE),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMNAME_SUBSTRING)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local name = context.formattedName or context.name
         if not name then
            return false
         end
         local stub = args[1]
         if not stub then
            return false
         end
         name = name:lower()
         stub = stub:lower()
         if args[2] then
            return name:find(stub) ~= nil
         else
            return name == stub
         end
      end
   ),
   [13] = ConditionBase:new( -- Can Be Researched
      _s(ITEMTRIG_STRING_CONDITIONNAME_CANBERESEARCHED),
      _s(ITEMTRIG_STRING_CONDITIONDESC_CANBERESEARCHED),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_CANBERESEARCHED_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_CANBERESEARCHED_YES)
            },
            default = true,
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local researchable = context.isResearchable
         if args[1] then
            return researchable
         end
         return not researchable
      end
   ),
   [14] = ConditionBase:new( -- Creator Name
      _s(ITEMTRIG_STRING_CONDITIONNAME_CREATORNAME),
      _s(ITEMTRIG_STRING_CONDITIONDESC_CREATORNAME),
      {
         [1] = { type = "string", placeholder = "name" },
         [2] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_CREATORNAME_WHOLE),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_CREATORNAME_SUBSTRING)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local name = context.creator
         local stub = tostring(args[1] or "")
         if args[2] then
            return name:find(stub) ~= nil
         else
            if stub == "$(player)" then
               --
               -- TODO: Document this.
               --
               stub = GetUnitName("player")
            end
            return name:lower() == stub:lower()
         end
      end
   ),
   [15] = ConditionBase:new( -- Locked
      _s(ITEMTRIG_STRING_CONDITIONNAME_LOCKED),
      _s(ITEMTRIG_STRING_CONDITIONDESC_LOCKED),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_LOCKED_NO), [2] = _s(ITEMTRIG_STRING_OPCODEARG_LOCKED_YES)} },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.locked
         end
         return not context.locked
      end
   ),
   [16] = ConditionBase:new( -- Junk
      _s(ITEMTRIG_STRING_CONDITIONNAME_JUNK),
      _s(ITEMTRIG_STRING_CONDITIONDESC_JUNK),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_JUNK_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_JUNK_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.hasJunkFlag
         end
         return not context.hasJunkFlag
      end
   ),
   [17] = ConditionBase:new( -- Item Style
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMSTYLE),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMSTYLE),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_YES)
            }
         },
         [2] = {
            type = "number",
            default = ITEMTYPE_TREASURE,
            enum =
               (function()
                  local e = ItemTrig.assign({
                     [-1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYALLIANCE),
                     [-2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYRACIAL),
                     [-3] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYNONSTYLE),
                     --
                     -- Pull the enum of all equipment styles, and add in some 
                     -- special checks indicated by indices below zero.
                     --
                  }, ItemTrig.gameEnums.styles)
                  e[ITEMSTYLE_NONE] = nil
                  return e
               end)(),
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = false
         do -- compare item style
            if args[2] >= 0 then
               result = context.style == args[2]
            else
               --
               -- We use negative numbers to denote checks with custom 
               -- logic.
               --
               local cs = context.style
               if args[2] == -1 then -- any alliance style
                  if cs == ITEMSTYLE_ALLIANCE_ALDMERI
                  or cs == ITEMSTYLE_ALLIANCE_DAGGERFALL
                  or cs == ITEMSTYLE_ALLIANCE_EBONHEART
                  then
                     result = true
                  end
               elseif args[2] == -2 then -- any racial style
                  if cs == ITEMSTYLE_RACIAL_ARGONIAN
                  or cs == ITEMSTYLE_RACIAL_BRETON
                  or cs == ITEMSTYLE_RACIAL_DARK_ELF
                  or cs == ITEMSTYLE_RACIAL_HIGH_ELF
                  or cs == ITEMSTYLE_RACIAL_IMPERIAL
                  or cs == ITEMSTYLE_RACIAL_KHAJIIT
                  or cs == ITEMSTYLE_RACIAL_NORD
                  or cs == ITEMSTYLE_RACIAL_ORC
                  or cs == ITEMSTYLE_RACIAL_REDGUARD
                  or cs == ITEMSTYLE_RACIAL_WOOD_ELF
                  then
                     result = true
                  end
               elseif args[2] == -3 then -- not actually a style
                  if cs == ITEMSTYLE_NONE
                  or cs == ITEMSTYLE_UNIQUE ----- used for extremely rare furnishings, deprecated items, and developer test items
                  or cs == ITEMSTYLE_UNIVERSAL -- unclear, but seems to include soul gems, instant research scrolls, repair kits, and the like
                  then
                     result = true
                  end
               end
            end
         end
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [18] = ConditionBase:new( -- Alchemy Effects (Known)
      _s(ITEMTRIG_STRING_CONDITIONNAME_ALCHEMYEFFECTS),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ALCHEMYEFFECTS),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ALCHEMYEFFECTS_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ALCHEMYEFFECTS_YES)
            }
         },
         [2] = {
            type = "number",
            enum = ItemTrig.gameEnums.alchemyEffectStrings,
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = false
         do -- check
            local traits = context.alchemyTraits
            local target = ItemTrig.gameEnums.alchemyEffectStrings[args[2] or -1] or ""
            target = target:lower()
            for i = 1, #traits do
               local n = traits[i].name
               if n and n:lower() == target then
                  result = true
                  break
               end
            end
         end
         if args[1] then
            return result
         end
         return not result
      end,
      {
         explanation = _s(ITEMTRIG_STRING_CONDITIONEXPLANATION_ALCHEMYEFFECTS),
      }
   ),
   [19] = ConditionBase:new( -- Log Trigger Miss
      _s(ITEMTRIG_STRING_CONDITIONNAME_LOGTRIGGERMISS),
      _s(ITEMTRIG_STRING_CONDITIONDESC_LOGTRIGGERMISS),
      {},
      function(state, context, args)
         return nil, ItemTrig.PLEASE_LOG_TRIG_MISS
      end,
      {
         explanation = _s(ITEMTRIG_STRING_CONDITIONEXPLANATION_LOGTRIGGERMISS),
         neverSkip   = true,
      }
   ),
   [20] = ConditionBase:new( -- Priority Sell
      _s(ITEMTRIG_STRING_CONDITIONNAME_PRIORITYSELL),
      _s(ITEMTRIG_STRING_CONDITIONDESC_PRIORITYSELL),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.isPrioritySell
         end
         return not context.isPrioritySell
      end
   ),
   [21] = ConditionBase:new( -- Is Crown Item
      _s(ITEMTRIG_STRING_CONDITIONNAME_CROWNITEM),
      _s(ITEMTRIG_STRING_CONDITIONDESC_CROWNITEM),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_CROWNITEM_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_CROWNITEM_YES)
            }
         },
         [2] = {
            type = "number",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_CROWNITEM_STORE),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_CROWNITEM_CRATE),
               [3] = _s(ITEMTRIG_STRING_OPCODEARG_CROWNITEM_ANY),
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result
         do
            if args[2] == 1 then
               result = context.isCrownStoreItem
            elseif args[2] == 2 then
               result = context.isCrownCrateItem
            elseif args[2] == 3 then
               result = context.isCrownCrateItem or context.isCrownStoreItem
            end
         end
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [22] = ConditionBase:new( -- Enlightened
      _s(ITEMTRIG_STRING_CONDITIONNAME_ENLIGHTENED),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ENLIGHTENED),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ENLIGHTENED_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ENLIGHTENED_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = IsEnlightenedAvailableForCharacter() and GetEnlightenedPool() > 0
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [23] = ConditionBase:new( -- Ornate
      _s(ITEMTRIG_STRING_CONDITIONNAME_ORNATE),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ORNATE),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ORNATE_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ORNATE_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.specialTrait == ITEM_TRAIT_INFORMATION_ORNATE
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [24] = ConditionBase:new( -- Intricate
      _s(ITEMTRIG_STRING_CONDITIONNAME_INTRICATE),
      _s(ITEMTRIG_STRING_CONDITIONDESC_INTRICATE),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_INTRICATE_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_INTRICATE_YES)
            }
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.specialTrait == ITEM_TRAIT_INFORMATION_INTRICATE
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [25] = ConditionBase:new( -- Item Trait, Armor
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_ARMOR),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_ARMOR),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_YES)
            }
         },
         [2] = {
            type = "number",
            default = ITEM_TRAIT_TYPE_NONE,
            enum =
               {
                  [ITEM_TRAIT_TYPE_NONE]               = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_NONE),
                  [ITEM_TRAIT_TYPE_ARMOR_DIVINES]      = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_DIVINES),
                  [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE),
                  [ITEM_TRAIT_TYPE_ARMOR_INFUSED]      = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_INFUSED),
                  [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]    = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
                  [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]    = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_NIRNHONED),
                  [ITEM_TRAIT_TYPE_ARMOR_ORNATE]       = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_ORNATE),
                  [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS),
                  [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_REINFORCED),
                  [ITEM_TRAIT_TYPE_ARMOR_STURDY]       = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_STURDY),
                  [ITEM_TRAIT_TYPE_ARMOR_TRAINING]     = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_TRAINING),
                  [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED),
               },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.trait == args[2]
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [26] = ConditionBase:new( -- Item Trait, Jewelry
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_JEWELRY),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_JEWELRY),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_YES)
            }
         },
         [2] = {
            type = "number",
            default = ITEM_TRAIT_TYPE_NONE,
            enum =
               {
                  [ITEM_TRAIT_TYPE_NONE]            = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_NONE),
                  [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_JEWELRY_ARCANE),
                  [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_JEWELRY_HEALTHY),
                  [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_JEWELRY_ORNATE),
                  [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_JEWELRY_ROBUST),
               },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.trait == args[2]
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [27] = ConditionBase:new( -- Item Trait, Weapon
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_WEAPON),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_WEAPON),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_YES)
            }
         },
         [2] = {
            type = "number",
            default = ITEM_TRAIT_TYPE_NONE,
            enum =
               {
                  [ITEM_TRAIT_TYPE_NONE]             = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_NONE),
                  [ITEM_TRAIT_TYPE_WEAPON_CHARGED]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_CHARGED),
                  [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_DECISIVE),
                  [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_DEFENDING),
                  [ITEM_TRAIT_TYPE_WEAPON_INFUSED]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_INFUSED),
                  [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
                  [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_NIRNHONED),
                  [ITEM_TRAIT_TYPE_WEAPON_ORNATE]    = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_ORNATE),
                  [ITEM_TRAIT_TYPE_WEAPON_POWERED]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_POWERED),
                  [ITEM_TRAIT_TYPE_WEAPON_PRECISE]   = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_PRECISE),
                  [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_SHARPENED),
                  [ITEM_TRAIT_TYPE_WEAPON_TRAINING]  = GetString(SI_ITEMTRAITTYPE0 + ITEM_TRAIT_TYPE_WEAPON_TRAINING), 
               },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = context.trait == args[2]
         if args[1] then
            return result
         end
         return not result
      end
   ),
   [28] = ConditionBase:new( -- Item Filter
      _s(ITEMTRIG_STRING_CONDITIONNAME_ITEMFILTER),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ITEMFILTER),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMFILTER_NO),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_ITEMFILTER_YES)
            }
         },
         [2] = {
            type = "number",
            default = ITEMFILTERTYPE_ALL,
            enum =
               {
                  [ITEMFILTERTYPE_ALCHEMY]             = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALCHEMY),
                  [ITEMFILTERTYPE_ALL]                 = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL),
                  [ITEMFILTERTYPE_ARMOR]               = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR),
                  [ITEMFILTERTYPE_BLACKSMITHING]       = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BLACKSMITHING),
                  [ITEMFILTERTYPE_CLOTHING]            = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CLOTHING),
                  [ITEMFILTERTYPE_COLLECTIBLE]         = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COLLECTIBLE),
                  [ITEMFILTERTYPE_CONSUMABLE]          = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CONSUMABLE),
                  [ITEMFILTERTYPE_CRAFTING]            = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CRAFTING),
                  [ITEMFILTERTYPE_DAMAGED]             = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_DAMAGED),
                  [ITEMFILTERTYPE_ENCHANTING]          = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ENCHANTING),
                  [ITEMFILTERTYPE_FURNISHING]          = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_FURNISHING),
                  [ITEMFILTERTYPE_JEWELRYCRAFTING]     = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRYCRAFTING),
                  [ITEMFILTERTYPE_JUNK]                = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JUNK),
                  [ITEMFILTERTYPE_MISCELLANEOUS]       = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MISCELLANEOUS),
                  [ITEMFILTERTYPE_PROVISIONING]        = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_PROVISIONING),
                  --[ITEMFILTERTYPE_QUEST]               = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_QUEST),
                  [ITEMFILTERTYPE_QUICKSLOT]           = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_QUICKSLOT),
                  [ITEMFILTERTYPE_STYLE_MATERIALS]     = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_STYLE_MATERIALS),
                  [ITEMFILTERTYPE_TRAIT_ITEMS]         = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_TRAIT_ITEMS),
                  [ITEMFILTERTYPE_WEAPONS]             = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS),
                  [ITEMFILTERTYPE_WOODWORKING]         = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WOODWORKING),
               },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         local result = false
         for i = 1, #context.itemFilters do
            if context.itemFilters[i] == args[2] then
               result = true
               break
            end
         end
         if args[1] then
            return result
         end
         return not result
      end
   ),
}
ItemTrig.countConditions = #ItemTrig.tableConditions
for i = 1, ItemTrig.countConditions do
   ItemTrig.tableConditions[i].opcode = i
end

ItemTrig.TRIGGER_CONDITION_COMMENT = ItemTrig.tableConditions[1]