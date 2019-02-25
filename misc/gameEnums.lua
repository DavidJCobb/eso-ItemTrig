ItemTrig.gameEnums = {}

ItemTrig.gameEnums.alchemyEffectStrings = {
   [-1] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_BREACH),
   [-2] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_COWARDICE),
   [-3] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_DEFILE),
   [-4] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_DETECTION),
   [-5] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_ENERVATION),
   [-6] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_ENTRAPMENT),
   [-7] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_FRACTURE),
   [-8] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_GRADUALRAVAGEHEALTH),
   [-9] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_HINDRANCE),
   [-10] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASEARMOR),
   [-11] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASESPELLRESIST),
   [-12] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASEWEAPONPOWER),
   [-13] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_INVISIBLE),
   [-14] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_LINGERINGHEALTH),
   [-15] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_MAIM),
   [-16] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_PROTECTION),
   [-17] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGEHEALTH),
   [-18] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGEMAGICKA),
   [-19] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGESTAMINA),
   [-20] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RESTOREHEALTH),
   [-21] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RESTOREMAGICKA),
   [-22] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_RESTORESTAMINA),
   [-23] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_SPEED),
   [-24] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_SPELLCRITICAL),
   [-25] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_UNCERTAINTY),
   [-26] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_UNSTOPPABLE),
   [-27] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_VITALITY),
   [-28] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_VULNERABILITY),
   [-29] = GetString(ITEMTRIG_STRING_ALCHEMYEFFECT_WEAPONCRITICAL),
}

do
   local styles = {}
   for i = 1, GetNumValidItemStyles() do
      local id   = GetValidItemStyleId(i)
      styles[id] = GetItemStyleName(id)
   end
   ItemTrig.gameEnums.styles = styles
end

ItemTrig.gameEnums.commonItems = {}
do
   local wasGenerated = false
   local ids = {
      -- Alchemy Reagents
      77583, -- Beetle Scuttle
      30157, -- Blessed Thistle
      30148, -- Blue Entoloma
      30160, -- Bugloss
      77585, -- Butterfly Wing
      139020, -- Clam Gall
      30164, -- Columbine
      30161, -- Corn Flower
      30162, -- Dragonthorn
      30151, -- Emetic Russula
      77587, -- Fleshfly Larva
      30156, -- Imp Stool
      30158, -- Lady's Smock
      30155, -- Luminous Russula
      30163, -- Mountain Flower
      77591, -- Mudcrab Chitin
      30153, -- Namira's Rot
      77590, -- Nightshade
      30165, -- Nirnroot
      139019, -- Powdered Mother of Pearl
      77589, -- Scrib Jelly
      77584, -- Spider Egg
      30149, -- Stinkhorn
      77581, -- Torchbug Thorax
      30152, -- Violet Coprinus
      30166, -- Water Hyacinth
      30154, -- White Cap
      30159, -- Wormwood
      -- Alliance War Repair Kit
      142133, -- Bridge and Milegate Repair Kit
       27962, -- Keep Door Woodwork Repair Kit
       27138, -- Keep Wall Masonry Repair Kit
       43056, -- Practice Siege Repair Kit
       27112, -- Siege Repair Kit
      -- Blacksmithing Boosters
      54170, -- Honing Stone
      54171, -- Dwarven Oil
      54172, -- Grain Solvent
      54173, -- Tempering Alloy
      -- Blacksmithing Materials, Refined
       5413, -- Iron Ingot
       4487, -- Steel Ingot
      23107, -- Orichalcum Ingot
       6000, -- Dwarven Ingot
       6001, -- Ebony Ingot
      46127, -- Calcinium Ingot
      46128, -- Galatite Ingot
      46129, -- Quicksilver Ingot
      46130, -- Voidstone Ingot
      64489, -- Rubedite Ingot
      -- Blacksmithing Materials, Raw
        808, -- Iron Ore
       5820, -- High Iron Ore (Steel)
      23103, -- Orichalcum Ore
      23104, -- Dwarven Ore
      23105, -- Ebony Ore
       4482, -- Calcinium Ore
      23133, -- Galatite Ore
      23134, -- Quicksilver Ore
      23135, -- Voidstone Ore
      71198, -- Rubedite Ore
      -- Clothier Boosters
      54174, -- Hemming
      54175, -- Embroidery
      54176, -- Elegant Lining
      54177, -- Dreugh Wax
      -- Clothier Materials, Refined
        794, -- Rawhide
        811, -- Jute
       4447, -- Hide
       4463, -- Flax
      23099, -- Leather
      23100, -- Thick Leather
      23101, -- Fell Hide
      23125, -- Cotton
      23126, -- Spidersilk
      23127, -- Ebonthread
      46131, -- Kresh Fiber
      46132, -- Ironthread
      46133, -- Silverweave
      46134, -- Void Cloth
      46135, -- Topgrain Hide
      46136, -- Iron Hide
      46137, -- Superb Hide
      46138, -- Shadowhide
      64504, -- Ancestor Silk
      64506, -- Rubedo Leather
      -- Clothier Material, Raw
        793, -- Rawhide Scraps
        800, -- Superb Hide Scraps
        812, -- Raw Jute
       4448, -- Hide Scraps
       4464, -- Raw Flax
       4478, -- Shadowhide Scraps
       6020, -- Thick Leather Scraps
      23095, -- Leather Scraps
      23097, -- Fell Hide Scraps
      23129, -- Raw Cotton
      23130, -- Raw Spidersilk
      23131, -- Raw Ebonthread
      23142, -- Topgrain Hide Scraps
      23143, -- Iron Hide Scraps
      33217, -- Raw Kreshweed
      33218, -- Raw Ironweed
      33219, -- Raw Silverweed
      33220, -- Raw Void Bloom
      71200, -- Raw Ancestor Silk
      71239, -- Rubedo Hide Scraps
      -- Enchanting Runes, Aspect
      45850, -- Ta
      45851, -- Jejota
      45852, -- Denata
      45853, -- Rekuta
      45854, -- Kuta
      -- Enchanting Runes, Essence
      45839, -- Dekeipa
      45833, -- Deni
      45836, -- Denima
      45842, -- Deteri
      68342, -- Hakeijo
      45841, -- Haoko
      45844, -- Jaedi
      45849, -- Kaderi
      45837, -- Kuoko
      45845, -- Lire
      45848, -- Makderi
      45832, -- Makko
      45835, -- Makkoma
      45840, -- Meip
      45831, -- Oko
      45834, -- Okoma
      45843, -- Okori
      45846, -- Oru
      45838, -- Rakeipa
      45847, -- Taderi
      -- Enchanting Runes, Potency
      45812, -- Denara
      45814, -- Derado
      45822, -- Edode
      45809, -- Edora
      45825, -- Hade
      45826, -- Idode
      68340, -- Itade
      45810, -- Jaera
      45821, -- Jayde
      64508, -- Jehade
      45806, -- Jejora
      45857, -- Jera
      45817, -- Jode
      45855, -- Jora
      45828, -- Kedeko
      45830, -- Kude
      45816, -- Kura
      45818, -- Notade
      45819, -- Ode
      45807, -- Odra
      45827, -- Pode
      45823, -- Pojode
      45808, -- Pojora
      45811, -- Pora
      45856, -- Porade
      45829, -- Rede
      64509, -- Rejera
      45824, -- Rekude
      45815, -- Rekuda
      68341, -- Repora
      45813, -- Rera
      45820, -- Tade
      -- Furnishing Materials
      114893, -- Alchemical Resin
      114890, -- Bast
      114891, -- Clean Pelt
      114894, -- Decorative Wax
      126581, -- Dwarven Construct Repair Parts
      114895, -- Heartwood
      114892, -- Mundane Rune
      135161, -- Ochre
      114889, -- Regulus
      -- Ingredients
      34349, -- Acai Berry
      115026, -- Aetherial Dust
      120894, -- Animus Stone
      34311, -- Apples
      33755, -- Bananas
      34329, -- Barley
      34309, -- Beets
      27059, -- Bervez Juice
      34334, -- Bittergreen
      34324, -- Carrots
      27057, -- Cheese
      33772, -- Coffee
      33768, -- Comberry
      34323, -- Corn
      120078, -- Diminished Aetherial Dust
      33753, -- Fish
      27100, -- Flour
      26802, -- Frost Mirriam
      28609, -- Game
      26954, -- Garlic
      27052, -- Ginger
      34346, -- Ginkgo
      34347, -- Ginseng
      28604, -- Greens
      34333, -- Guarana
      27043, -- Honey
      27035, -- Isinglass
      33771, -- Jasmine
      28610, -- Jazbay Grapes
      27049, -- Lemon
      34330, -- Lotus
      34308, -- Melon
      27048, -- Metheglin
      27064, -- Millet
      33773, -- Mint
      64222, -- Perfect Roe
      33758, -- Potato
      34321, -- Poultry
      34305, -- Pumpkin
      34307, -- Radish
      33752, -- Red Meat
      29030, -- Rice
      28636, -- Rose
      28639, -- Rye
      27063, -- Saltrice
      27058, -- Seasoning
      28666, -- Seaweed
      33756, -- Small Game
      34345, -- Surilie Grapes
      28603, -- Tomato
      34348, -- Wheat
      33754, -- White Meat
      33774, -- Yeast
      34335, -- Yerba Mate
      -- Jewelry Boosters
      135147, -- Terne Plating
      135148, -- Iridium Plating
      135149, -- Zircon Plating
      135150, -- Chromium Plating
      -- Jewelry Booster, Raw
      135151, -- Terne Grains
      135152, -- Iridium Grains
      135153, -- Zircon Grains
      135154, -- Chromium Grains
      -- Jewelry Material, Refined
      135138, -- Pewter Ounce
      135140, -- Copper Ounce
      135142, -- Silver Ounce
      135144, -- Electrum Ounce
      135146, -- Platinum Ounce
      -- Jewelry Material, Raw
      135137, -- Pewter Dust
      135139, -- Copper Dust
      135141, -- Silver Dust
      135143, -- Electrum Dust
      135145, -- Platinum Dust
      -- Jewelry Trait Material, Raw
      135159, -- Pulverized Antimony
      139417, -- Pulverized Aurbic Amber
      135158, -- Pulverized Cobalt
      139415, -- Pulverized Dawn-Prism
      139419, -- Pulverized Dibellium
      139418, -- Pulverized Gilding Wax
      139420, -- Pulverized Slaughterstone
      139416, -- Pulverized Titanium
      135160, -- Pulverized Zinc
      -- Jewelry Trait Material, Refined
      135156, -- Antimony
      139411, -- Aurbic Amber
      135155, -- Cobalt
      139409, -- Dawn-Prism
      139413, -- Dibellium
      139412, -- Gilding Wax
      139414, -- Slaughterstone
      139410, -- Titanium
      135157, -- Zinc
      -- Fishing Lures
      42875, -- Chub
      42871, -- Crawlers
      42873, -- Fish Roe
      42870, -- Guts
      42872, -- Insect Parts
      42876, -- Minnow
      42874, -- Shad
      42877, -- Simple Bait
      42869, -- Worms
      -- Poison Solvents
      75365, -- Alkahest
      75360, -- Gall
      75357, -- Grease
      75358, -- Ichor
      75364, -- Night-Oil
      75362, -- Pitch-Bile
      75359, -- Slime
      75363, -- Tarblack
      75361, -- Terebinthine
      -- Potion Solvents
      23265, -- Cleansed Water
       1187, -- Clear Water
      23268, -- Cloud Mist
      23266, -- Filtered Water
      64501, -- Lorkhan's Tears
        883, -- Natural Water
       4570, -- Pristine Water
      23267, -- Purified Water
      64500, -- Star Dew
      -- Style Materials
      33252, -- Adamantite
      82000, -- Amber Marble
      71736, -- Ancient Sandstone
      141821, -- Argent Pelt
      46150, -- Argentum
      125476, -- Ash Canvas
      71582, -- Auric Tusk
      71766, -- Azure Plasm
      137955, -- Battlemage Style Item NAME ME
      79304, -- Black Beeswax
      132620, -- Bloodroot Flux
      141820, -- Bloodscent Dew
      79305, -- Boiled Carapace
      33194, -- Bone
      46149, -- Bronze
      69555, -- Cassiterite
      59922, -- Charcoal of Remorse
      33256, -- Corundum
      145532, -- Crocodile Leather
      71668, -- Crown Mimic Stone
      137953, -- Culanda Lacquer
      46151, -- Daedra Heart
      79672, -- Defiled Whiskers
      134798, -- Desecrated Grave Soil
      114983, -- Distilled Slowsilver
      137958, -- Dragon Bone
      71740, -- Dragon Scute
      57587, -- Dwemer Frame
      71738, -- Eagle Feather
      64685, -- Ferrous Salts
      75370, -- Fine Chalk
      33150, -- Flint
      64687, -- Goldscale
      82002, -- Grinstones
      141740, -- Gryphon Plume
      145533, -- Hackwing Plumage
      137961, -- Infected Flesh
      64713, -- Laurel
      114984, -- Leviathan Scrimshaw
      71742, -- Lion Fang
      121520, -- Lustrous Sphalerite
      64689, -- Malachite
      33257, -- Manganese
      132619, -- Minotaur Bezoar
      33251, -- Molybdenum
      33255, -- Moonstone
      33254, -- Nickel
      82004, -- Night Pumice
      33253, -- Obsidian
      81994, -- Oxblood Fungus
      46152, -- Palladium
      81996, -- Pearl Sand
      130061, -- Polished Rivets
      130060, -- Polished Scarab Elytra
      76914, -- Polished Shilling
      71584, -- Potash
      75373, -- Pristine Shroud
      130059, -- Refined Bonemold Resin
      71538, -- Rogue's Soot
      140267, -- Sea Serpent Hide
      134687, -- Snake Fang
      114283, -- Stalhrim Shard
      81998, -- Star Sapphire
      33258, -- Starmetal
      76910, -- Tainted Blood
      138813, -- TEMP
      132617, -- Tempered Brass
      132618, -- Tenebrous Cord
      137951, -- Vitrified Malondo
      121518, -- Volcanic Viridian
      137957, -- Warrior's Heart Ashes
      96388, -- Wolfsbane Incense
      121519, -- Wrought Ferrofungus
      -- Tool
      30357, -- Lockpick
      44874, -- Petty Repair Kit
      44875, -- Minor Repair Kit
      44876, -- Lesser Repair Kit
      44877, -- Common Repair Kit
      44878, -- Greater Repair Kit
      44879, -- Grand Repair Kit
      -- Trait Material, Armor
      23221, -- Almandine
      30219, -- Bloodstone
      23219, -- Diamond
       4442, -- Emerald
      56862, -- Fortified Nirncrux
      23171, -- Garnet
       4456, -- Quartz
      23173, -- Sapphire
      30221, -- Sardonyx
      -- Trait Material, Weapon
      23204, -- Amethyst
      23165, -- Carnelian
      23203, -- Chysolite
      16291, -- Citrine
      23149, -- Fire Opal
        810, -- Jade
      56863, -- Potent Nirncrux
       4486, -- Ruby
        813, -- Turquoise
      -- Woodworking Booster
      54178, -- Pitch
      54179, -- Turpen
      54180, -- Mastic
      54181, -- Rosin
      -- Woodworking Material, Raw
       4439, -- Rough Ash
      23117, -- Rough Beech
        818, -- Rough Birch
      23118, -- Rough Hickory
      23137, -- Rough Mahogany
        802, -- Rough Maple
      23138, -- Rough Nightwood
        521, -- Rough Oak
      71199, -- Rough Ruby Ash
      23119, -- Rough Yew
      -- Woodworking Material, Refined
      64503, -- Purified Azure Ash
      46140, -- Sanded Ash
      23121, -- Sanded Beech
      46139, -- Sanded Birch
      23122, -- Sanded Hickory
      46141, -- Sanded Mahogany
        803, -- Sanded Maple
      46142, -- Sanded Nightwood
        533, -- Sanded Oak
      64502, -- Sanded Ruby Ash
      23123, -- Sanded Yew
   }
   local function _generate(t)
      if wasGenerated then
         return
      end
      for _, v in pairs(ids) do
         ItemTrig.gameEnums.commonItems[v] = zo_strformat("<<1>>", ItemTrig.getNaiveItemNameFor(v))
      end
      wasGenerated = true
      ids = nil -- garbage-collect the list
   end
   setmetatable(ItemTrig.gameEnums.commonItems, {
      __index =
         function(t, k)
            local base = rawget(t, k)
            if base then
               return base
            end
            if k == "generate" then
               return _generate
            end
            if k == "wasGenerated" then
               return wasGenerated
            end
         end
   })
end