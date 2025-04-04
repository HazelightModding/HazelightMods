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

namespace Mod
{
	void Log(FString Message, float Duration = 10f)
	{
		GetModManager().Log.Add(Message, Duration);
	}

	void Log(FName Message, float Duration = 10f)
	{
		Log(Message.ToString(), Duration);
	}

	namespace Log
	{
		FString GetAllLogMessages()
		{
			return GetModManager().Log.GetAllMessagesAsFString();
		}
	}
}

