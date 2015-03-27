CREATE TABLE [dbo].[tblSMReminderList]
(
    [intReminderListId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[strReminder] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,    
    [strType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strQuery] NVARCHAR(max) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strNamespace] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
