CREATE TABLE [dbo].[tblFAGLAccountChangeLog]
(
	[intLogId]			INT IDENTITY(1,1) NOT NULL,
	[intAssetId]		INT NOT NULL,
	[dtmDate]			DATETIME,
	[strDescription]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]		INT NULL,
	[intConcurrencyId]	INT DEFAULT (1) NOT NULL,

    CONSTRAINT [PK_tblFAGLAccountChangeLog] PRIMARY KEY CLUSTERED ([intLogId] ASC)
)
