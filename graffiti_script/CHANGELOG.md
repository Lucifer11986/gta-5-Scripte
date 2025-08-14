# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-08-14

This release marks a major overhaul of the script to fix critical bugs, improve stability, and add new features.

### Added
- **Graffiti Rendering:** Implemented the client-side logic to actually render graffiti decals on walls.
- **Anti-Spam Feature:** Added a server-side check to prevent players from spraying graffiti too close to each other. The minimum distance is configurable in `config.lua`.
- **Server-side Graffiti Cache:** The server now caches graffiti locations for improved performance of the anti-spam check.
- **Texture Dictionary Support:** The script is now configured to load graffiti textures from a `.ytd` file.
- **README.md:** Added a comprehensive README file.
- **CHANGELOG.md:** This changelog was created.

### Fixed
- **Critical Database Error:** Corrected the `graffiti` table schema in `sql.sql` to match the data being saved by the script.
- **Inconsistent Item System:** Unified the entire item flow. The script now consistently uses `spraycan_<color>` items, which are correctly consumed on use.
- **Broken UI Flow:** The NUI for selecting motifs is now correctly loaded and integrated. The entire communication chain from Lua -> JS -> Lua has been repaired.
- **Argument Mismatch:** Fixed a bug where client-to-server events had arguments in the wrong order.
- **Dead Code:** Removed unused event handlers and redundant files (`graffiti_mangment.lua`).

### Changed
- **Complete rewrite of `client/graffiti.lua`** to implement correct decal placement logic.
- **Complete rewrite of `html/script.js`** for a better user experience and compatibility.
- **Major refactor of `server/graffiti_management.lua`** to support the anti-spam feature.
- **Updated `fxmanifest.lua`** to load all necessary files, including UI, items, and the texture dictionary.
- **Updated `config.lua`** with a more robust data structure for motifs and a new setting for the anti-spam distance.
