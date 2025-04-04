UCLASS(Config = EditorPerProjectUserSettings)
class USendInputToBothPlayersDevInput : UHazeDevInputHandler
{
	default Name = n"Send Input To Both Players";
	default Category = n"Default";

	default DisplaySortOrder = 0;

	UPROPERTY(Config)
	TSet<FKey> Keybinds;

	int sendInputToBothPlayers = 0;

	UFUNCTION(BlueprintOverride)
	void Setup()
	{
		LoadConfig();

		if (Keybinds.IsEmpty())
		{
			// Default Binds
			Keybinds.Add(EKeys::Gamepad_DPad_Up);
			Keybinds.Add(EKeys::X);
			SaveConfig();
		}

		for (auto Keybind : Keybinds)
		{
			AddKey(Keybind);
		}
	}

	UFUNCTION(BlueprintOverride)
	bool CanBeTriggered()
	{
		return !Network::IsGameNetworked();
	}

	UFUNCTION(BlueprintOverride)
	void Trigger()
	{
		if (Console::GetConsoleVariableInt("Haze.SendAllInputToBothPlayers") == 0)
			sendInputToBothPlayers = 1;
		else
			sendInputToBothPlayers = 0;

		Console::SetConsoleVariableInt("Haze.SendAllInputToBothPlayers", sendInputToBothPlayers);
	}

	UFUNCTION(BlueprintOverride)
	void GetStatus(FString& OutDescription, FLinearColor& OutColor)
	{
		if (sendInputToBothPlayers != 0)
		{
			OutDescription = "[ ENABLED ]";
			OutColor = FLinearColor::Green;
		}
		else 
		{
			OutDescription = "[ DISABLED ]";
			OutColor = FLinearColor::Red;
		}
	}
};