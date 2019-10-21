CREATE TABLE [dbo].[tblSMReminderList]
(
    [intReminderListId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[strReminder] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,    
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strQuery] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strNamespace] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strParameter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NULL,
    [intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
