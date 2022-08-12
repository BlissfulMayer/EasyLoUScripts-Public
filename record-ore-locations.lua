-- A helper script to log locations of items.
-- This is used to generate the config files for mining/lumberjack locations.
-- Bind this to a key, move to a location, click the object you want to mine/cut. Hit the key.


File = io.open ("c:\\Users\\Games\\Desktop\\Scripts\\locations.txt", "a")

-- if CLICKOBJ.PERMANENTID ~= nil then
--   File.write("{ x = " .. CHARPOSX .. " , y = " .. CHARPOSY .. " , z = " .. CHARPOSZ .. " , id = " .. CLICKOBJ.PERMANENTID .." },\n")
-- end
-- File.close();


File.write("{ x = " .. CHARPOSX .. " , y = " .. CHARPOSY .. " , z = " .. CHARPOSZ .. " },\n")
File.close()
