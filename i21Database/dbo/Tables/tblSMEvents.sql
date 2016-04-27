CREATE TABLE [dbo].[tblSMEvents] (
	[intEventId] INT IDENTITY(1,1) NOT NULL,
	[intEntityId] INT NULL,
	[strEventTitle] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strJsonData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScreen] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] DATETIME DEFAULT (GETDATE()) NULL,
	[dtmModified] DATETIME DEFAULT (GETDATE()) NULL,
	[intConcurrencyId] INT NOT NULL,
	[dtmStart] DATETIME2(7) NULL,
	[dtmEnd] DATETIME2(7) NULL,
    CONSTRAINT [PK_tblSMEvents] PRIMARY KEY CLUSTERED ([intEventId] ASC)
);