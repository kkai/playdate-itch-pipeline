# Image Assets

Place your game's image assets in this directory.

## Supported Formats

- **PNG** - Recommended format
- **GIF** - For animations
- **JPG** - For photographs (converted to 1-bit)

## Playdate Image Requirements

- **1-bit depth** - Black and white only (no grayscale in final output)
- **Any size** - SDK will handle resizing
- **Transparent backgrounds** - Use PNG with transparency

## Organization

Organize your images in subdirectories:

```
images/
├── sprites/
│   ├── player.png
│   ├── enemy.png
│   └── powerup.png
├── backgrounds/
│   ├── level1.png
│   └── level2.png
├── ui/
│   ├── button.png
│   └── menu.png
└── tiles/
    ├── grass.png
    ├── stone.png
    └── water.png
```

## Loading Images

### Single Image

```lua
import "CoreLibs/graphics"
local gfx = playdate.graphics

local image = gfx.image.new("images/sprites/player")
image:draw(x, y)
```

### Image Table (for animation)

```lua
local imageTable = gfx.imagetable.new("images/sprites/player-walk")
-- Expects: player-walk-1.png, player-walk-2.png, etc.
```

### Using with Sprites

```lua
local sprite = gfx.sprite.new()
local image = gfx.image.new("images/sprites/player")
sprite:setImage(image)
sprite:moveTo(200, 120)
sprite:add()
```

## Tips

1. **Use descriptive names**: `player-idle.png` not `img1.png`
2. **Organize by type**: Separate sprites, backgrounds, UI elements
3. **Include states**: `player-walk-1.png`, `player-walk-2.png`, etc.
4. **Optimize size**: Smaller images load faster
5. **Test in simulator**: Preview how images look on device

## Tools

- [Playdate Pulp](https://play.date/pulp/) - Built-in sprite editor
- [Aseprite](https://www.aseprite.org/) - Pixel art editor
- [GIMP](https://www.gimp.org/) - Free image editor

## Example: Creating a Sprite

1. Create a 32x32 PNG in your image editor
2. Use only black and white
3. Save to `images/sprites/player.png`
4. Load in your game:

```lua
local playerImage = gfx.image.new("images/sprites/player")
```

---

For more information, see the [Playdate SDK Graphics Documentation](https://sdk.play.date/inside-playdate/#_graphics).
