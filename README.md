# StartWave

[![Steam Workshop](https://img.shields.io/static/v1?message=workshop&logo=steam&labelColor=gray&color=blue&logoColor=white&label=steam%20)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Favorites](https://img.shields.io/steam/favorites/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/GenZmeY/KF2-StartWave)](CHANGELOG.md)
[![GitHub](https://img.shields.io/github/license/GenZmeY/KF2-StartWave)](COPYING)

## Description
A utility mod that allows users to specify the starting wave and the boss that will spawn. Additionally, users can jump between waves during the match with a console command (mutate setwave, see below).
The purpose of this mod is to allow mappers to more efficiently test their maps for later waves or for the boss. It could also be used to skip early waves if you find them boring, or to test strategies against a specific boss.
It is designed to be compatible with every mutator and wave-based gamemode, and to require little to no maintenance after game updates.

- Server-side  
- Not whitelisted  
- Compatible with [SML](https://github.com/GenZmeY/KF2-SafeMutLoader)  

**This is the same as [Pharrahnox's StartWave](https://steamcommunity.com/sharedfiles/filedetails/?id=1417081496), but with some fixes:**
- Fixed starting Dosh for Endless mode  
- Fixed difficulty setting when changing wave  
- Optimized boss replacement: now it always works successfully and quickly  
- Players no longer need to download StartWave when connecting to a server  
- Added [SML](https://github.com/GenZmeY/KF2-SafeMutLoader) compatibility  

## Whitelist status
This mod is not whitelisted and will de-rank your server. Any XP earned will not be saved.  
To save your server's ranked status use [ranked patch](https://github.com/GenZmeY/KF2-Ranked-Patch) or [SML](https://github.com/GenZmeY/KF2-SafeMutLoader).  

## Usage
See [steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)

## Build
**Note:** If you want to build/brew/publish/test a mutator without git-bash and external scripts, follow [these instructions](https://tripwireinteractive.atlassian.net/wiki/spaces/KF2SW/pages/26247172/KF2+Code+Modding+How-to) instead of what is described here.  
1. Install [Killing Floor 2](https://store.steampowered.com/app/232090/Killing_Floor_2/), Killing Floor 2 - SDK and [git for windows](https://git-scm.com/download/win)  
2. open git-bash and go to any folder where you want to store sources:  
`cd <ANY_FOLDER_YOU_WANT>`  
3. Clone this repository and its dependencies:  
`git clone --recurse-submodules https://github.com/GenZmeY/KF2-StartWave`  
4. Go to the source folder:  
`cd KF2-StartWave`
5. Compile:  
`./tools/builder -c`  
The compiled files will be here:  
`%USERPROFILE%\Documents\My Games\KillingFloor2\KFGame\Unpublished`
6. (Optional) Brew:  
`./tools/builder -b`  
The brewed files will be here:  
`%USERPROFILE%\Documents\My Games\KillingFloor2\KFGame\Published`
7. (Optional) Upload to your steam workshop:  
`./tools/builder -u`  

## Contributors and Credits
- [Pharrahnox](https://steamcommunity.com/profiles/76561198021230296) - StartWave creator  
- [GenZmeY](https://steamcommunity.com/profiles/76561198001617867) - Fixes and optimizations  

## Status: Completed
- The mutator works with the current version of the game (v1150) and I have implemented everything I planned.  
- Development has stopped: I no longer have the time or motivation to maintain this mod. No further updates or bug fixes are planned.  

## Mirrors
- https://github.com/GenZmeY/KF2-StartWave  
- https://codeberg.org/GenZmeY/KF2-StartWave  

## License
**GPL-3.0-or-later**  
  
[![license](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)](COPYING)  
