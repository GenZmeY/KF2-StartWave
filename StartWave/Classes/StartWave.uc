class StartWave extends KFMutator
	config(StartWave);

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
/** Whether mod-specific events should be logged. */
var config bool bUseDebug;
/**
  * The boss override index. For the default boss list, 0-Hans, 1-Patty, 2-King FP, 3-Abomination. Negative
  * values can be used to keep the boss spawn random.
  */
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

function InitMutator(string Options, out string ErrorMessage)
{
	//This needs to be called first since KFMutator.InitMutator sets the MyKFGI reference.
	Super.InitMutator(Options, ErrorMessage);
	
	//Parse options entered via the launch command.
	//We further restrict StartWave later when we know the maximum wave number for the selected game length.
	StartWave = Max(class'GameInfo'.static.GetIntOption(Options, "StartWave", StartWave), 1);
	InitialTraderTime = Max(class'GameInfo'.static.GetIntOption(Options, "InitialTraderTime",
		InitialTraderTime), 1);
	TraderTime = Max(class'GameInfo'.static.GetIntOption(Options, "TraderTime", TraderTime), 1);
	Dosh = Max(class'GameInfo'.static.GetIntOption(Options, "Dosh", Dosh), 0);
	Boss = class'GameInfo'.static.GetIntOption(Options, "Boss", Boss);
	bStartWithTrader = GetBoolOption(Options, "bStartWithTrader", bStartWithTrader);
	bUseDebug = GetBoolOption(Options, "bUseDebug", bUseDebug);
	
	//DEBUG
	`log("StartWave: "$StartWave, bUseDebug, 'StartWave');
	`log("InitialTraderTime: "$InitialTraderTime, bUseDebug, 'StartWave');
	`log("TraderTime: "$TraderTime, bUseDebug, 'StartWave');
	`log("Dosh: "$Dosh, bUseDebug, 'StartWave');
	`log("Boss: "$Boss, bUseDebug, 'StartWave');
	`log("bStartWithTrader: "$bStartWithTrader, bUseDebug, 'StartWave');
	
	bOverridenDifficultySettings = false;
	bOverridenTraderDuration = false;
	
	SetTimer(0.1, false, nameof(OverrideTimer));
	
	//Override the boss with the boss corresponding to the specified boss index. -1 signifies random.
	if(Boss != -1)
	{
		SetTimer(0.1, false, nameof(OverrideBoss));
	}
	
	CheckForceInitialTrader();
	
	//We only care if this is the 'initial' trader time if we start with the trader active.
	bInitialTrader = bStartWithTrader;
	
	//If we want to start with the trader active or alter the starting wave number.
	if(bStartWithTrader || StartWave > 1)
	{
		`log("Calling StartWaveTimer() to alter the start wave or activate the trader initially.",
			bUseDebug, 'StartWave');
		SetTimer(0.2, false, nameof(StartWaveTimer));
	}
	
	//If we will need to alter TimeBetweenWaves for later activations of the trader.
	if(bStartWithTrader && InitialTraderTime != TraderTime)
	{
		`log("Calling UpdateTraderDurationTimer() to alter the trader duration later.", bUseDebug,
			'StartWave');
		SetTimer(1, true, nameof(UpdateTraderDurationTimer));
	}
}

/** Allows for handling player input in the console by the mutator. */
function Mutate(string MutateString, PlayerController Sender)
{
	local array<string> CommandBreakdown;
	
	if(MutateString == "")
	{
		return;
	}
	
	//Split the string on the space character.
	ParseStringIntoArray(MutateString, CommandBreakdown, " ", true);
	
	//The CheatManager check is equivalent to checking if cheats are enabled for that player.
	if(CommandBreakdown.Length > 1 && CommandBreakdown[0] == "setwave" && Sender.CheatManager != None &&
		MyKFGI.GetLivingPlayerCount() > 0)
	{
		//The setwave command should be: mutate setwave WaveNum bSkipTraderTime
		//where WaveNum is an integer (or byte) and bSkipTraderTime is a bool.
		
		if(CommandBreakdown.Length == 2)
		{
			SetWave(int(CommandBreakdown[1]), Sender);
		}
		else
		{
			SetWave(int(CommandBreakdown[1]), Sender, bool(CommandBreakdown[2]));
		}
	}
	
	Super.Mutate(MutateString, Sender);
}

/** Jumps to the specified wave, NewWaveNum, with trader time iff bSkipTraderTime is false. */
function SetWave(int NewWaveNum, PlayerController PC, optional bool bSkipTraderTime)
{
	if(NewWaveNum < 1)
	{
		`log("SetWave: new wave num must be > 0.", true, 'StartWave');
		return;
	}
	
	if(KFGameInfo_Endless(MyKFGI) != None)
	{
		//Jump straight to the final wave if the specified wave number is higher than wave max.
		if(NewWaveNum > 254)
		{
			NewWaveNum = 254;
		}
	}
	else
	{
		//Jump straight to the boss wave if the specified wave number is higher than wave max.
		if(NewWaveNum > KFGameInfo_Survival(MyKFGI).WaveMax)
		{
			NewWaveNum = KFGameInfo_Survival(MyKFGI).WaveMax+1;
		}
	}
	
	KFGameInfo_Survival(MyKFGI).WaveNum = NewWaveNum - 1;
	
	//Kill all zeds currently alive.
	PC.ConsoleCommand("KillZeds");
	
	//Clear any current objectives.
	MyKFGI.MyKFGRI.DeactivateObjective();
	
	if(bSkipTraderTime)
	{
		//Go to some unused state so that PlayingWave.BeginState is called when we go to PlayingWave.
		MyKFGI.GotoState('TravelTheWorld');
		
		UpdateEndlessDifficulty();
		
		//Go to PlayingWave to start the new wave.
		MyKFGI.GotoState('PlayingWave');
	}
	else
	{
		//Go to trader time before starting the new wave.
		MyKFGI.GotoState('TraderOpen');
		
		UpdateEndlessDifficulty();
	}

	MyKFGI.ResetAllPickups();
}

/**
  * Since the difficulty in Endless scales with the wave number, we need to update the difficulty when
  * jumping between wave numbers to match the expected difficulty.
  */
function UpdateEndlessDifficulty()
{
	local KFGameInfo_Endless Endless;
	local int i;
	
	Endless = KFGameInfo_Endless(MyKFGI);
	
	if(Endless == None)
	{
		return;
	}
	
	//Reflects the difficulty update in KFGameInfo_Endless.SetWave.
	Endless.bIsInHoePlus = false;
	Endless.ResetDifficulty();
	Endless.SpawnManager.GetWaveSettings(Endless.SpawnManager.WaveSettings);
	Endless.UpdateGameSettings();
	
	//Don't bother iterating for i=0-4, no difficulty increment can occur.
	for(i = 5; i < Endless.WaveNum; ++i)
	{
		//Simulate the death of a boss. The difficulty is incremented after each boss round.
		if(i % 5 == 0)
		{
			Endless.IncrementDifficulty();
		}
		
		//This should happen at the end of each wave (if we're in HoE+). The check is handled internally.
		//We do this after the simulation of a boss death so that bIsInHoePlus can be set first.
		Endless.HellOnEarthPlusRoundIncrement();
	}
}

/** Checks whether we should force the initial trader, regardless of the config/command value. */
function CheckForceInitialTrader()
{
	//Force the initial trader for compatibility with holdout maps. Otherwise, zeds spawn in the wrong room.
	if(!bStartWithTrader && StartWave > 1)
	{
		bStartWithTrader = true;
		InitialTraderTime = 1.0;
	}
}

/** Overrides the boss to spawn if a valid boss index has been specified. */
function OverrideBoss()
{
	local bool bHalt;
	local byte MaxIters, i, MaxSameIters, PrevIndex, SameIters;
	
	//We need a valid KFGRI reference as we use its public BossIndex field.
	if(MyKFGI.MyKFGRI == None)
	{
		SetTimer(0.2, false, nameof(OverrideBoss));
		return;
	}
	
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
	PrevIndex = MyKFGI.MyKFGRI.BossIndex;
	
	bHalt = Boss < 0 || MyKFGI.MyKFGRI.BossIndex == Boss;
	
	while(!bHalt)
	{
		++i;
		
		//Randomly select a new boss.
		MyKFGI.SetBossIndex();
		
		//Track whether the boss index is changing.
		if(MyKFGI.MyKFGRI.BossIndex == PrevIndex)
		{
			++SameIters;
		}
		else
		{
			SameIters = 0;
			PrevIndex = MyKFGI.MyKFGRI.BossIndex;
		}
		
		//Halt if we have the desired index or we have tried enough times.
		bHalt = MyKFGI.MyKFGRI.BossIndex == Boss || SameIters >= MaxSameIters || i >= MaxIters;
	}
	
	if(MyKFGI.MyKFGRI.BossIndex == Boss)
	{
		`log("Successfully overrode boss index to "$Boss$" after "$i$" attempts.", bUseDebug, 'StartWave');
	}
	else
	{
		`log("Failed to override boss index after "$i$" attempts.", bUseDebug, 'StartWave');
	}
}

/** Overrides difficulty settings and trader duration when possible. */
function OverrideTimer()
{
	local KFGameInfo_Survival KFGI_Surv;
	local KFGameInfo_Endless KFGI_Endl;
	local KFGameDifficulty_Endless KFGD_Endl;
	local int i;
	
	//If we've overriden what we need to, don't call this timer again.
	if(bOverridenDifficultySettings && bOverridenTraderDuration)
	{
		`log("All settings have been overriden.", bUseDebug, 'StartWave');
		return;
	}
	
	if(!bOverridenDifficultySettings && MyKFGI.DifficultyInfo != None)
	{
		`log("Overriding difficulty settings...", bUseDebug, 'StartWave');
		
		bOverridenDifficultySettings = true;
		
		//Override starting dosh.
		MyKFGI.DifficultyInfo.Normal.StartingDosh = Dosh;
		MyKFGI.DifficultyInfo.Hard.StartingDosh = Dosh;
		MyKFGI.DifficultyInfo.Suicidal.StartingDosh = Dosh;
		MyKFGI.DifficultyInfo.HellOnEarth.StartingDosh = Dosh;
		
		KFGI_Endl = KFGameInfo_Endless(MyKFGI);
		if (KFGI_Endl != None)
		{
			KFGD_Endl = KFGameDifficulty_Endless(KFGI_Endl.DifficultyInfo);
			if (KFGD_Endl != None)
			{
				for (i = 0; i < KFGD_Endl.CurrentDifficultyScaling.Difficulties.length; ++i)
				{
					KFGD_Endl.CurrentDifficultyScaling.Difficulties[i].StartingDosh = Dosh;
				}
			}
		}
		
		`log("Starting dosh has been set to: "$Dosh$" dosh.", bUseDebug, 'StartWave');
		
		//We need to set the difficulty settings again - normally done in KFGameInfo.InitGame - to apply
		//these changes, since this happens after InitGame is executed.
		MyKFGI.DifficultyInfo.SetDifficultySettings(MyKFGI.GameDifficulty);
	}
	
	//Set the starting wave number.
	if(!bOverridenTraderDuration)
	{
		KFGI_Surv = KFGameInfo_Survival(MyKFGI);
		
		if(KFGI_Surv != None)
		{
			//We require the SpawnManager to be set, because this signifies that InitSpawnManager has been
			//executed, which sets WaveMax.
			if(MyKFGI.SpawnManager != None)
			{
				`log("Overriding trader duration...", bUseDebug, 'StartWave');
				
				bOverridenTraderDuration = true;
				
				//Since InitSpawnManager has been executed, then PreBeginPlay must have been executed. This
				//means that PostBeginPlay will have been executed as well since it happens straight after.
				//Now we can override TimeBetweenWaves.
				KFGI_Surv.TimeBetweenWaves = bInitialTrader ? InitialTraderTime : TraderTime;
				
				`log("Trader duration has been set to: "$KFGI_Surv.TimeBetweenWaves$" seconds.", bUseDebug,
					'StartWave');
			}
			else
			{
				`log("MyKFGI.SpawnManager hasn't been set yet. Calling StartWaveTimer again.", bUseDebug,
					'StartWave');
				
				//We don't know WaveMax yet, so we need to wait longer.
				SetTimer(0.1, false, nameof(StartWaveTimer));
				return;
			}
		}
		else
		{
			`warn("The game mode does not extend KFGameInfo_Survival. Most features of this mutator are not"
				$"compatible with non-wave-based game modes.", true, 'StartWave');
		}
	}
	
	//If the difficulty info isn't set yet, wait.
	SetTimer(0.1, false, nameof(OverrideTimer));
}

function StartWaveTimer()
{
	local KFGameInfo_Survival KFGI_Surv;
	local PlayerController PC;
	
	//We need to wait for the wave to be active, as this will signify that StartMatch has been executed.
	if(!MyKFGI.IsWaveActive())
	{
		//If the wave isn't active yet (probably still in lobby), wait.
		SetTimer(0.1, false, nameof(StartWaveTimer));
		return;
	}
	
	KFGI_Surv = KFGameInfo_Survival(MyKFGI);
	
	if(KFGI_Surv == None)
	{
		return;
	}
	
	`log("Clearing the current wave.", bUseDebug, 'StartWave');
	
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
	StartWave = Min(StartWave, KFGI_Surv.WaveMax);
	//We need to subtract 1 because when the state is eventually reset to PlayingWave, this will be
	//incremented by 1.
	KFGI_Surv.WaveNum = StartWave - 1;
	
	`log("WaveNum set to: "$KFGI_Surv.WaveNum, bUseDebug, 'StartWave');
	
	if(bStartWithTrader)
	{
		`log("Switching to state: TraderOpen.", bUseDebug, 'StartWave');
		
		//We need to update GRI's WaveNum and update the HUD element that shows the last wave.
		MyKFGI.MyKFGRI.WaveNum = KFGI_Surv.WaveNum;
		MyKFGI.MyKFGRI.UpdateHUDWaveCount();
		
		//Start with the trader active.
		MyKFGI.GotoState('TraderOpen', 'Begin');
	}
	else
	{	
		`log("Switching to state: PlayingWave.", bUseDebug, 'StartWave');
		
		//Start with a wave as usual - but our StartWave number will be used.
		MyKFGI.GotoState('PlayingWave');
	}
	
	//Since we've updated the wave number, we need to update the game settings (which includes the
	//current wave number).
	MyKFGI.UpdateGameSettings();
	
	bInitialTrader = false;
}

/** Updates the trader duration. Waits until the initial trader has closed. */
function UpdateTraderDurationTimer()
{
	//If the initial trader has already been opened, and the wave is now active.
	if(!bInitialTrader && MyKFGI.IsWaveActive())
	{
		if(KFGameInfo_Survival(MyKFGI) != None)
		{
			`log("Updating trader duration to "$TraderTime$" seconds.", bUseDebug, 'StartWave');
			//We can update TimeBetweenWaves to be the TraderTime we specified in the launch command.
			KFGameInfo_Survival(MyKFGI).TimeBetweenWaves = TraderTime;
		}
		else
		{
			`warn("The game mode does not extend KFGameInfo_Survival. Most features of this mutator are not"
				$"compatible with non-wave-based game modes.", true, 'StartWave');
		}
		
		//We don't need to call this timer again.
		ClearTimer(nameof(UpdateTraderDurationTimer));
	}
}

/**
  * @brief Gets a bool from the launch command if available.
  *
  * @param Options - options passed in via the launch command
  * @param ParseString - the variable we are looking for
  * @param CurrentValue - the current value of the variable
  * @return bool value of the option we are looking for
  */
static function bool GetBoolOption(string Options, string ParseString, bool CurrentValue)
{
	local string InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = class'GameInfo'.static.ParseOption(Options, ParseString);
	
	if(InOpt != "")
	{
		return bool(InOpt);
	}
	
	//If a value for this variable was not specified in the launch command, return the original value.
	return CurrentValue;
}

/**
  * @brief Gets a string from the launch command if available.
  *
  * @param Options - options passed in via the launch command
  * @param ParseString - the variable we are looking for
  * @param CurrentValue - the current value of the variable
  * @return string value of the option we are looking for
  */
static function string GetStringOption(string Options, string ParseString, string CurrentValue)
{
	local string InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = class'GameInfo'.static.ParseOption(Options, ParseString);
	
	if(InOpt != "")
	{
		return InOpt;
	}
	
	//If a value for this variable was not specified in the launch command, return the original value.
	return CurrentValue;
}