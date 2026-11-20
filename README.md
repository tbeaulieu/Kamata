![image](https://github.com/tbeaulieu/Kamata/assets/3193399/06b3b21b-62cf-423d-8bc7-4203170a15b7)

# Kamata
 Another Ridge Racer 6 based dashboard for the GARW dash. I've been holding off on this one for a while trying to make it correct. There is a gauge peak functionality that will engage once you start driving, and will display when you are completely stopped (0 MPH/KMH), and your seatbelt is disconnected. You'll see the speed start scrolling when the peak is shown.

This repo contains a modified font (I redesigned it to be monospace) as downloaded from here: https://www.keshikan.net/fonts-e.html, here's the license for it: https://github.com/keshikan/DSEG/blob/master/DSEG-LICENSE.txt

It also contains another font that I developed; BoostedRegular.ttf. All risks are on you upon using it. Distribute it freely but please remember/note who made it :)

## Settings

Oil temperature and oil pressure can each be hidden with their Show row in the settings menu. Oil pressure can be shown in PSI or BAR. Coolant and oil temp High limits are in Celsius, and 0 turns the warning off.

## Layout

- `Kamata.qml` - entry file: live data, config load/save, joystick handling, settings menu
- `KamataDisplay.qml` - the dial itself
- `SettingsMenu.qml`, `SettingBox.qml`, `MonoText.qml`, `Theme.qml`, `GridBackground.qml` - settings menu (shared with AgeSolo)
- `SettingsPreview.qml` - standalone menu preview, not loaded by the dash
- `Kamata.qml.png` - preview shown in the dash picker

Settings are saved as JSON in `/opt/IC7/screen_configs/Kamata_config.json`. An existing `Kamata_config.txt` is imported once on first run.

---

# Installation notes:

1) Install via GARW Genie:  https://github.com/dustinsterk/GARWGenie

There are some prebuilt releases for the uploader, check with the Discord Channel here: https://discord.gg/bmKFrt8XP6
