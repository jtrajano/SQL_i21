CREATE TABLE [dbo].[tblFRArchive] (
    [intArchiveId]		INT IDENTITY(1,1) NOT NULL,
	[intReportId]		INT NULL,
	[blbReport]			VARBINARY(MAX) NULL,
	[strReportName]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]	NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[ysnSupressZero]    BIT DEFAULT(0) NULL,
	[dtmAsOfDate]		DATETIME NULL,
	[dtmDateCreated]	DATETIME DEFAULT (getdate()) NULL,
	[strGUID]			NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strType]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	[intEntityId]		INT NULL,
	[intConcurrencyId]	INT NOT NULL,
    CONSTRAINT [PK_tblFRArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
);