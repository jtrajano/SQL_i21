CREATE TABLE [dbo].[tblSMEvents] (
    [intEventId]		INT IDENTITY(1,1) NOT NULL,
	[intEntityId]		INT NULL,
	[strEventTitle]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dStart]            DATE NULL,
	[tStart]            TIME(7) NULL,
	[dEnd]              DATE NULL,
	[tEnd]              TIME(7) NULL,
	[strJsonData]       NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScreen]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated]		DATETIME DEFAULT (GETDATE()) NULL,
	[dtmModified]		DATETIME DEFAULT (GETDATE()) NULL,
	[intConcurrencyId]	INT NOT NULL,
    CONSTRAINT [PK_tblSMEvents] PRIMARY KEY CLUSTERED ([intEventId] ASC)
);