CREATE TABLE [dbo].[tblQMAttributeImport]
(
	[intImportId] INT NOT NULL IDENTITY, 
	[strAttributeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strDataTypeName] NVARCHAR(30) COLLATE Latin1_General_CI_AS, 
	[strListName] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strAttributeValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	
	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMAttributeImport_ysnProcessed] DEFAULT 0, 
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [PK_tblQMAttributeImport] PRIMARY KEY ([intImportId])
)