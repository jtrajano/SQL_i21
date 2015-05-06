CREATE TABLE [dbo].[tblQMProductType]
(
	[intProductTypeId] INT NOT NULL, 
	[strProductTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[ysnIsTemplate] BIT NOT NULL CONSTRAINT [DF_tblQMProductType_ysnIsTemplate] DEFAULT 0, 

	CONSTRAINT [PK_tblQMProductType] PRIMARY KEY ([intProductTypeId]), 
	CONSTRAINT [AK_tblQMProductType_strProductTypeName] UNIQUE ([strProductTypeName]) 
)