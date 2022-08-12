require "utils"

-- Play a lute forever.

while true do
  FindItem("Lute", BACKPACKID)
  if FINDITEM ~= nil then
    UseSelected(FINDITEM[1].ID)
    SafeSleep(2000)
    Eat()
  end
end
