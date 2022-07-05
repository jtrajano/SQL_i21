CREATE TABLE [tblSCDisconnectedScheduleCreationHistory]
(
[intHistoryId]		INT IDENTITY (1, 1) ,
[intScheduleId]	    INT NULL,
[strJobId]			NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
[strStatus]			NVARCHAR(200)  COLLATE Latin1_General_CI_AS NULL,
[strRemarks]		NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
[ysnRecurring]      BIT NULL DEFAULT(0),
[strTempJobId]		NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
[dtmDateOfExecution] DATETIME NULL,
[dtmDateCreated]	DATETIME NULL,
[dtmDateStarted]	DATETIME NULL,
[dtmDateCompleted]	DATETIME NULL,
[intConcurrencyId]	INT NOT NULL DEFAULT(1),
CONSTRAINT [PK_tblSCDisconnectedScheduleCreationHistory_intHistoryId] primary key clustered ([intHistoryId] ASC)

)