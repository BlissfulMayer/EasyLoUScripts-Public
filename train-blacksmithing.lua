require "utils"
require "config"
require "recall"
require "restock-regs"

-- This script will recall to a forge.
-- Repeatidly create a specific item till you run out of ingots.
-- Salvage ore from the items you just created and repeat till you run out of ingots
-- Then it will recall to the bank, get more ingots, restock regs, restock hammers
-- Repeat

SelectedSmithingLocation = "Britain Forge"
SelectedBankLocation = "Britain Bank"

FindItem("Crafting Pouch", GetLoginSafeValue(BACKPACKID))
CraftingPouch  = FINDITEM[1].ID
Resource       = "Iron"
AmountRequire  = 6
BlacksmithItem = "Short Spear"
BankCount      = 1

function MoveToBreakCurrentAction()
  OriginalZPosition = GetLoginSafeValue(CHARPOSZ)
  Walk(CHARPOSX, CHARPOSY, CHARPOSZ - 4)
  SafeSleep(2000)
  Walk(CHARPOSX, CHARPOSY, OriginalZPosition)
end

function DoBlacksmithing()
  if GetItemCount(Resource, CraftingPouch) >= AmountRequire then
    FindItem("Hammer", GetLoginSafeValue(BACKPACKID))
    if FINDITEM ~= nil then
      -- MoveToBreakCurrentAction()
      UseSelected(FINDITEM[1].ID)
      WaitForTarget()
      FindItem(SmithingLocations[SelectedSmithingLocation].AnvilId)
      if FINDITEM ~= nil then
        -- Speak("Blacksmithing")
        TargetDynamic(SmithingLocations[SelectedSmithingLocation].AnvilId)
        BlacksmithPanel = WaitForPanel("CraftingWindow")
        WaitForButtonThenClick(BlacksmithPanel, "Favorites")
        WaitForButtonThenClick(BlacksmithPanel, BlacksmithItem)
        WaitForButtonThenClick(BlacksmithPanel, "Craft All")
        WaitTillBlacksmithingComplete()
      end
    end
  end
end

function DoSalvaging()
  FindItem(BlacksmithItem, CraftingPouch)
  Deeds = FINDITEM
  if FINDITEM ~= nil then
    -- Speak("Salvaging")
    MoveToBreakCurrentAction()
    UseForgeOnPouch = function()
      Log('UsingForge')
      UseSelected(SmithingLocations[SelectedSmithingLocation].ForgeId)
      WaitForTarget()
      TargetDynamic(CraftingPouch)
      SafeSleep(1000)
    end
    SmeltAllConfirm = WaitForPanel("SmeltAllConfirm", nil, UseForgeOnPouch)
    WaitForButtonThenClick(SmeltAllConfirm, "Confirm")
    WaitTillSalvageComplete()
  end
end

function WaitTillSalvageComplete()
  StartTime = GetTime()
  repeat
    -- Log("WaitTillSalvageComplete loop " .. GetTime() - StartTime .. " seconds")
    FindItem(BlacksmithItem, CraftingPouch)
    SafeSleep(1000)
  until FINDITEM == nil -- or GetTime() > StartTime + 300
  if (FINDITEM == nil) then
    Log("Salvaging ended because the bag is empty")
  else
    Log("Salvaging ended because of timeout")
  end
end

function WaitTillBlacksmithingComplete()
  -- CraftingWindow = WaitForPanel("CraftingWindow", 300)
  -- if CraftingWindow ~= false then
  --   ClosePanel(CraftingWindow)
  -- end
  StartTime = GetTime()
  repeat
    -- Log("WaitTillBlacksmithingComplete loop " .. GetTime() - StartTime .. " seconds")
    FindPanel("CraftingWindow")
    SafeSleep(1000)
    FindItem("Hammer")
  until FINDPANEL ~= nil or FINDITEM == nil or GetTime() > StartTime + 900
  ClosePanel("CraftingWindow")
  if (FINDPANEL ~= nil) then
    Log("Blacksmithing ended because the window reopened")
  elseif FINDITEM == nil then
    Log("Blacksmithing ended because hammers ran out")
  else
    Log("Blacksmithing ended because of timeout")
  end
end

function DoBanking()
  -- Speak("Banking run number " .. BankCount)
  DoRecal(SelectedBankLocation)
  OpenBackpack()
  OpenBank()
  OpenContainer(BankRegBag)
  OpenContainer(BackpackRegBag)
  SafeSleep(3000)
  if GetItemCount(Resource, BankID) == 0 then
    Speak("No " .. Resource .. " Left - Exiting")
    LogoutAndEndScript()
  end
  RestockItemFromContainer(Resource, 300, BankID, CraftingPouch)
  GetMultipleNonStackableFromContainer("Hammer", 2, BankToolBag, BACKPACKID)
  RestockRegsResult = RestockRegs(20, { "Black Pearl", "Blood Moss", "Mandrake Root" })
  if RestockRegsResult == false then
    LogoutAndEndScript(RestockRegsResult)
  end
  DoRecal(SelectedSmithingLocation)
  BankCount = BankCount + 1
end

while true do
  FindItem(SmithingLocations[SelectedSmithingLocation].ForgeId)
  Forge = FINDITEM

  if Forge ~= nil then
    Eat()
    DoBlacksmithing()
    Eat()
    DoSalvaging()
  end

  FindItem("Hammer", BACKPACKID)
  Hammers = FINDITEM
  FindItem(BlacksmithItem, CraftingPouch)
  Deeds = FINDITEM

  if Hammers == nil or Forge == nil or (GetItemCount(Resource, CraftingPouch) < AmountRequire and Deeds == nil) then
    DoBanking()
  end

  Eat()
end
