require "utils"
require "config"

-- Do arms lore on a sword forever

FindItem("Sword", BACKPACKID)
Target = FINDITEM[1].ID

while true do
  AsboluteMacro(8)
  WaitForTarget()
  TargetDynamic(Target)
  SafeSleep(1000)
  Eat()
  FindPanel("ArmsLore")
  if FINDPANEL ~= nil then
    ClosePanel(FINDPANEL[1].ID)
  end
end
