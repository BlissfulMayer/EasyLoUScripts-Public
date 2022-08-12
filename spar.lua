require "utils"
require "config"

-- Fight and heal someone
-- Auto equip a new weapon when it breaks.

DoReEquip = true
ReEquipDelay = 1
LastReEquip = 0

function ReEquip()
  if DoReEquip then
    if GetTime() > (LastReEquip + ReEquipDelay) then
      for Slot, Item in pairs(EquipItems) do
        if CheckEquip(Slot, Item) == false then
          Equip(Item)
        end
      end
      LastEquip = GetTime()
    end
  end
end

while true do

  FindMobile(SparTarget)

  ReEquip()

  if (FINDMOBILE) then
    Victim = FINDMOBILE[1]

    if Victim.HP < 30 then
      if string.find(GetLoginSafeValue(CHARSTATUS), "G") then
        ToggleWarPeace()
      end
    end

    if Victim.HP > 60 then
      if string.find(GetLoginSafeValue(CHARSTATUS), "G") == nil then
        ToggleWarPeace()
        AttackSelected(Victim.ID)
      end
    end

    Eat()

    if DoHealSpar then
      if GetTime() > LastHeal + (HealDelay) then
        if SparHealThreshold == nil or (Victim.HP < SparHealThreshold) then
          FindItem("Bandage", GetLoginSafeValue(BACKPACKID))
          if (FINDITEM) then
            UseSelected(FINDITEM[1].ID)
            WaitForTarget()
            TargetDynamic(Victim.ID)
          end
        end
        LastHeal = GetTime()
      end
    end

    SafeSleep(500)
  end
end
