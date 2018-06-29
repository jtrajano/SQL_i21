CREATE PROCEDURE dbo.uspMFTransferProcessMovement (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intSourceSubLocationId INT
		,@intSourceStorageLocationId INT
		,@intDestinationSubLocationId INT
		,@intDestinationStorageLocationId INT
		,@intManufacturingProcessId INT
		,@intCategoryId INT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intNewItemId INT
		,@intInputLotId INT
		,@intInputItemId INT
		,@dblWeight NUMERIC(18, 6)
		,@dblInputWeight NUMERIC(18, 6)
		,@dblReadingQuantity NUMERIC(18, 6)
		,@intInputWeightUOMId INT
		,@intUserId INT
		,@ysnEmptyOut BIT
		,@ysnNegativeQuantityAllowed BIT
		,@ysnExcessConsumptionAllowed BIT
		,@strItemNo NVARCHAR(50)
		,@strInputItemNo NVARCHAR(50)
		,@intConsumptionMethodId INT
		,@intConsumptionStorageLocationId INT
		,@dblDefaultResidueQty NUMERIC(18, 6)
		,@dblNewWeight NUMERIC(18, 6)
		,@intDestinationLotId INT
		,@strLotNumber NVARCHAR(50)
		,@strLotTracking NVARCHAR(50)
		,@intItemLocationId INT
		,@dtmCurrentDateTime DATETIME
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intInventoryAdjustmentId INT
		,@intNewItemUOMId INT
		,@dblWeightPerQty NUMERIC(18, 6)
		,@strDestinationLotNumber NVARCHAR(50)
		,@intWeightUOMId INT
		,@intTransactionCount INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strProcessName NVARCHAR(50)
		,@intManufacturingCellId INT
		,@strNewLotNumber NVARCHAR(50)
		,@ysnItemChanged BIT
		,@strInternalCode NVARCHAR(50)
		,@strSplitLotNumber NVARCHAR(50)
		,@strTransferStorageLocationForNewLot NVARCHAR(50)
		,@ysnAllowMultipleLot BIT
		,@intSplitStorageLocationId INT
		,@intSplitSubLocationId INT
		,@ysnMergeOnMove BIT
		,@ysnAllowMultipleItem BIT

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSourceSubLocationId = intSourceSubLocationId
		,@intSourceStorageLocationId = intSourceStorageLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@dtmBusinessDate = dtmBusinessDate
		,@intBusinessShiftId = intBusinessShiftId
		,@intInputLotId = intInputLotId
		,@intInputItemId = intInputItemId
		,@dblInputWeight = dblInputWeight
		,@dblReadingQuantity = dblReadingQuantity
		,@intInputWeightUOMId = intInputWeightUOMId
		,@intDestinationSubLocationId = intDestinationSubLocationId
		,@intDestinationStorageLocationId = intDestinationStorageLocationId
		,@intUserId = intUserId
		,@ysnEmptyOut = ysnEmptyOut
		,@ysnNegativeQuantityAllowed = ysnNegativeQuantityAllowed
		,@ysnExcessConsumptionAllowed = ysnExcessConsumptionAllowed
		,@dblDefaultResidueQty = dblDefaultResidueQty
		,@strTransferStorageLocationForNewLot = strTransferStorageLocationForNewLot
		,@ysnItemChanged = ysnItemChanged
		,@intNewItemId = intNewItemId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intSourceSubLocationId INT
			,intSourceStorageLocationId INT
			,intManufacturingProcessId INT
			,dtmBusinessDate DATETIME
			,intBusinessShiftId INT
			,intInputLotId INT
			,intInputItemId INT
			,dblInputWeight NUMERIC(18, 6)
			,dblReadingQuantity NUMERIC(18, 6)
			,intInputWeightUOMId INT
			,intDestinationSubLocationId INT
			,intDestinationStorageLocationId INT
			,intUserId INT
			,ysnEmptyOut BIT
			,ysnNegativeQuantityAllowed BIT
			,ysnExcessConsumptionAllowed BIT
			,dblDefaultResidueQty NUMERIC(18, 6)
			,strTransferStorageLocationForNewLot NVARCHAR(50)
			,ysnItemChanged BIT
			,intNewItemId INT
			)

	IF @intInputLotId IS NULL
		OR @intInputLotId = 0
	BEGIN
		RAISERROR (
				'Lot can not be blank.'
				,14
				,1
				)
	END

	SELECT @strLotNumber = strLotNumber
		,@intInputLotId = intLotId
		,@dblWeight = (
			CASE 
				WHEN intWeightUOMId IS NOT NULL
					THEN dblWeight
				ELSE dblQty
				END
			)
		,@intNewItemUOMId = intItemUOMId
		,@dblWeightPerQty = (
			CASE 
				WHEN dblWeightPerQty IS NULL
					OR dblWeightPerQty = 0
					THEN 1
				ELSE dblWeightPerQty
				END
			)
		,@intWeightUOMId = intWeightUOMId
	FROM tblICLot
	WHERE intLotId = @intInputLotId

	IF @intInputLotId IS NULL
		OR @intInputLotId = 0
	BEGIN
		RAISERROR (
				'Please select a valid lot'
				,14
				,1
				)
	END

	IF @dblWeight <= 0
		AND @ysnNegativeQuantityAllowed = 0
	BEGIN
		RAISERROR (
				'Lot quantity should be greater than zero.'
				,14
				,1
				)
	END

	IF @intSourceStorageLocationId = @intDestinationStorageLocationId
	BEGIN
		RAISERROR (
				'Source storage location and destination storage location cannot be same.'
				,14
				,1
				)
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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
					'The quantity to be consumed must not exceed the selected lot quantity.'
					,14
					,1
					)
		END

		SELECT @dblAdjustByQuantity = (@dblNewWeight - @dblWeight) / (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN 1
					ELSE @dblWeightPerQty
					END
				)

		EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmCurrentDateTime
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSourceSubLocationId
			,@intStorageLocationId = @intSourceStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewUnitCost = NULL
			,@intItemUOMId = @intNewItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction (
			intWorkOrderId
			,intLotId
			,dblQuantity
			,intItemUOMId
			,intItemId
			,intTransactionId
			,intTransactionTypeId
			,strTransactionType
			,dtmTransactionDate
			,intProcessId
			,intShiftId
			)
		SELECT TOP 1 WI.intWorkOrderId
			,WI.intLotId
			,@dblNewWeight - @dblWeight
			,WI.intItemUOMId
			,WI.intItemId
			,@intInventoryAdjustmentId
			,24
			,'Empty Out Adj'
			,@dtmBusinessDate
			,intManufacturingProcessId
			,@intBusinessShiftId
		FROM dbo.tblMFWorkOrderInputLot WI
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
		WHERE intLotId = @intInputLotId

		PRINT 'Call Lot Adjust routine.'
	END

	IF @ysnItemChanged = 1
	BEGIN
		SELECT @intCategoryId = intCategoryId
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intInputItemId
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSourceSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 24
			,@ysnProposed = 0
			,@strPatternString = @strNewLotNumber OUTPUT
			,@intShiftId=@intBusinessShiftId

		SELECT @ysnAllowMultipleLot = ysnAllowMultipleLot
		FROM dbo.tblICStorageLocation
		WHERE intStorageLocationId = @intSourceStorageLocationId

		IF @ysnAllowMultipleLot = 0
		BEGIN
			SELECT @intSplitStorageLocationId = intStorageLocationId
				,@intSplitSubLocationId = intSubLocationId
			FROM dbo.tblICStorageLocation
			WHERE strName = @strTransferStorageLocationForNewLot
				AND intLocationId = @intLocationId
				--SELECT @intSourceStorageLocationId = @intSplitStorageLocationId
				--SELECT @intSourceSubLocationId = @intSplitSubLocationId
		END
		ELSE
		BEGIN
			SELECT @intSplitStorageLocationId = @intSourceStorageLocationId
				,@intSplitSubLocationId = @intSourceSubLocationId
		END

		DECLARE @intSplitItemUOMId INT

		SELECT @intSplitItemUOMId = (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN @intNewItemUOMId
					ELSE @intWeightUOMId
					END
				)

		EXEC dbo.uspMFLotSplit @intLotId = @intInputLotId
			,@intSplitSubLocationId = @intSplitSubLocationId
			,@intSplitStorageLocationId = @intSplitStorageLocationId
			,@dblSplitQty = @dblNewWeight
			,@intSplitItemUOMId = @intSplitItemUOMId
			,@intUserId = @intUserId
			,@strSplitLotNumber = @strSplitLotNumber OUTPUT
			,@strNewLotNumber = @strNewLotNumber
			,@strNote = NULL
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		SELECT @strLotNumber = @strSplitLotNumber

		EXEC [dbo].[uspICInventoryAdjustment_CreatePostItemChange]
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmCurrentDateTime
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSourceSubLocationId
			,@intStorageLocationId = @intSourceStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@dblAdjustByQuantity = 0
			,@intNewItemId = @intNewItemId
			,@intNewSubLocationId = @intSourceSubLocationId
			,@intNewStorageLocationId = @intSourceStorageLocationId
			,@intItemUOMId = @intNewItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		SELECT @intInputItemId = @intNewItemId
	END

	SELECT TOP 1 @strInternalCode = strInternalCode
		,@ysnMergeOnMove = ysnMergeOnMove
		,@ysnAllowMultipleLot=ysnAllowMultipleLot
		,@ysnAllowMultipleItem=ysnAllowMultipleItem
	FROM dbo.tblICStorageLocation SL
	JOIN dbo.tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
	WHERE intStorageLocationId = @intDestinationStorageLocationId

	SELECT @strDestinationLotNumber = @strLotNumber

	IF @ysnMergeOnMove IS NULL
		SELECT @ysnMergeOnMove = 0

	IF @ysnMergeOnMove = 1
	BEGIN
		SELECT TOP 1 @strDestinationLotNumber = strLotNumber
		FROM tblICLot
		WHERE intStorageLocationId = @intDestinationStorageLocationId
			AND intItemId = @intInputItemId
		ORDER BY dtmDateCreated DESC
	END

	IF @strInternalCode = 'PROD_STAGING'
		OR EXISTS (
			SELECT *
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intStorageLocationId = @intDestinationStorageLocationId
			)
	BEGIN
		SELECT @dblAdjustByQuantity = - @dblNewWeight / (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN 1
					ELSE @dblWeightPerQty
					END
				)

		EXEC uspICInventoryAdjustment_CreatePostLotMerge
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmCurrentDateTime
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSourceSubLocationId
			,@intStorageLocationId = @intSourceStorageLocationId
			,@strLotNumber = @strDestinationLotNumber
			-- Parameters for the new values: 
			,@intNewLocationId = @intLocationId
			,@intNewSubLocationId = @intDestinationSubLocationId
			,@intNewStorageLocationId = @intDestinationStorageLocationId
			,@strNewLotNumber = @strLotNumber
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewSplitLotQuantity = NULL
			,@dblNewWeight = NULL
			,@intNewItemUOMId = NULL --New Item UOM Id should be NULL as per Feb
			,@intNewWeightUOMId = NULL
			,@dblNewUnitCost = NULL
			,@intItemUOMId = @intNewItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	END
	ELSE
	BEGIN
		IF @ysnAllowMultipleLot = 0
			AND @ysnAllowMultipleItem = 0
		BEGIN
			IF (
					(
						SELECT COUNT(intLotId)
						FROM dbo.tblICLot
						WHERE intStorageLocationId = @intDestinationStorageLocationId
							AND dblQty > 0
						) >= 1
					)
			BEGIN
				RAISERROR (
						'The destination storage location is already used by other lot.'
						,11
						,1
						)

				RETURN
			END
		END
		ELSE IF @ysnAllowMultipleLot = 0
			AND @ysnAllowMultipleItem = 1
		BEGIN
			IF (
					(
						SELECT COUNT(intLotId)
						FROM tblICLot
						WHERE intStorageLocationId = @intDestinationStorageLocationId
							AND intItemId = @intInputItemId
							AND dblQty > 0
						) >= 1
					)
			BEGIN
				RAISERROR (
						'The destination storage location is already used by other lot for same item.'
						,11
						,1
						)

				RETURN
			END
		END
		ELSE IF @ysnAllowMultipleLot = 1
			AND @ysnAllowMultipleItem = 0
		BEGIN
			IF (
					(
						SELECT COUNT(intLotId)
						FROM tblICLot
						WHERE intStorageLocationId = @intDestinationStorageLocationId
							AND intItemId <> @intInputItemId
							AND dblQty > 0
						) >= 1
					)
			BEGIN
				RAISERROR (
						'The destination storage location is already used by other item'
						,11
						,1
						)

				RETURN
			END
		END

		SELECT @dblAdjustByQuantity = @dblNewWeight / (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN 1
					ELSE @dblWeightPerQty
					END
				)

		EXEC uspICInventoryAdjustment_CreatePostLotMove
			-- Parameters for filtering:
			@intItemId = @intInputItemId
			,@dtmDate = @dtmCurrentDateTime
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSourceSubLocationId
			,@intStorageLocationId = @intSourceStorageLocationId
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@intNewLocationId = @intLocationId
			,@intNewSubLocationId = @intDestinationSubLocationId
			,@intNewStorageLocationId = @intDestinationStorageLocationId
			,@strNewLotNumber = @strLotNumber
			,@dblMoveQty = @dblAdjustByQuantity
			,@intItemUOMId = @intNewItemUOMId
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
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


