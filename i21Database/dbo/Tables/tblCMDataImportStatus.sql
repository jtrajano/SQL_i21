CREATE TABLE [dbo].[tblCMDataImportStatus]
(
	[intDataImportStatusId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strDescription] NVARCHAR(250) NULL, 
    [dtmImportRun] DATETIME NULL, 
    [intUserId] INT NULL
)
