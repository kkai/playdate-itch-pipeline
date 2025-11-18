# Font Assets

Place your custom fonts in this directory.

## Playdate Font Format

Playdate uses a custom bitmap font format (`.fnt`).

## Creating Fonts

### Option 1: Use Caps (Recommended)

[Caps](https://play.date/caps/) is Playdate's official font creation tool.

1. Visit [play.date/caps](https://play.date/caps/)
2. Upload a TTF or OTF font
3. Configure settings
4. Download the `.fnt` file

### Option 2: Font Converter

Use the Playdate SDK font converter:

```bash
# Convert TTF/OTF to Playdate format
$PLAYDATE_SDK_PATH/bin/fontconverter input.ttf output
```

## Using Fonts

### Load a Custom Font

```lua
import "CoreLibs/graphics"
local gfx = playdate.graphics

-- Load font
local customFont = gfx.font.new("fonts/my-font")

-- Set as current font
gfx.setFont(customFont)

-- Draw text
gfx.drawText("Hello, World!", 10, 10)
```

### Font Families

Organize fonts by family:

```
fonts/
├── game-font/
│   ├── font-regular.fnt
│   ├── font-bold.fnt
│   └── font-italic.fnt
└── ui-font/
    └── font.fnt
```

### Multiple Fonts

```lua
local fonts = {
    regular = gfx.font.new("fonts/game-font/font-regular"),
    bold = gfx.font.new("fonts/game-font/font-bold"),
    ui = gfx.font.new("fonts/ui-font/font")
}

-- Switch fonts
gfx.setFont(fonts.bold)
gfx.drawText("Bold Text", 10, 10)

gfx.setFont(fonts.regular)
gfx.drawText("Regular Text", 10, 30)
```

## Built-in Fonts

Playdate includes system fonts:

```lua
-- System font (default)
local systemFont = gfx.getSystemFont()
gfx.setFont(systemFont)

-- Variants
local boldFont = gfx.font.new(gfx.font.kVariantBold)
local italicFont = gfx.font.new(gfx.font.kVariantItalic)
```

## Font Metrics

```lua
local font = gfx.font.new("fonts/my-font")

-- Get text width
local width = gfx.getTextSize("Hello", font)

-- Get font height
local height = font:getHeight()

-- Get specific glyph width
local glyphWidth = font:getGlyph("A"):width
```

## Text Drawing

### Basic Text

```lua
gfx.drawText("Hello!", 10, 10)
```

### Centered Text

```lua
local text = "Centered Text"
local width = gfx.getTextSize(text)
local x = (400 - width) / 2  -- 400 = screen width
local y = 120 - font:getHeight() / 2  -- 120 = screen center

gfx.drawText(text, x, y)
```

### Right-Aligned Text

```lua
local text = "Right Aligned"
local width = gfx.getTextSize(text)
local x = 400 - width - 10  -- 10px padding

gfx.drawText(text, x, 10)
```

### Multi-line Text

```lua
local lines = {
    "Line 1",
    "Line 2",
    "Line 3"
}

local y = 10
for i, line in ipairs(lines) do
    gfx.drawText(line, 10, y)
    y += font:getHeight() + 5  -- 5px line spacing
end
```

## Tips

1. **Test readability**: Ensure fonts are readable on device
2. **Consistent sizing**: Use same font sizes throughout
3. **Bitmap fonts**: Work best at designed size
4. **Include all glyphs**: Ensure font has all characters you need
5. **License check**: Verify font license allows game use

## Font Resources

### Free Fonts

- [Google Fonts](https://fonts.google.com/)
- [Font Squirrel](https://www.fontsquirrel.com/)
- [DaFont](https://www.dafont.com/) (check licenses)

### Pixel Fonts

Perfect for Playdate:

- [Kenney Fonts](https://kenney.nl/assets/kenney-fonts)
- [Pixel Fonts on Itch.io](https://itch.io/game-assets/tag-font)

### Creating Pixel Fonts

- [FontStruct](https://fontstruct.com/)
- [Bits N Picas](https://github.com/kreativekorp/bitsnpicas)

## Example: UI Text

```lua
import "CoreLibs/graphics"
local gfx = playdate.graphics

-- Load fonts
local titleFont = gfx.font.new("fonts/title-font")
local bodyFont = gfx.font.new("fonts/body-font")

function drawMenu()
    -- Draw title
    gfx.setFont(titleFont)
    local titleWidth = gfx.getTextSize("GAME MENU")
    gfx.drawText("GAME MENU", (400 - titleWidth) / 2, 20)

    -- Draw menu options
    gfx.setFont(bodyFont)
    gfx.drawText("1. New Game", 50, 80)
    gfx.drawText("2. Continue", 50, 110)
    gfx.drawText("3. Settings", 50, 140)
    gfx.drawText("4. Quit", 50, 170)
end
```

---

For more information, see the [Playdate SDK Font Documentation](https://sdk.play.date/inside-playdate/#_fonts).
