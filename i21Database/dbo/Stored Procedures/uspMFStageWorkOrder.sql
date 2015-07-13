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
		,@intWeightUOMId int
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

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
		,@dblWeight = (CASE WHEN intWeightUOMId IS NOT NULL THEN dblWeight ELSE dblQty END)
		,@intNewItemUOMId=(CASE WHEN intWeightUOMId IS NOT NULL THEN intWeightUOMId ELSE intItemUOMId END) 
		,@dblWeightPerQty= (Case When dblWeightPerQty is null or dblWeightPerQty=0 Then 1 Else dblWeightPerQty End)
		,@intWeightUOMId=intWeightUOMId
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

	IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId AND W.intStatusId=13
				)
		BEGIN
			RAISERROR (
					51079
					,11
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId AND W.intStatusId=11
				)
		BEGIN
			RAISERROR (
					51080
					,11
					,1
					)
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId AND W.intStatusId=10
				)
		BEGIN
			RAISERROR (
					51081
					,11
					,1
					)
		END
	
	IF @intTransactionCount = 0
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
		,ISNULL(intWeightUOMId,intItemUOMId)
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
		IF @dblInputWeight > @dblWeight
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				RAISERROR (
						51116
						,14
						,1
						)
			END
		END
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
			Select @dblAdjustByQuantity=(@dblNewWeight-@dblWeight)/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

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

					Select @dblAdjustByQuantity = -@dblNewWeight/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

					EXEC uspICInventoryAdjustment_CreatePostLotMove
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
						,@dblMoveQty  = @dblAdjustByQuantity
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intUserId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

				END
			END
			ELSE
			BEGIN
				EXEC dbo.uspSMGetStartingNumber 55
					,@strDestinationLotNumber OUTPUT
					
				PRINT '1.Call Lot Merge routine.'

				Select @dblAdjustByQuantity = -@dblNewWeight/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

				EXEC uspICInventoryAdjustment_CreatePostLotMerge
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
					,@dblNewWeight = NULL
					,@intNewItemUOMId = @intNewItemUOMId
					,@intNewWeightUOMId = NULL
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

			Select @dblAdjustByQuantity = -@dblNewWeight/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

			EXEC uspICInventoryAdjustment_CreatePostLotMerge
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
					,@dblNewSplitLotQuantity = NULL
					,@dblNewWeight = NULL
					,@intNewItemUOMId = NULL
					,@intNewWeightUOMId = NULL
					,@dblNewUnitCost = NULL
					-- Parameters used for linking or FK (foreign key) relationships
					,@intSourceId = 1
					,@intSourceTransactionTypeId = 8
					,@intUserId = @intUserId
					,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		END
	END
	IF @intTransactionCount = 0
	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
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


