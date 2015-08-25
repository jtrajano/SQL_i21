CREATE TABLE [dbo].[tblAPImportBillError]
(
	[intId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strDescription] NVARCHAR(200) NULL, 
    [strIssue] NVARCHAR(1000) NULL, 
    [ysnWarning] BIT NOT NULL DEFAULT 0
)
