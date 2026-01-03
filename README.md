# savemanager.lua
savemanager for love2d

## Example
```lua
local sman = require "savemanager.lua"

if sman:ffileExist("save.lua") then
  -- if file exist
  local t = sman:fload("save.lua")
else
  -- if not
  sman:fwrite({
    save = "on" 
  },"save.lua")
end

```
