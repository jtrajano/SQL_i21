CREATE TABLE [dbo].[tblQMAttributeDataType]
(
	[intDataTypeId] INT NOT NULL, 
	[strDataTypeName] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT [PK_tblQMAttributeDataType] PRIMARY KEY ([intDataTypeId])
)