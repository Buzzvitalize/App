# Idle Battler Prototype

A vertical Godot mobile prototype for Android with a visually busy idle-battler layout already assembled in-scene.

## Features
- Auto battle with tap bonus damage.
- Enemy stages, waves, and rewards.
- Multiple upgradeable units with DPS scaling.
- Offline rewards and save/load persistence.
- UI-first mobile screen structure with framed panels, buttons, bars, and counters.
- Android export preset scaffold.

## Project Structure
- `scenes/main.tscn` - Main playable scene and prebuilt UI layout.
- `scripts/main_ui.gd` - HUD refresh, interaction wiring, and feedback animation.
- `scripts/game_manager.gd` - Main gameplay loop, state aggregation, and save/load integration.
- `scripts/enemy_manager.gd` - Enemy state, health, defeat rewards, and stage progression.
- `scripts/unit_manager.gd` - Unit roster, DPS totals, and upgrade costs.
- `scripts/save_manager.gd` - Persistence and offline reward calculation.
- `export_presets.cfg` - Starter Android export configuration.

## Run in Godot
1. Open the project in **Godot 4.2+**.
2. Load `project.godot`.
3. Press **F5** to run the main scene.
4. Tap/click the battlefield to deal bonus damage.
5. Upgrade units in the bottom barracks panels.

## Android Export
1. Install the Android export templates from the Godot editor if needed.
2. In Godot, open **Project > Export**.
3. Select the existing **Android** preset from `export_presets.cfg`.
4. Update the package name, keystore signing, SDK paths, and icons for your environment.
5. Export to `builds/android/idle-battler.apk` or another APK path.

## Notes
- The supplied task referenced an attached image, but no image file was available inside the workspace/thread context during implementation.
- Placeholder shapes/colors are intentionally bold and layered so the prototype already reads like a mobile game mockup inside the editor.
