require "utils"
require "config"

-- Restock a set amount of specific regs from your bank

function RestockRegs(Amount, RegNames)

  if RegNames == nil then
    RegNames = {
      "Black Pearl",
      "Blood Moss",
      "Mandrake Root",
      "Garlic",
      "Nightshade",
      "Spider's Silk",
      "Sulfurous Ash",
      "Ginseng",
    }
  end

  OpenBank()
  OpenBackpack()
  OpenContainer(BankRegBag)
  OpenContainer(BackpackRegBag)

  for i,RegName in ipairs(RegNames) do
    RestockItemFromContainer(RegName, Amount, BankRegBag, BackpackRegBag)
  end

  return true
end
