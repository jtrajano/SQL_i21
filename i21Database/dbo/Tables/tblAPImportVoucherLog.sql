CREATE TABLE [dbo].[tblAPImportVoucherLog]
(
	[intImportLogId] INT NOT NULL IDENTITY, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
	[strLogKey]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblAPImportVoucherLog] PRIMARY KEY ([intImportLogId])
)
GO
CREATE NONCLUSTERED INDEX [IX_strLogKey]
    ON [dbo].[tblAPImportVoucherLog]([strLogKey] ASC);
GO