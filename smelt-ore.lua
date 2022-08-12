require "utils"
require "config"

-- Helper scripts for smelting ore, used by the mining script.

function SmeltOreTypeIndividually(OreToSmelt)
  GetAllFromContainer(OreToSmelt, BACKPACKID, HarvestingBag)
  FindItem(OreToSmelt, HarvestingBag);
  if(FINDITEM ~= nil) then
    OrePile = FINDITEM[1].ID;
    repeat
      OriginalOreInBackback = GetItemCount(OreToSmelt, BACKPACKID)
      ContextMenu(OrePile, "Split Stack")
      SplitStack = WaitForPanel("StackSplit")
      SetInput(SplitStack, "TextFieldStackAmount", 1)
      WaitForButtonThenClick(SplitStack, "Accept")
      local startTime = GetTime()
      repeat
        SafeSleep(100)
        Dropc(BACKPACKID)
        OreInBackback = GetItemCount(OreToSmelt, BACKPACKID)
      until OreInBackback > OriginalOreInBackback or GetTime() > startTime + 5
      SingleOre = FINDITEM[1].ID;
      UseSelected(SmithingLocations[SelectedSmithingLocation].ForgeId)
      WaitForTarget()
      TargetDynamic(SingleOre)
      FindItem(OreToSmelt, HarvestingBag);
    until FINDITEM == nil
  end
end

function SmeltOreType(OreToSmelt)
  FindItem(OreToSmelt, BACKPACKID)
  if FINDITEM ~= nil then
    UseSelected(SmithingLocations[SelectedSmithingLocation].ForgeId)
    WaitForTarget()
    TargetDynamic(FINDITEM[1].ID)
  end
end

function SmeltAllOre(AlwaysSmeltAll)
  FindItem("Ore", BACKPACKID)
  if FINDITEM then
    repeat
    for Ore in FINDITEM do
      if AlwaysSmeltAll == true or OreTypes[Ore.NAME].SmeltAll == true then
        SmeltOreType(Ore.NAME)
      else
        SmeltOreTypeIndividually(Ore.NAME)
      end
      SafeSleep(1000)
      FindItem("Ore", BACKPACKID)
    end
    until FINDITEM == nil
  end
end
