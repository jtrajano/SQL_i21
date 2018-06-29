CREATE TABLE dbo.tblMFAttributeDataType (
	intAttributeDataTypeId INT
	,strAttributeDataTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFAttributeDataType_intAttributeDataTypeId PRIMARY KEY (intAttributeDataTypeId)
	,CONSTRAINT UQ_tblMFAttributeDataType_strAttributeDataTypeName UNIQUE (strAttributeDataTypeName)
	)
