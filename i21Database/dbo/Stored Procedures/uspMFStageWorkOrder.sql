CREATE PROCEDURE [dbo].[uspMFStageWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intSubLocationId INT
		,@intManufacturingProcessId INT
		,@intMachineId INT
		,@intWorkOrderId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intItemId INT
		,@intStorageLocationId INT
		,@intInputLotId INT
		,@intInputItemId INT
		,@dblWeight NUMERIC(18, 6)
		,@dblInputWeight NUMERIC(18, 6)
		,@dblReadingQuantity NUMERIC(18, 6)
		,@intInputWeightUOMId INT
		,@intUserId INT
		,@ysnEmptyOut BIT
		,@intContainerId INT
		,@strReferenceNo NVARCHAR(50)
		,@dtmActualInputDateTime DATETIME
		,@intShiftId INT
		,@ysnNegativeQuantityAllowed BIT
		,@ysnExcessConsumptionAllowed BIT
		,@strItemNo NVARCHAR(50)
		,@strInputItemNo NVARCHAR(50)
		,@intConsumptionMethodId INT
		,@intConsumptionStorageLocationId INT
		,@dblDefaultResidueQty NUMERIC(18, 6)
		,@dblNewWeight NUMERIC(18, 6)
		,@intDestinationLotId int
		,@strLotNumber nvarchar(50)
		,@strLotTracking nvarchar(50)
		,@intItemLocationId int
		,@dtmCurrentDateTime datetime
		,@dblAdjustByQuantity numeric(18,6)
		,@intInventoryAdjustmentId int
		,@intNewItemUOMId int
		,@dblWeightPerQty numeric(18,6)
		,@strDestinationLotNumber nvarchar(50)
		,@intConsumptionSubLocationId int

	Select @dtmCurrentDateTime=GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intMachineId = intMachineId
		,@intWorkOrderId = intWorkOrderId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intInputLotId = intInputLotId
		,@intInputItemId = intInputItemId
		,@dblInputWeight = dblInputWeight
		,@dblReadingQuantity = dblReadingQuantity
		,@intInputWeightUOMId = intInputWeightUOMId
		,@intUserId = intUserId
		,@ysnEmptyOut = ysnEmptyOut
		,@intContainerId = intContainerId
		,@strReferenceNo = strReferenceNo
		,@dtmActualInputDateTime = dtmActualInputDateTime
		,@intShiftId = intShiftId
		,@ysnNegativeQuantityAllowed = ysnNegativeQuantityAllowed
		,@ysnExcessConsumptionAllowed = ysnExcessConsumptionAllowed
		,@dblDefaultResidueQty = dblDefaultResidueQty
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intSubLocationId INT
			,intManufacturingProcessId INT
			,intMachineId INT
			,intWorkOrderId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,intStorageLocationId INT
			,intInputLotId INT
			,intInputItemId INT
			,dblInputWeight NUMERIC(18, 6)
			,dblReadingQuantity NUMERIC(18, 6)
			,intInputWeightUOMId INT
			,intUserId INT
			,ysnEmptyOut BIT
			,intContainerId INT
			,strReferenceNo NVARCHAR(50)
			,dtmActualInputDateTime DATETIME
			,intShiftId INT
			,ysnNegativeQuantityAllowed BIT
			,ysnExcessConsumptionAllowed BIT
			,dblDefaultResidueQty NUMERIC(18, 6)
			)

	IF @intInputLotId IS NULL
		OR @intInputLotId = 0
	BEGIN
		RAISERROR (
				51112
				,14
				,1
				)
	END

	SELECT @strLotNumber=strLotNumber,
		@intInputLotId = intLotId
		,@dblWeight = dblWeight
		,@intNewItemUOMId=intItemUOMId
		,@dblWeightPerQty= (Case When dblWeightPerQty is null or dblWeightPerQty=0 Then 1 Else dblWeightPerQty End)
	FROM tblICLot
	WHERE intLotId = @intInputLotId

	IF @intInputLotId IS NULL
		OR @intInputLotId = 0
	BEGIN
		RAISERROR (
				51113
				,14
				,1
				)
	END

	IF @intWorkOrderId IS NULL
		OR @intWorkOrderId = 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = intWorkOrderId
		FROM dbo.tblMFWorkOrder
		WHERE intItemId = @intItemId
			AND dtmPlannedDate = @dtmPlannedDate
			AND intPlannedShiftId = @intPlannedShiftId
			AND intStatusId = 10
			AND intLocationId = @intLocationId
		ORDER BY dtmCreated

		IF @intWorkOrderId IS NULL
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			RAISERROR (
					51111
					,14
					,1
					,@strItemNo
					)
		END
	END

	IF @dblWeight <= 0
		AND @ysnNegativeQuantityAllowed = 0
	BEGIN
		RAISERROR (
				51110
				,14
				,1
				)
	END

	SELECT @intConsumptionMethodId = RI.intConsumptionMethodId
		,@intConsumptionStorageLocationId = RI.intStorageLocationId
		,@intInputItemId = RI.intItemId
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
	WHERE R.intItemId = @intItemId
		AND R.ysnActive = 1
		AND R.intLocationId = @intLocationId
		AND RI.intRecipeItemTypeId = 1
		AND RI.intItemId = @intInputItemId

	Select @intConsumptionSubLocationId=intSubLocationId 
	From dbo.tblICStorageLocation 
	Where intStorageLocationId=@intConsumptionStorageLocationId

	IF @intInputItemId IS NULL
		OR @intInputItemId = 0
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		SELECT @strInputItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		RAISERROR (
				51114
				,14
				,1
				,@strInputItemNo
				,@strItemNo
				)
	END

	IF @intConsumptionStorageLocationId IS NULL
		OR @intConsumptionStorageLocationId = 0
	BEGIN
		RAISERROR (
				51115
				,14
				,1
				)
	END

	BEGIN TRANSACTION

	INSERT INTO dbo.tblMFWorkOrderInputLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,intSequenceNo
		,intShiftId
		,intStorageLocationId
		,intMachineId
		,ysnConsumptionReversed
		,intContainerId
		,strReferenceNo
		,dtmActualInputDateTime
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT @intWorkOrderId
		,intItemId
		,intLotId
		,@dblInputWeight
		,intWeightUOMId
		,@dblInputWeight / (
			CASE 
				WHEN dblWeightPerQty = 0
					THEN 1
				ELSE dblWeightPerQty
				END
			)
		,intItemUOMId
		,1
		,@intShiftId
		,@intStorageLocationId
		,@intMachineId
		,0
		,@intContainerId
		,@strReferenceNo
		,@dtmActualInputDateTime
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
	FROM dbo.tblICLot
	WHERE intLotId = @intInputLotId

	IF @intConsumptionMethodId = 1 --By Lot consumption
	BEGIN
		PRINT 'Call Lot reservation routine.'
	END

	IF @intConsumptionMethodId = 2
	BEGIN
		SET @dblNewWeight = CASE 
				WHEN @ysnEmptyOut = 0
					THEN CASE 
							WHEN @dblInputWeight >= @dblWeight
								THEN @dblWeight + @dblDefaultResidueQty
							ELSE @dblInputWeight
							END
				ELSE @dblInputWeight
				END

		IF @dblNewWeight > @dblWeight
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						51116
						,14
						,1
						)
			END
			Select @dblAdjustByQuantity=(@dblNewWeight-@dblWeight)/@dblWeightPerQty

			EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
					-- Parameters for filtering:
					@intItemId = @intInputItemId
					,@dtmDate = @dtmCurrentDateTime
					,@intLocationId = @intLocationId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strLotNumber	
					-- Parameters for the new values: 
					,@dblAdjustByQuantity =@dblAdjustByQuantity
					,@dblNewUnitCost =NULL
					-- Parameters used for linking or FK (foreign key) relationships
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intUserId = @intUserId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

			PRINT 'Call Lot Adjust routine.'
		END

		SELECT TOP 1 @intDestinationLotId = intLotId,@strDestinationLotNumber=strLotNumber
		FROM dbo.tblICLot
		WHERE intStorageLocationId = @intConsumptionStorageLocationId
			AND intItemId = @intInputItemId
			AND intLotId <> @intInputLotId
			AND dtmExpiryDate > @dtmCurrentDateTime
			AND intLotStatusId = 1
		ORDER BY dtmDateCreated DESC

		IF @intDestinationLotId IS NULL --There is no lot in the destination location
		BEGIN
			IF @dblNewWeight = @dblWeight --It is a full qty staging.
			BEGIN
				IF @intStorageLocationId <> @intConsumptionStorageLocationId --Checking whether the lot is not in the staging location.
				BEGIN
					PRINT 'Call Lot Move routine.'

					Select @dblAdjustByQuantity = -@dblNewWeight/@dblWeightPerQty

					EXEC [uspICInventoryAdjustment_CreatePostSplitLot]
						-- Parameters for filtering:
						@intItemId = @intInputItemId
						,@dtmDate = @dtmCurrentDateTime
						,@intLocationId = @intLocationId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber
						-- Parameters for the new values: 
						,@intNewLocationId = @intLocationId
						,@intNewSubLocationId = @intConsumptionSubLocationId
						,@intNewStorageLocationId = @intConsumptionStorageLocationId
						,@strNewLotNumber = @strLotNumber
						,@dblAdjustByQuantity = @dblAdjustByQuantity
						,@dblNewSplitLotQuantity = 0
						,@dblNewWeight = @dblNewWeight
						,@intNewItemUOMId = @intNewItemUOMId
						,@intNewWeightUOMId = @intInputWeightUOMId
						,@dblNewUnitCost = NULL
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intUserId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

				END
			END
			ELSE
			BEGIN
				--*****************************************************
				--Create staging lot
				--*****************************************************
				--DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

				--CREATE TABLE #GeneratedLotItems (
				--	intLotId INT
				--	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
				--	,intDetailId INT
				--	)

				---- Create and validate the lot numbers
				--BEGIN
					--DECLARE @strLifeTimeType NVARCHAR(50)
					--	,@intLifeTime INT
					--	,@dtmExpiryDate DATETIME

					--SELECT @strLifeTimeType = strLifeTimeType
					--	,@intLifeTime = intLifeTime
					--	,@strLotTracking = strLotTracking
					--FROM dbo.tblICItem
					--WHERE intItemId = @intInputItemId

					--IF @strLifeTimeType = 'Years'
					--	SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmCurrentDateTime)
					--ELSE IF @strLifeTimeType = 'Months'
					--	SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)
					--ELSE IF @strLifeTimeType = 'Days'
					--	SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, @dtmCurrentDateTime)
					--ELSE IF @strLifeTimeType = 'Hours'
					--	SET @dtmExpiryDate = DateAdd(hh, @intLifeTime,@dtmCurrentDateTime)
					--ELSE IF @strLifeTimeType = 'Minutes'
					--	SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, @dtmCurrentDateTime)
					--ELSE
					--	SET @dtmExpiryDate = DateAdd(yy, 1, @dtmCurrentDateTime)
					
		
					--SELECT @intItemLocationId = intItemLocationId
					--FROM dbo.tblICItemLocation
					--WHERE intItemId = @intInputItemId

					--IF  @strLotTracking <> 'Yes - Serial Number'
					--BEGIN
						EXEC dbo.uspSMGetStartingNumber 55
							,@strDestinationLotNumber OUTPUT
					--END

				--	INSERT INTO @ItemsThatNeedLotId (
				--		intLotId
				--		,strLotNumber
				--		,strLotAlias
				--		,intItemId
				--		,intItemLocationId
				--		,intSubLocationId
				--		,intStorageLocationId
				--		,dblQty
				--		,intItemUOMId
				--		,dblWeight
				--		,intWeightUOMId
				--		,dtmExpiryDate
				--		,dtmManufacturedDate
				--		,intOriginId
				--		,strBOLNo
				--		,strVessel
				--		,strReceiptNumber
				--		,strMarkings
				--		,strNotes
				--		,intEntityVendorId
				--		,strVendorLotNo
				--		,intVendorLocationId
				--		,strVendorLocation
				--		,intDetailId
				--		,ysnProduced
				--		)
				--	SELECT intLotId = NULL
				--		,strLotNumber = @strDestinationLotNumber
				--		,strLotAlias = NULL
				--		,intItemId = @intInputItemId
				--		,intItemLocationId = @intItemLocationId
				--		,intSubLocationId = @intSubLocationId
				--		,intStorageLocationId = @intStorageLocationId
				--		,dblQty = 0
				--		,intItemUOMId = @intInputWeightUOMId
				--		,dblWeight = 0
				--		,intWeightUOMId = @intInputWeightUOMId
				--		,dtmExpiryDate = @dtmExpiryDate
				--		,dtmManufacturedDate = @dtmCurrentDateTime
				--		,intOriginId = NULL
				--		,strBOLNo = NULL
				--		,strVessel = NULL
				--		,strReceiptNumber = NULL
				--		,strMarkings = NULL
				--		,strNotes = NULL
				--		,intEntityVendorId = NULL
				--		,strVendorLotNo = NULL
				--		,intVendorLocationId = NULL
				--		,strVendorLocation = NULL
				--		,intDetailId = @intWorkOrderId
				--		,ysnProduced = 1

				--	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
				--		,@intUserId

				--	SELECT TOP 1 @intDestinationLotId = intLotId,
				--				@strDestinationLotNumber=strLotNumber
				--	FROM #GeneratedLotItems
				--	WHERE intDetailId = @intWorkOrderId
				--END

				--*****************************************************
				--End of create staging lot
				--*****************************************************
				PRINT '1.Call Lot Merge routine.'
				Select @dblAdjustByQuantity = -@dblNewWeight/@dblWeightPerQty
				EXEC [uspICInventoryAdjustment_CreatePostSplitLot]
					-- Parameters for filtering:
					@intItemId = @intInputItemId
					,@dtmDate = @dtmCurrentDateTime
					,@intLocationId = @intLocationId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strLotNumber
					-- Parameters for the new values: 
					,@intNewLocationId = @intLocationId
					,@intNewSubLocationId = @intConsumptionSubLocationId
					,@intNewStorageLocationId = @intConsumptionStorageLocationId
					,@strNewLotNumber = @strDestinationLotNumber
					,@dblAdjustByQuantity = @dblAdjustByQuantity
					,@dblNewSplitLotQuantity = 0
					,@dblNewWeight = @dblNewWeight
					,@intNewItemUOMId = @intNewItemUOMId
					,@intNewWeightUOMId = @intInputWeightUOMId
					,@dblNewUnitCost = NULL
					-- Parameters used for linking or FK (foreign key) relationships
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intUserId = @intUserId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

			END
		END
		ELSE
		BEGIN
			PRINT '2.Call Lot Merge routine.'
			Select @dblAdjustByQuantity = -@dblNewWeight/@dblWeightPerQty
			EXEC [uspICInventoryAdjustment_CreatePostSplitLot]
					-- Parameters for filtering:
					@intItemId = @intInputItemId
					,@dtmDate = @dtmCurrentDateTime
					,@intLocationId = @intLocationId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@strLotNumber = @strLotNumber
					-- Parameters for the new values: 
					,@intNewLocationId = @intLocationId
					,@intNewSubLocationId = @intConsumptionSubLocationId
					,@intNewStorageLocationId = @intConsumptionStorageLocationId
					,@strNewLotNumber = @strDestinationLotNumber
					,@dblAdjustByQuantity = @dblAdjustByQuantity
					,@dblNewSplitLotQuantity = 0
					,@dblNewWeight = @dblNewWeight
					,@intNewItemUOMId = @intNewItemUOMId
					,@intNewWeightUOMId = @intInputWeightUOMId
					,@dblNewUnitCost = NULL
					-- Parameters used for linking or FK (foreign key) relationships
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intUserId = @intUserId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		END
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
GO


