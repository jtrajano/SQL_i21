CREATE TABLE [dbo].[tblQMDataType]
(
	[intDataTypeId] INT NOT NULL, 
	[strDataTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT [PK_tblQMDataType] PRIMARY KEY ([intDataTypeId])
)