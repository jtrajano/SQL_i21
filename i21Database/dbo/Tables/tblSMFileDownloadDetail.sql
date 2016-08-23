CREATE TABLE [dbo].[tblSMFileDownloadDetail]
(
	[intFileDownloadDetailId] INT NOT NULL IDENTITY,
	[intFileDownloadId] INT NOT NULL,
	[strFile] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intSize] INT NULL,
	[dtmDateAdded] DATETIME NOT NULL,
	[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblSMFileDownloadDetail] PRIMARY KEY ([intFileDownloadDetailId]),
	CONSTRAINT [FK_tblSMFileDownloadDetail_tblSMFileDownload] FOREIGN KEY ([intFileDownloadId]) REFERENCES [tblSMFileDownload]([intFileDownloadId]) ON DELETE CASCADE
)