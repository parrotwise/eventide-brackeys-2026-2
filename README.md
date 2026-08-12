## Technical specs
- Godot version 4.7 stable, using the Compatibility renderer.
- Targeting a 1920×1080 Web export meant to be played on the browser.

## Code styling
- Please read the [[GDScript style guide]](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) in full *(it's a really good read!)*, and try to follow it as best you can.
- Prioritize readable code over compact code, use descriptive names, don't rely on comments to explain the code.

## Programming practices
- Use static typing, except in shorthand *(e.g. lambda functions)* or if support is spotty *(e.g. nested containers)*.
- Use signals liberally to decouple object logic, expose a signal for each event that other objects might react to.
  - Connect signals to behaviors across objects in the scene root's `_ready()` callback *(e.g. the game level)*.
  - Implement global events *(e.g. game finished)* as signals of the `Game` autoload, connect them the same way.
- Use `@export` variables for any parameters that could be tuned during testing, to allow testing on the editor.
- Use composition to implement complex objects in a modular way, avoid inheritance except for basic use cases.
  - Implement components as nodes, put instances of each component under the parent object's scene tree.
  - Do initialization in the object's script, and leverage the tree order (top to bottom) for component processing.
  - To access a component from an object, define getters on the object to locate the component by its path.
  - To access the object from a component, have the object store a reference to itself in the comp on `_ready()`.
- Prioritize an early implementation over a high-performing one, don't pre-emptively stress about optimization.

## Collaboration practices
- Never commit a change without at least making a rudimentary check to confirm nothing is broken or crashing.
- Take ownership of scripts linked to your self-assigned tasks, make as few changes as possible in other scripts.
- Be mindful of others' current tasks, ask in `#programming` if there's an overlap that may cause merge conflicts.
- Don't let non-functional auto-corrections *(e.g. indentation, UIDs, floats)* risk merge conflicts, roll them back.
- Don't correct other people's code just for styling or refactoring, communicate in `#programming` instead.
- For the sake of speed, always commit to the main branch. If some merge conflicts slip through, just resolve them.

## Globals
- The `Game` autoload serves as a global registry of game object instances and game state flags/counters.
  - Have `Node` objects *(e.g. the player)* register their own instances as `Game` variables when `_ready()`.
  - Instantiate `Resource` scripts directly in `Game._ready()` and register those too as `Game` variables.
  - Declare game state parameters as `Game` variables, have other scripts treat them as public attributes.
- Instantiate audio players under the `Audio` autoload and handle audio events across game scenes in it.
- The `Debug` autoload can pretty-print debug messages and stack traces color-coded by debug level as desired.
- Use local enum definitions *only* if no other script will ever use them, otherwise use the `Enums` autoload.
- The `Random` utility class manages RNGs and exposes convenience functions for generating random values.

## Directory structure
- 📂 `assets`  *(media resources, not scenes or scripts)*
  - 📂 `art`  *(sprites/animations and derived resources)*
    - 📂 `plants`  *(subfolders by theme)*
      - 📄 `bushes.png`
      - 📄 `bushes_anim.tres`
      - 📄 `bushes_atlas.tres`
      - 📄 `bushes_tileset.tres`
      - 📄 `trees.png`
      - 📄 `...`
    - 📂 `...`
  - 📂 `audio`  *(music/sounds and derived resources)*
    - 📂 `music`  *(subfolders by asset type)*
      - 📄 `theme.ogg`
      - 📄 `theme_stream.tres`
      - 📄 `...`
    - 📂 `sfx`
      - 📄 `sound.wav`
      - 📄 `sound_stream.tres`
      - 📄 `...`
  - 📂 `fonts`
    - 📄 `font.otf`
    - 📄 `...`
  - 📂 `shaders`
    - 📄 `shader.gdshader`
    - 📄 `...`
  - 📂 `styles`
    - 📄 `theme.tres`
    - 📄 `stylebox.tres`
    - 📄 `...`
  - 📂 `...`
- 📂 `objects`  *(scenes and scripts together)*
  - 📂 `audio`  *(audio stream players)*
    - 📄 `music_player.gd`
    - 📄 `music_player.tscn`
    - 📄 `...`
  - 📂 `game`  *(game objects)*
    - 📂 `birbs`  *(subfolders by theme)*
      - 📄 `pigeon.gd`
      - 📄 `pigeon.tscn`
      - 📄 `...`
    - 📂 `...`
  - 📂 `global`  *(autoloads and utilities)*
    - 📄 `audio.gd`
    - 📄 `game.gd`
    - 📄 `...`
  - 📂 `ui`  *(control nodes)*
    - 📄 `menu.gd`
    - 📄 `menu.tscn`
    - 📄 `...`
- 📂 `temp`  *(test scenes etc, use as sandbox)*
  - 📂 `parrot`  *(make your own subfolder)*
    - 📄 `...`
  - 📂 `...`
