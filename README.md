# KF2-StartWave

[![Steam Workshop](https://img.shields.io/static/v1?message=workshop&logo=steam&labelColor=gray&color=blue&logoColor=white&label=steam%20)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Downloads](https://img.shields.io/steam/downloads/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Favorites](https://img.shields.io/steam/favorites/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![MegaLinter](https://github.com/GenZmeY/KF2-StartWave/actions/workflows/mega-linter.yml/badge.svg?branch=master)](https://github.com/GenZmeY/KF2-StartWave/actions/workflows/mega-linter.yml)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/GenZmeY/KF2-StartWave)](https://github.com/GenZmeY/KF2-StartWave/tags)
[![GitHub](https://img.shields.io/github/license/GenZmeY/KF2-StartWave)](LICENSE)

## Description
A utility mod that allows users to specify the starting wave and the boss that will spawn. Additionally, users can jump between waves during the match with a console command (mutate setwave, see below).
The purpose of this mod is to allow mappers to more efficiently test their maps for later waves or for the boss. It could also be used to skip early waves if you find them boring, or to test strategies against a specific boss.
It is designed to be compatible with every mutator and wave-based gamemode, and to require little to no maintenance after game updates.

**This is the same as [Pharrahnox's StartWave](https://steamcommunity.com/sharedfiles/filedetails/?id=1417081496), but with some fixes:**
- fixed starting Dosh for Endless mode;
- fixed difficulty setting when changing wave;
- optimized boss replacement: now it always works successfully and quickly;
- players no longer need to download StartWave when connecting to a server.

## Usage
[See steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)

***

**Note:** If you want to build/test/brew/publish a mutator without git-bash and/or scripts, follow [these instructions](https://tripwireinteractive.atlassian.net/wiki/spaces/KF2SW/pages/26247172/KF2+Code+Modding+How-to) instead of what is described here.  

## Build
**Note:** If you want to build/test/brew/publish a mutator without git-bash and/or scripts, follow [these instructions](https://tripwireinteractive.atlassian.net/wiki/spaces/KF2SW/pages/26247172/KF2+Code+Modding+How-to) instead of what is described here.  
1. Install [Killing Floor 2](https://store.steampowered.com/app/232090/Killing_Floor_2/), Killing Floor 2 - SDK and [git for windows](https://git-scm.com/download/win);  
2. open git-bash and go to any folder where you want to store sources:  
`cd <ANY_FOLDER_YOU_WANT>`  
3. Clone this repository and go to the source folder:  
`git clone https://github.com/GenZmeY/KF2-StartWave && cd KF2-StartWave`  
4. Download dependencies:  
`git submodule init && git submodule update`  
5. Compile:  
`./tools/builder -c`  
5. The compiled files will be here:  
`C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame\Unpublished\BrewedPC\Script\`  

## Bug reports
If you find a bug, go to the [issue page](https://github.com/GenZmeY/KF2-StartWave/issues) and check if there is a description of your bug. If not, create a new issue.  
Describe what the bug looks like and how reproduce it.  
Attach screenshots if you think it might help.  

If it's a crash issue, be sure to include the `Launch.log` file. You can find it here:  
`C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame\Logs\`  

## License
[![license](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)](LICENSE)  
