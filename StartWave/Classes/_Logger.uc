// This file is part of Start Wave.
// Start Wave - a mutator for Killing Floor 2.
//
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

class _Logger extends Object
	abstract;

enum E_LogLevel
{
	LL_WrongLevel,
	LL_None,
	LL_Fatal,
	LL_Error,
	LL_Warning,
	LL_Info,
	LL_Debug,
	LL_Trace,
	LL_All
};

public static function E_LogLevel LogLevelFromString(String LogLevel, optional E_LogLevel DefaultLogLevel)
{
	switch (LogLevel)
	{
		case "0":
		case "WrongLevel":
		case "LL_WrongLevel":
			return LL_WrongLevel;

		case "1":
		case "None":
		case "LL_None":
			return LL_None;

		case "2":
		case "Fatal":
		case "LL_Fatal":
			return LL_Fatal;

		case "3":
		case "Error":
		case "LL_Error":
			return LL_Error;

		case "4":
		case "Warning":
		case "LL_Warning":
			return LL_Warning;

		case "5":
		case "Info":
		case "LL_Info":
			return LL_Info;

		case "6":
		case "Debug":
		case "LL_Debug":
			return LL_Debug;

		case "7":
		case "Trace":
		case "LL_Trace":
			return LL_Trace;

		case "8":
		case "All":
		case "LL_All":
			return LL_All;

		default:
			return DefaultLogLevel;
	}
}

defaultproperties
{

}