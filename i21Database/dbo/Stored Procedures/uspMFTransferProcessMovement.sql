﻿CREATE PROCEDURE dbo.uspMFTransferProcessMovement (@strXML NVARCHAR(MAX))
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
				51112
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
				51113
				,14
				,1
				)
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

	IF @intSourceStorageLocationId = @intDestinationStorageLocationId
	BEGIN
		RAISERROR (
				90010
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
					51116
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

	IF @dblWeight > @dblNewWeight
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

		SELECT @ysnAllowMultipleLot = ysnAllowMultipleLot
		FROM dbo.tblICStorageLocation
		WHERE intStorageLocationId = @intSourceStorageLocationId

		IF @ysnAllowMultipleLot = 0
		BEGIN
			SELECT @intSplitStorageLocationId = intStorageLocationId
				,@intSplitSubLocationId = intSubLocationId
			FROM dbo.tblICStorageLocation
			WHERE strName = @strTransferStorageLocationForNewLot
		END
		ELSE
		BEGIN
			SELECT @intSplitStorageLocationId = @intSourceStorageLocationId
				,@intSplitSubLocationId = @intSourceSubLocationId
		END

		EXEC dbo.uspMFLotSplit @intLotId = @intInputLotId
			,@intSplitSubLocationId = @intSplitSubLocationId
			,@intSplitStorageLocationId = @intSplitStorageLocationId
			,@dblSplitQty = @dblNewWeight
			,@intUserId = @intUserId
			,@strSplitLotNumber = @strSplitLotNumber OUTPUT
			,@strNewLotNumber = @strNewLotNumber
			,@strNote = NULL
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		SELECT @strLotNumber = @strSplitLotNumber
	END

	IF @ysnItemChanged = 1
	BEGIN
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
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		SELECT @intInputItemId = @intNewItemId
	END

	SELECT TOP 1 @strInternalCode = strInternalCode
	FROM dbo.tblICStorageLocation SL
	JOIN dbo.tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
	WHERE intStorageLocationId = @intDestinationStorageLocationId

	IF @strInternalCode = 'PROD_STAGING'
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
			,@strLotNumber = @strLotNumber
			-- Parameters for the new values: 
			,@intNewLocationId = @intLocationId
			,@intNewSubLocationId = @intDestinationSubLocationId
			,@intNewStorageLocationId = @intDestinationStorageLocationId
			,@strNewLotNumber = @strDestinationLotNumber
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewSplitLotQuantity = NULL
			,@dblNewWeight = NULL
			,@intNewItemUOMId = NULL --New Item UOM Id should be NULL as per Feb
			,@intNewWeightUOMId = NULL
			,@dblNewUnitCost = NULL
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	END
	ELSE
	BEGIN
		SELECT @dblAdjustByQuantity = - @dblNewWeight / (
				CASE 
					WHEN @intWeightUOMId IS NULL
						THEN 1
					ELSE @dblWeightPerQty
					END
				)

		--SELECT @intInputItemId,@dtmCurrentDateTime,@intLocationId,@intSourceSubLocationId,@intSourceStorageLocationId,@strLotNumber,@intDestinationSubLocationId,@intDestinationStorageLocationId,@dblAdjustByQuantity
		--Select 'Begin'
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
			-- Parameters used for linking or FK (foreign key) relationships
			,@intSourceId = 1
			,@intSourceTransactionTypeId = 8
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
			--Select 'End'
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



