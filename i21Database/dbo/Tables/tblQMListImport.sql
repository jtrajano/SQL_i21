CREATE TABLE [dbo].[tblQMListImport]
(
	[intListImportId] INT NOT NULL IDENTITY, 
	[strListName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strSQL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strListItemName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnIsDefault] BIT NOT NULL CONSTRAINT [DF_tblQMListImport_ysnIsDefault] DEFAULT 0, 
	[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblQMListImport_ysnActive] DEFAULT 0, 
	
	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMListImport_ysnProcessed] DEFAULT 0, 
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [PK_tblQMListImport] PRIMARY KEY ([intListImportId])
)