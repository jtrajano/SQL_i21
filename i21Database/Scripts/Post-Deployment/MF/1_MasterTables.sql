IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 1)
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

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 1
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 1
		,'Process Run Duration'
		,5
		,'Select strManufacturingProcessRunDurationName as ValueMember,strManufacturingProcessRunDurationName as DisplayMember from tblMFManufacturingProcessRunDuration'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 2
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 2
		,'Container Type'
		,5
		,'Select strDisplayMember as ValueMember,strDisplayMember as DisplayMember from tblICContainerType'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 3
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 3
		,'Is Container Mandatory'
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 4
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 4
		,'Is LotAlias Mandatory'
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 5
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 5
		,'Is Reading Entry Mandatory'
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 6
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 6
		,'Produce Lot Status'
		,5
		,'Select strSecondaryStatus as ValueMember,strSecondaryStatus as DisplayMember from tblICLotStatus'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 7
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 7
		,'Is Cycle Count Mandatory'
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 8
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 8
		,'Are Output Items Cycle Counted'
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 9
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,strSQL
		)
	SELECT 9
		,'Item Types Excluded From Cycle Count'
		,5
		,'Select ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember'
END
GO