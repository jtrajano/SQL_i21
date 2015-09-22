CREATE TABLE [dbo].[tblIUPatchDetail]
(
	[intPatchDetailId] INT NOT NULL IDENTITY, 
    [intVersionId] INT NOT NULL, 
    [strCommitId] NVARCHAR(11) NOT NULL, 
    [strVersion] NVARCHAR(15) NOT NULL, 
    [strChangeType] NVARCHAR(15) NULL, 
    [strFilePath] NVARCHAR(2000) NULL, 
    [strFileName] NVARCHAR(500) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblIUPatchDetail] PRIMARY KEY ([intPatchDetailId]), 
    CONSTRAINT [FK_tblIUPatchDetail_tblSMBuildNumber] FOREIGN KEY ([intVersionId]) REFERENCES [tblSMBuildNumber]([intVersionID]) 
)
