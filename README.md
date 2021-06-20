# KF2-StartWave

[![Steam Workshop](https://img.shields.io/static/v1?message=workshop&logo=steam&labelColor=gray&color=blue&logoColor=white&label=steam%20)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Subscriptions](https://img.shields.io/steam/subscriptions/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Favorites](https://img.shields.io/steam/favorites/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![Steam Update Date](https://img.shields.io/steam/update-date/2521731447)](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/GenZmeY/KF2-StartWave)](https://github.com/GenZmeY/KF2-StartWave/tags)
[![GitHub](https://img.shields.io/github/license/GenZmeY/KF2-StartWave)](LICENSE)

# Description
A utility mod that allows users to specify the starting wave and the boss that will spawn. Additionally, users can jump between waves during the match with a console command (mutate setwave, see below).
The purpose of this mod is to allow mappers to more efficiently test their maps for later waves or for the boss. It could also be used to skip early waves if you find them boring, or to test strategies against a specific boss.
It is designed to be compatible with every mutator and wave-based gamemode, and to require little to no maintenance after game updates.

**This is the same as [Pharrahnox's SetWave](https://steamcommunity.com/sharedfiles/filedetails/?id=1417081496), but with some fixes:**
- fixed starting Dosh for Endless mode.

# Usage
[See steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=2521731447)

***

**Note:** If you want to build/test/brew/publish a mutator without git-bash and/or scripts, follow [these instructions](https://tripwireinteractive.atlassian.net/wiki/spaces/KF2SW/pages/26247172/KF2+Code+Modding+How-to) instead of what is described here.

# Build
1. Install [Killing Floor 2](https://store.steampowered.com/app/232090/Killing_Floor_2/), Killing Floor 2 - SDK and [git for windows](https://git-scm.com/download/win);
2. Open git-bash in the folder: `C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame`
3. Clone this repository and go to the source folder:  
`git clone https://github.com/GenZmeY/KF2-StartWave && cd KF2-StartWave`
4. Run make.sh script:
`./make.sh --compile`
5. The compiled files will be here:  
`C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame\Unpublished\BrewedPC\Script\`

# Testing
You can check your build using the `make.sh` script.  
Open git-bash in the source folder and run the script:  
`./make.sh --test`  
On first launch, the script will create `testing.ini` file and launch the game with the settings from it. Edit this file if you need to test the mutator with different parameters.

# Bug reports
If you find a bug, go to the [issue page](https://github.com/GenZmeY/KF2-StartWave/issues) and check if there is a description of your bug. If not, create a new issue.  
Describe what the bug looks like and how reproduce it.  
Attach screenshots if you think it might help.

If it's a crash issue, be sure to include the `Launch.log` and `Launch_2.log` files. You can find them here:  
`C:\Users\<USERNAME>\Documents\My Games\KillingFloor2\KFGame\Logs\`  
Please note that these files are overwritten every time you start the game/server. Therefore, you must take these files immediately after the game crashes in order not to lose information.

# License
[GNU GPLv3](LICENSE)