# 📊 Tokebi Analytics for GameMaker

Simple analytics integration for GameMaker Studio that tracks player behavior and game events.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![GameMaker](https://img.shields.io/badge/GameMaker-Studio%202-green.svg)](https://www.yoyogames.com/gamemaker)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

## 📦 Installation

**Easy Install:** Download [`tokebi_analytics.yymps`](dist/tokebi_analytics.yymps) and drag into GameMaker Studio.

**Manual Install:** Copy the scripts from `src/` and create the manager object.

## ⚡ Quick Start

### 1. Install the Package

**Option 1 (Recommended):** Download from [GitHub Releases](../../releases/latest)  
**Option 2:** Download [`tokebi_analytics.yymps`](dist/tokebi_analytics.yymps) directly from this repo

Then **drag the .yymps file into GameMaker Studio** - it will install automatically!

**Manual Installation:** Copy the 3 scripts from `src/` and create `obj_tokebi_manager` using the code in `src/obj_tokebi_manager.gml`.

### 2. Get Your Tokebi Credentials
1. Go to [tokebimetrics.com](https://tokebimetrics.com)
2. **Sign up** for an account
3. **Create a new game** in your dashboard
4. Copy your **API Key** and **Game ID**

### 3. Configure in Your Game
In your main game object's **Create Event**:
```gml
// Replace with your actual credentials from Tokebi dashboard
global.tokebi_api_key = "tk_live_abc123def456";  // Your API key
global.tokebi_game_id = "my-awesome-game";       // Your game name
tokebi_init();
```

**Example with real values:**
```gml
global.tokebi_api_key = "tk_live_abc123def456ghi789";
global.tokebi_game_id = "super-puzzle-adventure";
tokebi_init();
```

### 4. Track Events
```gml
// Start session when player begins
tokebi_start_session();

// Track events throughout gameplay
tokebi_track("menu_opened", noone);
tokebi_track_level_start("level_1");
tokebi_track_level_complete("level_1", 45.2, 1500);
tokebi_track_purchase("health_potion", "gold", 50);

// End session when player quits
tokebi_end_session();
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
- 📈 **Real-time Analytics** - Live dashboard at [tokebimetrics.com](https://tokebimetrics.com)
- 🔄 **Auto-batching** - Events sent every 30 seconds automatically
- 💾 **Offline Support** - Events saved when offline, sent when back online
- 🎯 **Pre-built Events** - Common game events ready to use
- 🛡️ **Reliable** - Auto-retry failed requests

## 📁 Project Structure

```
gamemaker-tokebi-analytics/
├── README.md                    # This file
├── CHANGELOG.md                 # Version history
├── LICENSE                      # MIT license  
├── .gitignore                   # Git ignore rules
├── src/                         # Source files
│   ├── tokebi_core.gml         # Main functions
│   ├── tokebi_http.gml         # HTTP handling
│   ├── tokebi_storage.gml      # Offline storage
│   └── obj_tokebi_manager.gml  # Manager object events
├── examples/                    # Usage examples
│   ├── basic_usage.gml         # Simple implementation
└── dist/                       # Ready-to-use packages
    └── tokebi_analytics.yymps  # GameMaker package
```

## 📁 Examples

Check the `examples/` folder for detailed usage patterns:
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
