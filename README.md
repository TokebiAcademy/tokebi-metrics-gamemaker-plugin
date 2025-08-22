# 📊 Tokebi Analytics for GameMaker

Simple analytics integration for GameMaker Studio that tracks player behavior and game events.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![GameMaker](https://img.shields.io/badge/GameMaker-Studio%202-green.svg)](https://www.yoyogames.com/gamemaker)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

## ⚡ Quick Start

### 1. Install
Copy the 3 scripts from `src/` into your GameMaker project:
- `tokebi_core.gml`
- `tokebi_http.gml` 
- `tokebi_storage.gml`

Create `obj_tokebi_manager` using the events in `src/obj_tokebi_manager/`

### 2. Configure
```gml
// In your game's Create event
global.tokebi_api_key = "your-api-key-here";
global.tokebi_game_id = "your-game-name";
tokebi_init();
```

### 3. Track Events
```gml
// Start session
tokebi_start_session();

// Track events
tokebi_track("menu_opened", noone);
tokebi_track_level_start("level_1");
tokebi_track_level_complete("level_1", 45.2, 1500);
tokebi_track_purchase("health_potion", "gold", 50);

// End session
tokebi_end_session();
```

## 📖 API Reference

### Core Functions
- `tokebi_init()` - Initialize the system
- `tokebi_start_session()` - Start tracking session
- `tokebi_end_session()` - End tracking session
- `tokebi_track(event_name, data_map)` - Track custom event
- `tokebi_flush_events()` - Manually send queued events

### Predefined Events
- `tokebi_track_level_start(level_name)`
- `tokebi_track_level_complete(level_name, time, score)`
- `tokebi_track_purchase(item_id, currency, cost)`

## ✨ Features

- 🚀 **Easy Setup** - Just 3 scripts and 1 object
- 📈 **Near-Real-time Analytics** - Live dashboard at [tokebimetrics.com](https://tokebimetrics.com)
- 🔄 **Auto-batching** - Events sent every 30 seconds automatically
- 💾 **Offline Support** - Events saved when offline, sent when back online
- 🎯 **Pre-built Events** - Common game events ready to use
- 🛡️ **Reliable** - Auto-retry failed requests

## 📁 Examples

Check the `examples/` folder for:
- `basic_usage.gml` - Simple implementation
- `rpg_game.gml` - RPG-style tracking
- `puzzle_game.gml` - Puzzle game events

## 🐛 Troubleshooting

**Events not sending?**
- Check your API key and game ID
- Look for error messages in the debug console
- Verify internet connection

**Registration failing?**
- Ensure game name has no special characters
- Check that Tokebi service is reachable

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- [Tokebi Platform](https://tokebimetrics.com)
- [Get API Key](https://tokebimetrics.com)
- [Documentation](https://www.tokebimetrics.com/documentation-guide)
