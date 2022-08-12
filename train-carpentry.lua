require "utils"
require "config"
require "recall"
require "restock-regs"


-- This script will recall to a carpentry bench.
-- Repeatidly create a specific item till you run out of wood.
-- Salvage wood from the items you just created and repeat till you run out of wood
-- Then it will recall to the bank, get more wood, restock regs, restock tools
-- Repeat

SelectedCarpentryLocation = "Yew Carpenter"
SelectedBankLocation = "Britain Bank"

FindItem("Crafting Pouch", GetLoginSafeValue(BACKPACKID))
CraftingPouch  = FINDITEM[1].ID
Resource = "Plain Wooden Board"
AmountRequire = 6
Product = "Wooden Standing Torch"
BankCount = 1
Tool = "Saw"
Salvage = true
AllowSpeech = false

function MoveToBreakCurrentAction()
  OriginalXPosition = GetLoginSafeValue(CHARPOSX)
  Walk(CHARPOSX - 4, CHARPOSY, CHARPOSZ)
  SafeSleep(2000)
  Walk(OriginalXPosition, CHARPOSY, CHARPOSZ)
end

function DoCarpentry()
  if GetItemCount(Resource, CraftingPouch) >= AmountRequire then
    FindItem(Tool, GetLoginSafeValue(BACKPACKID))
    if FINDITEM ~= nil then
      -- MoveToBreakCurrentAction()
      UseSelected(FINDITEM[1].ID)
      WaitForTarget()
      FindItem(CarpentryLocations[SelectedCarpentryLocation].TableId)
      if FINDITEM ~= nil then
        Speak("Carpentry")
        TargetDynamic(CarpentryLocations[SelectedCarpentryLocation].TableId)
        CarpentryPanel = WaitForPanel("CraftingWindow")
        WaitForButtonThenClick(CarpentryPanel, "Favorites")
        WaitForButtonThenClick(CarpentryPanel, Product)
        WaitForButtonThenClick(CarpentryPanel, "Craft All")
        WaitTillCarpentryComplete()
      end
    end
  end
end

function DoSalvaging()
  FindItem(Product, CraftingPouch)
  Deeds = FINDITEM
  if Deeds ~= nil then
    Speak("Salvaging")
    MoveToBreakCurrentAction()
    UseTableOnPouch = function()
      Log('UsingHatchet')
      FindItem("Hatchet", BACKPACKID)
      Hatchet = FINDITEM
      if Hatchet ~= nil then
        Equip("Hatchet")
        AsboluteMacro(30)
        WaitForTarget()
        TargetDynamic(CraftingPouch)
        SafeSleep(1000)
      end
    end
    SmeltAllConfirm = WaitForPanel("ChopAllConfirm", nil, UseTableOnPouch)
    WaitForButtonThenClick(SmeltAllConfirm, "Confirm")
    WaitTillSalvageComplete()
  end
end

function WaitTillSalvageComplete()
  StartTime = GetTime()
  repeat
    -- Log("WaitTillSalvageComplete loop " .. GetTime() - StartTime .. " seconds")
    FindItem(Product, CraftingPouch)
    SafeSleep(1000)
  until FINDITEM == nil -- or GetTime() > StartTime + 300
  if(FINDITEM == nil) then
    Log("Salvaging ended because the bag is empty")
  else
    Log("Salvaging ended because of timeout")
  end
end

function WaitTillCarpentryComplete()
  -- CraftingWindow = WaitForPanel("CraftingWindow", 300)
  -- if CraftingWindow ~= false then
  --   ClosePanel(CraftingWindow)
  -- end
  StartTime = GetTime()
  repeat
    -- Log("WaitTillCarpentryComplete loop " .. GetTime() - StartTime .. " seconds")
    FindPanel("CraftingWindow")
    SafeSleep(1000)
    FindItem(Tool)
  until FINDPANEL ~= nil or FINDITEM == nil or GetTime() > StartTime + 900
  ClosePanel("CraftingWindow")
  if(FINDPANEL ~= nil) then
    Log("Carpentry ended because the window reopened")
  elseif FINDITEM == nil then
    Log("Carpentry ended because saws ran out")
  else
    Log("Carpentry ended because of timeout")
  end
end

function DoBanking()
  Speak("Banking run number " .. BankCount)
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
  if Salvage == false then
    BankItems(Product, CraftingPouch)
  end
  RestockItemFromContainer(Resource, 250, BankID, CraftingPouch)
  GetMultipleNonStackableFromContainer(Tool, 2, BankToolBag, BACKPACKID)
  RestockRegsResult = RestockRegs(20, {"Black Pearl", "Blood Moss", "Mandrake Root"})
  RestockItemFromContainer("Bandage", 20, BankID, BACKPACKID)
  RestockItemFromContainer("Bread", 5, BankID, BACKPACKID)
  if RestockRegsResult == false then
    LogoutAndEndScript(RestockRegsResult)
  end
  DoRecal(SelectedCarpentryLocation)
  BankCount = BankCount + 1
end

while true do
    FindItem(CarpentryLocations[SelectedCarpentryLocation].TableId)
    Table = FINDITEM

    if Table ~= nil then
      Eat()
      if Salvage then
        DoSalvaging()
      end
      Eat()
      DoCarpentry()
      Eat()
    end

    FindItem(Tool, BACKPACKID)
    Tools = FINDITEM

    if Salvage then
      FindItem(Product, CraftingPouch)
      Deeds = FINDITEM
      if Tools == nil or Table == nil or (GetItemCount(Resource, CraftingPouch) < AmountRequire and Deeds == nil) then
        DoBanking()
      end
    else
      if Tools == nil or Table == nil or (GetItemCount(Resource, CraftingPouch) < AmountRequire) then
        DoBanking()
      end
    end


    Eat()
end


