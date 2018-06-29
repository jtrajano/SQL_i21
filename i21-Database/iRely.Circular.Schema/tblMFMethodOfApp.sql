CREATE TABLE [dbo].[tblMFMethodOfApp]
(
	[intMethodOfAppId] INT NOT NULL IDENTITY(1,1), 
    [strName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT 0
    CONSTRAINT [PK_tblMFMethodOfApp_intMethodOfAppId] PRIMARY KEY ([intMethodOfAppId]), 
    CONSTRAINT [UQ_tblMFMethodOfApp_strName] UNIQUE ([strName]) 
)
