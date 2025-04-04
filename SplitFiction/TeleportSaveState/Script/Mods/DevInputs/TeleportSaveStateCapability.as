struct FModTeleportData
{
	FVector Location;
	FRotator Rotation;
	FVector Velocity;

	FHazeProgressPointRef ProgressPoint;
}

UCLASS(Config = EditorPerProjectUserSettings)
class UTeleportSaveStateCapability : UHazePlayerCapability
{
	default CapabilityTags.Add(n"Mod");
	default TickGroup = EHazeTickGroup::Gameplay;

	UPROPERTY(Config)
	int SaveSlot = 1;

	UPROPERTY(Config)
	bool bWithVelocity = false;

	UPROPERTY(Config)
	TArray<FModTeleportData> Saved;

	UPROPERTY(Config)
	TSet<FKey> TeleportToSavedKeybinds;

	UPROPERTY(Config)
	TSet<FKey> SaveCurrentLocationKeybinds;

	UPROPERTY(Config)
	TSet<FKey> SaveSlotKeybinds;

	UPROPERTY(Config)
	TSet<FKey> TeleportWithVelocityKeybinds;

	UPROPERTY(Config)
	TSet<FKey> TeleportToCheckpointKeybinds;

	bool bIsTeleporting = false;
	bool bTeleportingWithProgressPoint = false;
	int teleportToSaveSlot = 0;



	UFUNCTION(BlueprintOverride)
	void Setup()
	{
		Saved.Add(FModTeleportData());
		Saved.Add(FModTeleportData());
		Saved.Add(FModTeleportData());
		Saved.Add(FModTeleportData());
		Saved.Add(FModTeleportData());

		LoadConfig();

		if (TeleportToSavedKeybinds.IsEmpty())
		{
			// Default Binds
			TeleportToSavedKeybinds.Add(EKeys::Gamepad_DPad_Left);
			TeleportToSavedKeybinds.Add(EKeys::F);
		}

		if (SaveCurrentLocationKeybinds.IsEmpty())
		{
			// Default Binds
			SaveCurrentLocationKeybinds.Add(EKeys::Gamepad_DPad_Right);
			SaveCurrentLocationKeybinds.Add(EKeys::C);
		}

		if (SaveSlotKeybinds.IsEmpty())
		{
			// Default Binds
			SaveSlotKeybinds.Add(EKeys::Gamepad_RightShoulder);
			SaveSlotKeybinds.Add(EKeys::E);
		}

		if (TeleportWithVelocityKeybinds.IsEmpty())
		{
			// Default Binds
			TeleportWithVelocityKeybinds.Add(EKeys::Gamepad_DPad_Down);
			TeleportWithVelocityKeybinds.Add(EKeys::R);
		}

		if (TeleportToCheckpointKeybinds.IsEmpty())
		{
			// Default Binds
			TeleportToCheckpointKeybinds.Add(EKeys::Gamepad_LeftShoulder);
			TeleportToCheckpointKeybinds.Add(EKeys::T);
		}

		SaveConfig();

		FHazeDevInputInfo TeleportToSaved;
		TeleportToSaved.Name = n"Teleport to Saved Location";
		TeleportToSaved.Category = n"Default";
		TeleportToSaved.DisplaySortOrder = 1;
		TeleportToSaved.OnTriggered.BindUFunction(this, n"TriggerTeleportToSaved");
		TeleportToSaved.Keys = TeleportToSavedKeybinds;
		Player.RegisterDevInput(TeleportToSaved);
		TeleportToSaved.Category = n"Saved Locations";
		Player.RegisterDevInput(TeleportToSaved);

		FHazeDevInputInfo SaveCurrentLocation;
		SaveCurrentLocation.Name = n"Save current location";
		SaveCurrentLocation.Category = n"Default";
		SaveCurrentLocation.DisplaySortOrder = 3;
		SaveCurrentLocation.OnTriggered.BindUFunction(this, n"TriggerSaveCurrentLocation");
		SaveCurrentLocation.Keys = SaveCurrentLocationKeybinds;
		Player.RegisterDevInput(SaveCurrentLocation);
		SaveCurrentLocation.Category = n"Saved Locations";
		Player.RegisterDevInput(SaveCurrentLocation);

		FHazeDevInputInfo TeleportSaveSlot;
		TeleportSaveSlot.Name = n"Save Slot";
		TeleportSaveSlot.Category = n"Saved Locations";
		TeleportSaveSlot.bTriggerLocalOnly = true;
		TeleportSaveSlot.DisplaySortOrder = 5;
		TeleportSaveSlot.OnTriggered.BindUFunction(this, n"TriggerSaveSlot");
		TeleportSaveSlot.OnStatus.BindUFunction(this, n"StatusSaveSlot");
		TeleportSaveSlot.Keys = SaveSlotKeybinds;
		Player.RegisterDevInput(TeleportSaveSlot);

		FHazeDevInputInfo TeleportWithVelocityInfo;
		TeleportWithVelocityInfo.Name = n"Teleport with velocity";
		TeleportWithVelocityInfo.Category = n"Saved Locations";
		TeleportWithVelocityInfo.bTriggerLocalOnly = true;
		TeleportWithVelocityInfo.DisplaySortOrder = 7;
		TeleportWithVelocityInfo.OnTriggered.BindUFunction(this, n"TriggerTeleportWithVelocity");
		TeleportWithVelocityInfo.OnStatus.BindUFunction(this, n"StatusTeleportWithVelocity");
		TeleportWithVelocityInfo.Keys = TeleportWithVelocityKeybinds;
		Player.RegisterDevInput(TeleportWithVelocityInfo);

		FHazeDevInputInfo TeleportToCheckpointInfo;
		TeleportToCheckpointInfo.Name = n"Teleport to Checkpoint";
		TeleportToCheckpointInfo.Category = n"Saved Locations";
		TeleportToCheckpointInfo.bTriggerLocalOnly = true;
		TeleportToCheckpointInfo.DisplaySortOrder = 9;
		TeleportToCheckpointInfo.OnTriggered.BindUFunction(this, n"TriggerTeleportToCheckpoint");
		TeleportToCheckpointInfo.Keys = TeleportToCheckpointKeybinds;
		Player.RegisterDevInput(TeleportToCheckpointInfo);

		for (int i = 0; i < 5; i++)
		{
			int Slot = i + 1;
			FHazeDevInputInfo TeleportSlotInfo;
			TeleportSlotInfo.Name = FName("Slot" + Slot);
			TeleportSlotInfo.Category = n"Saved Locations";
			TeleportSlotInfo.DisplaySortOrder = Slot * 2;
			TeleportSlotInfo.OnTriggered.BindUFunction(this, FName("TriggerTeleportSlot" + Slot));
			TeleportSlotInfo.OnStatus.BindUFunction(this, FName("StatusTeleportSlot" + Slot));
			switch (Slot)
			{
				case 1: {
					TeleportSlotInfo.AddKey(EKeys::One);
					TeleportSlotInfo.AddKey(EKeys::Gamepad_FaceButton_Top);
					break;
				}
				case 2: {
					TeleportSlotInfo.AddKey(EKeys::Two);
					TeleportSlotInfo.AddKey(EKeys::Gamepad_FaceButton_Right);
					break;
				}
				case 3: {
					TeleportSlotInfo.AddKey(EKeys::Three);
					TeleportSlotInfo.AddKey(EKeys::Gamepad_FaceButton_Bottom);
					break;
				}
				case 4: {
					TeleportSlotInfo.AddKey(EKeys::Four);
					TeleportSlotInfo.AddKey(EKeys::Gamepad_FaceButton_Left);
					break;
				}
				case 5: {
					TeleportSlotInfo.AddKey(EKeys::Five);
					TeleportSlotInfo.AddKey(EKeys::Gamepad_RightThumbstick);
					break;
				}
			}
			Player.RegisterDevInput(TeleportSlotInfo);
		}



	}

	UFUNCTION() void TriggerTeleportSlot1(){ TriggerTeleportSlot(1); }
	UFUNCTION() void TriggerTeleportSlot2(){ TriggerTeleportSlot(2); }
	UFUNCTION() void TriggerTeleportSlot3(){ TriggerTeleportSlot(3); }
	UFUNCTION() void TriggerTeleportSlot4(){ TriggerTeleportSlot(4); }
	UFUNCTION() void TriggerTeleportSlot5(){ TriggerTeleportSlot(5); }

	UFUNCTION() void StatusTeleportSlot1(FString& OutDescription, FLinearColor& OutColor){ StatusTeleportSlot(OutDescription, OutColor, 1); }
	UFUNCTION() void StatusTeleportSlot2(FString& OutDescription, FLinearColor& OutColor){ StatusTeleportSlot(OutDescription, OutColor, 2); }
	UFUNCTION() void StatusTeleportSlot3(FString& OutDescription, FLinearColor& OutColor){ StatusTeleportSlot(OutDescription, OutColor, 3); }
	UFUNCTION() void StatusTeleportSlot4(FString& OutDescription, FLinearColor& OutColor){ StatusTeleportSlot(OutDescription, OutColor, 4); }
	UFUNCTION() void StatusTeleportSlot5(FString& OutDescription, FLinearColor& OutColor){ StatusTeleportSlot(OutDescription, OutColor, 5); }

	UFUNCTION()
	void TriggerTeleportSlot(int Slot)
	{
		StartTeleport(Slot);
	}

	UFUNCTION()
	void StatusTeleportSlot(FString& OutDescription, FLinearColor& OutColor, int Slot)
	{
		FHazeProgressPointRef ProgressPointRef = GetSaveSlotData(Slot).ProgressPoint;
		FString PointName = ProgressPointRef.Name;
		FString LevelName = Progress::GetShortLevelName(Progress::GetLevelGroup(ProgressPointRef.InLevel));

		OutDescription = LevelName + "  " + PointName + "\n[ " + GetSaveSlotData(Slot).Location + " ]";
		OutColor = FLinearColor::White;
	}

	UFUNCTION()
	void TriggerTeleportToCheckpoint()
	{
		StartTeleport(SaveSlot, true);
	}

	UFUNCTION()
	void TriggerTeleportWithVelocity()
	{
		bWithVelocity = !bWithVelocity;
		SaveConfig();
	}

	UFUNCTION()
	void StatusTeleportWithVelocity(FString& OutDescription, FLinearColor& OutColor)
	{
		if (bWithVelocity)
		{
			OutDescription = "[ YES ]";
			OutColor = FLinearColor::Green;
		} 
		else
		{
			OutDescription = "[ NO ]";
			OutColor = FLinearColor::Red;
		}
	}

	UFUNCTION()
	void TriggerSaveSlot()
	{
		if (SaveSlot >= 5)
			SaveSlot = 1;
		else
			SaveSlot++;
		SaveConfig();
	}

	UFUNCTION()
	void StatusSaveSlot(FString& OutDescription, FLinearColor& OutColor)
	{
		OutDescription = "[ " + SaveSlot + " ]";
		OutColor = FLinearColor::LucBlue;
	}

	UFUNCTION()
	void TriggerSaveCurrentLocation()
	{
		SaveLocation();
	}

	UFUNCTION()
	void TriggerTeleportToSaved()
	{
		StartTeleport(SaveSlot);
	}

	AHazeActor GetTeleportingActor()
	{
		auto AttachedActor = Player.GetAttachParentActor();
		if (AttachedActor != nullptr)
			return Cast<AHazeActor>(AttachedActor);

		return Cast<AHazeActor>(Player);
	}

	void SaveLocation()
	{
		auto TeleportingActor = GetTeleportingActor();
		GetCurrentSaveSlotData().Location = TeleportingActor.ActorLocation;
		GetCurrentSaveSlotData().Rotation = TeleportingActor.ActorRotation;
		GetCurrentSaveSlotData().Velocity = TeleportingActor.ActorVelocity;

		FHazeProgressPointRef ChapterRef;
		FHazeProgressPointRef ProgressPointRef;
		if (Save::GetSaveToRestart(ChapterRef, ProgressPointRef))
		{
			GetCurrentSaveSlotData().ProgressPoint = ProgressPointRef;
		}

		SaveConfig();
	}

	FModTeleportData& GetCurrentSaveSlotData()
	{
		return Saved[SaveSlot - 1];
	}

	FModTeleportData& GetSaveSlotData(int inSaveSlot)
	{
		return Saved[inSaveSlot - 1];
	}

	void StartTeleport(int Slot, bool bIsProgressPoint = false)
	{
		teleportToSaveSlot = Slot;
		bTeleportingWithProgressPoint = bIsProgressPoint;
		bIsTeleporting = true;
	}

	void StopTeleport()
	{
		bIsTeleporting = false;
		teleportToSaveSlot = 0;
		bTeleportingWithProgressPoint = false;
	}

	UFUNCTION(BlueprintOverride)
	bool ShouldActivate() const
	{
		if (Game::IsInLoadingScreen())
			return false;
		if (bIsTeleporting)
			return true;
		return false;
	}

	UFUNCTION(BlueprintOverride)
	bool ShouldDeactivate() const
	{
		if (bIsTeleporting)
			return false;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated()
	{
		auto Slot = GetSaveSlotData(teleportToSaveSlot);
		if (bTeleportingWithProgressPoint)
		{
			FString SavedProgressPoint = Progress::GetProgressPointRefID(Slot.ProgressPoint);
			Mod::Log("Restarting from Progress Point: " + SavedProgressPoint, 2.0);
			Progress::RestartFromProgressPoint(SavedProgressPoint, false);
		}
		else
		{
			auto TeleportingActor = GetTeleportingActor();
			TeleportingActor.TeleportActor(
				Slot.Location,
				Slot.Rotation,
				n"TeleportToSavedLocation",
				true
			);

			if (bWithVelocity)
			{
				TeleportingActor.ActorVelocity = Slot.Velocity;
			}

			Mod::Log("Teleporting to: " + Slot.Location, 2.0);
		}

		StopTeleport();
	}
}
