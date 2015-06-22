﻿IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 1)
BEGIN
    INSERT INTO tblMFRecipeItemType(intRecipeItemTypeId,strName)
    VALUES(1,'INPUT')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 2)
BEGIN
    INSERT INTO tblMFRecipeItemType(intRecipeItemTypeId,strName)
    VALUES(2,'OUTPUT')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 1)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(1,'By Lot')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 2)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(2,'By Location')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 3)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(3,'FIFO')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 4)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(4,'None')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostDistributionMethod WHERE intCostDistributionMethodId = 1)
BEGIN
    INSERT INTO tblMFCostDistributionMethod(intCostDistributionMethodId,strName)
    VALUES(1,'By Quantity')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostDistributionMethod WHERE intCostDistributionMethodId = 2)
BEGIN
    INSERT INTO tblMFCostDistributionMethod(intCostDistributionMethodId,strName)
    VALUES(2,'By Percentage')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendRequirementStatus WHERE intStatusId = 1)
BEGIN
    INSERT INTO tblMFBlendRequirementStatus(intStatusId,strName)
    VALUES(1,'New')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendRequirementStatus WHERE intStatusId = 2)
BEGIN
    INSERT INTO tblMFBlendRequirementStatus(intStatusId,strName)
    VALUES(2,'Closed')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderProductionType WHERE intProductionTypeId = 1)
BEGIN
    INSERT INTO tblMFWorkOrderProductionType(intProductionTypeId,strName)
    VALUES(1,'Make To Order')
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderProductionType
	SET strName = 'Make To Order'
	WHERE intProductionTypeId = 1
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderProductionType WHERE intProductionTypeId = 2)
BEGIN
    INSERT INTO tblMFWorkOrderProductionType(intProductionTypeId,strName)
    VALUES(2,'Stock')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 1)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(1,'New')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 2)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(2,'Not Released')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 3)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(3,'Open')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 4)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(4,'Frozen')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 5)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(5,'Hold')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 6)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(6,'Pre Kitted')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 7)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(7,'Kitted')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 8)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(8,'Kit Transferred')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 9)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(9,'Released')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 10)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(10,'Started')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 11)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(11,'Paused')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 12)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(12,'Staged')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 13)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(13,'Completed')
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFReleaseStatus
		WHERE intReleaseStatusId=1
		)
BEGIN
	INSERT INTO dbo.tblMFReleaseStatus (
		intReleaseStatusId
		,strReleaseStatus
		)
	SELECT 1
		,'Release'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFReleaseStatus
		WHERE intReleaseStatusId=2
		)
BEGIN
	INSERT INTO dbo.tblMFReleaseStatus (
		intReleaseStatusId
		,strReleaseStatus
		)
	SELECT 2
		,'Hold'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE intStationTypeId=1
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 1
		,'Sub Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE intStationTypeId=2
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 2
		,'Parent Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE  intStationTypeId=3
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 3
		,'Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFFloorMovementType
		WHERE intFloorMovementTypeId=1
		)
BEGIN
	INSERT INTO dbo.tblMFFloorMovementType (
		intFloorMovementTypeId
		,strFloorMovementTypeName
		)
	SELECT 1
		,'Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFFloorMovementType
		WHERE intFloorMovementTypeId=2
		)
BEGIN
	INSERT INTO dbo.tblMFFloorMovementType (
		intFloorMovementTypeId
		,strFloorMovementTypeName
		)
	SELECT 2
		,'Machine'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 1
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 1
		,'Bit'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 2
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 2
		,'Integer'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 3
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 3
		,'Decimal'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 4
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 4
		,'DateTime'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 5
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 5
		,'List'
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 6
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 6
		,'String'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 1
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 1
		,'Open'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 2
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 2
		,'By Shift'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 3
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 3
		,'By Day'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 4
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 4
		,'By Week'
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 1)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(1,'Pick Order',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 2)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(2,'Is Cost Applicable?',2)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 3)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(3,'Is Quality Data Applicable?',3)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='FIFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'FIFO','FIFO',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='FEFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'FEFO','FEFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='LIFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'LIFO','LIFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='LEFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'LEFO','LEFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 2 AND strValue='Yes')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(2,'Yes','Yes',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 2 AND strValue='No')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(2,'No','No',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 3 AND strValue='Yes')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(3,'Yes','Yes',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 3 AND strValue='No')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(3,'No','No',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 1)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(1,'Common')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 2)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(2,'Blending')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 3)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(3,'Packaging')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 4)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(4,'Others')
END
GO