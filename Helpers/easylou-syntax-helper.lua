-- Stop vscode form complaining about EasyLOU functions and variables not existing

if true == false then
  CHARNAME = ""
  HEALTH = ""
  MANA = ""
  INT = ""
  CLIGAMESTATE = ""
  CHARID = ""
  CHARBUFFS = {}
  FINDPANEL = {}
  FINDINPUT = {}
  FINDBUTTON = {}
  FINDITEM = {}
  FINDLABEL = {}
  FINDMOBILE = {}
  FINDPERMANENT = {}
  BACKPACKID = ""
  CHARWEIGHT = ""
  CHARPOSX = ""
  CHARPOSY = ""
  CHARPOSZ = ""
  RIGHTHANDNAME = ""
  NEARBYMONSTERS = ""
  MONSTERSNEARBY = false
  LEFTHANDNAME = ""
  CLICKOBJ = {}
  CHARSTATUS = ""
  CHESTNAME = ""

  function ClosePanel(PanelID) end

  function TargetPermanent(ID) end

  function FindItem(Item, ContainerID) end

  function FindPermanent(PermanentId, MaxDistance) end

  function Key() end

  function Move(x, y, z) end

  function Stop() end

  function ScanJournal() end

  function Macro() end

  function Say(Text) end

  function SayCustom(Text) end

  function ToggleWarPeace() end

  function TargetDynamic(ObjectId) end

  function TargetPermanent() end

  function TargetLoc(x, y, z) end

  function LastTarget() end

  function TargetSelf() end

  function WaitForTarget() end

  function AttackSelected(ObjectID) end

  function UseSelected(Id) end

  function ContextMenu(ObjectId, Command) end

  function Drag(ItemID) end

  function Dropc(ContainerID) end

  function Dropg(x, y, z) end

  function sleep(var) end

  function FindMobile(Item) end

  function FindGameObject() end

  function SetUsername() end

  function SetPassword() end

  function Login() end

  function SelectServer(Server) end

  function CharacterSelect(Number) end

  function FindButton(Panel, ButtonName) end

  function FindInput() end

  function FindLabel() end

  function ClickButton(PanelName, ButtonName) end

  function GetTooltip() end

  function FindPanel(PanelName) end

  function SetInput(ContainerName, InputName, NewValue) end

  function SetTargetFrameRate() end

  function SetVSyncCount() end

  function SetMainCameraMask() end

  function ResetVars() end

  function Logout() end

  function SetUsername(Email) end
end
