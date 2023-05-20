class StartWaveMut extends KFMutator;

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

public function AddMutator(Mutator Mut)
{
	if (Mut == Self || bPendingDelete || bDeleteMe) return;

	if (Mut.Class == Class)
		StartWaveMut(Mut).SafeDestroy();
	else
		Super.AddMutator(Mut);
}

public function Mutate(String MutateString, PlayerController Sender)
{
	StartWave.Mutate(MutateString, Sender);

	Super.Mutate(MutateString, Sender);
}

defaultproperties
{

}