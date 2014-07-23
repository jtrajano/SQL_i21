CREATE TABLE [dbo].[tblCMDataImportStatus]
(
	[intDataImportStatusId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [dtmImportRun] DATETIME NULL, 
    [intUserId] INT NULL
)
