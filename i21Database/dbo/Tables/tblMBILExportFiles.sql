CREATE TABLE [dbo].[tblMBILExportFiles](
	[intExportFilesId] INT IDENTITY NOT NULL,
	[strFileName] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,	
	[dtmCreatedDate] DATETIME NULL DEFAULT GETDATE(),
	[intUserId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblMBILExportFiles] PRIMARY KEY CLUSTERED ([intExportFilesId] ASC)
)