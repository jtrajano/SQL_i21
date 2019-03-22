CREATE TABLE [dbo].[tblSCImportLogFile]
(
	[intImportLogFileId] INT NOT NULL IDENTITY,
	[intTransactionId] INT NULL,
	[strTransactionNumber] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strLogMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmImportDate] DATETIME NULL DEFAULT GETDATE(), 
)
