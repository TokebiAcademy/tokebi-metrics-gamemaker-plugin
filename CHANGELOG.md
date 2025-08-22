# Changelog

All notable changes to the GameMaker Tokebi Analytics plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-22

### Added
- Initial release of GameMaker Tokebi Analytics plugin
- Core tracking functions (`tokebi_init`, `tokebi_track`, `tokebi_start_session`, `tokebi_end_session`)
- Predefined event functions for levels and purchases
- Automatic event batching and flushing every 30 seconds
- Offline event storage and retry mechanism
- Game registration with Tokebi platform
- Session management with unique session IDs
- Persistent player ID generation
- HTTP request handling with proper error management
- Auto-flush timer via `obj_tokebi_manager`
- Support for custom event data via ds_maps

### Features
- 🚀 Easy 3-script setup
- 📊 Real-time analytics dashboard integration
- 💾 Offline event persistence
- 🔄 Automatic retry of failed requests
- 🎯 Built-in level and purchase tracking
- 🛡️ Reliable event delivery
- ⚡ Minimal performance impact

### Technical Details
- Compatible with GameMaker Studio 2.3+
- Uses async HTTP requests (non-blocking)
- JSON-based event format
- Automatic game ID resolution
- Queue-based event batching (max 100 events)
- File-based offline storage
- Cross-session player tracking

---

## Template for Future Releases

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

---

**Release Notes:**
- Each version follows semantic versioning (MAJOR.MINOR.PATCH)
- Breaking changes increment MAJOR version
- New features increment MINOR version  
- Bug fixes increment PATCH version
