CREATE PROCEDURE [dbo].[uspICDuplicateStorageLocation]
	@StorageLocationId INT,
	@NewStorageLocationId INT OUTPUT
AS
BEGIN

	----------------------------------------
	-- Generate New Storage Location Name --
	----------------------------------------
	DECLARE @StorageLocationName NVARCHAR(50),
		@NewStorageLocationName NVARCHAR(50),
		@NewStorageLocationNameWithCounter NVARCHAR(50),
		@counter INT
	SELECT @StorageLocationName = strName, @NewStorageLocationName = strName + '-copy' FROM tblICStorageLocation WHERE intStorageLocationId = @StorageLocationId
	IF EXISTS(SELECT TOP 1 1 FROM tblICStorageLocation WHERE strName = @NewStorageLocationName)
	BEGIN
		SET @counter = 1
		SET @NewStorageLocationNameWithCounter = @NewStorageLocationName + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblICStorageLocation WHERE strName = @NewStorageLocationNameWithCounter)
		BEGIN
			SET @counter += 1
			SET @NewStorageLocationNameWithCounter = @NewStorageLocationName + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @NewStorageLocationName = @NewStorageLocationNameWithCounter
	END
	-------------------------------------------------
	-- End Generation of New Storage Location Name --
	-------------------------------------------------

	--------------------------------------
	-- Duplicate Storage Location table --
	--------------------------------------
	INSERT INTO tblICStorageLocation(
		strName 
		,strDescription
		,intStorageUnitTypeId
		,intLocationId
		,intSubLocationId 
		,intParentStorageLocationId
		,ysnAllowConsume
		,ysnAllowMultipleItem
		,ysnAllowMultipleLot
		,ysnMergeOnMove
		,ysnCycleCounted
		,ysnDefaultWHStagingUnit
		,intRestrictionId
		,strUnitGroup
		,dblMinBatchSize
		,dblBatchSize
		,intBatchSizeUOMId
		,intSequence
		,ysnActive
		,intRelativeX
		,intRelativeY
		,intRelativeZ
		,intCommodityId
		,intItemId
		,dblPackFactor
		,dblEffectiveDepth
		,dblUnitPerFoot
		,dblResidualUnit
	)
	SELECT @NewStorageLocationName
		,strDescription
		,intStorageUnitTypeId
		,intLocationId
		,intSubLocationId 
		,intParentStorageLocationId
		,ysnAllowConsume
		,ysnAllowMultipleItem
		,ysnAllowMultipleLot
		,ysnMergeOnMove
		,ysnCycleCounted
		,ysnDefaultWHStagingUnit
		,intRestrictionId
		,strUnitGroup
		,dblMinBatchSize
		,dblBatchSize
		,intBatchSizeUOMId
		,intSequence
		,ysnActive
		,intRelativeX
		,intRelativeY
		,intRelativeZ
		,intCommodityId
		,intItemId
		,dblPackFactor
		,dblEffectiveDepth
		,dblUnitPerFoot
		,dblResidualUnit
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @StorageLocationId
	-----------------------------------------------
	-- End duplication of Storage Location table --
	-----------------------------------------------

	SET @NewStorageLocationId = SCOPE_IDENTITY()
	
	--------------------------------------------------
	-- Duplicate Storage Location Measurement table --
	--------------------------------------------------
	INSERT INTO tblICStorageLocationMeasurement(
		intStorageLocationId 
		,intMeasurementId
		,intReadingPointId
		,ysnActive
		,intSort
	)
	SELECT 
		@NewStorageLocationId 
		,intMeasurementId
		,intReadingPointId
		,ysnActive
		,intSort
	FROM tblICStorageLocationMeasurement
	WHERE intStorageLocationId = @StorageLocationId
	-----------------------------------------------------------
	-- End duplication of Storage Location Measurement table --
	-----------------------------------------------------------

	-----------------------------------------------
	-- Duplicate Storage Location Category table --
	-----------------------------------------------
	INSERT INTO tblICStorageLocationCategory(		
		intStorageLocationId
		,intCategoryId
		,intSort
	)
	SELECT 
		@NewStorageLocationId
		,intCategoryId
		,intSort
	FROM tblICStorageLocationCategory
	WHERE intStorageLocationId = @StorageLocationId
	--------------------------------------------------------
	-- End duplication of Storage Location Category table --
	--------------------------------------------------------

	------------------------------------------------
	-- Duplicate Storage Location Container table --
	-----------------------------------
	INSERT INTO tblICStorageLocationContainer(
		intStorageLocationId
		,intContainerId
		,intExternalSystemId
		,intContainerTypeId
		,strLastUpdatedBy
		,dtmLastUpdatedOn
		,intSort
	)
	SELECT 
		@NewStorageLocationId
		,intContainerId
		,intExternalSystemId
		,intContainerTypeId
		,strLastUpdatedBy
		,dtmLastUpdatedOn
		,intSort
	FROM tblICStorageLocationContainer
	WHERE intStorageLocationId = @StorageLocationId
	---------------------------------------------------------
	-- End duplication of Storage Location Container table --
	---------------------------------------------------------

	------------------------------------------
	-- Duplicate Storage Location Sku table --
	------------------------------------------
	INSERT INTO tblICStorageLocationSku(
		intStorageLocationId
		,intItemId
		,intSkuId
		,dblQuantity
		,intContainerId
		,intLotCodeId
		,intLotStatusId
		,intOwnerId
		,intSort
	)
	SELECT 
		@NewStorageLocationId
		,intItemId
		,intSkuId
		,dblQuantity
		,intContainerId
		,intLotCodeId
		,intLotStatusId
		,intOwnerId
		,intSort
	FROM tblICStorageLocationSku
	WHERE intStorageLocationId = @StorageLocationId
	---------------------------------------------------
	-- End duplication of Storage Location Sku table --
	---------------------------------------------------
END