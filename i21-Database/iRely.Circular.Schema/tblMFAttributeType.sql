CREATE TABLE [dbo].[tblMFAttributeType]
(
	intAttributeTypeId INT
	,strAttributeTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFAttributeType_intAttributeTypeId PRIMARY KEY (intAttributeTypeId)
	,CONSTRAINT UQ_tblMFAttributeType_strAttributeTypeName UNIQUE (strAttributeTypeName)
)
