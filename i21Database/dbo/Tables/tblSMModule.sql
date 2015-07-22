CREATE TABLE [dbo].[tblSMModule]
(
	[intModuleId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strApplicationName] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strModule] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strAppCode] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnSupported] BIT NOT NULL DEFAULT 1, 
	[intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1 
)
