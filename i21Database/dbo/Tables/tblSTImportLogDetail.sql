
CREATE TABLE [dbo].[tblSTImportLogDetail]
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
	CONSTRAINT [PK_tblSTImportLogDetail] PRIMARY KEY NONCLUSTERED ([intImportLogDetailId]),
	CONSTRAINT [FK_tblSTImportLogDetail_tblSTImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [tblSTImportLog]([intImportLogId]) ON DELETE CASCADE
)
GO
