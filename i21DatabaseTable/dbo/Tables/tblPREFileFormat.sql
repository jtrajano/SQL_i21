CREATE TABLE [dbo].[tblPREFileFormat]
(
	[intEFileFormatId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intFormat] INT NULL, 
    [ysnDefault] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [AK_tblPREFileFormat_strName] UNIQUE ([strName])
)
