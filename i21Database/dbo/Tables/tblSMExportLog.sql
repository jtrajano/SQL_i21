CREATE TABLE [dbo].[tblSMExportLog]
(
	[intExportLogId]		INT NOT NULL PRIMARY KEY IDENTITY,
	[intEntityId]			[int] NOT NULL,
	[strContextId]			[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strName]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strJsonData]			[text] NULL,
	[strStatus]				[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmCreated]			[datetime] NULL DEFAULT (GETUTCDATE()), 
	[dtmCompleted]			[datetime] NULL, 
	[intConcurrencyId]		[int] NOT NULL DEFAULT (1),
    CONSTRAINT [FK_tblSMExportLog_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE
)
