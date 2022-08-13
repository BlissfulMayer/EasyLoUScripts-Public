require "math"
require "table"

-- Sleep and log back in if you're disconnected
function SafeSleep(Time)
  if CLIGAMESTATE ~= "Game" then
    CheckForRelog()
  end
  sleep(Time)
end

-- Log to file.
function Log(message)
  File = io.open("c:\\Users\\Games\\Desktop\\Scripts\\log.txt", "a")
  File.write(os.date("%X") .. ": " .. message .. "\n")
  File.close();
  print(os.date("%X") .. ": " .. message)
end

-- Use the numbers that are on the slots ui rather than zero based.
function AsboluteMacro(Slot)
  Macro(Slot - 1)
end

function MacroTargetSelf(Slot)
  AsboluteMacro(Slot)
  WaitForTarget()
  TargetSelf()
end

function GetTime()
  return os.time(os.date("!*t"))
end

function Round(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Equip(item)
  FindItem(item, BACKPACKID)

  if FINDITEM == nil then
    Log(item .. " not found!")
    return
  end

  local tool_id = FINDITEM[1].ID;
  local cont_id = FINDITEM[1].CNTID;

  if tostring(cont_id) == tostring(CHARID) then
    Log(item .. " already equipped!")
    return
  end

  SayCustom(".x use " .. tool_id .. " Equip")
end

function Walk(x2, y2, z2)
  local x1 = GetLoginSafeValue(CHARPOSX)
  local y1 = GetLoginSafeValue(CHARPOSY)
  local z1 = GetLoginSafeValue(CHARPOSZ)
  local xDif = x2 - x1
  local yDif = y2 - y1
  local zDif = z2 - z1
  local distance = ((xDif ^ 2 + zDif ^ 2) ^ .5)
  local n = math.ceil(distance / 40)
  for i = 1, n do
    local count = 0
    repeat
      count = count + 1
      Move((x1 + ((xDif / n) * i)), y2, (z1 + ((zDif / n) * i)))
      SafeSleep(250)
    until ((((math.abs(GetLoginSafeValue(CHARPOSX)) - math.abs((x1 + ((xDif / n) * i)))) < 2)
        and (math.abs((math.abs(GetLoginSafeValue(CHARPOSZ)) - math.abs((z1 + ((zDif / n) * i)))))) < 2)
        or count == 100)
  end
end

function WalkRoute(Route)
  for i, Location in ipairs(Route) do
    Log("Walking to point: " .. i)
    Walk(Location.x, Location.y, Location.z)
  end
end

function Reverse(obj)
  local output = {}
  for i = #obj, 1, -1 do
    table.insert(output, obj[i])
  end
  return output
end

function NilToZero(var)
  if var == nil then
    return 0
  else
    return var
  end
end

-- Open backpack, BACKPACKID must be set in config
function OpenBackpack()
  FindPanel(BACKPACKID)
  if FINDPANEL == nil then
    repeat
      UseSelected(BACKPACKID)
      SafeSleep(100)
      FindPanel("PlayerBackpack")
    until FINDPANEL ~= nil
    SafeSleep(500)
  end
end

function WaitForPanel(Name, Timeout, Callback)
  FindPanel(Name)
  local startTime = GetTime()
  repeat
    if Callback ~= nil then
      Callback()
    end
    SafeSleep(100)
    FindPanel(Name)
  until FINDPANEL ~= nil or (Timeout ~= nil and GetTime() > startTime + Timeout)
  if FINDPANEL ~= nil then
    return FINDPANEL[1].ID
  end
  return false
end

function WaitForButtonThenClick(PanelID, ButtonText)
  FindButton(PanelID, ButtonText)
  repeat
    SafeSleep(100)
    FindButton(PanelID, ButtonText)
  until FINDBUTTON ~= nil
  ClickButton(PanelID, FINDBUTTON[1].NAME)
end

function WaitForButton2ThenClick(PanelID, ButtonText)
  FindButton(PanelID, ButtonText)
  repeat
    SafeSleep(100)
    FindButton(PanelID, ButtonText)
  until FINDBUTTON ~= nil
  ClickButton(PanelID, FINDBUTTON[2].NAME)
end

-- Open backpack, BankID must be set in config
function OpenBank()
  FindPanel(BankID)
  if FINDPANEL == nil then
    Say("Guards! Open the bank vault please!")
    repeat
      SafeSleep(100)
      FindPanel(BankID)
    until FINDPANEL ~= nil
    SafeSleep(500)
  end
end

function OpenContainer(ContainerID)
  FindPanel(ContainerID)
  if FINDPANEL == nil then
    repeat
      UseSelected(ContainerID)
      SafeSleep(100)
      FindPanel(ContainerID)
    until FINDPANEL ~= nil
    SafeSleep(500)
  end
end

function TakeFromStack(Item, Container, Amount)
  FindItem(Item, Container)
  if FINDITEM == nil then
    return false
  else
    ContextMenu(FINDITEM[1].ID, "Split Stack")
    WaitForPanel("StackSplit")
    SetInput("StackSplit", "TextFieldStackAmount", Amount)
    WaitForButtonThenClick("StackSplit", "Accept")
  end
end

-- Move items from backpack to bank BACKPACKID must be set in config
function BankItems(itemName, SourceContainerID)
  if SourceContainerID == nil then
    SourceContainerID = GetLoginSafeValue(BACKPACKID)
  else
    OpenBank()
  end
  OpenBackpack()
  FindItem(itemName, SourceContainerID)
  if (FINDITEM ~= nil) then
    for i, Item in ipairs(FINDITEM) do
      Drag(Item.ID)
      SafeSleep(1000)
      Dropc(BankID)
      SafeSleep(1000)
    end
  end
end

function RightHandCheck(ItemName)
  if RIGHTHANDNAME == nil or string.match(RIGHTHANDNAME:lower(), ItemName:lower()) == nil then
    return false
  else
    return true
  end
end

function LeftHandCheck(ItemName)
  if LEFTHANDNAME == nil or string.match(LEFTHANDNAME:lower(), ItemName:lower()) == nil then
    return false
  else
    return true
  end
end

function CheckEquip(Slot, ItemName)
  if _G[Slot] == nil or string.match(_G[Slot]:lower(), ItemName:lower()) == nil then
    return false
  else
    return true
  end
end

function UseFromContainer(ItemName, ContainerID)
  FindItem(ItemName, ContainerID)
  if FINDITEM ~= nil then
    UseSelected(FINDITEM[1].ID)
  end
end

function GetFromContainer(Item, Container, Amount, TargetContainer)
  if TargetContainer == nil then
    TargetContainer = GetLoginSafeValue(BACKPACKID)
  end
  FindItem(Item, Container)
  if FINDITEM ~= nil then
    TakeFromStack(Item, Container, Amount)
    TargetCount = GetItemCount(Item, TargetContainer)
    local startTime = GetTime()
    repeat
      SafeSleep(100)
      Dropc(TargetContainer)
      NewTargetCount = GetItemCount(Item, TargetContainer)
    until GetTime() > startTime + 5 or NewTargetCount > TargetCount
  end
end

function GetAllFromContainer(Item, Container, TargetContainer)
  if TargetContainer == nil then
    TargetContainer = GetLoginSafeValue(BACKPACKID)
  end
  FindItem(Item, Container)
  if FINDITEM ~= nil then
    Drag(FINDITEM[1].ID)
    TargetCount = GetItemCount(Item, TargetContainer)
    repeat
      Dropc(TargetContainer)
      NewTargetCount = GetItemCount(Item, TargetContainer)
      SafeSleep(500)
    until NewTargetCount > TargetCount
  end
end

-- HealSlot must be set in config
function Heal()
  if DoHeal then
    if GetTime() > (LastHeal + HealDelay) then
      if GetLoginSafeValue(HEALTH) < HealThreshold then
        Log("Healing")
        AsboluteMacro(HealSlot)
        WaitForTarget()
        TargetSelf()
      end
      LastHeal = GetTime()
    end
  end
end

function KillNearbyMonsters()
  if MONSTERSNEARBY then
    for i, Monster in ipairs(NEARBYMONSTERS) do
      Speak("Fighting")
      Equip(Weapon)
      SafeSleep(1000)
      AttackSelected(Monster.ID)
      repeat
        Equip(Weapon)
        SafeSleep(2000)
        Heal()
        Move(Monster.ID)
        SafeSleep(1000)
        AttackSelected(Monster.ID)
        FindMobile(Monster.ID)
      until MONSTERSNEARBY == false or FINDMOBILE == nil or FINDMOBILE[1].HP == 0 or Monster.HP == 0
      ToggleWarPeace()
      if FINDMOBILE ~= nil and FINDMOBILE[1].HP == 0 then
        LootMob(FINDMOBILE[1].ID)
      end
    end
  end
end

function LootMob(CorpseID)
  Speak("Looting")
  ContextMenu(CorpseID, "Harvest")
  SafeSleep(1000)
  ContextMenu(CorpseID, "Loot All")
  SafeSleep(8000)
end

-- Checking variables will usually crash the script if you're logged out at the time
-- This checks for login first and re-logs you in if needed.
-- This allows most scripts to continure running when you log back in.
function GetLoginSafeValue(val)
  if CLIGAMESTATE ~= "Game" then
    CheckForRelog()
  end
  if val == nil then
    val = 0
  end
  return val
end

function CheckForRelog()
  if CLIGAMESTATE ~= "Game" then
    DoRelog()
  end
  CloseLoginWindows()
end

function DoRelog()
  Log("Logged out")
  repeat
    sleep(1000)
  until CLIGAMESTATE == "Login"
  LoginCharacter()
end

function LoginCharacter()
  if Email ~= nil then
    SetUsername(Email)
    sleep(5000)
  end
  Login()
  sleep(10000)
  SelectServer("cluster1.shardsonline.com:5150")
  sleep(5000)
  repeat
    CharacterSelect(CharacterNumber)
    sleep(1000)
  until CLIGAMESTATE == "Game"
  Log("Relogged")
end

function CloseLoginWindows()
  ClosePanel("NewsWindow")
  ClosePanel("Power")
end

-- Always keep a weapon equipped, Weapon must be set in config
function KeepEquiped()
  if DoEquip then
    if GetTime() > (LastEquip + EquipDelay) then
      if (Weapon ~= nil) then
        if RightHandCheck(Weapon) == false then
          Equip(Weapon)
        end
      end
      if (Shield ~= nil) then
        if LeftHandCheck(Shield) == false then
          Equip(Shield)
        end
      end
      LastEquip = GetTime()
    end
  end
end

-- Eat if you're hungry, FoodSlot must be set in config
function Eat()
  if DoEat then
    if GetTime() > (LastEat + EatDelay) then
      if CHARBUFFS ~= nil then
        for i, v in ipairs(CHARBUFFS) do
          Hunger = "Hunger"
          if string.find(v:lower(), Hunger:lower()) then
            AsboluteMacro(FoodSlot)
            Log("Eating")
          end
        end
      end
      LastEat = GetTime()
    end
  end
end

-- Text to speech so you can have updates will you AFK.
function Speak(Text)
  Log(Text)
  if AllowSpeech then
    os.execute("mshta vbscript:Execute(\"CreateObject(\"\"SAPI.SpVoice\"\").Speak(\"\"" ..
      Text .. "\"\")(window.close)\")")
  end
end

-- Count the amount of a specific item in a container
function GetItemCount(ItemName, ContainerID)
  FindItem(ItemName, ContainerID);
  if FINDITEM == nil then
    return 0
  end
  NumberInBackPack = tonumber(string.match(FINDITEM[1].NAME, "%d+"));
  if (NumberInBackPack == nil) then
    return 1
  end
  return NumberInBackPack
end

function LogoutAndEndScript(Error)
  if (AutoLogout) then
    Speak(Error)
    Logout()
  end
  repeat
    SafeSleep(10000)
  until true == false
end

-- Pick up items from the floor.
function HarvestItemsFromFloor(ItemName)
  FindItem(ItemName, 0)
  if FINDITEM ~= nil and FINDITEM[1].DISTANCE < 15 then
    Speak("Getting " .. ItemName)
    Item = FINDITEM[1]
    Walk(Item.x, Item.y, Item.z)
    TargetCount = GetItemCount(Item.NAME, BackpackRegBag)
    Drag(Item.ID)
    SafeSleep(1000)
    -- repeat
    --   SafeSleep(1000)
    Dropc(GetLoginSafeValue(BACKPACKID))
    -- NewTargetCount = GetItemCount(Item.NAME, BackpackRegBag)
    SafeSleep(500)
    -- until NewTargetCount > TargetCount
  end
end

-- Handle persistant storage to variables can survive a script restart.
function SetPersistentValue(ID, Value)
  local FileName = ScriptID .. "." .. CharacterName .. "." .. ID
  local File = io.open("c:\\Users\\Games\\Desktop\\Scripts\\persistence\\" .. FileName, "w")
  if not File then return false end
  File:write(tostring(Value))
  File:close()
  return true
end

-- Handle persistant storage to variables can survive a script restart.
function GetPersistentValue(ID)
  local FileName = ScriptID .. "." .. CharacterName .. "." .. ID
  local File = io.open("c:\\Users\\Games\\Desktop\\Scripts\\persistence\\" .. FileName, "rb")
  if not File then return nil end
  local Content = File:read "*a" -- *a or *all reads the whole file
  File:close()
  return Content
end

function GetPersistentInt(ID)
  return tonumber(GetPersistentValue(ID))
end

function SetPersistentInt(ID, Value)
  return SetPersistentValue(ID, tonumber(Value))
end

-- Count the amount of a non stackable item in a container.
function CountNonStackable(Item, ContainerID)
  FindItem(Item, ContainerID)
  if FINDITEM == nil then
    return 0
  end
  return #FINDITEM
end

function GetMultipleNonStackableFromContainer(Item, Amount, SourceContainer, DestinationContainer)
  OpenContainer(SourceContainer)
  if DestinationContainer == BACKPACKID then
    OpenBackpack()
  else
    OpenContainer(DestinationContainer)
  end
  Count = CountNonStackable(Item, DestinationContainer)
  if (Count < Amount) then
    for i = (Amount - Count), 1, -1 do
      FindItem(Item, SourceContainer)
      if FINDITEM ~= nil then
        Drag(FINDITEM[1].ID)
        repeat
          SafeSleep(1000)
          Dropc(DestinationContainer)
        until CountNonStackable(Item, DestinationContainer) > Count
        Count = CountNonStackable(Item, DestinationContainer)
      end
    end
  end
end

function RestockItemFromContainer(Item, Amount, BankContainer, BackpackContainer)

  FindItem(Item, BankContainer);
  if (FINDITEM == nil) then
    NumberInBank = 0
    return "No " .. Item .. " in bank!"
  else
    BankPile = FINDITEM[1];
    -- Parse the number from the start of the item, if there's no number then there's 1
    NumberInBank = tonumber(string.match(BankPile.NAME:gsub(",", ""), "%d+"));
    if NumberInBank == nil then
      NumberInBank = 1
    end
  end

  FindItem(Item, BackpackContainer);
  if (FINDITEM == nil) then
    NumberInBackPack = 0
  else
    BackPackPile = FINDITEM[1];
    -- Parse the number from the start of the item, if there's no number then there's 1
    NumberInBackPack = tonumber(string.match(BackPackPile.NAME:gsub(",", ""), "%d+"));
    if NumberInBackPack == nil then
      NumberInBackPack = 1
    end
  end

  if NumberInBackPack > Amount then
    Source = BackpackContainer
    Destination = BankContainer
    Difference = NumberInBackPack - Amount
  elseif NumberInBackPack < Amount then
    Source = BankContainer
    Destination = BackpackContainer
    Difference = Amount - NumberInBackPack
  else
    return "Already at correct ammount"
  end

  GetFromContainer(Item, Source, Difference, Destination)
end
