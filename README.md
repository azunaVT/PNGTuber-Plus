# PNGTuber Plus

![Build Status](https://github.com/litruv/PNGTuber-Plus/workflows/Build%20Windows/badge.svg)

A fork of [kaiakairos/PNGTuber-Plus](https://github.com/kaiakairos/PNGTuber-Plus) with some quality-of-life upgrades, editor polish, and a few power-user toys.

---

## 🔧 Fork Changes (Litruv Edition)

### 🎛️ Opacity Controls

Added a proper opacity slider for sprites, with an "affect children" toggle. Clip masks still behave like they should.

![Opacity Demo](https://github.com/user-attachments/assets/d5a05508-1cb1-46e0-8c90-d0aac73398db)


### 🌀 Rotation Wobble

Sprites can now do a subtle (or chaotic) rotational wobble. Frequency + amplitude sliders included.

![Rotation Wobble](https://github.com/user-attachments/assets/f45c3cc8-98d8-48cf-8821-b015de0a2f78)


### 🔗 Wobble Sync Groups

Keep multiple sprites in sync with wobble sync groups. Create groups, assign sprites, and all wobble parameters (X/Y/Rotation frequency, amplitude) automatically sync across group members. Perfect for ears, hair, accessories, or any elements that should move together.

* Create custom sync groups with descriptive names
* Assign multiple sprites to the same group
* Edit any group member's wobble settings to update the entire group
* Visual indicators show which sprites are synced
* Groups persist in save files
 

### ⌨️ Enhanced Modifier Keys

Supports combos like Ctrl+Shift+Alt+Cmd. For people with more keybinds than fingers.

![Modifier Keys](https://github.com/user-attachments/assets/6d492134-f929-4e3e-a6c6-a89cf16cd62f)


### ↗️ Editor Middle Mouse Button Panning

Hold MMB in the editor to pan around the scene, it'll reset when you go back to live.

![Panning](https://github.com/user-attachments/assets/b8687b69-fc84-43c9-950b-70395ae54820)

### ↗️ View Mode MMB Shake

Hold MMB in view mode to shake your character, Show off them physics!

![viewmodeshake](https://github.com/user-attachments/assets/536dc4ae-0562-494f-8cd0-2d2ef115f085)


### 🎞️ Delta Time Physics

Physics are now framerate-independent. Low FPS won’t make your character move in slow motion anymore. 
Just smooth, consistent jank if that’s your thing. Great for stop-motion vibes.


### 🎤 Microphone Fixes

Merged in [k0ffinz’s](https://github.com/k0ffinz/PNGTuber-Plus) audio tweaks:

* Reduced mic startup delay
* Better loudness detection
* General stability improvements


### 🧱 Engine Update

Updated to **Godot 4.4.1** — no more editor nags or compatibility weirdness.


### 🎚️ StreamDeck Integration

StreamDeck plugin was already in, this just wires up the buttons. 

---

## 🧾 Credits

* Original project by [kaiakairos](https://github.com/kaiakairos/PNGTuber-Plus)
* StreamDeck plugin from [BoyneGames](https://github.com/BoyneGames/streamdeck-godot-plugin)
* Mic improvements by [k0ffinz](https://github.com/k0ffinz/PNGTuber-Plus)
