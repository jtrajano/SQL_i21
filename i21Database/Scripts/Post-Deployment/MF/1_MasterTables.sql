GO
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
		FROM dbo.tblMFWorkOrderProductionType
		WHERE intProductionTypeId=1
		)
BEGIN
	INSERT INTO dbo.tblMFWorkOrderProductionType (
		intProductionTypeId
		,strName
		)
	SELECT 1
		,'Stock'
END
GO