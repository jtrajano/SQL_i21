CREATE TABLE [dbo].[tblIUPatchHistory]
(
	[intPatchHistoryId] INT NOT NULL  IDENTITY, 
    [intVersionId] INT NOT NULL, 
    [strCommitId] NVARCHAR(11) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strVersion] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strChangeType] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL,
    [strFilePath] NVARCHAR(2000) COLLATE Latin1_General_CI_AS NULL, 
    [strFileName] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [FK_tblIUPatchHistory_tblSMBuildNumber] FOREIGN KEY ([intVersionId]) REFERENCES [tblSMBuildNumber]([intVersionID]), 
    CONSTRAINT [PK_tblIUPatchHistory] PRIMARY KEY ([intPatchHistoryId])
)
