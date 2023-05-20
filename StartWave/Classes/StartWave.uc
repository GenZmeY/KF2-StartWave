class StartWave extends Info
	config(StartWave);

const OptionsParser = class'OptionsParser';

var private KFGameInfo            KFGI;
var private KFGameInfo_Survival   KFGIS;
var private KFGameInfo_Endless    KFGIE;

var private KFGI_Access           KFGIA;

var private KFGameReplicationInfo KFGRI;

/*********************************************************************************************************
 * Config properties
 *********************************************************************************************************/

/** The wave that the match should start on. It is clamped between wave 1 and the boss wave. */
var config int StartWave;
/** The duration of the 'initial' trader (before the first wave). */
var config int InitialTraderTime;
/** The duration of standard trader (between waves). */
var config int TraderTime;
/** The starting dosh of players. */
var config int Dosh;
/** Whether an 'initial' trader time should occur before the first wave. */
var config bool bStartWithTrader;
/** Log level. */
var config E_LogLevel LogLevel;

/**
*** The boss override index. For the default boss list, 0-Hans, 1-Patty, 2-King FP, 3-Abomination. Negative
*** values can be used to keep the boss spawn random.
***/
var config int Boss;

/*********************************************************************************************************
 * Instance variables
 *********************************************************************************************************/

/** Used to determine whether the initial trader is still open / hasn't been closed. */
var bool bInitialTrader;

//These are used to determine whether everything in OverrideTimer has been done.
/** Whether the difficulty settings have been overriden. */
var bool bOverridenDifficultySettings;
/** Whether the trader duration has been overriden. */
var bool bOverridenTraderDuration;

public simulated function bool SafeDestroy()
{
	`Log_Trace();

	return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
	`Log_Trace();

	if (WorldInfo.NetMode == NM_Client)
	{
		`Log_Fatal("Wrong NetMode:" @ WorldInfo.NetMode);
		SafeDestroy();
		return;
	}

	Super.PreBeginPlay();

	PreInit();
}

public event PostBeginPlay()
{
	`Log_Trace();

	if (bPendingDelete || bDeleteMe) return;

	Super.PostBeginPlay();

	PostInit();
}

private function PreInit()
{
	local String Options;

	`Log_Trace();

	Options = WorldInfo.GetLocalURL();

	//Parse options entered via the launch command.
	//We further restrict StartWave later when we know the maximum wave number for the selected game length.
	StartWave         = OptionsParser.static.GetIntOption     (Options, "StartWave",         StartWave);
	InitialTraderTime = OptionsParser.static.GetIntOption     (Options, "InitialTraderTime", InitialTraderTime);
	TraderTime        = OptionsParser.static.GetIntOption     (Options, "TraderTime",        TraderTime);
	Dosh              = OptionsParser.static.GetIntOption     (Options, "Dosh",              Dosh);
	Boss              = OptionsParser.static.GetIntOption     (Options, "Boss",              Boss);
	bStartWithTrader  = OptionsParser.static.GetBoolOption    (Options, "bStartWithTrader",  bStartWithTrader);
	LogLevel          = OptionsParser.static.GetLogLevelOption(Options, "LogLevel",          LogLevel);

	// Adjust values if needed
	StartWave         = Max(StartWave, 1);
	InitialTraderTime = Max(InitialTraderTime, 1);
	TraderTime        = Max(TraderTime, 1);
	Dosh              = Max(Dosh, 0);

	//DEBUG
	`Log_Debug("StartWave:"         @ StartWave);
	`Log_Debug("InitialTraderTime:" @ InitialTraderTime);
	`Log_Debug("TraderTime:"        @ TraderTime);
	`Log_Debug("Dosh:"              @ Dosh);
	`Log_Debug("Boss:"              @ Boss);
	`Log_Debug("bStartWithTrader:"  @ bStartWithTrader);

	bOverridenDifficultySettings = false;
	bOverridenTraderDuration     = false;
}

private function PostInit()
{
	`Log_Trace();

	if (WorldInfo.Game == None || WorldInfo.GRI == None)
	{
		SetTimer(0.2, false, nameof(PostInit));
		return;
	}

	KFGI = KFGameInfo(WorldInfo.Game);
	if (KFGI == None)
	{
		`Log_Fatal("Incompatible gamemode:" @ WorldInfo.Game $ ". Destroy...");
		SafeDestroy();
		return;
	}

	KFGIA = new(KFGI) class'KFGI_Access';
	if (KFGIA == None)
	{
		`Log_Fatal("Can't create KFGI_Access object");
		SafeDestroy();
		return;
	}

	KFGIS = KFGameInfo_Survival(KFGI);
	if (KFGIS == None)
	{
		`Log_Warn("The game mode does not extend KFGameInfo_Survival. Most features of this mutator are not compatible with non-wave-based game modes.");
	}

	KFGIE = KFGameInfo_Endless(KFGIS);

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI == None)
	{
		`Log_Fatal("Incompatible game replication info:" @ WorldInfo.GRI $ ". Destroy...");
		SafeDestroy();
		return;
	}

	SetTimer(0.1, false, nameof(OverrideTimer));

	//Override the boss with the boss corresponding to the specified boss index. -1 signifies random.
	KFGIA.OverrideBossIndex(Boss);

	CheckForceInitialTrader();

	//We only care if this is the 'initial' trader time if we start with the trader active.
	bInitialTrader = bStartWithTrader;

	//If we want to start with the trader active or alter the starting wave number.
	if (bStartWithTrader || StartWave > 1)
	{
		`Log_Debug("Calling StartWaveTimer() to alter the start wave or activate the trader initially.");
		SetTimer(0.2, false, nameof(StartWaveTimer));
	}

	//If we will need to alter TimeBetweenWaves for later activations of the trader.
	if (bStartWithTrader && InitialTraderTime != TraderTime)
	{
		`Log_Debug("Calling UpdateTraderDurationTimer() to alter the trader duration later.");
		SetTimer(1, true, nameof(UpdateTraderDurationTimer));
	}
}

/** Allows for handling player input in the console by the mutator. */
public function Mutate(string MutateString, PlayerController Sender)
{
	local array<string> CommandBreakdown;

	`Log_Trace();

	if (MutateString == "")
	{
		return;
	}

	//Split the string on the space character.
	ParseStringIntoArray(MutateString, CommandBreakdown, " ", true);

	//The CheatManager check is equivalent to checking if cheats are enabled for that player.
	if (CommandBreakdown.Length > 1&&
		CommandBreakdown[0] == "setwave" &&
		Sender.CheatManager != None &&
		KFGI.GetLivingPlayerCount() > 0)
	{
		//The setwave command should be: mutate setwave WaveNum bSkipTraderTime
		//where WaveNum is an integer (or byte) and bSkipTraderTime is a bool.

		if (CommandBreakdown.Length == 2)
		{
			SetWave(int(CommandBreakdown[1]), Sender);
		}
		else
		{
			SetWave(int(CommandBreakdown[1]), Sender, bool(CommandBreakdown[2]));
		}
	}
}

/** Jumps to the specified wave, NewWaveNum, with trader time iff bSkipTraderTime is false. */
private function SetWave(int NewWaveNum, PlayerController PC, optional bool bSkipTraderTime)
{
	`Log_Trace();

	if (NewWaveNum < 1)
	{
		`Log_Error("SetWave: new wave num must be > 0.");
		return;
	}

	if (KFGIE != None)
	{
		//Jump straight to the final wave if the specified wave number is higher than wave max.
		if (NewWaveNum > 254)
		{
			NewWaveNum = 254;
		}
	}
	else
	{
		//Jump straight to the boss wave if the specified wave number is higher than wave max.
		if (NewWaveNum > KFGameInfo_Survival(KFGI).WaveMax)
		{
			NewWaveNum = KFGameInfo_Survival(KFGI).WaveMax+1;
		}
	}

	if (KFGIS != None)
	{
		KFGIS.WaveNum = NewWaveNum - 1;
	}

	//Kill all zeds currently alive.
	PC.ConsoleCommand("KillZeds");

	//Clear any current objectives.
	KFGRI.DeactivateObjective();

	if (bSkipTraderTime)
	{
		//Go to some unused state so that PlayingWave.BeginState is called when we go to PlayingWave.
		KFGI.GotoState('TravelTheWorld');

		UpdateEndlessDifficulty();

		//Go to PlayingWave to start the new wave.
		KFGI.GotoState('PlayingWave');
	}
	else
	{
		//Go to trader time before starting the new wave.
		KFGI.GotoState('TraderOpen');

		UpdateEndlessDifficulty();
	}

	KFGI.ResetAllPickups();
}

/**
*** Since the difficulty in Endless scales with the wave number, we need to update the difficulty when
*** jumping between wave numbers to match the expected difficulty.
***/
private function UpdateEndlessDifficulty()
{
	local int i;

	`Log_Trace();

	if (KFGIE == None)
	{
		return;
	}

	//Reflects the difficulty update in KFGameInfo_Endless.SetWave.
	KFGIE.bIsInHoePlus = false;
	KFGIE.ResetDifficulty();
	KFGIE.SpawnManager.GetWaveSettings(KFGIE.SpawnManager.WaveSettings);
	KFGIE.UpdateGameSettings();

	//Don't bother iterating for i=0-4, no difficulty increment can occur.
	for (i = 5; i < KFGIE.WaveNum; ++i)
	{
		//Simulate the death of a boss. The difficulty is incremented after each boss round.
		if (i % 5 == 0)
		{
			KFGIE.IncrementDifficulty();
		}

		//This should happen at the end of each wave (if we're in HoE+). The check is handled internally.
		//We do this after the simulation of a boss death so that bIsInHoePlus can be set first.
		KFGIE.HellOnEarthPlusRoundIncrement();
	}
}

/** Checks whether we should force the initial trader, regardless of the config/command value. */
private function CheckForceInitialTrader()
{
	`Log_Trace();

	//Force the initial trader for compatibility with holdout maps. Otherwise, zeds spawn in the wrong room.
	if (!bStartWithTrader && StartWave > 1)
	{
		bStartWithTrader = true;
		InitialTraderTime = 1.0;
	}
}

/** Overrides the boss to spawn if a valid boss index has been specified. */
private function OverrideBoss()
{
	local bool bHalt;
	local byte MaxIters, i, MaxSameIters, PrevIndex, SameIters;

	`Log_Trace();

	//Unfortunately, we cannot directly set the boss index since KFGameInfo.BossIndex is protected. The only
	//way we can affect BossIndex is through KFGameInfo.SetBossIndex which randomly chooses a value in the
	//valid range. So we have to continue calling SetBossIndex until the desired index has been chosen. We
	//can verify this by checking KFGameReplicationInfo.BossIndex because that is public.

	i = 0;
	MaxIters = 100;

	//Since some events/maps could force a specific boss to be spawned (see KFGameInfo.SetBossIndex), we
	//should check whether the index hasn't changed after several iterations. If it stays the same for a
	//while we assume the index is forced, in which case we can't do anything about it.
	SameIters = 0;
	MaxSameIters = 10;
	PrevIndex = KFGRI.BossIndex;

	bHalt = Boss < 0 || KFGRI.BossIndex == Boss;

	while (!bHalt)
	{
		++i;

		//Randomly select a new boss.
		KFGI.SetBossIndex();

		//Track whether the boss index is changing.
		if (KFGRI.BossIndex == PrevIndex)
		{
			++SameIters;
		}
		else
		{
			SameIters = 0;
			PrevIndex = KFGRI.BossIndex;
		}

		//Halt if we have the desired index or we have tried enough times.
		bHalt = KFGRI.BossIndex == Boss || SameIters >= MaxSameIters || i >= MaxIters;
	}

	if (KFGRI.BossIndex == Boss)
	{
		`Log_Debug("Successfully overrode boss index to" @ Boss @ "after" @ i @ "attempts.");
	}
	else
	{
		`Log_Debug("Failed to override boss index after" @ i @ "attempts.");
	}
}

/** Overrides difficulty settings and trader duration when possible. */
private function OverrideTimer()
{
	local KFGameDifficulty_Endless KFGDE;
	local int i;

	`Log_Trace();

	//If we've overriden what we need to, don't call this timer again.
	if (bOverridenDifficultySettings && bOverridenTraderDuration)
	{
		`Log_Debug("All settings have been overriden.");
		return;
	}

	if (!bOverridenDifficultySettings && KFGI.DifficultyInfo != None)
	{
		`Log_Debug("Overriding difficulty settings...");

		bOverridenDifficultySettings = true;

		//Override starting dosh.
		KFGI.DifficultyInfo.Normal.StartingDosh = Dosh;
		KFGI.DifficultyInfo.Hard.StartingDosh = Dosh;
		KFGI.DifficultyInfo.Suicidal.StartingDosh = Dosh;
		KFGI.DifficultyInfo.HellOnEarth.StartingDosh = Dosh;

		if (KFGIE != None)
		{
			KFGDE = KFGameDifficulty_Endless(KFGIE.DifficultyInfo);
			if (KFGDE != None)
			{
				for (i = 0; i < KFGDE.CurrentDifficultyScaling.Difficulties.length; ++i)
				{
					KFGDE.CurrentDifficultyScaling.Difficulties[i].StartingDosh = Dosh;
				}
			}
		}

		`Log_Debug("Starting dosh has been set to:" @ Dosh @ "dosh.");

		//We need to set the difficulty settings again - normally done in KFGameInfo.InitGame - to apply
		//these changes, since this happens after InitGame is executed.
		KFGI.DifficultyInfo.SetDifficultySettings(KFGI.GameDifficulty);
	}

	//Set the starting wave number.
	if (!bOverridenTraderDuration)
	{
		if (KFGIS != None)
		{
			//We require the SpawnManager to be set, because this signifies that InitSpawnManager has been
			//executed, which sets WaveMax.
			if (KFGI.SpawnManager != None)
			{
				`Log_Debug("Overriding trader duration...");

				bOverridenTraderDuration = true;

				//Since InitSpawnManager has been executed, then PreBeginPlay must have been executed. This
				//means that PostBeginPlay will have been executed as well since it happens straight after.
				//Now we can override TimeBetweenWaves.
				KFGIS.TimeBetweenWaves = bInitialTrader ? InitialTraderTime : TraderTime;

				`Log_Debug("Trader duration has been set to:" @ KFGIS.TimeBetweenWaves @ "seconds.");
			}
			else
			{
				`Log_Debug("KFGI.SpawnManager hasn't been set yet. Calling StartWaveTimer again.");

				//We don't know WaveMax yet, so we need to wait longer.
				SetTimer(0.1, false, nameof(StartWaveTimer));
				return;
			}
		}
		else
		{
			`Log_Warn("The game mode does not extend KFGameInfo_Survival. Most features of this mutator are not compatible with non-wave-based game modes.");
		}
	}

	//If the difficulty info isn't set yet, wait.
	SetTimer(0.1, false, nameof(OverrideTimer));
}

private function StartWaveTimer()
{
	local PlayerController PC;

	`Log_Trace();

	//We need to wait for the wave to be active, as this will signify that StartMatch has been executed.
	if (!KFGI.IsWaveActive())
	{
		//If the wave isn't active yet (probably still in lobby), wait.
		SetTimer(0.1, false, nameof(StartWaveTimer));
		return;
	}

	if (KFGIS == None)
	{
		return;
	}

	`Log_Debug("Clearing the current wave.");

	//Clear the current wave.
	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		if (KFDemoRecSpectator(PC) == none)
		{
			PC.ConsoleCommand("KillZeds");
			break;
		}
	}

	//Set the starting wave number.
	//Keep the assignments separated so that we can used the restricted StartWave later if we want.
	StartWave = Min(StartWave, KFGIS.WaveMax);
	//We need to subtract 1 because when the state is eventually reset to PlayingWave, this will be
	//incremented by 1.
	KFGIS.WaveNum = StartWave - 1;

	`Log_Debug("WaveNum set to:" @ KFGIS.WaveNum);

	if (bStartWithTrader)
	{
		`Log_Debug("Switching to state: TraderOpen.");

		//We need to update GRI's WaveNum and update the HUD element that shows the last wave.
		KFGRI.WaveNum = KFGIS.WaveNum;
		KFGRI.UpdateHUDWaveCount();

		//Start with the trader active.
		KFGI.GotoState('TraderOpen', 'Begin');
	}
	else
	{
		`Log_Debug("Switching to state: PlayingWave.");

		//Start with a wave as usual - but our StartWave number will be used.
		KFGI.GotoState('PlayingWave');
	}

	//Since we've updated the wave number, we need to update the game settings (which includes the
	//current wave number).
	KFGI.UpdateGameSettings();

	bInitialTrader = false;
}

/** Updates the trader duration. Waits until the initial trader has closed. */
private function UpdateTraderDurationTimer()
{
	`Log_Trace();

	//If the initial trader has already been opened, and the wave is now active.
	if (!bInitialTrader && KFGI.IsWaveActive())
	{
		if (KFGameInfo_Survival(KFGI) != None)
		{
			`Log_Debug("Updating trader duration to" @ TraderTime @ "seconds.");
			//We can update TimeBetweenWaves to be the TraderTime we specified in the launch command.
			KFGameInfo_Survival(KFGI).TimeBetweenWaves = TraderTime;
		}
		else
		{
			`Log_Warn("The game mode does not extend KFGameInfo_Survival. Most features of this mutator are not compatible with non-wave-based game modes.");
		}

		//We don't need to call this timer again.
		ClearTimer(nameof(UpdateTraderDurationTimer));
	}
}

defaultproperties
{

}