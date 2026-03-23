# Idle Battler Prototype

A vertical Godot mobile prototype for Android with a visually busy idle-battler layout already assembled in-scene.

## Folder Structure
- `assets/placeholders/` - simple SVG placeholder art.
- `assets/ui/` - project icon and UI art.
- `scenes/` - main playable Godot scene.
- `scripts/managers/` - gameplay, enemy, unit, and save managers.
- `scripts/ui/` - screen-level UI controller.

## Features
- Auto battle with tap bonus damage.
- Enemy stages, waves, and rewards.
- Five upgradeable units with DPS scaling.
- Offline rewards and save/load persistence.
- UI-first mobile screen structure with framed panels, buttons, bars, and counters.
- Android export preset scaffold.

## Main Scene Structure
- Top HUD with coins, gems, stage, wave, and enemy health.
- Large battle arena with placeholder heroes, enemy, floating damage, and tap overlay.
- Middle skill bar with four skill buttons and AUTO toggle.
- Bottom barracks area with multiple unit upgrade cards and extra framed utility panels.

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
