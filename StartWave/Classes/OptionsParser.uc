class OptionsParser extends Object;

const GameInfo = class'GameInfo';

/**
*** @brief Gets a int from the launch command if available.
***
*** @param Options - options passed in via the launch command
*** @param ParseString - the variable we are looking for
*** @param CurrentValue - the current value of the variable
*** @return int value of the option we are looking for
***/
static function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	return GameInfo.static.GetIntOption(Options, ParseString, CurrentValue);
}

/**
*** @brief Gets a bool from the launch command if available.
***
*** @param Options - options passed in via the launch command
*** @param ParseString - the variable we are looking for
*** @param CurrentValue - the current value of the variable
*** @return bool value of the option we are looking for
***/
static public function bool GetBoolOption(string Options, string ParseString, bool CurrentValue)
{
	local string InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = GameInfo.static.ParseOption(Options, ParseString);

	if(InOpt != "")
	{
		return bool(InOpt);
	}

	//If a value for this variable was not specified in the launch command, return the original value.
	return CurrentValue;
}

/**
*** @brief Gets a string from the launch command if available.
***
*** @param Options - options passed in via the launch command
*** @param ParseString - the variable we are looking for
*** @param CurrentValue - the current value of the variable
*** @return string value of the option we are looking for
***/
static public function string GetStringOption(string Options, string ParseString, string CurrentValue)
{
	local string InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = GameInfo.static.ParseOption(Options, ParseString);

	if(InOpt != "")
	{
		return InOpt;
	}

	//If a value for this variable was not specified in the launch command, return the original value.
	return CurrentValue;
}

/**
*** @brief Gets a LogLevel from the launch command if available.
***
*** @param Options - options passed in via the launch command
*** @param ParseString - the variable we are looking for
*** @param CurrentValue - the current value of the variable
*** @return E_LogLevel value of the option we are looking for
***/
static public function E_LogLevel GetLogLevelOption(string Options, string ParseString, E_LogLevel CurrentValue)
{
	return CurrentValue; // TODO: impl
}