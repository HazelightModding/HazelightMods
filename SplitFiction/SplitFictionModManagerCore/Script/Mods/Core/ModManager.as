UCLASS(Config = EditorPerProjectUserSettings)
class UModManagerSingleton : UHazeSingleton
{
	FModLog Log;

	UPROPERTY(Config)
	TMap<FString, int> DefaultCVars;

	UPROPERTY(Config)
	bool bDisplayInGameTimer = false;

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		LoadConfig();
		for (auto CVar : DefaultCVars)
		{
			Mod::Log(CVar.Key + " = " + CVar.Value, 2.0);
			Console::SetConsoleVariableInt(CVar.Key, CVar.Value);
		}

		UGlobalMenuSingleton MenuSingleton = Game::GetSingleton(UGlobalMenuSingleton);
		MenuSingleton.bDisplayTimer = bDisplayInGameTimer;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		Log.UpdateLogMessages(DeltaTime);
	}
}

namespace Mod
{
	UModManagerSingleton GetModManager()
	{
		return Game::GetSingleton(UModManagerSingleton);
	}
}