CharacterName = "YourCharacterName2"
Email = "YourCharacterName2@email.com"
CharacterNumber = 0
RuneAction = "Recall"
RecallScrollsToCarry = 0

BankID = 502913450
BankRegBag = 311527237
BackpackRegBag = 504985328
BankToolBag = 346964921
HarvestingBag = 7060164

FindItem("Reagent Pouch", GetLoginSafeValue(BACKPACKID))
if FINDITEM then
  BackpackRegBag  = FINDITEM[1].ID
end

SelectedSmithingLocation = "Britain Forge"

FoodSlot = 2
CureSlot = 11
HealSlot = 1

LastHeal = 1
LastCure = 0
LastEat = 0

HealDelay = 5
CureDelay = 10
EatDelay = 300

HealThreshold = 50
Weapon = "Sword"
Shield = "Shield"

DoCure = false
DoHeal = true
DoEat = true

DoHealSpar = false
DoReEquip = true
ReEquipDelay = 1
LastReEquip = 0
SparTarget = "YourCharacterName"

EquipItems = {
	-- CHESTNAME = "Tunic",
	-- LEGSNAME = "Leggings",
	-- HEADNAME = "Coif",
	RIGHTHANDNAME = "Hatchet"
}
