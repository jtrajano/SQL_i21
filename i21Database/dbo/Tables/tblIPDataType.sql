CREATE TABLE [dbo].[tblIPDataType]
(
	[intDataTypeId] INT NOT NULL,
	[intServerTypeId] INT NOT NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPDataType_intDataTypeId] PRIMARY KEY ([intDataTypeId]), 
    CONSTRAINT [UQ_tblIPDataType_strName] UNIQUE ([intServerTypeId],[strName]) 
)
