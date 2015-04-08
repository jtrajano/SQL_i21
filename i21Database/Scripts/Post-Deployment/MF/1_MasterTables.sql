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
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFReleaseStatus
		WHERE strReleaseStatus = 'Release'
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
		WHERE strReleaseStatus = 'Hold'
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
		WHERE strStationTypeName = 'Sub Location'
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
		WHERE strStationTypeName = 'Parent Storage Location'
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
		WHERE strStationTypeName = 'Storage Location'
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
		WHERE strFloorMovementTypeName = 'Storage Location'
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
		WHERE strFloorMovementTypeName = 'Machine'
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
		FROM dbo.tblICLotStatus
		WHERE strSecondaryStatus = 'Active' and strPrimaryStatus='Active'
		)
BEGIN
	INSERT INTO dbo.tblICLotStatus (
		strSecondaryStatus
		,strDescription
		,strPrimaryStatus
		,intSort
		,intConcurrencyId
		)
	SELECT 'Active'
		,'Active'
		,'Active'
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFWorkOrderProductionType
		WHERE strName = 'Stock'
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
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFShift
		WHERE strShiftName = 'Shift1'
		)
BEGIN
	INSERT INTO dbo.tblMFShift (
		strShiftName
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intStartOffset
		,intEndOffset
		,intShiftSequence
		,intLocationId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	VALUES (
		'Shift1'
		,'1900-01-01 06:00:00.000'
		,'1900-01-01 13:59:59.999'
		,28800
		,0
		,0
		,1
		,1
		,1
		,Getdate()
		,1
		,GetDate()
		,1
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFShift
		WHERE strShiftName = 'Shift2'
		)
BEGIN
	INSERT INTO dbo.tblMFShift (
		strShiftName
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intStartOffset
		,intEndOffset
		,intShiftSequence
		,intLocationId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	VALUES (
		'Shift2'
		,'1900-01-01 14:00:00.000'
		,'1900-01-01 21:59:59.999'
		,28800
		,0
		,0
		,2
		,1
		,1
		,Getdate()
		,1
		,GetDate()
		,1
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFShift
		WHERE strShiftName = 'Shift3'
		)
BEGIN
	INSERT INTO dbo.tblMFShift (
		strShiftName
		,dtmShiftStartTime
		,dtmShiftEndTime
		,intDuration
		,intStartOffset
		,intEndOffset
		,intShiftSequence
		,intLocationId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	VALUES (
		'Shift3'
		,'1900-01-01 22:00:00.000'
		,'1900-01-01 05:59:59.999'
		,28800
		,0
		,0
		,3
		,1
		,1
		,Getdate()
		,1
		,GetDate()
		,1
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'NO CONTAINER'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'NONE'
		,'NO CONTAINER'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,0
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'BAGS'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'BAGS'
		,'BAGS'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,0
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,2
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'BOXES'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'BOXES'
		,'BOXES'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,150
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,3
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'TOTES'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'TOTES'
		,'TOTES'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,500
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,4
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'RAILCAR'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'RAILCAR'
		,'RAILCAR'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,0
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,4
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainerType
		WHERE strDisplayMember = 'AUDIT CONTAINER'
		)
BEGIN
	INSERT INTO dbo.tblICContainerType (
		intExternalSystemId
		,strInternalCode
		,strDisplayMember
		,intDimensionUnitMeasureId
		,dblHeight
		,dblWidth
		,dblDepth
		,intWeightUnitMeasureId
		,dblMaxWeight
		,ysnLocked
		,ysnDefault
		,dblPalletWeight
		,strLastUpdateBy
		,dtmLastUpdateOn
		,strContainerDescription
		,ysnReusable
		,ysnAllowMultipleItems
		,ysnAllowMultipleLots
		,ysnMergeOnMove
		,intTareUnitMeasureId
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'AUDIT CONTAINER'
		,'AUDIT CONTAINER'
		,1
		,48
		,48
		,44
		,1
		,2000
		,1
		,0
		,0
		,'dbo'
		,Getdate()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,4
		,0
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainer
		WHERE strContainerId = 'BAG'
		)
	AND EXISTS (
		SELECT TOP 1 intStorageLocationId
		FROM dbo.tblICStorageLocation
		)
BEGIN
	INSERT INTO dbo.tblICContainer (
		intExternalSystemId
		,strContainerId
		,intContainerTypeId
		,intStorageLocationId
		,strLastUpdateBy
		,dtmLastUpdateOn
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'BAG'
		,(
			SELECT intContainerTypeId
			FROM dbo.tblICContainerType
			WHERE strDisplayMember = 'BAGS'
			)
		,(
			SELECT TOP 1 intStorageLocationId
			FROM dbo.tblICStorageLocation
			)
		,'dbo'
		,GetDate()
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainer
		WHERE strContainerId = 'BOX'
		)
	AND EXISTS (
		SELECT TOP 1 intStorageLocationId
		FROM dbo.tblICStorageLocation
		)
BEGIN
	INSERT INTO dbo.tblICContainer (
		intExternalSystemId
		,strContainerId
		,intContainerTypeId
		,intStorageLocationId
		,strLastUpdateBy
		,dtmLastUpdateOn
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'BOX'
		,(
			SELECT intContainerTypeId
			FROM dbo.tblICContainerType
			WHERE strDisplayMember = 'BOXS'
			)
		,(
			SELECT TOP 1 intStorageLocationId
			FROM dbo.tblICStorageLocation
			)
		,'dbo'
		,GetDate()
		,2
		,0
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainer
		WHERE strContainerId = 'RAILCAR'
		)
	AND EXISTS (
		SELECT TOP 1 intStorageLocationId
		FROM dbo.tblICStorageLocation
		)
BEGIN
	INSERT INTO dbo.tblICContainer (
		intExternalSystemId
		,strContainerId
		,intContainerTypeId
		,intStorageLocationId
		,strLastUpdateBy
		,dtmLastUpdateOn
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'RAILCAR'
		,(
			SELECT intContainerTypeId
			FROM dbo.tblICContainerType
			WHERE strDisplayMember = 'RAILCAR'
			)
		,(
			SELECT TOP 1 intStorageLocationId
			FROM dbo.tblICStorageLocation
			)
		,'dbo'
		,GetDate()
		,3
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICContainer
		WHERE strContainerId = 'AUDIT CONTAINER'
		)
	AND EXISTS (
		SELECT TOP 1 intStorageLocationId
		FROM dbo.tblICStorageLocation
		)
BEGIN
	INSERT INTO dbo.tblICContainer (
		intExternalSystemId
		,strContainerId
		,intContainerTypeId
		,intStorageLocationId
		,strLastUpdateBy
		,dtmLastUpdateOn
		,intSort
		,intConcurrencyId
		)
	SELECT NULL
		,'AUDIT CONTAINER'
		,(
			SELECT intContainerTypeId
			FROM dbo.tblICContainerType
			WHERE strDisplayMember = 'AUDIT CONTAINER'
			)
		,(
			SELECT TOP 1 intStorageLocationId
			FROM dbo.tblICStorageLocation
			)
		,'dbo'
		,GetDate()
		,4
		,0
END