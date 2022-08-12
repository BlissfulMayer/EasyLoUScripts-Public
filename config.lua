-- Set some global config and load character specific config depending on the logged in character

AllowSpeech = true
RuneBook = true

if CHARNAME == nil then
  DoRelog()
  repeat
      SafeSleep(1000)
  until CHARNAME ~= nil
end

SmithingLocations = {}
SmithingLocations["Britain Forge"] = {RuneName = "Britain Forge", AnvilId = 676068, ForgeId = 121000191}
CarpentryLocations = {}
CarpentryLocations["Yew Carpenter"] = {RuneName = "Yew Carpenter", TableId = 146246524}

AutoLogout = false


-- Load charcater specific config
if string.find(CHARNAME, "YourCharacterName") then
  require("config/YourCharacterName")
end

if string.find(CHARNAME, "YourCharacterName2") then
  require("config/YourCharacterName2")
end

Locations = {}

OreTypes = {}
OreTypes["Iron Ore"] = {OreName = "Iron Ore", IngotName = "Iron", SmeltAll = true}
OreTypes["Dull Copper Ore Copper"] = {OreName = "Dull Copper Ore", IngotName = "Dull" , SmeltAll = true}
OreTypes["Shadow Ore"] = {OreName = "Shadow Ore", IngotName = "Shadow Ingot", SmeltAll = true}
OreTypes["Copper Ore"] = {OreName = "Copper Ore", IngotName = "Copper", SmeltAll = true}
OreTypes["Bronze Ore"] = {OreName = "Bronze Ore", IngotName = "Bronze",  SmeltAll = true}
OreTypes["Golden Ore"] = {OreName = "Golden Ore", IngotName = "Golden", SmeltAll = false}
OreTypes["Agapite Ore"] = {OreName = "Agapite Ore", IngotName = "Agapite", SmeltAll = false}
OreTypes["Verite Ore"] = {OreName = "Verite Ore", IngotName = "Verite Ingot", SmeltAll = false}
OreTypes["Valorite Ore"] = {OreName = "Valorite Ore", IngotName = "Valorite", SmeltAll = false}

Gems = {
  "Topaz",
  "Sapphire",
  "Emerald",
  "Ruby",
  "Diamond",
}


LogTypes = {}
LogTypes["Plain"] = {LogName = "Plain Wooden Log", BoardName = "Plain Wooden Board", CutAll = true}
LogTypes["Oak"] = {LogName = "Oak Log", BoardName = "Oak Board", CutAll = false}
LogTypes["Ash"] = {LogName = "Ash Log", BoardName = "AshBoard"}
-- LogTypes["Yew"] = {LogName = "Yew Log", BoardName = "Yew Board"}
-- LogTypes["Bloodwood"] = {LogName = "Bloodwood Log", BoardName = "Bloodwood Board"}
-- LogTypes["Frostwood"] = {LogName = "Frostwood Log", BoardName = "Frostwood Board"}
-- LogTypes["Heartwood"] = {LogName = "Heartwood Log", BoardName = "Heartwood Board"}
