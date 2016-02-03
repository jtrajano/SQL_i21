﻿CREATE PROCEDURE uspMFWarehouseReleaseLot (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @intLotId INT
		,@strLotNumber NVARCHAR(50)
		,@strGTINCaseBarCode NVARCHAR(50)
		,@dblQty NUMERIC(18, 6)
		,@intLocationId INT
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@intLotStatusId INT
		,@strSecondaryStatus NVARCHAR(50)
		,@strPrimaryStatus NVARCHAR(50)
		,@CasesPerPallet INT
		,@dblProduceQty NUMERIC(18, 6)
		,@dblReleaseQty NUMERIC(18, 6)
		,@intProduceUnitMeasureId INT
		,@CurrentDate DATETIME
		,@intShiftId INT
		,@strComment NVARCHAR(MAX)
		,@intManufacturingProcessId INT
		,@intUserId INT
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@dtmCurrentDate DATETIME
		,@strGTIN NVARCHAR(50)
		,@dtmDateCreated DATETIME
		,@intItemUOMId INT
		,@intLayerPerPallet INT
		,@intUnitPerLayer INT
		,@intBatchId INT
		,@strUserName NVARCHAR(50)
		,@intOwnerId INT
		,@intUnitMeasureId INT
		,@intSKUId INT
		,@intStagingLocationId INT
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)
		,@intInventoryAdjustmentId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intAttributeIdByBatch INT
		,@strAttributeValueByBatch NVARCHAR(50)
		,@intCategoryId int

	SELECT @dtmCurrentDate = GETDATE()



	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLotId = intLotId
		,@strGTINCaseBarCode = strGTINCaseBarCode
		,@dblReleaseQty = dblReleaseQty
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intUserId = intUserId
		,@strComment = strComment
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLotId INT
			,strGTINCaseBarCode NVARCHAR(50)
			,dblReleaseQty NUMERIC(18, 6)
			,intManufacturingProcessId INT
			,intUserId INT
			,strComment NVARCHAR(MAX)
			)

	IF @intLotId = 0
		OR @intLotId IS NULL
	BEGIN
		RAISERROR (
				80020
				,11
				,1
				)

		RETURN
	END

	IF @strGTINCaseBarCode = ''
		OR @strGTINCaseBarCode IS NULL
	BEGIN
		RAISERROR (
				51058
				,11
				,1
				)

		RETURN
	END

	SELECT @intLotId = intLotId
		,@strLotNumber = strLotNumber
		,@intLocationId = intLocationId
		,@intItemId = intItemId
		,@dblQty = dblQty
		,@intLotStatusId = intLotStatusId
		,@dtmDateCreated = dtmDateCreated
		,@intItemUOMId = intItemUOMId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	SELECT @intAttributeIdByBatch = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Warehouse Release Lot By Batch'

	SELECT @strAttributeValueByBatch = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeIdByBatch

	IF @strAttributeValueByBatch = 'True'
	BEGIN
		SELECT @dblReleaseQty=dblQty FROM dbo.tblICLot WHERE intLotId=@intLotId
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				51054
				,11
				,1
				,@strLotNumber
				)
	END

	IF @dblQty = 0
		OR EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderProducedLot
			WHERE ysnReleased = 1
				AND intLotId = @intLotId
			)
	BEGIN
		RAISERROR (
				51055
				,11
				,1
				)

		RETURN
	END

	SELECT @strSecondaryStatus = strSecondaryStatus
		,@strPrimaryStatus = strPrimaryStatus
	FROM dbo.tblICLotStatus
	WHERE intLotStatusId = @intLotStatusId

	IF @intLotStatusId = 2
	BEGIN
		RAISERROR (
				51056
				,11
				,1
				)
	END

	IF @intLotStatusId = 1
		OR (
			@strSecondaryStatus = 'In_Warehouse'
			AND @strPrimaryStatus = 'On_Hold'
			)
		--OR (
		--	@strSecondaryStatus = 'ACTIVE'
		--	AND @strPrimaryStatus = 'ACTIVE'
		--	)
	BEGIN
		RAISERROR (
				51055
				,11
				,1
				)
	END

	SELECT @CasesPerPallet = intLayerPerPallet * intUnitPerLayer
		,@strItemNo = strItemNo
		,@strGTIN = strGTIN
		,@intLayerPerPallet = intLayerPerPallet
		,@intUnitPerLayer = intUnitPerLayer
		,@intCategoryId=intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @CasesPerPallet > 0
		AND @dblReleaseQty > @CasesPerPallet
	BEGIN
		RAISERROR (
				51059
				,11
				,1
				)

		RETURN
	END

	IF @strGTINCaseBarCode NOT IN (
			@strItemNo
			,@strGTIN
			)
	BEGIN
		RAISERROR (
				51060
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderRecipe R
			JOIN dbo.tblICLot L ON L.intItemId = R.intItemId
				AND R.intLocationId = @intLocationId
				AND R.intManufacturingProcessId = @intManufacturingProcessId
			)
	BEGIN
		RAISERROR (
				51057
				,11
				,1
				)
	END

	SELECT @CurrentDate = Convert(CHAR, @dtmCurrentDate, 108)

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @CurrentDate BETWEEN dtmShiftStartTime
			AND dtmShiftEndTime + intEndOffset

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Create SKU/Container on Warehouse Release'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	BEGIN TRANSACTION

	IF @dblQty <> @dblReleaseQty
	BEGIN
		SELECT @dblAdjustByQuantity = @dblReleaseQty - @dblQty

		EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
			-- Parameters for filtering:
			@intItemId = @intItemId
			,@dtmDate = @dtmCurrentDate
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewUnitCost = NULL
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		PRINT 'Call Lot Adjust routine.'
	END

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET dblReleaseQty = @dblReleaseQty
		,ysnReleased = 1
		,intReleasedUserId = @intUserId
		,dtmReleasedDate = @dtmCurrentDate
		,intReleasedShiftId = @intShiftId
		,strComment = @strComment
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intLotId = @intLotId

	--UPDATE tblICLot
	--SET intLotStatusId = 1
	--WHERE intLotId = @intLotId
	EXEC uspMFSetLotStatus @intLotId = @intLotId
		,@intNewLotStatusId = 1
		,@intUserId = @intUserId
		,@strNotes = ''

	IF @strAttributeValue = 'True'
	BEGIN
		SELECT @intStagingLocationId = intLocationId
		FROM tblICStorageLocation
		WHERE ysnDefaultWHStagingUnit = 1
			AND intLocationId = @intLocationId

		IF @intStagingLocationId IS NULL
		BEGIN
			RAISERROR (
					90007
					,11
					,1
					)
		END

		SELECT @strUserName = strUserName
		FROM dbo.tblSMUserSecurity
		WHERE intEntityUserSecurityId = @intUserId

		SELECT @intOwnerId = IO.intOwnerId
		FROM dbo.tblICItemOwner IO
		WHERE intItemId = @intItemId

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM dbo.tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		--EXEC dbo.uspSMGetStartingNumber 33
		--	,@intBatchId OUTPUT

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
					,@intItemId = @intItemId
					,@intManufacturingId = NULL
					,@intSubLocationId = @intSubLocationId
					,@intLocationId = @intLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 33
					,@ysnProposed = 0
					,@strPatternString = @intBatchId OUTPUT

		EXEC dbo.uspWHCreateSKUByLot @strUserName = @strUserName
			,@intCompanyLocationSubLocationId = @intLocationId
			,@intDefaultStagingLocationId = @intStagingLocationId
			,@intItemId = @intItemId
			,@dblQty = @dblReleaseQty
			,@intLotId = @intLotId
			,@dtmProductionDate = @dtmDateCreated
			,@intOwnerAddressId = @intOwnerId
			,@ysnStatus = 0
			,@strPalletLotCode = @strLotNumber
			,@ysnUseContainerPattern = 1
			,@intUOMId = @intUnitMeasureId
			,@intUnitPerLayer = @intUnitPerLayer
			,@intLayersPerPallet = @intLayerPerPallet
			,@ysnForced = 1
			,@ysnSanitized = 0
			,@strBatchNo = @intBatchId
			,@intSKUId = @intSKUId OUTPUT
	END

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
