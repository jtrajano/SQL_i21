CREATE TABLE [dbo].[tblAPImportVoucherLog]
(
	[intImportLogId] INT NOT NULL IDENTITY, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intLogType] INT NOT NULL, 
    CONSTRAINT [PK_tblAPImportVoucherLog] PRIMARY KEY ([intImportLogId])
)
