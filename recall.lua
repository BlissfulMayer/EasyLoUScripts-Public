require "utils"
require "config"

-- Recall to a location using a rune or book.
-- This will keep retrying till you succeed.
-- CheckObjectID is an object of ObjectType near the recall location.
-- This is used to check if the recall was successful.
-- If the recall location is a bank the script will restock recall scrolls or recharge your rune book.
-- you'll need to set some item id's in /config/YourChacraterName.lua

RuneLocations = {}
RuneLocations['Britain Bank'] = {ButtonName = 'Britain Bank', CheckObjectID = '148722407', ObjectType = "Item", IsBank = true}
RuneLocations['Britain Forge'] = {ButtonName = 'Britain Forge', CheckObjectID = '30535',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Minoc'] = {ButtonName = 'Minoc', CheckObjectID = '83324',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Rocks I'] = {ButtonName = "Rocks I", CheckObjectID = '14523',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Trees I'] = {ButtonName = "Trees I", CheckObjectID = '14523',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Britain Carpenter'] = {ButtonName = "Britain Carpenter", CheckObjectID = '505334858',  ObjectType = "Item", IsBank = false}
RuneLocations['Britain General Store'] = {ButtonName = "Britain General Store", CheckObjectID = '505335064',  ObjectType = "Item", IsBank = false}
RuneLocations['Dagger Isle'] = {ButtonName = "Dagger Isle", CheckObjectID = '79194',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Sand Graveyard'] = {ButtonName = "Sand Graveyard", CheckObjectID = '40991',  ObjectType = "Permanent", IsBank = false}
RuneLocations['Yew Carpenter'] = {ButtonName = "Yew Carpenter", CheckObjectID = '146246524',  ObjectType = "Item", IsBank = false}
RuneLocations['Cove Bank'] = {ButtonName = "Cove Bank", CheckObjectID = '11214026',  ObjectType = "Item", IsBank = true}

Delay = 20000

function FindCheckItem(Destination)
  if RuneLocations[Destination].ObjectType == "Permanent" then
    FindPermanent(RuneLocations[Destination].CheckObjectID)
    return FINDPERMANENT
  else
    FindItem(RuneLocations[Destination].CheckObjectID)
    return FINDITEM
  end
end

function UseBook(Destination)
      Object = FindCheckItem(Destination)
      Log(RuneAction .. " to " .. RuneLocations[Destination].ButtonName);
      FindItem("Runebook", BACKPACKID)
      UseSelected(FINDITEM[1].ID)
      SafeSleep(1000)
      FindPanel("Runebook")
      if(FINDPANEL ~= nil) then
        RuneBook = FINDPANEL[1].ID
        WaitForButtonThenClick(RuneBook, RuneLocations[Destination].ButtonName)
        WaitForButtonThenClick(RuneBook, RuneAction)
        if Object ~= nil and Object[1].DISTANCE < 15 then
          return false
        end
        ClickButton(RuneBook, FINDBUTTON[1].NAME)
        SafeSleep(Delay)
      end
      Object = FindCheckItem(Destination)
      return true
end

function UseRunes(Destination)
  FindItem(Destination)
  if FINDITEM ~= nil then
    AsboluteMacro(10)
    WaitForTarget()
    TargetDynamic(FINDITEM[1].ID)
    SafeSleep(Delay)
  else
    print("Rune not found")
    LogoutAndEndScript()
  end
  Object = FindCheckItem(Destination)
end

function DoRecal(Destination, DelayOverride)
  Object = FindCheckItem(Destination)
  if Object == nil or Object[1].DISTANCE > 15 then
    if(DelayOverride ~= nil) then
      Delay = DelayOverride
    end
    if RuneAction == "Charge" then
      SafeSleep(2000)
      RechargeBook()
    end
    repeat
      if(RuneBook) then
        AlreadyAtLocation = UseBook(Destination)
      else
        AlreadyAtLocation = UseRunes(Destination)
      end
      -- if AlreadyAtLocation then
      --   goto skip_recal
      -- end
      Object = FindCheckItem(Destination)
    until Object ~= nil and Object[1].DISTANCE < 15
    ::skip_recal::
    if RuneAction == "Charge" then
      SafeSleep(2000)
      RechargeBook()
      if RuneLocations[Destination].IsBank == true then
        GetRecScrollsFromBank()
      end
    end
  end
end


function RechargeBook()
  OpenBackpack()
  TakeFromStack("Recall Scroll", GetLoginSafeValue(BACKPACKID), 1)
  FindItem("Runebook", GetLoginSafeValue(BACKPACKID))
  SafeSleep(1000)
  Dropc(FINDITEM[1].ID)
  SafeSleep(1000)
  Dropc(GetLoginSafeValue(BACKPACKID))
  FindPanel("Runebook")
  if(FINDPANEL ~= nil) then
    ClosePanel(FINDPANEL[1].ID)
  end
end

function GetRecScrollsFromBank()
  OpenBank()
  OpenBackpack()
  FindItem("Recall Scroll", GetLoginSafeValue(BACKPACKID));

  if FINDITEM == nil then
    NumberInBackPack = 0;
  else
    BackPackPile = FINDITEM[1];
    NumberInBackPack = tonumber(string.match(FINDITEM[1].NAME:gsub("00FF00", ""), "%d+"));
    if(NumberInBackPack == nil) then
      NumberInBackPack = 1
    end
  end

  if NumberInBackPack < RecallScrollsToCarry then
    GetFromContainer("Recall Scroll", BankID, RecallScrollsToCarry - NumberInBackPack)
  end
end
