UCLASS(Config = EditorPerProjectUserSettings)
class UModManagerSingleton : UHazeSingleton
{
	FModLog Log;

	UPROPERTY(Config)
	TMap<FString, int> DefaultCVars;

	UPROPERTY(Config)
	bool bDisplayInGameTimer = false;

	UPROPERTY()
	TArray<UHazeSingleton> Singletons;

	UFUNCTION(BlueprintOverride)
	void Initialize()
	{
		Mod::Log("Split Fiction Mod Manager 1.0.0");
		LoadConfig();
		for (auto CVar : DefaultCVars)
		{
			Mod::Log(CVar.Key + " = " + CVar.Value, 2.0);
			Console::SetConsoleVariableInt(CVar.Key, CVar.Value);
		}

		UGlobalMenuSingleton MenuSingleton = Game::GetSingleton(UGlobalMenuSingleton);
		MenuSingleton.bDisplayTimer = bDisplayInGameTimer;

		for (auto Singleton : Singletons)
		{
			Singleton.Initialize();
		}

	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		Log.UpdateLogMessages(DeltaTime);

		for (auto Singleton : Singletons)
		{
			Singleton.Tick(DeltaTime);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Shutdown()
	{
		for (auto Singleton : Singletons)
		{
			Singleton.Shutdown();
		}
	}
	
	UFUNCTION(BlueprintOverride)
	void ResetStateBetweenLevels()
	{
		for (auto Singleton : Singletons)
		{
			Singleton.ResetStateBetweenLevels();
		}
	}
}

namespace Mod
{
	UModManagerSingleton GetModManager()
	{
		// Making sure GlobalMenuSingleton is added to the list first.
		Game::GetSingleton(UGlobalMenuSingleton);
		return Game::GetSingleton(UModManagerSingleton);
	}

	TArray<AActor> GetAllActorsOfClass(UClass Class)
	{
		TArray<AActor> FilteredActors;
		for (auto Actor : GetAllActors())
		{
			if (IsValid(Actor) && Actor.IsA(Class))
				FilteredActors.Add(Actor);
		}
		
		return FilteredActors;
	}

	TArray<AActor> GetAllActors()
	{
		TArray<AActor> AllActors;
		for (auto Level : GetActiveLevels())
		{
			AllActors.Append(Level.Actors);
		}
		for (auto Level : GetPreparedLevels())
		{
			AllActors.Append(Level.Actors);
		}
		return AllActors;
	}

	TArray<ULevel> GetActiveLevels()
	{
		TArray<ULevel> Levels;
		Levels.Add(Game::Mio.Level);
		for (auto LevelName : Progress::GetActiveLevels())
		{
			TSoftObjectPtr<UWorld> World = TSoftObjectPtr<UWorld>(FSoftObjectPath("/Game/Maps/" + LevelName + "." + FPaths::GetBaseFilename(LevelName)));
			//Mod::Log("Asset: " + World.AssetName);
			if (World.Get() == nullptr)
				continue;

			Levels.Add(World.Get().PersistentLevel);
		}
		return Levels;
	}

	TArray<ULevel> GetPreparedLevels()
	{
		TArray<ULevel> Levels;
		for (auto LevelName : Progress::GetPreparedLevels())
		{
			TSoftObjectPtr<UWorld> World = TSoftObjectPtr<UWorld>(FSoftObjectPath("/Game/Maps/" + LevelName + "." + FPaths::GetBaseFilename(LevelName)));
			//Mod::Log("Asset: " + World.AssetName);
			if (World.Get() == nullptr)
				continue;

			Levels.Add(World.Get().PersistentLevel);
		}
		return Levels;
	}

	
	UHazeSingleton GetSingleton(TSubclassOf<UHazeSingleton> Class)
	{
		for (auto Singleton : GetModManager().Singletons)
		{
			if (IsValid(Singleton) && Singleton.IsA(Class))
				return Singleton;
		}

		auto NewSingleton = Cast<UHazeSingleton>(NewObject(GetModManager(), Class));
		NewSingleton.Initialize();
		GetModManager().Singletons.AddUnique(NewSingleton);
		return NewSingleton;
	}
}