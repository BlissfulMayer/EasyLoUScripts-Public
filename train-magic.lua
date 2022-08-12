require "utils"
require "auto-buy"

-- This script will repeatidly cast on your self while automatically buying regs
-- It also has an option to maximise healing skill gains.

-- Slot numbers are the numbers shown in game when you open the keyboard binding screen.
-- They start at 1 rather than the internal numbers used by EasyLOU which start at 0
-- GetLoginSafeValue() and SafeSleep() insure that the script will log you back in if logged out when it would normally die due to errors

SpellSlot = 10 -- A spell that deals damage
SpellMana = 20 -- The mana required to cast the spell
SpellDelay = 1.5 -- The spell delay in seconds

HealSlot = 1 -- Either a spell that heals or bandages
HealThreshold = 30 -- The amount of HP to start healing at, This should be more than the maximum damage of the spell
HealDelay = 11 -- The amount of ti_gainsme your healing spell or bandages take in seconds
MaximizeHealingGains = false -- If this is set to true healing is attempted between every cast rather than only when health is low, set to false to conserve bandages

MeditateSlot = 20 -- Meditation
MeditationDelay = 5 -- The amount of time to wait between meditation attempts in seconds

FoodSlot = 2 -- A slot with some food in it

BuyDelay = 600
LastBuy = 0
-- BuyTimesAllowed = 10 -- How many time should regs be purchased
BuyRegs = false
DoHeal = false

Vendors = {"Winston", "Asisa", "Conway"}
RegsToBuy = {"Spider's Silk", "Sulfurous Ash"}
LastHeal = GetTime()

AllowSpeech = true

function DoCastSpell()
	MacroTargetSelf(SpellSlot)
	SafeSleep(SpellDelay * 1000)
	-- Say("guards")
	if MaximizeHealingGains == true then
		AsboluteMacro(HealSlot)
	end
end

function DoMeditate()
	repeat
		-- if GetLoginSafeValue(INT) > 39 then
		-- 	AsboluteMacro(HealSlot)
		-- 	SpellSlot = 24
		-- 	SpellMana = 40
		-- end
		AsboluteMacro(MeditateSlot)
		SafeSleep(MeditationDelay * 1000)
		-- Say("guards")
	until GetLoginSafeValue(MANA) > GetLoginSafeValue(INT)-1
end

function DoBuy()
	for i,Vendor in ipairs(Vendors) do
		BuyFromVendor(Vendor, RegsToBuy, "All")
	end
end


function DoMagicHeal()
	if GetTime() > LastHeal + (HealDelay) then
		if HEALTH < HealThreshold then
				Log("Healing")
				AsboluteMacro(HealSlot)
		end
		LastHeal = GetTime()
	end
end


function DoBuyRegs()
	if BuyRegs then
		if GetTime() > LastBuy + (BuyDelay) then
			-- if(BuyCount < BuyTimesAllowed) then
				DoBuy()
				BuyCount = BuyCount + 1
			-- end
			LastBuy = GetTime()
		end
	end
end

Count = 0
BuyCount = 1
while true do
	Eat()
	print("looping")
	if GetLoginSafeValue(MANA) < SpellMana then
		print(1)
		-- Heal()
		DoMeditate()
	elseif GetLoginSafeValue(HEALTH) < HealThreshold then
		print(2)
		Heal()
		SafeSleep(13000)
		Heal()
	elseif GetLoginSafeValue(HEALTH) >= HealThreshold then
		print(3)
		DoCastSpell()
	end
	DoBuyRegs()
end
