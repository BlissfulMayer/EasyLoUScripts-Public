require "utils"
require "config"

-- Try not die, for use when you're a sparring target or to run in the background while in dungeons.

DoReEquip = false
LastReEquip = 0
ReEquipDelay = 2

function Cure()
  if DoCure then
    if GetTime() > LastCure + (CureDelay) then
      if GetLoginSafeValue(CHARBUFFS) ~= nil then
        for i, v in ipairs(GetLoginSafeValue(CHARBUFFS)) do
          if string.find(v:lower(), "poison") then
            LastCure = GetTime()
            Heal()
            Log("Curing")
            AsboluteMacro(CureSlot)
          end
        end
      end
    end
  end
end

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
  SafeSleep(100)
  Eat()
  Cure()
  Heal()
  ReEquip()
end
