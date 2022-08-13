require "utils"
require "config"

SparHealThreshold = 100
DoHealSpar = true


-- Run this while sparring to practice healing ont he target.


while true do
  if DoHealSpar then
    FindMobile(SparTarget)
    if FINDMOBILE then
      Victim = FINDMOBILE[1]
      if SparHealThreshold == nil or (Victim.HP < SparHealThreshold) then
        FindItem("Bandage", GetLoginSafeValue(BACKPACKID))
        if FINDITEM then
          UseSelected(FINDITEM[1].ID)
          WaitForTarget()
          TargetDynamic(Victim.ID)
        end
      end
    end
    SafeSleep(5000)
  end
end
