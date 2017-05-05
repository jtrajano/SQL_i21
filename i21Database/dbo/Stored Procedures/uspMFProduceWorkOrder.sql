CREATE PROCEDURE [dbo].[uspMFProduceWorkOrder] (
	@intWorkOrderId INT
	,@intItemId INT = NULL
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@strVesselNo NVARCHAR(50)
	,@intUserId INT
	,@intStorageLocationId INT
	,@strBatchId NVARCHAR(40) = NULL
	,@strLotNumber NVARCHAR(50)
	,@intContainerId INT
	,@dblTareWeight NUMERIC(38, 20) = NULL
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblPhysicalCount NUMERIC(38, 20) = NULL
	,@intPhysicalItemUOMId INT = NULL
	,@intBatchId INT
	,@intShiftId INT = NULL
	,@strReferenceNo NVARCHAR(50) = NULL
	,@intStatusId INT = NULL
	,@intLotId INT OUTPUT
	,@ysnPostProduction BIT = 0
	,@strLotAlias NVARCHAR(50)
	,@intLocationId INT = NULL
	,@intMachineId INT = NULL
	,@dtmProductionDate DATETIME = NULL
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strComment NVARCHAR(MAX) = NULL
	,@strParentLotNumber NVARCHAR(50) = NULL
	,@intInputLotId INT = NULL
	,@intInputStorageLocationId INT = NULL
	,@ysnFillPartialPallet BIT = 0
	,@intSpecialPalletLotId INT = NULL
	)
AS
BEGIN
	DECLARE @dtmCreated DATETIME
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intWorkOrderProducedLotId INT
		,@intItemOwnerId INT
		,@intOwnerId INT
		,@intCategoryId INT
		,@intItemTypeId INT
		,@intProductId INT
		,@intParentLotId1 INT
		,@strParentLotNumber1 NVARCHAR(50)
		,@strParentLotNumber2 NVARCHAR(50)
		,@intSpecialPalletItemId INT
		,@intSpecialPalletCategoryId INT

	SELECT @dtmCreated = Getdate()

	IF @intStatusId = 0
		OR @intStatusId IS NULL
		SELECT @intStatusId = 13 --Complete Work Order

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND intWeightUOMId IS NULL
			)
	BEGIN
		UPDATE dbo.tblICLot
		SET dblWeight = dblQty
			,intWeightUOMId = intItemUOMId
			,dblWeightPerQty = 1
		WHERE intLotId = @intLotId
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intShiftId = 0
		SELECT @intShiftId = NULL

	SELECT @intProductId = intItemId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intItemTypeId = (
			CASE 
				WHEN RI.ysnConsumptionRequired = 0
					OR RI.ysnConsumptionRequired IS NULL
					THEN 5
				WHEN @intProductId = @intItemId
					THEN 2
				ELSE 4
				END
			)
	FROM dbo.tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = @intItemId

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,dblTareWeight
		,strVesselNo
		,intContainerId
		,intStorageLocationId
		,dtmBusinessDate
		,intBusinessShiftId
		,dtmProductionDate
		,intShiftId
		,strReferenceNo
		,intBatchId
		,intMachineId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,strComment
		,strParentLotNumber
		,intInputLotId
		,intInputStorageLocationId
		,ysnFillPartialPallet
		,intSpecialPalletLotId
		,intItemTypeId
		)
	SELECT @intWorkOrderId
		,@intItemId
		,@intLotId
		,@dblProduceQty
		,@intProduceUOMKey
		,(
			CASE 
				WHEN @dblUnitQty IS NOT NULL
					THEN @dblUnitQty
				ELSE @dblProduceQty / @dblPhysicalCount
				END
			)
		,@dblPhysicalCount
		,@intPhysicalItemUOMId
		,@dblTareWeight
		,@strVesselNo
		,(
			CASE 
				WHEN @intContainerId = 0
					THEN NULL
				ELSE @intContainerId
				END
			)
		,@intStorageLocationId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@dtmProductionDate
		,@intShiftId
		,@strReferenceNo
		,@intBatchId
		,@intMachineId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId
		,@strComment
		,@strParentLotNumber
		,@intInputLotId
		,@intInputStorageLocationId
		,@ysnFillPartialPallet
		,@intSpecialPalletLotId
		,@intItemTypeId

	SELECT @intWorkOrderProducedLotId = SCOPE_IDENTITY()

	UPDATE tblMFWorkOrder
	SET dblProducedQuantity = isnull(dblProducedQuantity, 0) + (
			CASE 
				WHEN intItemId = @intItemId
					THEN (
							CASE 
								WHEN intItemUOMId = @intProduceUOMKey
									THEN @dblProduceQty
								ELSE @dblPhysicalCount
								END
							)
				ELSE 0
				END
			)
		,dtmActualProductionEndDate = @dtmCreated
		,dtmCompletedDate = @dtmCreated
		,intStatusId = @intStatusId
		,intStorageLocationId = @intStorageLocationId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrder
	SET dtmLastProducedDate = @dtmCreated
	WHERE intItemId = @intItemId

	IF NOT EXISTS (
			SELECT *
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intItemId
				AND intItemTypeId IN (
					2
					,4
					,5
					)
			)
	BEGIN
		SELECT @intCategoryId = intCategoryId
		FROM tblICItem
		WHERE intItemId = @intItemId

		INSERT INTO tblMFProductionSummary (
			intWorkOrderId
			,intItemId
			,dblOpeningQuantity
			,dblOpeningOutputQuantity
			,dblOpeningConversionQuantity
			,dblInputQuantity
			,dblConsumedQuantity
			,dblOutputQuantity
			,dblOutputConversionQuantity
			,dblCountQuantity
			,dblCountOutputQuantity
			,dblCountConversionQuantity
			,dblCalculatedQuantity
			,intCategoryId
			,intItemTypeId
			)
		SELECT @intWorkOrderId
			,@intItemId
			,0
			,0
			,0
			,0
			,0
			,@dblProduceQty
			,0
			,0
			,0
			,0
			,0
			,@intCategoryId
			,@intItemTypeId
	END
	ELSE
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblOutputQuantity = dblOutputQuantity + @dblProduceQty
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intItemId
			AND intItemTypeId IN (
				2
				,4
				,5
				)
	END

	DECLARE @intAttributeTypeId INT
		,@intManufacturingProcessId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeTypeId = intAttributeTypeId
	FROM dbo.tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	IF @intAttributeTypeId = 2
		OR @ysnPostProduction = 1
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblICLot
				WHERE strLotNumber = @strLotNumber
				)
		BEGIN
			SELECT @intParentLotId1 = intParentLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber

			SELECT @strParentLotNumber1 = strParentLotNumber
			FROM tblICParentLot
			WHERE intParentLotId = @intParentLotId1

			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = NULL
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 78
				,@ysnProposed = 0
				,@strPatternString = @strParentLotNumber2 OUTPUT
				,@intShiftId = @intShiftId
				,@dtmDate = @dtmProductionDate

			IF  Not (@strParentLotNumber1 Like '%'+@strParentLotNumber2+'%')
			BEGIN
				SELECT @strParentLotNumber = @strParentLotNumber1 + ' / ' + @strParentLotNumber2
			END
		END

		EXEC uspMFPostProduction 1
			,0
			,@intWorkOrderId
			,@intItemId
			,@intUserId
			,NULL
			,@intStorageLocationId
			,@dblProduceQty
			,@intProduceUOMKey
			,@dblUnitQty
			,@dblPhysicalCount
			,@intPhysicalItemUOMId
			,@strBatchId
			,@strLotNumber
			,@intBatchId
			,@intLotId OUT
			,@strLotAlias
			,@strVendorLotNo
			,@strParentLotNumber
			,@strVesselNo
			,@dtmProductionDate
			,@intWorkOrderProducedLotId
			,NULL
			,@intShiftId
	END
	ELSE
	BEGIN
		EXEC uspMFPostConsumptionProduction @intWorkOrderId = @intWorkOrderId
			,@intItemId = @intItemId
			,@strLotNumber = @strLotNumber
			,@dblWeight = @dblProduceQty
			,@intWeightUOMId = @intProduceUOMKey
			,@dblUnitQty = @dblUnitQty
			,@dblQty = @dblPhysicalCount
			,@intItemUOMId = @intPhysicalItemUOMId
			,@intUserId = @intUserId
			,@intBatchId = @intBatchId
			,@intLotId = @intLotId OUT
			,@strLotAlias = @strLotAlias
			,@strVendorLotNo = @strVendorLotNo
			,@strParentLotNumber = @strParentLotNumber
			,@intStorageLocationId = @intStorageLocationId
			,@dtmProductionDate = @dtmProductionDate
			,@intTransactionDetailId = @intWorkOrderProducedLotId
	END

	IF @strParentLotNumber IS NULL
		OR @strParentLotNumber = ''
	BEGIN
		DECLARE @intParentLotId INT

		SELECT @intParentLotId = intParentLotId
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT @strParentLotNumber = strParentLotNumber
		FROM tblICParentLot
		WHERE intParentLotId = @intParentLotId
	END

	SELECT @intItemOwnerId = intItemOwnerId
		,@intOwnerId = intOwnerId
	FROM tblICItemOwner
	WHERE intItemId = @intItemId
		AND ysnDefault = 1

	IF @intItemOwnerId IS NOT NULL
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM tblMFLotInventory
				WHERE intLotId = @intLotId
				)
		BEGIN
			INSERT INTO tblMFLotInventory (
				intConcurrencyId
				,intLotId
				,intItemOwnerId
				)
			SELECT 1
				,@intLotId
				,@intItemOwnerId

			INSERT INTO tblMFItemOwnerDetail (
				intLotId
				,intItemId
				,intOwnerId
				,dtmFromDate
				)
			SELECT @intLotId
				,@intItemId
				,@intOwnerId
				,@dtmProductionDate
		END
		ELSE
		BEGIN
			UPDATE tblMFLotInventory
			SET intItemOwnerId = @intItemOwnerId
				,intConcurrencyId = (intConcurrencyId + 1)
			WHERE intLotId = @intLotId
		END
	END

	UPDATE tblMFWorkOrderProducedLot
	SET intLotId = @intLotId
		,strParentLotNumber = IsNULL(@strParentLotNumber2, @strParentLotNumber)
	WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId

	IF @intSpecialPalletLotId IS NOT NULL
	BEGIN
		INSERT INTO dbo.tblMFWorkOrderConsumedLot (
			intWorkOrderId
			,intItemId
			,intLotId
			,dblQuantity
			,intItemUOMId
			,dblIssuedQuantity
			,intItemIssuedUOMId
			,intBatchId
			,intSequenceNo
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,intShiftId
			,dtmActualInputDateTime
			,intStorageLocationId
			,intSubLocationId
			)
		SELECT @intWorkOrderId
			,intItemId
			,intLotId
			,(
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				)
			,ISNULL(intWeightUOMId, intItemUOMId)
			,(
				CASE 
					WHEN L.intWeightUOMId IS NOT NULL
						THEN L.dblWeight
					ELSE L.dblQty
					END
				)
			,ISNULL(intWeightUOMId, intItemUOMId)
			,NULL AS intBatchId
			,1
			,@dtmCreated
			,@intUserId
			,@dtmCreated
			,@intUserId
			,@intBusinessShiftId
			,@dtmBusinessDate
			,intStorageLocationId
			,intSubLocationId
		FROM dbo.tblICLot L
		WHERE intLotId = @intSpecialPalletLotId

		SELECT @intSpecialPalletItemId = intItemId
		FROM dbo.tblICLot L
		WHERE intLotId = @intSpecialPalletLotId

		IF NOT EXISTS (
				SELECT *
				FROM tblMFProductionSummary
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = @intSpecialPalletItemId
					AND intItemTypeId IN (
						1
						,3
						)
				)
		BEGIN
			SELECT @intSpecialPalletCategoryId = intCategoryId
			FROM tblICItem
			WHERE intItemId = @intSpecialPalletItemId

			INSERT INTO tblMFProductionSummary (
				intWorkOrderId
				,intItemId
				,dblOpeningQuantity
				,dblOpeningOutputQuantity
				,dblOpeningConversionQuantity
				,dblInputQuantity
				,dblConsumedQuantity
				,dblOutputQuantity
				,dblOutputConversionQuantity
				,dblCountQuantity
				,dblCountOutputQuantity
				,dblCountConversionQuantity
				,dblCalculatedQuantity
				,intCategoryId
				,intItemTypeId
				)
			SELECT @intWorkOrderId
				,@intSpecialPalletItemId
				,0
				,0
				,0
				,0
				,1
				,0
				,0
				,0
				,0
				,0
				,0
				,@intSpecialPalletCategoryId
				,1
		END
		ELSE
		BEGIN
			UPDATE tblMFProductionSummary
			SET dblConsumedQuantity = dblConsumedQuantity + 1
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intSpecialPalletItemId
				AND intItemTypeId IN (
					1
					,3
					)
		END
	END
END
