CREATE TABLE dbo.tblMFAttribute (
	intAttributeId INT Not NULL
	,strAttributeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intAttributeDataTypeId INT
	,strSQL NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,CONSTRAINT PK_tblMFAttribute_intAttributeId PRIMARY KEY (intAttributeId)
	,CONSTRAINT FK_tblMFAttribute_tblMFAttributeDataType_intAttributeDataTypeId FOREIGN KEY (intAttributeDataTypeId) REFERENCES tblMFAttributeDataType(intAttributeDataTypeId)
	)