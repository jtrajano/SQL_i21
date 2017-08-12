CREATE TABLE [dbo].[tblSMLetter]
(
	[intLetterId] INT NOT NULL IDENTITY, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [blbMessage] VARBINARY(MAX) NULL, 
	[strModuleName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnSystemDefined] BIT NULL DEFAULT 0,
    [intSourceLetterId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMLetter] PRIMARY KEY ([intLetterId]), 
    CONSTRAINT [UQ_tblSMLetter_strName] UNIQUE ([strName]) 
)
