CREATE TABLE [dbo].[tblFRArchive] (
    [intArchiveId]		INT IDENTITY(1,1) NOT NULL,
	[intReportId]		INT NULL,
	[blbReport]			VARBINARY(MAX) NULL,
	[strReportName]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strDescripion]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[dtmAsOfDate]		DATETIME NULL,
	[dtmAdded]			DATETIME DEFAULT (getdate()) NULL,
	[strGUID]			NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]		INT NULL,
	[intConcurrencyId]	INT NOT NULL,
    CONSTRAINT [PK_tblFRArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
);