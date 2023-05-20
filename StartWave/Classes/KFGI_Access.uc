class KFGI_Access extends Object
	within KFGameInfo;

public function OverrideBossIndex(int Index, optional bool Force = false)
{
	if (Index < 0 || Index >= default.AIBossClassList.Length)
	{
		return;
	}

	if (!UseSpecificBossIndex(BossIndex) || Force)
	{
		BossIndex = Index;
	}

	MyKFGRI.CacheSelectedBoss(BossIndex);
}

defaultproperties
{

}
