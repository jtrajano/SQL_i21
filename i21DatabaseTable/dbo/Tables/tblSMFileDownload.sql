CREATE TABLE [dbo].[tblSMFileDownload]
(
	[intFileDownloadId] INT NOT NULL IDENTITY,
	[strFileGroupName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intParentMenuId] INT NOT NULL DEFAULT 0,
	[ysnLeaf] BIT NOT NULL DEFAULT 0,
	[intSort] INT NOT NULL DEFAULT 1,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_intFileDownloadId] PRIMARY KEY ([intFileDownloadId])
)