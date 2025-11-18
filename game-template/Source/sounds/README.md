# Sound Assets

Place your game's sound effects in this directory.

## Supported Formats

- **WAV** - Recommended (16-bit, mono or stereo)
- **AIFF** - Also supported
- **MP3** - Supported (converted to ADPCM)

## Recommended Settings

- **Sample Rate**: 22050 Hz or 44100 Hz
- **Bit Depth**: 16-bit
- **Channels**: Mono (saves memory) or Stereo

## Organization

Organize your sounds by category:

```
sounds/
├── effects/
│   ├── jump.wav
│   ├── coin.wav
│   └── explosion.wav
├── ui/
│   ├── button-click.wav
│   └── menu-open.wav
├── ambient/
│   ├── wind.wav
│   └── rain.wav
└── music/
    ├── theme.mp3
    └── boss-battle.mp3
```

## Playing Sounds

### Sound Effects (Short Sounds)

```lua
import "CoreLibs/sound"

-- Load a sound
local jumpSound = playdate.sound.sampleplayer.new("sounds/effects/jump")

-- Play it
jumpSound:play()

-- Adjust volume (0.0 to 1.0)
jumpSound:setVolume(0.8)
```

### Music (Long Sounds)

```lua
-- Load music (streamed from disk)
local music = playdate.sound.fileplayer.new("sounds/music/theme")

-- Play music
music:play()

-- Loop music
music:play(0)  -- 0 = infinite loop

-- Stop music
music:stop()
```

### Sound With Parameters

```lua
local sound = playdate.sound.sampleplayer.new("sounds/effects/coin")

-- Play with volume
sound:setVolume(0.5)
sound:play()

-- Play with pitch (1.0 = normal, 2.0 = double speed)
sound:setRate(1.5)
sound:play()
```

## Tips

1. **Keep sounds short**: < 1 second for effects
2. **Use music sparingly**: Streams from disk, uses memory
3. **Normalize volume**: Make all sounds similar volume
4. **Test on device**: Speakers sound different than computer
5. **Compress music**: Use MP3 for long tracks

## Sound Manager Pattern

Create a centralized sound manager:

```lua
-- soundManager.lua
import "CoreLibs/sound"

SoundManager = {}

function SoundManager.init()
    SoundManager.sounds = {
        jump = playdate.sound.sampleplayer.new("sounds/effects/jump"),
        coin = playdate.sound.sampleplayer.new("sounds/effects/coin"),
    }
end

function SoundManager.play(soundName, volume)
    local sound = SoundManager.sounds[soundName]
    if sound then
        if volume then sound:setVolume(volume) end
        sound:play()
    end
end

-- Usage:
SoundManager.init()
SoundManager.play("jump", 0.8)
```

## Audio Synthesis

Playdate supports synthesized audio:

```lua
local synth = playdate.sound.synth.new()
synth:playNote("C4", 1.0)  -- Note, duration
```

## Tools

- [Audacity](https://www.audacityteam.org/) - Free audio editor
- [BFXR](https://www.bfxr.net/) - Sound effect generator
- [ChipTone](https://sfbgames.itch.io/chiptone) - Retro sound generator

## Example: Jump Sound

1. Create or find a jump sound effect
2. Export as 16-bit WAV, 22050 Hz, mono
3. Save to `sounds/effects/jump.wav`
4. Load in your game:

```lua
local jumpSound = playdate.sound.sampleplayer.new("sounds/effects/jump")

function Player:jump()
    -- Jump logic
    self.velocityY = -5

    -- Play sound
    jumpSound:play()
end
```

---

For more information, see the [Playdate SDK Sound Documentation](https://sdk.play.date/inside-playdate/#_sound).
