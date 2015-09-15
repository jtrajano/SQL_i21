CREATE TABLE [dbo].[tblIUPatchHistory]
(
	[intPatchHistoryId] INT NOT NULL PRIMARY KEY, 
    [intVersionId] INT NOT NULL, 
    [strCommitId] NVARCHAR(11) NOT NULL, 
	[strVersion] NVARCHAR(15) NOT NULL, 
	[strUpdateType] NVARCHAR(15) NOT NULL,
	[strChangeType] NVARCHAR(15) NULL,
    [strFilePath] NVARCHAR(2000) NULL, 
    [strFileName] NVARCHAR(500) NULL, 
    CONSTRAINT [FK_tblIUPatchHistory_tblSMBuildNumber] FOREIGN KEY ([intVersionId]) REFERENCES [tblSMBuildNumber]([intVersionID])
)
