CREATE TABLE [tblSCDisconnectedScheduleCreationHistory]
(
[intHistoryId]		INT IDENTITY (1, 1) ,
[intScheduleId]	    INT NULL,
[strJobId]			NVARCHAR(MAX) NULL,
[strStatus]			NVARCHAR(200) NULL,
[strRemarks]		NVARCHAR(MAX) NULL,
[strTempJobId]		NVARCHAR(MAX) NULL,
[dtmDateOfExecution] DATETIME NULL,
[dtmDateCreated]	DATETIME NULL,
[dtmDateStarted]	DATETIME NULL,
[dtmDateCompleted]	DATETIME NULL,
[intConcurrencyId]	INT NOT NULL DEFAULT(1),
CONSTRAINT [PK_tblSCDisconnectedScheduleCreationHistory_intHistoryId] primary key clustered ([intHistoryId] ASC)

)