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
ItemTrig.gameEnums.styles = {
   [ITEMSTYLE_ALLIANCE_ALDMERI]       = GetItemStyleName(ITEMSTYLE_ALLIANCE_ALDMERI),
   [ITEMSTYLE_ALLIANCE_DAGGERFALL]    = GetItemStyleName(ITEMSTYLE_ALLIANCE_DAGGERFALL),
   [ITEMSTYLE_ALLIANCE_EBONHEART]     = GetItemStyleName(ITEMSTYLE_ALLIANCE_EBONHEART),
   [ITEMSTYLE_AREA_AKAVIRI]           = GetItemStyleName(ITEMSTYLE_AREA_AKAVIRI),
   [ITEMSTYLE_AREA_ANCIENT_ELF]       = GetItemStyleName(ITEMSTYLE_AREA_ANCIENT_ELF),
   [ITEMSTYLE_AREA_ANCIENT_ORC]       = GetItemStyleName(ITEMSTYLE_AREA_ANCIENT_ORC),
   [ITEMSTYLE_AREA_ASHLANDER]         = GetItemStyleName(ITEMSTYLE_AREA_ASHLANDER),
   [ITEMSTYLE_AREA_DWEMER]            = GetItemStyleName(ITEMSTYLE_AREA_DWEMER),
   [ITEMSTYLE_AREA_RA_GADA]           = GetItemStyleName(ITEMSTYLE_AREA_RA_GADA),
   [ITEMSTYLE_AREA_REACH]             = GetItemStyleName(ITEMSTYLE_AREA_REACH),
   [ITEMSTYLE_AREA_REACH_WINTER]      = GetItemStyleName(ITEMSTYLE_AREA_REACH_WINTER),
   [ITEMSTYLE_AREA_SOUL_SHRIVEN]      = GetItemStyleName(ITEMSTYLE_AREA_SOUL_SHRIVEN),
   [ITEMSTYLE_AREA_TSAESCI]           = GetItemStyleName(ITEMSTYLE_AREA_TSAESCI),
   [ITEMSTYLE_AREA_XIVKYN]            = GetItemStyleName(ITEMSTYLE_AREA_XIVKYN),
   [ITEMSTYLE_AREA_YOKUDAN]           = GetItemStyleName(ITEMSTYLE_AREA_YOKUDAN),
   [ITEMSTYLE_DEITY_AKATOSH]          = GetItemStyleName(ITEMSTYLE_DEITY_AKATOSH),
   [ITEMSTYLE_DEITY_MALACATH]         = GetItemStyleName(ITEMSTYLE_DEITY_MALACATH),
   [ITEMSTYLE_DEITY_TRINIMAC]         = GetItemStyleName(ITEMSTYLE_DEITY_TRINIMAC),
   [ITEMSTYLE_EBONY]                  = GetItemStyleName(ITEMSTYLE_EBONY),
   [ITEMSTYLE_ENEMY_BANDIT]           = GetItemStyleName(ITEMSTYLE_ENEMY_BANDIT),
   [ITEMSTYLE_ENEMY_DAEDRIC]          = GetItemStyleName(ITEMSTYLE_ENEMY_DAEDRIC),
   [ITEMSTYLE_ENEMY_DRAUGR]           = GetItemStyleName(ITEMSTYLE_ENEMY_DRAUGR),
   [ITEMSTYLE_ENEMY_DROMOTHRA]        = GetItemStyleName(ITEMSTYLE_ENEMY_DROMOTHRA),
   [ITEMSTYLE_ENEMY_MAORMER]          = GetItemStyleName(ITEMSTYLE_ENEMY_MAORMER),
   [ITEMSTYLE_ENEMY_MAZZATUN]         = GetItemStyleName(ITEMSTYLE_ENEMY_MAZZATUN),
   [ITEMSTYLE_ENEMY_MINOTAUR]         = GetItemStyleName(ITEMSTYLE_ENEMY_MINOTAUR),
   [ITEMSTYLE_ENEMY_PRIMITIVE]        = GetItemStyleName(ITEMSTYLE_ENEMY_PRIMITIVE),
   [ITEMSTYLE_ENEMY_SILKEN_RING]      = GetItemStyleName(ITEMSTYLE_ENEMY_SILKEN_RING),
   [ITEMSTYLE_GLASS]                  = GetItemStyleName(ITEMSTYLE_GLASS),
   [ITEMSTYLE_HOLIDAY_FROSTCASTER]    = GetItemStyleName(ITEMSTYLE_HOLIDAY_FROSTCASTER),
   [ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN] = GetItemStyleName(ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN),
   [ITEMSTYLE_HOLIDAY_HOLLOWJACK]     = GetItemStyleName(ITEMSTYLE_HOLIDAY_HOLLOWJACK),
   [ITEMSTYLE_HOLIDAY_SKINCHANGER]    = GetItemStyleName(ITEMSTYLE_HOLIDAY_SKINCHANGER),
   [ITEMSTYLE_NONE]                   = GetItemStyleName(ITEMSTYLE_NONE), -- typically an empty string
   [ITEMSTYLE_ORG_ABAHS_WATCH]        = GetItemStyleName(ITEMSTYLE_ORG_ABAHS_WATCH),
   [ITEMSTYLE_ORG_ASSASSINS]          = GetItemStyleName(ITEMSTYLE_ORG_ASSASSINS),
   [ITEMSTYLE_ORG_BUOYANT_ARMIGER]    = GetItemStyleName(ITEMSTYLE_ORG_BUOYANT_ARMIGER),
   [ITEMSTYLE_ORG_DARK_BROTHERHOOD]   = GetItemStyleName(ITEMSTYLE_ORG_DARK_BROTHERHOOD),
   [ITEMSTYLE_ORG_HLAALU]             = GetItemStyleName(ITEMSTYLE_ORG_HLAALU),
   [ITEMSTYLE_ORG_MORAG_TONG]         = GetItemStyleName(ITEMSTYLE_ORG_MORAG_TONG),
   [ITEMSTYLE_ORG_ORDINATOR]          = GetItemStyleName(ITEMSTYLE_ORG_ORDINATOR),
   [ITEMSTYLE_ORG_OUTLAW]             = GetItemStyleName(ITEMSTYLE_ORG_OUTLAW),
   [ITEMSTYLE_ORG_REDORAN]            = GetItemStyleName(ITEMSTYLE_ORG_REDORAN),
   [ITEMSTYLE_ORG_TELVANNI]           = GetItemStyleName(ITEMSTYLE_ORG_TELVANNI),
   [ITEMSTYLE_ORG_THIEVES_GUILD]      = GetItemStyleName(ITEMSTYLE_ORG_THIEVES_GUILD),
   [ITEMSTYLE_ORG_WORM_CULT]          = GetItemStyleName(ITEMSTYLE_ORG_WORM_CULT),
   [ITEMSTYLE_RACIAL_ARGONIAN]        = GetItemStyleName(ITEMSTYLE_RACIAL_ARGONIAN),
   [ITEMSTYLE_RACIAL_BRETON]          = GetItemStyleName(ITEMSTYLE_RACIAL_BRETON),
   [ITEMSTYLE_RACIAL_DARK_ELF]        = GetItemStyleName(ITEMSTYLE_RACIAL_DARK_ELF),
   [ITEMSTYLE_RACIAL_HIGH_ELF]        = GetItemStyleName(ITEMSTYLE_RACIAL_HIGH_ELF),
   [ITEMSTYLE_RACIAL_IMPERIAL]        = GetItemStyleName(ITEMSTYLE_RACIAL_IMPERIAL),
   [ITEMSTYLE_RACIAL_KHAJIIT]         = GetItemStyleName(ITEMSTYLE_RACIAL_KHAJIIT),
   [ITEMSTYLE_RACIAL_NORD]            = GetItemStyleName(ITEMSTYLE_RACIAL_NORD),
   [ITEMSTYLE_RACIAL_ORC]             = GetItemStyleName(ITEMSTYLE_RACIAL_ORC),
   [ITEMSTYLE_RACIAL_REDGUARD]        = GetItemStyleName(ITEMSTYLE_RACIAL_REDGUARD),
   [ITEMSTYLE_RACIAL_WOOD_ELF]        = GetItemStyleName(ITEMSTYLE_RACIAL_WOOD_ELF),
   [ITEMSTYLE_RAIDS_CRAGLORN]         = GetItemStyleName(ITEMSTYLE_RAIDS_CRAGLORN),
   [ITEMSTYLE_UNDAUNTED]              = GetItemStyleName(ITEMSTYLE_UNDAUNTED),
   [ITEMSTYLE_UNIQUE]                 = GetItemStyleName(ITEMSTYLE_UNIQUE),
   [ITEMSTYLE_UNIVERSAL]              = GetItemStyleName(ITEMSTYLE_UNIVERSAL),
}