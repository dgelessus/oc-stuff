--[[ test_bios
Very basic BIOS that provides a very basic Lua prompt.
Text input, the backspace key and clipboard are supported.
Any computer events (except key presses and clipboard) are displayed on screen.
A convenient print function is also made available in the global namespace.
--]]

local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.maxResolution()
local prompt = "(function() "
local inbuf = ""

gpu.bind(component.list("screen")())
gpu.setResolution(w, h)
gpu.setDepth(gpu.maxDepth())
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)

function print(...)
  local s = ""
  local args = table.pack(...)
  for i = 1, args.n do
    s = s .. tostring(args[i]) .. "    "
  end
  
  repeat
    gpu.set(1, h, unicode.sub(s, 1, w))
    gpu.copy(1, 2, w, h-1, 0, -1)
    gpu.fill(1, h, w, 1, " ")
    s = unicode.sub(s, w)
  until #s <= 0
end

running = true
while running do
  gpu.set(1, h, prompt)
  gpu.set(unicode.len(prompt) + 1, h, inbuf)
  gpu.set(unicode.len(prompt) + unicode.len(inbuf) + 1, h, "_")
  
  local sig = table.pack(computer.pullSignal())
  if sig[1] == "key_down" then
    local char, code = sig[3], sig[4]
    
    if code == 0x0E then
      gpu.set(unicode.len(prompt) + unicode.len(inbuf) + 1, h, " ")
      inbuf = unicode.sub(inbuf, 1, -2)
    elseif code == 0x1C then
      gpu.set(unicode.len(prompt) + unicode.len(inbuf) + 1, h, " end)()")
      print()
      local loaded, error = load(inbuf, "=(input)", "t")
      if loaded then
        local ret = table.pack(pcall(loaded))
        if ret[1] then
          print("-->", table.unpack(ret, 2, ret.n))
        else
          print("--!", ret[2])
        end
      else
        print("--?", error)
      end
      inbuf = ""
    elseif char ~= 0 then
      inbuf = inbuf .. unicode.char(char)
    end
  elseif sig[1] == "key_up" then
    --
  elseif sig[1] == "clipboard" then
    inbuf = inbuf .. sig[3]
  else
    print(table.unpack(sig))
  end
end

computer.shutdown(false)
