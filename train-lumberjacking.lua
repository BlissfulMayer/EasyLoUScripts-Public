require "utils"
require "config"
require "config/dager-island-lumber-locations"
require "config/treesi-lumber-locations"
require "recall"
require "restock-regs"
require "auto-buy"

-- This script will recall to one of two good areas for lumberjacking
-- It will then walk between points in that area (points are in the config folder)
-- Once it has exhausted all the wood at that point it will move to the next
-- When you're overweight it will recall to a carpenter table and make boards till you run out of logs
-- It will then recall to the bank, refill regs, refill hatchets, bank logs
-- Repeat

ScriptID = 'lumberjacking'

SwitchLocations = false
AllowSpeech = false
Vendor = "General Trader"
Tool = "Dovetail Saw"
CarpentryTable = 146246524

if GetPersistentValue("CurrentLumberjackLocation") == nil then
  -- SetPersistentValue("CurrentLumberjackLocation", "Dagger Isle")
  SetPersistentValue("CurrentLumberjackLocation", "Trees I")
end

if GetPersistentInt("CurrentLumberjackNode") == nil then
  SetPersistentInt("CurrentLumberjackNode", 1)
end

function CutTree(SpotID)
  FindPermanent(SpotID)
  if FINDPERMANENT[1].TREESTATE ~= 1 then
    -- if FINDPERMANENT[1].TREESTATE == 0 then
    local startTime = GetTime()
    Eat()
    repeat
      if (RightHandCheck("Hatchet") == false) then
        Equip("Hatchet")
      end
      AsboluteMacro(29)
      WaitForTarget()
      TargetPermanent(SpotID)
      FindPermanent(SpotID)
      SafeSleep(2000)
    until GetTime() > startTime + 60 or FINDPERMANENT[1].TREESTATE == 1
  end
end

function DoCutting()
  DoRecal(GetPersistentValue("CurrentLumberjackLocation"))
  Speak("Lumberjacking")
  for i, Location in ipairs(Locations[GetPersistentValue("CurrentLumberjackLocation")]) do
    SetPersistentInt("CurrentLumberjackNode", i)
    Log("Cutting node: " .. i);
    Walk(Location.x, Location.y, Location.z)
    CutTree(Location.id)
    KillNearbyMonsters()
    if (GetLoginSafeValue(HEALTH) < 100) then
      Heal()
    end
    if (GetLoginSafeValue(CHARWEIGHT) > 340) then
      return
    end
    if GetPersistentInt("CurrentLumberjackNode") == #Locations[GetPersistentValue("CurrentLumberjackLocation")] then
      return
    end
  end
end

function SwitchLumberLocation()
  if SwitchMines then
    if GetPersistentValue("CurrentLumberjackLocation") == "Dagger Isle" then
      SetPersistentValue("CurrentLumberjackLocation", "Trees I")
    else
      SetPersistentValue("CurrentLumberjackLocation", "Dagger Isle")
    end
  end
  SetPersistentInt("CurrentLumberjackNode", 1)
end

function FixOverburden()
  if GetLoginSafeValue(CHARWEIGHT) > 379 then
    FindItem("Plain Wooden Log")
    if (FINDITEM ~= nil) then
      repeat
        TakeFromStack("Plain Wooden Log", BACKPACKID, 1)
        SafeSleep(500)
        Dropg(CHARPOSX, CHARPOSY, CHARPOSZ)
      until GetLoginSafeValue(CHARWEIGHT) < 380
    end
  end
end

function DoBoardMaking(LogType)
  if GetItemCount(LogType.LogName, BACKPACKID) >= 1 then
    FindItem(Tool, GetLoginSafeValue(BACKPACKID))
    if FINDITEM ~= nil then
      UseSelected(FINDITEM[1].ID)
      WaitForTarget()
      TargetDynamic(CarpentryTable)
      CarpentryPanel = WaitForPanel("CraftingWindow")
      WaitForButtonThenClick(CarpentryPanel, "Favorites")
      WaitForButtonThenClick(CarpentryPanel, LogType.BoardName)
      WaitForButtonThenClick(CarpentryPanel, "Craft All")
      WaitTillBoardMakingComplete()
    end
  end
end

function MakeBoards()
  FixOverburden()
  DoRecal("Yew Carpenter")
  Speak("Making Boards")
  for k, LogType in pairs(LogTypes) do
    print(LogType.LogName)
    Logs = nil
    FindItem(LogType.LogName, BACKPACKID)
    Logs = FINDITEM
    if Logs ~= nil then
      print(1)
      repeat
        if LogType.CutAll == true then
          Equip("Hatchet")
          AsboluteMacro(30)
          TargetDynamic(Logs[1].ID)
          SafeSleep(3000)
        else
          DoBoardMaking(LogType)
        end
        FindItem(LogType.LogName, BACKPACKID)
      until FINDITEM == nil
    end
  end
end

function WaitTillBoardMakingComplete()
  StartTime = GetTime()
  repeat
    -- Log("WaitTillBoardMakingComplete loop " .. GetTime() - StartTime .. " seconds")
    FindPanel("CraftingWindow")
    SafeSleep(1000)
    FindItem(Tool)
  until FINDPANEL ~= nil or FINDITEM == nil or GetTime() > StartTime + 900
  ClosePanel("CraftingWindow")
  if (FINDPANEL ~= nil) then
    Log("BoardMaking ended because the window reopened")
  elseif FINDITEM == nil then
    Log("BoardMaking ended because toolkits ran out")
  else
    Log("BoardMaking ended because of timeout")
  end
end

function DoBanking()
  Speak("Banking")
  DoRecal("Britain Bank")
  OpenBank()
  SafeSleep(3000)
  OpenContainer(BankRegBag)
  OpenContainer(BackpackRegBag)
  OpenContainer(BankToolBag)
  BankItems("Board")
  BankItems("Log")
  BankItems("Gold")
  BankItems("Apple")
  BankItems("Kindling")
  BankItems("Seed")
  RestockRegs(10, { "Black Pearl", "Blood Moss", "Mandrake Root" })
  RestockItemFromContainer("Apple", 10, BankID, BACKPACKID)
  GetMultipleNonStackableFromContainer("Hatchet", 3, BankToolBag, BACKPACKID)
  GetMultipleNonStackableFromContainer("Saw", 3, BankToolBag, BACKPACKID)
end

while true do
  DoBanking()
  SwitchLumberLocation()
  DoCutting()
  MakeBoards()
end
