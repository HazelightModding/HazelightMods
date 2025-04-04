class UDisplayDebugInfoDevInput : UHazeDevInputHandler
{
	default Name = n"Display Debug Info";
	default Category = n"Default";

	default DisplaySortOrder = 6000;

	UPROPERTY(Config)
	TSet<FKey> Keybinds;

	UFUNCTION(BlueprintOverride)
	void Setup()
	{
		LoadConfig();

		if (Keybinds.IsEmpty())
		{
			// Default Binds
			Keybinds.Add(EKeys::Gamepad_FaceButton_Bottom);
			Keybinds.Add(EKeys::M);
			SaveConfig();
		}

		for (auto Keybind : Keybinds)
		{
			AddKey(Keybind);
		}
	}

	UFUNCTION(BlueprintOverride)
	void Trigger()
	{
		int bDebugInfoDevInputEnabled = 0;

		if (Console::GetConsoleVariableInt("Mod.ShowDebugInfo") == 0)
			bDebugInfoDevInputEnabled = 1;

		Console::SetConsoleVariableInt("Mod.ShowDebugInfo", bDebugInfoDevInputEnabled);
	}

	UFUNCTION(BlueprintOverride)
	void GetStatus(FString& OutDescription, FLinearColor& OutColor)
	{
		if (Console::GetConsoleVariableInt("Mod.ShowDebugInfo") != 0)
		{
			OutDescription = "[ VISIBLE ]";
			OutColor = FLinearColor::Green;
		}
		else 
		{
			OutDescription = "[ NOT VISIBLE ]";
			OutColor = FLinearColor::Red;
		}
	}
};
