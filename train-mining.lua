require "utils"
require "config"
require "config/minoc-inside-locations"
require "config/rocksi-locations"
require "recall"
require "restock-regs"
require "smelt-ore"

-- This script will recall to one of two good areas for mining
-- It will then walk between points in that area (points are in the config folder)
-- Once it has exhausted all the ore at that point it will move to the next
-- When you're overweight it will recall to a forge and smelt till you run out of ore
-- It will then recall to the bank, refill regs, refill hatchets, bank ingots
-- Repeat

-- Also tries to fight off enemies and loot any Sulfurous Ash

ScriptID = 'mining'

-- Set AlwaysSmeltAll to false if you want to smilt ore 1 at a time for better mining gains
AlwaysSmeltAll = true
SwitchMines = true
AllowSpeech = false

if GetPersistentValue("CurrentMiningLocation") == nil then
  SetPersistentValue("CurrentMiningLocation", "Rocks I")
  -- SetPersistentValue("CurrentMiningLocation", "Minoc")
end


if GetPersistentInt("CurrentMiningNode") == nil then
  SetPersistentInt("CurrentMiningNode", 1)
end

function MineSpot(SpotID)
  FindPermanent(SpotID)
  if FINDPERMANENT[1].STONESTATE == 0 or FINDPERMANENT[1].STONESTATE == 2 then
    -- if FINDPERMANENT[1].STONESTATE == 0 then
    local startTime = GetTime()
    Eat()
    repeat
      if (RightHandCheck("Pick") == false) then
        Equip("Pick")
      end
      AsboluteMacro(29)
      WaitForTarget()
      TargetPermanent(SpotID)
      FindPermanent(SpotID)
      SafeSleep(1000)
    until GetTime() > startTime + 30 or FINDPERMANENT[1].STONESTATE == 1
  end
end

function DoMining()
  Speak("Mining")
  for i, Location in ipairs(Locations[GetPersistentValue("CurrentMiningLocation")]) do
    if i >= GetPersistentInt("CurrentMiningNode") then
      SetPersistentInt("CurrentMiningNode", i)
      Log("Mining node: " .. i);
      Walk(Location.x, Location.y, Location.z)
      MineSpot(Location.id)
      KillNearbyMonsters()
      -- HarvestItemsFromFloor("Sulfurous Ash")
      if (GetLoginSafeValue(HEALTH) < 100) then
        Heal()
      end
      if (GetLoginSafeValue(CHARWEIGHT) > 340) then
        return
      end
    end
    if GetPersistentInt("CurrentMiningNode") == #Locations[GetPersistentValue("CurrentMiningLocation")] then
      return
    end
  end
end

function SwitchMiningLocation()
  if SwitchMines then
    if GetPersistentValue("CurrentMiningLocation") == "Minoc" then
      SetPersistentValue("CurrentMiningLocation", "Rocks I")
    else
      SetPersistentValue("CurrentMiningLocation", "Minoc")
    end
  end
  SetPersistentInt("CurrentMiningNode", 1)
end

function DoSmelting()
  Speak("Smelting")
  DoRecal("Britain Forge")
  SmeltAllOre(AlwaysSmeltAll)
end

function DoBanking()
  Speak("Banking")
  DoRecal("Britain Bank")
  OpenBank()
  SafeSleep(2000)
  OpenContainer(BankRegBag)
  OpenContainer(BackpackRegBag)
  OpenContainer(BankToolBag)

  for k, OreType in pairs(OreTypes) do
    BankItems(OreType.IngotName)
  end
  for i, Gem in ipairs(Gems) do
    BankItems(Gem)
  end
  BankItems("Gold")
  BankItems("Stone")
  BankItems("Sulfurous Ash", BackpackRegBag)

  FindItem("Iron[", BankID)
  if FINDITEM then
    IronCount = tonumber(string.match(FINDITEM[1].NAME:gsub(",", ""), "%d+"));
    Speak(IronCount .. " Iron in bank")
  end

  GetMultipleNonStackableFromContainer("Pick", 3, BankToolBag, BACKPACKID)

  RestockRegs(20, { "Black Pearl", "Blood Moss", "Mandrake Root" })
  RestockItemFromContainer("Bread", 2, BankID, BACKPACKID)

  SwitchMiningLocation()
  DoRecal(GetPersistentValue("CurrentMiningLocation"))
end

while true do
  DoBanking()
  DoMining()
  DoSmelting()
end
