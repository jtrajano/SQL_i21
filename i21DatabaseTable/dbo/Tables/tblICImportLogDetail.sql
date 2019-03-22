CREATE TABLE [dbo].[tblICImportLogDetail]
(
	[intImportLogDetailId] INT IDENTITY(1, 1) NOT NULL,
	[intImportLogId] INT NOT NULL,
	[strType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intRecordNo] INT NULL,
	[strField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strValue] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAction] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [PK_tblICImportLogDetail] PRIMARY KEY NONCLUSTERED ([intImportLogDetailId]),
	CONSTRAINT [FK_tblICImportLogDetail_tblICImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [tblICImportLog]([intImportLogId]) ON DELETE CASCADE
)
GO
