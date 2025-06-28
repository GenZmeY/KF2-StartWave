// This file is part of Start Wave.
// Start Wave - a mutator for Killing Floor 2.
//
// Copyright (C) 2018      Pharrahnox
// Copyright (C) 2021-2024 GenZmeY (mailto: genzmey@gmail.com)
//
// Start Wave is free software: you can redistribute it
// and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Start Wave is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with Start Wave. If not, see <https://www.gnu.org/licenses/>.

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
static function int GetIntOption( String Options, String ParseString, int CurrentValue)
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
static public function bool GetBoolOption(String Options, String ParseString, bool CurrentValue)
{
	local String InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = GameInfo.static.ParseOption(Options, ParseString);

	if (InOpt != "")
	{
		return bool(InOpt);
	}

	//If a value for this variable was not specified in the launch command, return the original value.
	return CurrentValue;
}

/**
*** @brief Gets a String from the launch command if available.
***
*** @param Options - options passed in via the launch command
*** @param ParseString - the variable we are looking for
*** @param CurrentValue - the current value of the variable
*** @return String value of the option we are looking for
***/
static public function String GetStringOption(String Options, String ParseString, String CurrentValue)
{
	local String InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = GameInfo.static.ParseOption(Options, ParseString);

	if (InOpt != "")
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
static public function E_LogLevel GetLogLevelOption(String Options, String ParseString, E_LogLevel CurrentValue)
{
	local String InOpt;

	//Find the value associated with this variable in the launch command.
	InOpt = GameInfo.static.ParseOption(Options, ParseString);

	if (InOpt != "")
	{
		return class'_Logger'.static.LogLevelFromString(InOpt, CurrentValue);
	}

	return CurrentValue;
}