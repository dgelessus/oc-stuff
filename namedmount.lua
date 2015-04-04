-- NamedMount, a short boot script that gives labelled file systems named mount
-- points in /mnt. For example a floppy disk labelled "floppy" would get mounted
-- at /mnt/floppy in addition to the normal mount point assigned by the OS.
-- 
-- All non-alphanumeric characters except the underscore are replaced with
-- an underscore to ensure that the name is usable in a shell.
-- If a conflicting mount point already exists, the start of the address is
-- appended to the label to prevent overwriting other mount points.
--------------------------------------------------------------------------------

local component = require("component")
local event = require("event")
local fs = require("filesystem")

local function doNamedMount(name, address, componentType)
  if componentType == "filesystem" then
    local proxy = component.proxy(address)
    if proxy and proxy:getLabel() then
      local path = fs.concat("/mnt", (proxy:getLabel():gsub("[^%w_]+", "_")))
      if fs.exists(path) then
        -- Mount point exists already, start appending address
        local addrlen = 3
        local path = path .. "-" .. address:sub(1, addrlen)
        while fs.exists(path)
          and addrlen < address:len() -- just to be on the safe side
        do
          path = path .. address:sub(addrlen, addrlen)
        end
      end
      fs.mount(proxy, path)
    end
  end
end

function start(...)
  event.listen("component_added", doNamedMount)
end

-- Uncomment when placing this in /boot instead of using rc
-- start()
