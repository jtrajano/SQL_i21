-- Attribute Datatype
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 1)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(1,'Integer')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 2)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(2,'Float')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 3)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(3,'Date')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 4)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(4,'Text')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 5)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(5,'List')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 6)
BEGIN
	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
	VALUES(6,'Document')
END
GO
