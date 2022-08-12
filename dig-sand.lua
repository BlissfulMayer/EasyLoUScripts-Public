require "utils"
require "config"
require "recall"
require "restock-regs"

-- Recall to the graveyard, dig sand till overweight
-- Recall to the bank, deposit sand, restock regs, restock shovels
-- Repeat


AllowSpeech = true

function DoDigging()
  DoRecal("Sand Graveyard")
  Speak("Digging")
  repeat
    Eat()
    Heal()
    FindItem("Shovel", BACKPACKID)
    UseSelected(FINDITEM[1].ID)
    WaitForTarget()
    TargetLoc(CHARPOSX, CHARPOSY, CHARPOSZ)
    KillNearbyMonsters()
    SafeSleep(2000)
  until GetLoginSafeValue(CHARWEIGHT) > 340
end

function DoBanking()
  DoRecal("Britain Bank")
  Speak("Banking")
  OpenBank()
  OpenContainer(BankRegBag)
  OpenContainer(BackpackRegBag)
  OpenContainer(BankToolBag)
  BankItems("Sand")
  BankItems("Gold")
  GetMultipleNonStackableFromContainer("Shovel", 3, BankToolBag, BACKPACKID)
  RestockRegs(10, {"Black Pearl", "Blood Moss", "Mandrake Root"})
end

while true do
  DoBanking()
  DoDigging()
end


