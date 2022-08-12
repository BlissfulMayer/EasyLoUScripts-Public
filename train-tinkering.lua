require "utils"
require "config"
require "recall"
require "restock-regs"

Resource = "Iron"
Product = "Lockpick"
Tool = "Tool kit"
AmountRequire = 1
BankCount = 1
AllowSpeech = false

-- This script will repeatidly make an item untill you run out of resources or tools
-- It will then get more resources and tools from the bank and repeat

function DoTinkering()
  if GetItemCount(Resource, BACKPACKID) >= AmountRequire then
    FindItem(Tool, GetLoginSafeValue(BACKPACKID))
    if FINDITEM ~= nil then
      UseSelected(FINDITEM[1].ID)
      BlacksmithPanel = WaitForPanel("CraftingWindow")
      WaitForButtonThenClick(BlacksmithPanel, "Favorites")
      WaitForButtonThenClick(BlacksmithPanel, Product)
      WaitForButtonThenClick(BlacksmithPanel, "Craft All")
      WaitTillTinkeringComplete()
    end
  end
end

function WaitTillTinkeringComplete()
  StartTime = GetTime()
  repeat
    -- Log("WaitTillTinkeringComplete loop " .. GetTime() - StartTime .. " seconds")
    FindPanel("CraftingWindow")
    SafeSleep(1000)
    FindItem(Tool)
  until FINDPANEL ~= nil or FINDITEM == nil or GetTime() > StartTime + 900
  ClosePanel("CraftingWindow")
  if(FINDPANEL ~= nil) then
    Log("Tinkering ended because the window reopened")
  elseif FINDITEM == nil then
    Log("Tinkering ended because toolkits ran out")
  else
    Log("Tinkering ended because of timeout")
  end
end

function DoBanking()
  Speak("Banking run number " .. BankCount)
  OpenBackpack()
  OpenBank()
  SafeSleep(3000)
  BankItems(Product)
  if GetItemCount(Resource, BankID) == 0 then
      Speak("No " .. Resource .. " Left - Exiting")
      LogoutAndEndScript()
  end
  GetMultipleNonStackableFromContainer(Tool, 2, BankToolBag, BACKPACKID)
  RestockItemFromContainer(Resource, 275, BankID, BACKPACKID)
  BankCount = BankCount + 1
end

while true do
    Eat()
    DoTinkering()
    FindItem(Tool, BACKPACKID)
    if FINDITEM == nil or (GetItemCount(Resource, BACKPACKID) < AmountRequire) then
      DoBanking()
    end
end


