CREATE TABLE [dbo].[tblCCImportStatus]
(
	[intImportStatusId] INT NOT NULL IDENTITY,
    [strImportType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnActive] BIT NOT NULL,    
    [dtmImportDate] DATETIME NOT NULL,
    [intUserId] INT NULL,
    CONSTRAINT [PK_tblCCImportStatus] PRIMARY KEY ([intImportStatusId])
)
