--[[ colorsys
Provides a Color class that represents a RGB color, which can be created from
and converted to various color representations.

A few Minecraft-specific conversions from block or chat colors are available.
These can only be converted to a Color, not the other way around.

Default OpenComputers libraries do not accept Colors as arguments. Use the
toHex method to convert a Color to the expected format.
--]]

local colorsys = {}

-- Maps colored block metadata numbers to names and vice versa.
colorsys.blockColorNames = require("colors")

-- Maps colored block metadata numbers to RGB values.
colorsys.blockColors = {
  [0] = {0xff, 0xff, 0xff}, -- white
  {0xd8, 0x7f, 0x33}, -- orange
  {0xb2, 0x4c, 0xd8}, -- magenta
  {0x66, 0x99, 0xd8}, -- lightblue
  {0xe5, 0xe5, 0x33}, -- yellow
  {0x7f, 0xcc, 0x19}, -- lime
  {0xf2, 0x7f, 0xa5}, -- pink
  {0x4c, 0x4c, 0x4c}, -- gray
  {0x99, 0x99, 0x99}, -- silver
  {0x4c, 0x7f, 0x99}, -- cyan
  {0x7f, 0x3f, 0xb2}, -- purple
  {0x33, 0x4c, 0xb2}, -- blue
  {0x66, 0x4c, 0x33}, -- brown
  {0x66, 0x7f, 0x33}, -- green
  {0x99, 0x33, 0x33}, -- red
  {0x19, 0x19, 0x19}, -- silver
}

-- Maps chat color codes to names and vice versa.
colorsys.chatColorNames = {
  [0] = "black",
  "dark_blue",
  "dark_green",
  "dark_aqua",
  "dark_red",
  "dark_purple",
  "gold",
  "gray",
  "dark_gray",
  "blue",
  "green",
  "aqua",
  "red",
  "light_purple",
  "yellow",
  "white",
}

for k, v in pairs(colorsys.chatColorNames) do
  colorsys.chatColorNames[v] = k
end

-- Maps chat color codes to foreground RGB values.
colorsys.chatForegroundColors = {
  [0] = {0x00, 0x00, 0x00}, -- black
  {0x00, 0x00, 0xaa}, -- dark_blue
  {0x00, 0xaa, 0x00}, -- dark_green
  {0x00, 0xaa, 0xaa}, -- dark_aqua
  {0xaa, 0x00, 0x00}, -- dark_red
  {0xaa, 0x00, 0xaa}, -- dark_purple
  {0xff, 0xaa, 0x00}, -- gold
  {0xaa, 0xaa, 0xaa}, -- gray
  {0x55, 0x55, 0x55}, -- dark_gray
  {0x55, 0x55, 0xff}, -- blue
  {0x55, 0xff, 0x55}, -- green
  {0x55, 0xff, 0xff}, -- aqua
  {0xff, 0x55, 0x55}, -- red
  {0xff, 0x55, 0xff}, -- light_purple
  {0xff, 0xff, 0x55}, -- yellow
  {0xff, 0xff, 0xff}, -- white
}

-- Maps chat color codes to background RGB values.
colorsys.chatBackgroundColors = {
  [0] = {0x00, 0x00, 0x00}, -- black
  {0x00, 0x00, 0x2a}, -- dark_blue
  {0x00, 0x2a, 0x00}, -- dark_green
  {0x00, 0x2a, 0x2a}, -- dark_aqua
  {0x2a, 0x00, 0x00}, -- dark_red
  {0x2a, 0x00, 0x2a}, -- dark_purple
  {0x2a, 0x2a, 0x00}, -- gold
  {0x2a, 0x2a, 0x2a}, -- gray
  {0x15, 0x15, 0x15}, -- dark_gray
  {0x15, 0x15, 0x3f}, -- blue
  {0x15, 0x3f, 0x15}, -- green
  {0x15, 0x3f, 0x3f}, -- aqua
  {0x3f, 0x15, 0x15}, -- red
  {0x3f, 0x15, 0x3f}, -- light_purple
  {0x3f, 0x3f, 0x15}, -- yellow
  {0x3f, 0x3f, 0x3f}, -- white
}

-- Similar to OC's built-in checkArg function, but errors if min <= have <= max
-- is not true.
local function checkBounds(n, have, min, max)
  if have < min or have > max then
    error(("bad argument #%d (got %s, minimum %s, maximum %s)"):format(n, have, min, max))
  end
end

-- Represents a RGB color, with each component ranging
-- from 0 to 255 (inclusive). Although the components can technically be changed
-- in-place, this is not recommended. Color instances should be used as if they
-- were immutable.
colorsys.Color = setmetatable({ -- Table - instance methods
  -- Implements self == other. Return true if other is a Color-like object with
  -- equal components. This comparison is subject to the same precision
  -- behavior as normal floating-point comparison.
  __eq = function(self, other)
    return type(other) == "table" and self.r == other.r and self.g == other.g and self.b == other.b
  end,
  
  -- Implements tostring(self).
  __tostring = function(self)
    return ("colorsys.Color(%f, %f, %f)"):format(self:toRGB())
  end,
  
  -- Return the red, green and blue components of self, each ranging
  -- from 0 to 255 (inclusive).
  toRGB = function(self)
    return self.r, self.g, self.b
  end,
  
  -- Return the red, green and blue components of self, each ranging
  -- from 0.0 to 1.0 (inclusive).
  toRGBPercent = function(self)
    return self.r/255, self.g/255, self.b/255
  end,
  
  -- Return a "hexadecimal" representation of self as a number, in the format
  -- 0xRRGGBB, where each pair represents one RGB component ranging
  -- from 0x00 to 0xFF (inclusive).
  toHex = function(self)
    return math.floor(self.r) * 2^16 + math.floor(self.g) * 2^8 + math.floor(self.b)
  end,
}, { -- Metatable - class methods
  -- Implements cls(...). Generic constructor that accepts any of the
  -- following arguments:
  -- * one table: treat it as if it were a Color instance and copy it
  -- * one number: interpret it as a hexadecimal color number
  -- * three numbers: use them as the red, green and blue components
  __call = function(cls, r, g, b)
    checkArg(1, r, "number", "table")
    checkArg(2, g, "number", "nil")
    checkArg(3, b, "number", "nil")
    
    if type(r) == "table" and g == nil and b == nil then
      r, g, b = r.r, r.g, r.b
    elseif type(r) == "number" and g == nil and b == nil then
      return cls:fromHex(r)
    end
    
    checkBounds(1, r, 0, 255)
    checkBounds(2, g, 0, 255)
    checkBounds(3, b, 0, 255)
    
    return setmetatable({r=r, g=g, b=b}, cls)
  end,
  
  -- Return a Color with the given red, green and blue components, each ranging
  -- from 0 to 255 (inclusive).
  fromRGB = function(cls, r, g, b)
    checkArg(1, r, "number")
    checkArg(2, g, "number")
    checkArg(3, b, "number")
    checkBounds(1, r, 0, 255)
    checkBounds(2, g, 0, 255)
    checkBounds(3, b, 0, 255)
    return cls(r, g, b)
  end,
  
  -- Return a Color with the given red, green and blue components, each ranging
  -- from 0.0 to 1.0 (inclusive).
  fromRGBPercent = function(cls, r, g, b)
    checkArg(1, r, "number")
    checkArg(2, g, "number")
    checkArg(3, b, "number")
    checkBounds(1, r, 0.0, 1.0)
    checkBounds(2, g, 0.0, 1.0)
    checkBounds(3, b, 0.0, 1.0)
    return cls(r*255, g*255, b*255)
  end,
  
  -- Create a color from the given "hexadecimal" color, in the format
  -- 0xRRGGBB, where each pair represents one RGB component ranging
  -- from 0x00 to 0xFF (inclusive).
  fromHex = function(cls, hex)
    checkArg(1, hex, "number")
    checkBounds(1, hex, 0x0, 0xFFFFFF)
    
    local r = math.floor(hex / 2^16)
    hex = hex - r * 2^16
    local g = math.floor(hex / 2^8)
    hex = hex - g * 2^8
    local b = hex
    
    return cls(r, g, b)
  end,
  
  -- Convert the given "block color" name or metadata number to a Color.
  fromBlockColor = function(cls, code)
    checkArg(1, code, "string", "number")
    
    if type(code) == "string" then
      code = colorsys.blockColorNames[code]
      if code == nil then
        error(("bad argument #1 (unknown name %q)"):format(code))
      end
    end
    
    checkBounds(1, code, 0, 15)
    
    return cls(table.unpack(colorsys.blockColors[code]))
  end,
  
  -- Convert the given chat color name or number to its foreground color.
  fromChatColorForeground = function(cls, code)
    checkArg(1, code, "string", "number")
    
    if type(code) == "string" then
      code = colorsys.chatColorNames[code]
      if code == nil then
        error(("bad argument #1 (unknown name %q)"):format(code))
      end
    end
    
    checkBounds(1, code, 0, 15)
    
    return cls(table.unpack(colorsys.chatForegroundColors[code]))
  end,
  
  -- Convert the given chat color name or number to its background color.
  fromChatColorBackground = function(cls, code)
    checkArg(1, code, "string", "number")
    
    if type(code) == "string" then
      code = colorsys.chatColorNames[code]
      if code == nil then
        error(("bad argument #1 (unknown name %q)"):format(code))
      end
    end
    
    checkBounds(1, code, 0, 15)
    
    return cls(table.unpack(colorsys.chatBackgroundColors[code]))
  end,
})
getmetatable(colorsys.Color).__index = getmetatable(colorsys.Color)
colorsys.Color.__index = colorsys.Color

colorsys.Color.fromChatColor = colorsys.Color.fromChatColorForeground

return colorsys
