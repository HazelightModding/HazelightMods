struct FLogMessage
{
	FString Message;
	float Duration;

	FLogMessage(FString InMessage, float InDuration)
	{
		Message = InMessage;
		Duration = InDuration;
	}

	bool HasExpired()
	{
		return Duration <= 0;
	}

}

struct FModLog
{
	TArray<FLogMessage> Messages;
	int MaxSize = 35;

	void Add(FString Message, float Duration = 10f)
	{
		Messages.Add(FLogMessage(Message, Duration));
	}

	void UpdateLogMessages(float DeltaTime)
	{
		for (int i = Messages.Num() - 1; i >= 0; i--)
		{
			if (i > MaxSize)
				continue;

			Messages[i].Duration -= DeltaTime;

			if (Messages[i].HasExpired())
			{
				Messages.RemoveAt(i);
				continue;
			}

		}
	}

	void SetMaxSize(int InSize)
	{
		MaxSize = InSize;
	}

	FString GetAllMessagesAsFString()
	{
		FString Str;

		int MaxIndex = Messages.Num() > MaxSize ? MaxSize : Messages.Num();
		for (int i = 0; i < MaxIndex; i++)
		{
			Str += Messages[i].Message + "\n";
		}

		if (Messages.Num() > MaxSize)
		{
			Str += "\n+ " + (Messages.Num() - MaxSize) + " more log messages.";
		}

		return Str;
	}
}

namespace Global
{
	void Log(const FString& Text){ Log(Text); }
	void LogInfo(const FString& Text){ LogInfo(Text); }
	void LogDisplay(const FString& Text){ LogDisplay(Text); }
	void Error(const FString& Text){ Error(Text); }
	void Warning(const FString& Text){ Warning(Text); }
	void LogIf(bool Condition, const FString& Text){ LogIf(Condition, Text); }
	void LogInfoIf(bool Condition, const FString& Text){ LogInfoIf(Condition, Text); }
	void LogDisplayIf(bool Condition, const FString& Text){ LogDisplayIf(Condition, Text); }
	void ErrorIf(bool Condition, const FString& Text){ ErrorIf(Condition, Text); }
	void WarningIf(bool Condition, const FString& Text){ WarningIf(Condition, Text); }

	void Log(const FName& CategoryName, const FString& Text){ Log(CategoryName, Text); }
	void LogInfo(const FName& CategoryName, const FString& Text){ LogInfo(CategoryName, Text); }
	void LogDisplay(const FName& CategoryName, const FString& Text){ LogDisplay(CategoryName, Text); }
	void Error(const FName& CategoryName, const FString& Text){ Error(CategoryName, Text); }
	void Warning(const FName& CategoryName, const FString& Text){ Warning(CategoryName, Text); }
	void LogIf(bool Condition, const FName& CategoryName, const FString& Text){ LogIf(Condition, CategoryName, Text); }
	void LogInfoIf(bool Condition, const FName& CategoryName, const FString& Text){ LogInfoIf(Condition, CategoryName, Text); }
	void LogDisplayIf(bool Condition, const FName& CategoryName, const FString& Text){ LogDisplayIf(Condition, CategoryName, Text); }
	void ErrorIf(bool Condition, const FName& CategoryName, const FString& Text){ ErrorIf(Condition, CategoryName, Text); }
	void WarningIf(bool Condition, const FName& CategoryName, const FString& Text){ WarningIf(Condition, CategoryName, Text); }

	void Throw(const FString& Text){ Throw(Text); }
	void ThrowIf(bool Condition, const FString& Text){ ThrowIf(Condition, Text); }
	void Print(const FString& Text, float32 Duration = 5.f, FLinearColor Color = FLinearColor::LucBlue){ Print(Text, Duration, Color); }
	void PrintFromObject(const UObject WorldContextObject, const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue) { PrintFromObject(WorldContextObject, Text, Duration, Color); }
	void PrintToScreen(const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue) { PrintToScreen(Text, Duration, Color); }
	void PrintWarning(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Yellow) { PrintWarning(Text, Duration, Color); }
	void PrintError(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Red) { PrintError(Text, Duration, Color); }
}


namespace Mod
{
	void AppendMessageToFile(FString Message, FString FileName)
	{
		FString FilePath = "../../Logs/" + FileName;
		FString FileContent = "[" + FDateTime::Now().ToString() + "] " + Message + "\n";
		FFileHelper::SaveStringToFile(FileContent, FilePath, FFileHelper::EEncodingOptions::AutoDetect, uint32(EFileWrite::Append));
	}

	void AppendMessageToFile(FString Message)
	{
		AppendMessageToFile(Message, "SplitFiction.log");
	}



	void Log(const FString& Text, float Duration = 5.0)
	{
		Mod::UE_LOG(Text, Duration);
		//Global::Log(Text);
	}

	void Log(FName Message)
	{
		Mod::Log(Message.ToString());
	}

	void LogInfo(const FString& Text)
	{
		Mod::UE_LOG("[Information] " + Text);
		Global::LogInfo(Text);
	}

	void LogDisplay(const FString& Text)
	{
		Mod::UE_LOG("[Display] " + Text);
		Global::LogDisplay(Text);
	}

	void Error(const FString& Text)
	{
		Mod::UE_LOG("[Error] " + Text);
		Global::Error(Text);
	}

	void Warning(const FString& Text)
	{
		Mod::UE_LOG("[Warning] " + Text);
		Global::Warning(Text);
	}

	void LogIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::UE_LOG(Text);
		}
	}

	void LogInfoIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::LogInfo(Text);
		}
	}

	void LogDisplayIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::LogDisplay(Text);
		}
	}

	void ErrorIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::Error(Text);
		}
	}

	void WarningIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::Warning(Text);
		}
	}

	void Throw(const FString& Text)
	{
		Mod::UE_LOG(Text);
		Throw(Text);
	}

	void ThrowIf(bool Condition, const FString& Text)
	{
		if (Condition)
		{
			Mod::Throw(Text);
		}
	}

	void Print(const FString& Text, float32 Duration = 5.f, FLinearColor Color = FLinearColor::LucBlue)
	{
		Mod::UE_LOG(Text, Duration);
		Global::Print(Text, Duration, Color);
	}

	void PrintFromObject(const UObject WorldContextObject, const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue)
	{
		Mod::UE_LOG(WorldContextObject.Name + " " + Text, Duration);
		Global::PrintFromObject(WorldContextObject, Text, Duration, Color);
	}

	void PrintToScreen(const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue)
	{
		Mod::UE_LOG(Text, Duration);
		Global::PrintToScreen(Text, Duration, Color);
	}

	void PrintWarning(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Yellow)
	{
		Mod::UE_LOG(Text, Duration);
		Global::PrintWarning(Text, Duration, Color);
	}

	void PrintError(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Red)
	{
		Mod::UE_LOG(Text, Duration);
		Global::PrintError(Text, Duration, Color);
	}

	void UE_LOG(FString Message, float32 Duration = 5.f)
	{
		GetModManager().Log.Add(Message, Duration);
		AppendMessageToFile(Message);
	}

	namespace Log
	{
		FString GetAllLogMessages()
		{
			return GetModManager().Log.GetAllMessagesAsFString();
		}
	}
}

