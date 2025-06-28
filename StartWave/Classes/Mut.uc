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

class Mut extends KFMutator;

var private StartWave StartWave;

public simulated function bool SafeDestroy()
{
	return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
	Super.PreBeginPlay();

	if (WorldInfo.NetMode == NM_Client) return;

	foreach WorldInfo.DynamicActors(class'StartWave', StartWave)
	{
		break;
	}

	if (StartWave == None)
	{
		StartWave = WorldInfo.Spawn(class'StartWave');
	}

	if (StartWave == None)
	{
		`Log_Base("FATAL: Can't Spawn 'StartWave'");
		SafeDestroy();
	}
}

public function AddMutator(Mutator M)
{
	if (M == Self) return;

	if (M.Class == Class)
		Mut(M).SafeDestroy();
	else
		Super.AddMutator(M);
}

public function Mutate(String MutateString, PlayerController Sender)
{
	StartWave.Mutate(MutateString, Sender);

	Super.Mutate(MutateString, Sender);
}

static function String GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	return String(class'StartWave');
}

defaultproperties
{

}