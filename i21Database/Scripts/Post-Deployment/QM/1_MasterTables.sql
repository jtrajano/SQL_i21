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

-- Control Point
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Offer Sample')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Offer Sample','Offer Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Approval Sample')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Approval Sample','Approval Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Inspection')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Inspection','Inspection')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Inventory Quality')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Inventory Quality','Inventory Quality')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Receipt Sample')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Receipt Sample','Receipt Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Production')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Production','Production')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Production Computed')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Production Computed','Production Computed')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE strControlPointName = 'Shipping')
BEGIN
	INSERT INTO tblQMControlPoint(strControlPointName,strDescription)
	VALUES('Shipping','Shipping')
END
GO
