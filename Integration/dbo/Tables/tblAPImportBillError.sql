CREATE TABLE [dbo].[tblAPImportBillError]
(
	[intId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strIssue] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, 
    [ysnWarning] BIT NOT NULL DEFAULT 0
)
