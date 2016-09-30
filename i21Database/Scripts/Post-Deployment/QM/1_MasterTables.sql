﻿-- Attribute Datatype
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
--GO
--IF NOT EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 6)
--BEGIN
--	INSERT INTO tblQMAttributeDataType(intDataTypeId,strDataTypeName)
--	VALUES(6,'Document')
--END
--GO
GO
IF EXISTS(SELECT 1 FROM tblQMAttributeDataType WHERE intDataTypeId = 6)
BEGIN
	UPDATE tblQMAttribute Set intDataTypeId = 4 where intDataTypeId = 6
	DELETE tblQMAttributeDataType Where intDataTypeId = 6
END
GO

-- Control Point
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 1)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(1,'Offer Sample','Offer Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 2)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(2,'Approval Sample','Approval Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 3)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(3,'Inspection','Inspection')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 4)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(4,'Inventory Quality','Inventory Quality')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 5)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(5,'Inbound Sample','Inbound Sample')
END
ELSE
BEGIN -- Earlier Receipt Sample. Changing to Inbound Sample
    UPDATE tblQMControlPoint SET strControlPointName = 'Inbound Sample' WHERE intControlPointId = 5 AND strControlPointName = 'Receipt Sample'
    UPDATE tblQMControlPoint SET strDescription = 'Inbound Sample' WHERE intControlPointId = 5 AND strDescription = 'Receipt Sample'
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 6)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(6,'Production','Production')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 7)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(7,'Production Computed','Production Computed')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 8)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(8,'Shipping','Shipping')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 9)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(9,'Receipt Sample','Receipt Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 10)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(10,'Outbound Sample','Outbound Sample')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMControlPoint WHERE intControlPointId = 11)
BEGIN
	INSERT INTO tblQMControlPoint(intControlPointId,strControlPointName,strDescription)
	VALUES(11,'Line Sample','Line Sample')
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
--GO
--IF NOT EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Time')
--BEGIN
--	INSERT INTO tblQMDataType(intDataTypeId,strDataTypeName)
--	VALUES(11,'Time')
--END
--GO
GO
IF EXISTS(SELECT 1 FROM tblQMDataType WHERE strDataTypeName = 'Time')
BEGIN
	UPDATE tblQMProperty Set intDataTypeId = 12 where intDataTypeId = 11
	DELETE tblQMDataType Where strDataTypeName = 'Time'
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
GO
IF NOT EXISTS(SELECT 1 FROM tblQMSampleStatus WHERE strStatus = 'Pending')
BEGIN
	INSERT INTO tblQMSampleStatus(strStatus,strDescription,strSecondaryStatus,intSequence)
	VALUES('Pending','Pending','Pending',5)
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
	VALUES(1,'Category','Category',1)
END
ELSE
BEGIN
	UPDATE tblQMProductType SET strProductTypeName = 'Category', strDescription = 'Category' WHERE intProductTypeId = 1
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 2)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(2,'Item','Item',1)
END
ELSE
BEGIN
	UPDATE tblQMProductType SET strProductTypeName = 'Item', strDescription = 'Item' WHERE intProductTypeId = 2
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
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 10)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(10,'Shipment Line Item','Shipment Line Item',0)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 11)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(11,'Parent Lot','Parent Lot',0)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMProductType WHERE intProductTypeId = 12)
BEGIN
	INSERT INTO tblQMProductType(intProductTypeId,strProductTypeName,strDescription,ysnIsTemplate)
	VALUES(12,'Work Order','Work Order',0)
END
GO
-- Drop unwanted tables
GO
IF EXISTS(SELECT * FROM sysobjects where xtype = 'U' and name = 'tblQMDocumentFile')
BEGIN
	DROP TABLE tblQMDocumentFile
END
GO

-- Report Properties
GO
DELETE FROM tblQMReportProperty WHERE strReportName = 'Quality Label'
GO

/*
GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Density'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,1
END
GO

GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'OS Sparkle'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,2
END
GO

GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'OS Colour'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,3
END
GO

GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'OS Impact'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,4
END
GO

GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'OS Body'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,5
END
GO

GO
DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'OS Astringency'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblQMReportProperty
		WHERE strReportName = 'Quality Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Quality Label'
		,@intPropertyId
		,6
END
GO
*/

GO
IF EXISTS (
		SELECT *
		FROM tblQMCompanyPreference
		)
BEGIN
	UPDATE tblQMCompanyPreference
	SET intNumberofDecimalPlaces = 3
END
ELSE
BEGIN
	INSERT INTO tblQMCompanyPreference (intNumberofDecimalPlaces)
	SELECT 3
END
GO

GO
UPDATE tblQMCompanyPreference
SET ysnEnableParentLot = 0
WHERE ysnEnableParentLot IS NULL
GO

GO
UPDATE tblQMCompanyPreference
SET ysnIsSamplePrintEnable = 1
GO

GO
UPDATE tblQMCompanyPreference
SET intApproveLotStatus = 1
WHERE intApproveLotStatus IS NULL
GO

GO
UPDATE tblQMCompanyPreference
SET intRejectLotStatus = 2
WHERE intRejectLotStatus IS NULL
GO

GO
UPDATE tblQMCompanyPreference
SET ysnChangeLotStatusOnApproveforPreSanitizeLot = 0
WHERE ysnChangeLotStatusOnApproveforPreSanitizeLot IS NULL
GO

GO
UPDATE tblQMReportProperty SET intConcurrencyId = 1 WHERE intConcurrencyId IS NULL
GO

-- Cupping Report Property Mapping
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Volume')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Volume','Volume')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Moisture')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Moisture','Moisture')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Color')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Color','Color')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Uniformity')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Uniformity','Uniformity')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Acidity')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Acidity','Acidity')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Body')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Body','Body')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Flavor')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Flavor','Flavor')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Taints/Defects')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Taints/Defects','Taints/Defects')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Rate (1-100)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Rate (1-100)','Rate (1-100)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (16)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (16)','Screen size (16)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (15)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (15)','Screen size (15)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (14)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (14)','Screen size (14)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (13)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (13)','Screen size (13)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (12)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (12)','Screen size (12)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Screen size (PAN)')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Screen size (PAN)','Screen size (PAN)')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Overall Cup Analysis')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Overall Cup Analysis','Overall Cup Analysis')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'HUMIDITY')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('HUMIDITY','HUMIDITY')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'Bulk Density')
BEGIN
	INSERT INTO tblQMReportCuppingPropertyMapping(strPropertyName,strActualPropertyName)
	VALUES('Bulk Density','Bulk Density')
END
GO
GO
IF EXISTS(SELECT 1 FROM tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'TOTAL DEFECTS')
BEGIN
	DELETE tblQMReportCuppingPropertyMapping WHERE strPropertyName = 'TOTAL DEFECTS'
END
GO

-- Updating Location
GO
DECLARE @intLocationId INT

SELECT TOP 1 @intLocationId = intCompanyLocationId
FROM tblSMCompanyLocation
ORDER BY intCompanyLocationId ASC

UPDATE tblQMSample
SET intLocationId = @intLocationId
WHERE intLocationId IS NULL
GO

-- Updating Business Date
GO
UPDATE tblQMSample
SET dtmBusinessDate = dbo.fnGetBusinessDate(dtmCreated, intLocationId)
WHERE dtmBusinessDate IS NULL
GO

-- Updating Business Shift Id
GO
IF OBJECT_ID('fnQMGetBusinessShiftId') IS NOT NULL
BEGIN
	DROP FUNCTION fnQMGetBusinessShiftId
END
GO

GO
CREATE FUNCTION fnQMGetBusinessShiftId (
	@dtmCreated DATETIME
	,@dtmBusinessDate DATETIME
	,@intLocationId INT
	)
RETURNS INT
AS
BEGIN
	DECLARE @intShiftId INT

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	RETURN @intShiftId
END
GO

GO
UPDATE tblQMSample
SET intShiftId = dbo.fnQMGetBusinessShiftId(dtmCreated, dtmBusinessDate, intLocationId)
WHERE intShiftId IS NULL
GO

GO
IF OBJECT_ID('fnQMGetBusinessShiftId') IS NOT NULL
BEGIN
	DROP FUNCTION fnQMGetBusinessShiftId
END
GO

-- Control Point Report Names
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportNameMapping WHERE intControlPointId = 5)
BEGIN
	INSERT INTO tblQMReportNameMapping(strReportName,intControlPointId,intConcurrencyId)
	VALUES('ArrivalForm',5,1)
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblQMReportNameMapping WHERE intControlPointId = 10)
BEGIN
	INSERT INTO tblQMReportNameMapping(strReportName,intControlPointId,intConcurrencyId)
	VALUES('ArrivalForm',10,1)
END
GO
