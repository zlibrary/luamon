require "luamon.class"

local version = string.match(_VERSION, "5.*")
if (not version) or (tonumber(version) <= 5.1) then
    error("please use version 5.2 or above.")
end
