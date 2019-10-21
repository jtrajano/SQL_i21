CREATE TABLE [dbo].[tblSMInterDatabaseControl]
(
	[intControlId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intScreenId] INT NOT NULL, 
    [strControlId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strContainer] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)