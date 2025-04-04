UCLASS(Config = EditorPerProjectUserSettings)
class UInGameTimerDevInput : UHazeDevInputHandler
{
	default Name = n"Toggle In-game Timer";
	default Category = n"Default";

	default DisplaySortOrder = 5000;

	UPROPERTY(Config)
	TSet<FKey> Keybinds;

	UGlobalMenuSingleton GlobalMenuSingleton;
	UFUNCTION(BlueprintOverride)
	void Setup()
	{
		LoadConfig();

		if (Keybinds.IsEmpty())
		{
			// Default Binds
			Keybinds.Add(EKeys::Gamepad_FaceButton_Top);
			Keybinds.Add(EKeys::P);
			SaveConfig();
		}

		for (auto Keybind : Keybinds)
		{
			AddKey(Keybind);
		}
		
		GlobalMenuSingleton = Game::GetSingleton(UGlobalMenuSingleton);
	}

	UFUNCTION(BlueprintOverride)
	void Trigger()
	{
		GlobalMenuSingleton.bDisplayTimer = !GlobalMenuSingleton.bDisplayTimer;
	}

	UFUNCTION(BlueprintOverride)
	void GetStatus(FString& OutDescription, FLinearColor& OutColor)
	{
		if (GlobalMenuSingleton.bDisplayTimer)
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
}

