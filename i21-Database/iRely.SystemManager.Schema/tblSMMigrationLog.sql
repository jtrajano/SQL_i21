CREATE TABLE [dbo].[tblSMMigrationLog]
(
	[MigrationLogId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strModule] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strEvent] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmMigrated] DATETIME NOT NULL
)
