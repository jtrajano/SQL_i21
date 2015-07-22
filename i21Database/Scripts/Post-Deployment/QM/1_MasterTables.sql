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

-- Analysis Type
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAnalysisType WHERE strAnalysisTypeName = 'Physical')
BEGIN
	INSERT INTO tblQMAnalysisType(intAnalysisTypeId,strAnalysisTypeName,strDescription)
	VALUES(1,'Physical','Physical')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAnalysisType WHERE strAnalysisTypeName = 'Sensorial')
BEGIN
	INSERT INTO tblQMAnalysisType(intAnalysisTypeId,strAnalysisTypeName,strDescription)
	VALUES(2,'Sensorial','Sensorial')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAnalysisType WHERE strAnalysisTypeName = 'Biological')
BEGIN
	INSERT INTO tblQMAnalysisType(intAnalysisTypeId,strAnalysisTypeName,strDescription)
	VALUES(3,'Biological','Biological')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMAnalysisType WHERE strAnalysisTypeName = 'Chemical')
BEGIN
	INSERT INTO tblQMAnalysisType(intAnalysisTypeId,strAnalysisTypeName,strDescription)
	VALUES(4,'Chemical','Chemical')
END
GO

-- Data Type
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Integer')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(1,'Integer')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Float')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(2,'Float')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Date')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(3,'Date')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Bit')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(4,'Bit')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'List')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(5,'List')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Decimal')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(6,'Decimal')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Property Computation')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(7,'Property Computation')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Test Computation')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(8,'Test Computation')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'String')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(9,'String')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'BusinessDate')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(10,'BusinessDate')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Time')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(11,'Time')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'DateTime')
BEGIN
	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
	VALUES(12,'DateTime')
END
GO

-- Sample Status
GO
IF NOT EXISTS(SELECT 1 FROM tblQMSampleStatus WHERE strStatus = 'Received')
BEGIN
	INSERT INTO tblQMSampleStatus(strStatus,strDescription,strSecondaryStatus,intSequence)
	VALUES('Received','Received','Received',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMSampleStatus WHERE strStatus = 'Sent to Lab')
BEGIN
	INSERT INTO tblQMSampleStatus(strStatus,strDescription,strSecondaryStatus,intSequence)
	VALUES('Sent to Lab','Sent to Lab','Sent to Lab',2)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMSampleStatus WHERE strStatus = 'Approved')
BEGIN
	INSERT INTO tblQMSampleStatus(strStatus,strDescription,strSecondaryStatus,intSequence)
	VALUES('Approved','Approved','Approved',3)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMSampleStatus WHERE strStatus = 'Rejected')
BEGIN
	INSERT INTO tblQMSampleStatus(strStatus,strDescription,strSecondaryStatus,intSequence)
	VALUES('Rejected','Rejected','Rejected',4)
END
GO

-- Computation Type
GO
IF NOT EXISTS(SELECT 1 FROM tblQMComputationType WHERE intComputationTypeId = 1)
BEGIN
	INSERT INTO tblQMComputationType(intComputationTypeId,strComputationTypeName)
	VALUES(1,'QUALITY')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMComputationType WHERE intComputationTypeId = 2)
BEGIN
	INSERT INTO tblQMComputationType(intComputationTypeId,strComputationTypeName)
	VALUES(2,'LOT')
END
GO

-- Product Type
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 1)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(1,'Material Type','Material Type',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 2)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(2,'Material','Material',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 3)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(3,'Receipt','Receipt',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 4)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(4,'Shipment','Shipment',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 5)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(5,'Transfer','Transfer',1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 6)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(6,'Lot','Lot',0)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 7)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(7,'Receiving','Receiving',0)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 8)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(8,'Contract Line Item','Contract Line Item',0)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 9)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(9,'Container Line Item','Container Line Item',0)
END
GO

