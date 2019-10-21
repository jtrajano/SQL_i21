CREATE TABLE [dbo].[tblSMCleanupLog]
(
	[intCleanupLogId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strModuleName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDesription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate] DATETIME NOT NULL, 
    [dtmUtcDate] DATETIME NOT NULL, 
    [ysnActive] BIT NOT NULL
)
