enum EModVisibleVolumes
{
	All,
	BlockingVolumes,
	RespawnPoints,
	ProgressPoints,
	DeathVolumes,
	CameraVolumes,
	CapabilityVolumes,
	PlayerTriggers,
	ActorTriggers,
	VOTriggers,
	SplineTriggers,
	None
}

enum EModVolumeLineThickness
{
	Thin,
	Normal,
	Thick,
	MAX
}

namespace Mod
{
	namespace VolumeColors
	{
		const FLinearColor RespawnPointVolume = 				FLinearColor(0.0, 1.0, 0.8, 1.0);
		const FLinearColor DeathVolume = 						FLinearColor(1.0, 0.0, 0.0, 1.0);
		const FLinearColor BlockingVolume = 					FLinearColor(1.00, 0.50, 0.50);

		const FLinearColor ActorTrigger = 						FLinearColor(0.5, 0.6, 0.1, 1.0);
		const FLinearColor PlayerTrigger = 						FLinearColor(1.0, 0.0, 0.8, 1.0);
		const FLinearColor BothPlayerTrigger = 					FLinearColor(0.5, 0.2, 1.0, 1.0);
		const FLinearColor CameraVolume = 						FLinearColor(0.0, 1.0, 0.4, 1.0);

		const FLinearColor PlayerVOTrigger =					FLinearColor(0.61, 0.00, 0.50);
		const FLinearColor PlayerVOLocationTrigger = 			FLinearColor(0.91, 0.00, 0.88);
		const FLinearColor ContextualMovesTrigger = 			FLinearColor(0.07, 0.70, 0.10);
		const FLinearColor FallTowardSplineZone = 				FLinearColor(0.32, 0.34, 0.59);
		const FLinearColor CapabilitySheetVolume = 				FLinearColor(0.8, 1.0, 0.2, 1.0);
		const FLinearColor CapabilityBlockVolume = 				FLinearColor(1.0, 0.5, 0.5, 1.0);
		const FLinearColor ApplySettingsTrigger = 				FLinearColor(0.0, 0.6, 0.9, 1.0);
		const FLinearColor IndoorSkyLightingVolume = 			FLinearColor(0.94, 1.00, 0.43);
		const FLinearColor PlayerKillOnAnyImpactVolume = 		FLinearColor(1.00, 0.49, 0.08); 

	}
}

UCLASS(Config = EditorPerProjectUserSettings)
class UToggleVolumesCapability : UHazePlayerCapability
{
	default CapabilityTags.Add(n"Mod");
	default TickGroup = EHazeTickGroup::Gameplay;

	bool ShouldShowVolumes = false;
	EModVisibleVolumes VolumeVisibility = EModVisibleVolumes::All;
	EModVolumeLineThickness LineThickness = EModVolumeLineThickness::Thin;
	TArray<ABrush> Brushes;
	bool bDisplayNames = true;

	UPROPERTY(Config)
	TSet<FKey> ToggleVolumesKeybinds;

	UPROPERTY(Config)
	TSet<FKey> VisibleVolumesKeybinds;

	UPROPERTY(Config)
	TSet<FKey> LineThicknessKeybinds;

	UPROPERTY(Config)
	TSet<FKey> NamesVisibleKeybinds;

	UFUNCTION(BlueprintOverride)
	void Setup()
	{
		LoadConfig();

		if (ToggleVolumesKeybinds.IsEmpty())
		{
			// Default Binds
			ToggleVolumesKeybinds.Add(EKeys::Gamepad_FaceButton_Right);
			ToggleVolumesKeybinds.Add(EKeys::O);
		}

		if (VisibleVolumesKeybinds.IsEmpty())
		{
			// Default Binds
			VisibleVolumesKeybinds.Add(EKeys::Gamepad_FaceButton_Bottom);
			VisibleVolumesKeybinds.Add(EKeys::I);
		}

		if (LineThicknessKeybinds.IsEmpty())
		{
			// Default Binds
			LineThicknessKeybinds.Add(EKeys::Gamepad_FaceButton_Left);
			LineThicknessKeybinds.Add(EKeys::U);
		}

		if (NamesVisibleKeybinds.IsEmpty())
		{
			// Default Binds
			NamesVisibleKeybinds.Add(EKeys::Gamepad_FaceButton_Top);
			NamesVisibleKeybinds.Add(EKeys::Y);
		}

		SaveConfig();

		FHazeDevInputInfo Toggle;
		Toggle.Name = n"Toggle Volumes";
		Toggle.Category = n"Default";
		Toggle.DisplaySortOrder = 1;
		Toggle.OnTriggered.BindUFunction(this, n"ToggleVolumes");
		Toggle.OnStatus.BindUFunction(this, n"StatusVolumes");
		Toggle.bTriggerLocalOnly = true;
		Toggle.Keys = ToggleVolumesKeybinds;
		Player.RegisterDevInput(Toggle);
		Toggle.Category = n"Volumes";
		Player.RegisterDevInput(Toggle);

		FHazeDevInputInfo VisibleVolumes;
		VisibleVolumes.Name = n"Visible Volumes: ";
		VisibleVolumes.Category = n"Volumes";
		VisibleVolumes.DisplaySortOrder = 0;
		VisibleVolumes.OnTriggered.BindUFunction(this, n"NextVolumeVisibility");
		VisibleVolumes.OnStatus.BindUFunction(this, n"VolumeVisiblityStatus");
		VisibleVolumes.bTriggerLocalOnly = true;
		VisibleVolumes.Keys = VisibleVolumesKeybinds;
		Player.RegisterDevInput(VisibleVolumes);

		FHazeDevInputInfo LineThicknessInfo;
		LineThicknessInfo.Name = n"Line Thickness: ";
		LineThicknessInfo.Category = n"Volumes";
		LineThicknessInfo.DisplaySortOrder = 2;
		LineThicknessInfo.OnTriggered.BindUFunction(this, n"NextLineThickness");
		LineThicknessInfo.OnStatus.BindUFunction(this, n"LineThicknessStatus");
		LineThicknessInfo.bTriggerLocalOnly = true;
		LineThicknessInfo.Keys = LineThicknessKeybinds;
		Player.RegisterDevInput(LineThicknessInfo);

		FHazeDevInputInfo NameInfo;
		NameInfo.Name = n"Names Visible: ";
		NameInfo.Category = n"Volumes";
		NameInfo.DisplaySortOrder = 3;
		NameInfo.OnTriggered.BindUFunction(this, n"ToggleNameVisibility");
		NameInfo.OnStatus.BindUFunction(this, n"NameVisibilityStatus");
		NameInfo.bTriggerLocalOnly = true;
		NameInfo.Keys = NamesVisibleKeybinds;
		Player.RegisterDevInput(NameInfo);

	}

	UFUNCTION()
	void ToggleNameVisibility()
	{
		bDisplayNames = !bDisplayNames;

		if (ShouldShowVolumes)
		{
			SetNameVisibility(bDisplayNames);
		}
	}


	UFUNCTION()
	void NameVisibilityStatus(FString &OutDescription, FLinearColor &OutColor)
	{
		if (bDisplayNames)
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

	UFUNCTION()
	void NextLineThickness()
	{
		LineThickness++;

		if (LineThickness == EModVolumeLineThickness::MAX)
		{
			LineThickness = EModVolumeLineThickness::Thin;
		}

		if (ShouldShowVolumes)
		{
			for (auto Brush : Brushes)
			{
				if (IsValid(Brush) && IsValid(Brush.BrushComponent))
					SetLineThickness(Brush.BrushComponent);
			}
		}
	}


	UFUNCTION()
	void LineThicknessStatus(FString &OutDescription, FLinearColor &OutColor)
	{
		FString ThicknessName = "None";
		switch(LineThickness)
		{
			case EModVolumeLineThickness::Thin: 		ThicknessName = "Thin"; break;
			case EModVolumeLineThickness::Normal: 		ThicknessName = "Normal"; break;
			case EModVolumeLineThickness::Thick: 		ThicknessName = "Thick"; break;
			case EModVolumeLineThickness::MAX: 			ThicknessName = "???"; break;
		}
		OutDescription = "[ " + ThicknessName + " ]";
		OutColor = FLinearColor::LucBlue;
	}


	UFUNCTION()
	void NextVolumeVisibility()
	{
		VolumeVisibility++;

		if (VolumeVisibility == EModVisibleVolumes::None)
		{
			VolumeVisibility = EModVisibleVolumes::All;
		}

		if (ShouldShowVolumes)
		{
			SetBrushVisibility(ShouldShowVolumes);
			SetNameVisibility(bDisplayNames);
		}
	}

	UFUNCTION()
	void VolumeVisiblityStatus(FString &OutDescription, FLinearColor &OutColor)
	{
		FString VisibilityName = "None";
		switch (VolumeVisibility)
		{
			case EModVisibleVolumes::All: 					VisibilityName = "All"; break;
			case EModVisibleVolumes::BlockingVolumes: 		VisibilityName = "BlockingVolumes"; break;
			case EModVisibleVolumes::RespawnPoints: 		VisibilityName = "RespawnPoints"; break;
			case EModVisibleVolumes::ProgressPoints: 		VisibilityName = "ProgressPoints"; break;
			case EModVisibleVolumes::DeathVolumes: 			VisibilityName = "DeathVolumes"; break;
			case EModVisibleVolumes::CameraVolumes: 		VisibilityName = "CameraVolumes"; break;
			case EModVisibleVolumes::CapabilityVolumes: 	VisibilityName = "CapabilityVolumes"; break;
			case EModVisibleVolumes::PlayerTriggers: 		VisibilityName = "PlayerTriggers"; break;
			case EModVisibleVolumes::ActorTriggers: 		VisibilityName = "ActorTriggers"; break;
			case EModVisibleVolumes::VOTriggers: 			VisibilityName = "VOTriggers"; break;
			case EModVisibleVolumes::SplineTriggers: 		VisibilityName = "SplineTriggers"; break;
			case EModVisibleVolumes::None: 					VisibilityName = "???"; break;
		}

		OutDescription = "[ " + VisibilityName + " ]";
		OutColor = FLinearColor::LucBlue;
		
	}

	UFUNCTION()
	void ToggleVolumes()
	{
		ShouldShowVolumes = !ShouldShowVolumes;
	}

	UFUNCTION()
	void StatusVolumes(FString &OutDescription, FLinearColor &OutColor)
	{
		if (ShouldShowVolumes)
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

	UFUNCTION(BlueprintOverride)
	bool ShouldActivate() const
	{
		if (ShouldShowVolumes)
			return true;

		return false;
	}

	UFUNCTION(BlueprintOverride)
	bool ShouldDeactivate() const
	{
		if (ShouldShowVolumes)
			return false;

		return true;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated()
	{
		Mod::Log("Showing Volumes", 2.0);
		GetAllBrushes();
		SetBrushVisibility(true);
		SetNameVisibility(bDisplayNames);
	}

	TArray<UPrimitiveComponent> OtherComponentsToVisualize;
	void GetAllBrushes()
	{
		for (auto Actor : Mod::GetAllActors())
		{
			if (Actor.IsA(ABrush.Get()))
			{
				ABrush Brush = Cast<ABrush>(Actor);
				if (Brush != nullptr)
					Brushes.AddUnique(Brush);
			}			
		}
	}

	void SetBrushVisibility(bool bIsVisible)
	{
		for (auto Brush : Brushes)
		{
			if (Brush == nullptr) 
				continue;

			auto BrushComponent = Brush.BrushComponent;
			if (BrushComponent == nullptr) 
				continue;

			SetLineThickness(BrushComponent);

			if (ShouldVolumeBeVisible(Brush.Name))
			{
				BrushComponent.SetVisibility(bIsVisible, true);
				BrushComponent.SetHiddenInGame(!bIsVisible, true);
			}
			else
			{
				BrushComponent.SetVisibility(false, true);
				BrushComponent.SetHiddenInGame(true, true);
			}

			BrushComponent.MarkRenderStateDirty();
		}
	}

	void SetLineThickness(UBrushComponent BrushComp)
	{
		if (BrushComp == nullptr)
			return;

		switch(LineThickness)
		{
			case EModVolumeLineThickness::Thin: BrushComp.LineThickness = 1.0f; break;
			case EModVolumeLineThickness::Normal: BrushComp.LineThickness = 5.0f; break;
			case EModVolumeLineThickness::Thick: BrushComp.LineThickness = 15.0f; break;
		}

		BrushComp.MarkRenderStateDirty();
	}

	void SetNameVisibility(bool bIsVisible)
	{
		for (auto Brush : Brushes)
		{
			if (Brush == nullptr)
			{
				Brushes.Remove(Brush);
				continue;
			}

			auto BrushComponent = Brush.BrushComponent;
			if (BrushComponent == nullptr) 
				continue;

			UTextRenderComponent NameTag = UTextRenderComponent::GetOrCreate(Brush, n"ModVolumeVisibilityNameTag");

			if (!IsValid(NameTag))
				continue;

			if (bIsVisible)
			{
				NameTag.SetText(FText::FromName(Brush.Name));
				NameTag.SetTextRenderColor(GetColorForBrush(Brush.Name).ToFColor(false));

				NameTag.SetWorldSize(100.0f);
				NameTag.SetHorizontalAlignment(EHorizTextAligment::EHTA_Center);
				NameTag.SetVerticalAlignment(EVerticalTextAligment::EVRTA_TextCenter);
				NameTag.SetRelativeLocation(FVector(0,0,10));
				NameTag.SetRelativeRotation(FRotator(0,0,0));
				NameTag.SetAbsolute(false, false, true);
			}
			
			NameTag.SetVisibility(bIsVisible);
			NameTag.MarkRenderStateDirty();
		}
	}

	FLinearColor GetColorForBrush(FName Name)
	{
		FLinearColor TextColor = FLinearColor::White;
		FString BrushName = Name.ToString();

		if (BrushName.Contains("RespawnPoint")) 		TextColor = Mod::VolumeColors::RespawnPointVolume;
		if (BrushName.Contains("Camera")) 				TextColor = Mod::VolumeColors::CameraVolume;
		if (BrushName.Contains("Death")) 				TextColor = Mod::VolumeColors::DeathVolume;
		if (BrushName.Contains("CapabilityBlock")) 		TextColor = Mod::VolumeColors::CapabilityBlockVolume;
		if (BrushName.Contains("CapabilitySheet")) 		TextColor = Mod::VolumeColors::CapabilitySheetVolume;
		if (BrushName.Contains("ActorTrigger")) 		TextColor = Mod::VolumeColors::ActorTrigger;
		if (BrushName.Contains("PlayerTrigger")) 		TextColor = Mod::VolumeColors::PlayerTrigger;
		if (BrushName.Contains("PlayerVO")) 			TextColor = Mod::VolumeColors::PlayerVOTrigger;
		if (BrushName.Contains("Blocking")) 			TextColor = Mod::VolumeColors::BlockingVolume;

		return TextColor;
	}

	bool ShouldVolumeBeVisible(FName Name)
	{
		bool bShouldBeVisible = false;
		FString BrushName = Name.ToString();
		switch (VolumeVisibility)
		{
			case EModVisibleVolumes::All: 																bShouldBeVisible = true; break;
			case EModVisibleVolumes::BlockingVolumes: 		if (BrushName.Contains("BlockingVolume")) 	bShouldBeVisible = true; break;
			case EModVisibleVolumes::RespawnPoints: 		if (BrushName.Contains("RespawnPoint")) 	bShouldBeVisible = true; break;
			case EModVisibleVolumes::ProgressPoints: 		if (BrushName.Contains("ProgressPoint")) 	bShouldBeVisible = true; break;
			case EModVisibleVolumes::CameraVolumes: 		if (BrushName.Contains("Camera")) 			bShouldBeVisible = true; break;
			case EModVisibleVolumes::DeathVolumes: 			if (BrushName.Contains("Death")) 			bShouldBeVisible = true; break;
			case EModVisibleVolumes::CapabilityVolumes: 	if (BrushName.Contains("Capability")) 		bShouldBeVisible = true; break;
			case EModVisibleVolumes::PlayerTriggers: 		if (BrushName.Contains("PlayerTrigger")) 	bShouldBeVisible = true; break;
			case EModVisibleVolumes::ActorTriggers: 		if (BrushName.Contains("ActorTrigger")) 	bShouldBeVisible = true; break;
			case EModVisibleVolumes::VOTriggers: 			if (BrushName.Contains("PlayerVO")) 		bShouldBeVisible = true; break;
			case EModVisibleVolumes::SplineTriggers: 		if (BrushName.Contains("Spline")) 			bShouldBeVisible = true; break;
			case EModVisibleVolumes::None: 																bShouldBeVisible = false; break;
		}

		return bShouldBeVisible;
	}


	UFUNCTION(BlueprintOverride)
	void OnDeactivated()
	{
		Mod::Log("Hiding Volumes", 2.0);
		
		SetBrushVisibility(false);
		SetNameVisibility(false);
	}

	UFUNCTION(BlueprintOverride)
	void TickActive(float DeltaTime)
	{
		if (!ShouldShowVolumes)
			return;
	

		for (auto Brush : Brushes)
		{
			if (Brush == nullptr)
			{
				Brushes.Remove(Brush);
				continue;
			}

			UTextRenderComponent NameTag = UTextRenderComponent::Get(Brush, n"ModVolumeVisibilityNameTag");
			if (NameTag == nullptr)
				continue;
				

			if (!NameTag.IsVisible())
				continue;

			FVector ToCamera = (Player.GetViewLocation() - NameTag.WorldLocation).GetSafeNormal();
			FVector Up = Player.GetViewRotation().RotateVector(FVector::UpVector).GetSafeNormal();
			FVector Right = Up.CrossProduct(ToCamera).GetSafeNormal();
			FVector Forward = Right.CrossProduct(Up).GetSafeNormal();
			FQuat LookAtQuat = FQuat::MakeFromAxes(Forward, Right, Up);

			NameTag.SetWorldRotation(LookAtQuat);
		}
	}

	UFUNCTION(BlueprintOverride)
	void PreTick(float DeltaTime)
	{
		if (Game::IsInLoadingScreen())
		{
			Brushes.Reset();
			ShouldShowVolumes = false;
		}
	}
};