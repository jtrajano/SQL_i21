CREATE PROCEDURE uspMFLotItemChange @intLotId INT
	,@intNewItemId INT
	,@intUserId INT
	,@strNewLotNumber NVARCHAR(100) = NULL OUTPUT
	,@dtmDate DATETIME
	,@strReasonCode NVARCHAR(MAX) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@ysnBulkChange BIT = 0
	,@ysnProducedItemChange BIT = 0
	,@dblPhysicalCount NUMERIC(38, 20) = NULL
AS
BEGIN TRY
	DECLARE @intItemId INT
		,@intLocationId INT
		,@intStorageLocationId INT
		,@intSubLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSourceId INT
		,@intSourceTransactionTypeId INT
		,@intLotStatusId INT
		,@intItemUOMId INT
		,@dblLotWeightPerUnit NUMERIC(38, 20)
		,@dblLotQty NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@intTransactionCount INT
		,@strErrMsg NVARCHAR(MAX)
		,@intAdjustItemUOMId INT
		,@intUnitMeasureId INT
		,@strUnitMeasure NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@intFromItemCategory INT
		,@intToItemCategory INT
		,@strFromItemCategory NVARCHAR(50)
		,@strToItemCategory NVARCHAR(50)
		,@intNewLotId INT
		,@dblAdjustByQuantity NUMERIC(16, 8)
		,@dblLotReservedQty NUMERIC(16, 8)
		,@ysnGenerateNewParentLotOnChangeItem BIT
		,@intParentLotId INT
		,@strDescription NVARCHAR(MAX)
		,@strXML NVARCHAR(MAX)
		,@strOutputLotNumber NVARCHAR(50)
		,@strRetBatchId NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@intWorkOrderId INT
		,@intBatchId INT
		,@intProducedLotId INT
		,@dblTareWeight NUMERIC(18, 6)
		,@dblUnitQty NUMERIC(18, 6)
		,@intPhysicalItemUOMId INT
		,@dblProduceQty NUMERIC(18, 6)
		,@intProduceUnitMeasureId INT
		,@intManufacturingProcessId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@strVendorLotNo NVARCHAR(50)
		,@dblReadingQuantity NUMERIC(18, 6)
		,@intContainerId INT
		,@intMachineId INT
		,@strParentLotNumber NVARCHAR(50)
		,@strReferenceNo NVARCHAR(50)
		,@intCurrentStatusId INT
		,@strInstantConsumption NVARCHAR(50)
		,@intOldProduceItemUOMId INT
		,@intOldPhysicalItemUOMId INT
		,@intOldProduceUnitMeasureId INT
		,@intOldPhysicalUnitMeasureId INT
		,@intProduceItemUOMId INT
		,@ysnProductionReversal Bit

	
	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @strDescription = Ltrim(isNULL(@strReasonCode, '') + ' ' + isNULL(@strNotes, ''))

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@strLotNumber = strLotNumber
		,@intItemUOMId = intItemUOMId
		,@dblAdjustByQuantity = - dblQty
		,@intAdjustItemUOMId = intItemUOMId
		,@intParentLotId = intParentLotId
		,@intLotStatusId = intLotStatusId
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @ysnGenerateNewParentLotOnChangeItem = ysnGenerateNewParentLotOnChangeItem
	FROM tblMFCompanyPreference

	IF @ysnGenerateNewParentLotOnChangeItem IS NULL
		SELECT @ysnGenerateNewParentLotOnChangeItem = 1

	SELECT @dblLotReservedQty = dblQty
	FROM tblICStockReservation
	WHERE intLotId = @intLotId
		AND ISNULL(ysnPosted, 0) = 0

	IF (ISNULL(@dblLotReservedQty, 0) > 0)
	BEGIN
		RAISERROR (
				'There is reservation against this lot. Cannot proceed.'
				,16
				,1
				)
	END

	SELECT @strFromItemCategory = C.strCategoryCode
		,@intFromItemCategory = C.intCategoryId
	FROM dbo.tblICItem I
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	WHERE I.intItemId = @intItemId

	SELECT @strToItemCategory = C.strCategoryCode
		,@intToItemCategory = C.intCategoryId
	FROM dbo.tblICItem I
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	WHERE I.intItemId = @intNewItemId

	IF @intItemId = @intNewItemId
	BEGIN
		IF @ysnBulkChange = 1
		BEGIN
			SELECT @strNewLotNumber = ''

			RETURN
		END
	END

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFItemChangeMap
			WHERE intFromItemCategoryId = @intFromItemCategory
				AND intToItemCategoryId = @intToItemCategory
			)
		AND @intFromItemCategory <> @intToItemCategory
	BEGIN
		SET @strErrMsg = 'Item change not allowed from category ' + @strFromItemCategory + ' to ' + @strToItemCategory + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intItemUOMId

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemUOM
			WHERE intItemId = @intNewItemId
				AND intUnitMeasureId = @intUnitMeasureId
			)
	BEGIN
		SELECT @strUnitMeasure = strUnitMeasure
		FROM dbo.tblICUnitMeasure
		WHERE intUnitMeasureId = @intUnitMeasureId

		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intNewItemId

		RAISERROR (
				'Source Lot''s UOM %s is not configured as one of the UOM in destination item %s.'
				,11
				,1
				,@strUnitMeasure
				,@strItemNo
				)
	END

	IF @dtmDate = NULL
		SELECT @dtmDate = GETDATE()

	SELECT @intSourceId = 1
		,@intSourceTransactionTypeId = 8

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @ysnProducedItemChange = 0
	BEGIN
		EXEC uspICInventoryAdjustment_CreatePostItemChange @intItemId = @intItemId
			,@dtmDate = @dtmDate
			,@intLocationId = @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@intNewItemId = @intNewItemId
			,@intNewSubLocationId = @intSubLocationId
			,@intNewStorageLocationId = @intStorageLocationId
			,@intItemUOMId = @intAdjustItemUOMId
			,@intSourceId = @intSourceId
			,@intSourceTransactionTypeId = @intSourceTransactionTypeId
			,@intEntityUserSecurityId = @intUserId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
			,@strDescription = @strDescription

		SELECT TOP 1 @strNewLotNumber = strLotNumber
			,@intNewLotId = intLotId
		FROM tblICLot
		WHERE intSplitFromLotId = @intLotId
		ORDER BY intLotId DESC

		EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmDate
			,@intTransactionTypeId = 15
			,@intItemId = @intNewItemId
			,@intSourceLotId = @intLotId
			,@intDestinationLotId = @intNewLotId
			,@dblQty = @dblAdjustByQuantity
			,@intItemUOMId = @intAdjustItemUOMId
			,@intOldItemId = @intItemId
			,@dtmOldExpiryDate = NULL
			,@dtmNewExpiryDate = NULL
			,@intOldLotStatusId = NULL
			,@intNewLotStatusId = NULL
			,@intUserId = @intUserId
			,@strNote = @strNotes
			,@strReason = @strReasonCode
			,@intLocationId = @intLocationId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId

		IF @ysnGenerateNewParentLotOnChangeItem = 0
		BEGIN
			UPDATE tblICLot
			SET intParentLotId = @intParentLotId
			WHERE intLotId = @intNewLotId
		END
	END
	ELSE
	BEGIN
		If @dblPhysicalCount is null 
		Begin
			Select @ysnProductionReversal=0
		End
		Else
		Begin
			Select @ysnProductionReversal=1
		End

		SELECT @intWorkOrderId = intWorkOrderId
			,@intBatchId = intBatchId
			,@intProducedLotId = intLotId
			,@intOldProduceItemUOMId = intItemUOMId
			,@dblPhysicalCount = CASE 
				WHEN @dblPhysicalCount IS NULL
					THEN dblPhysicalCount
				ELSE @dblPhysicalCount
				END
			,@intOldPhysicalItemUOMId = intPhysicalItemUOMId
			,@dblTareWeight = dblTareWeight
			,@intContainerId = intContainerId
			,@intMachineId = intMachineId
			,@strParentLotNumber = strParentLotNumber
			,@strReferenceNo = strReferenceNo
			,@dtmPlannedDate = dtmProductionDate
			,@intPlannedShiftId = intShiftId
		FROM tblMFWorkOrderProducedLot WP
		WHERE intLotId IN (
				SELECT intLotId
				FROM tblICLot
				WHERE strLotNumber = @strLotNumber
				)

		IF @dblPhysicalCount <> Abs(@dblAdjustByQuantity) and @ysnProductionReversal=0
		BEGIN
			RAISERROR (
					'Item change is not allowed for this pallet. Qty is adjusted.'
					,16
					,1
					)
		END

		SELECT @dblUnitQty = dblWeight
		FROM tblICItem
		WHERE intItemId = @intNewItemId

		SELECT @dblProduceQty = @dblPhysicalCount * @dblUnitQty

		SELECT @intOldProduceUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intOldProduceItemUOMId

		SELECT @intOldPhysicalUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intOldPhysicalItemUOMId

		IF @intOldProduceUnitMeasureId = @intOldPhysicalUnitMeasureId
		BEGIN
			SELECT @dblUnitQty = 1
				,@dblProduceQty = @dblPhysicalCount
		END

		SELECT @intProduceItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intNewItemId
			AND intUnitMeasureId = @intOldProduceUnitMeasureId

		SELECT @intPhysicalItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intNewItemId
			AND intUnitMeasureId = @intOldPhysicalUnitMeasureId

		SELECT @strXML = '<root><intWorkOrderId>' + Ltrim(@intWorkOrderId) + '</intWorkOrderId><intBatchId>' + Ltrim(@intBatchId) + '</intBatchId><intLotId>' + Ltrim(@intProducedLotId) + '</intLotId><intUserId>' + Ltrim(@intUserId) + '</intUserId><ysnForceUndo>1</ysnForceUndo></root>'

		SELECT @intManufacturingProcessId = intManufacturingProcessId
			,@strWorkOrderNo = strWorkOrderNo
			,@strVendorLotNo = strVendorLotNo
			,@intCurrentStatusId = intStatusId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strInstantConsumption = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 20 --Is Instant Consumption

		IF @strInstantConsumption = 'False'
		BEGIN
			RAISERROR (
					'Item change/Production reversal is not allowed when instant consumption is false.'
					,16
					,1
					)

			RETURN
		END

		EXEC dbo.uspMFUndoPallet @strXML = @strXML

		IF @dblPhysicalCount > 0
		BEGIN
			SELECT @strXML = '<root>'

			SELECT @strXML = @strXML + '<intWorkOrderId>' + Ltrim(@intWorkOrderId) + '</intWorkOrderId>'

			SELECT @strXML = @strXML + '<intManufacturingProcessId>' + Ltrim(@intManufacturingProcessId) + '</intManufacturingProcessId>'

			SELECT @strXML = @strXML + '<dtmPlannedDate>' + Ltrim(@dtmPlannedDate) + '</dtmPlannedDate>'

			SELECT @strXML = @strXML + '<intPlannedShiftId>' + Ltrim(@intPlannedShiftId) + '</intPlannedShiftId>'

			SELECT @strXML = @strXML + '<intItemId>' + Ltrim(@intNewItemId) + '</intItemId>'

			SELECT @strXML = @strXML + '<dblProduceQty>' + Ltrim(@dblProduceQty) + '</dblProduceQty>'

			SELECT @strXML = @strXML + '<intProduceUnitMeasureId>' + Ltrim(@intProduceItemUOMId) + '</intProduceUnitMeasureId>'

			SELECT @strXML = @strXML + '<dblTareWeight>' + Ltrim(@dblTareWeight) + '</dblTareWeight>'

			SELECT @strXML = @strXML + '<dblUnitQty>' + Ltrim(@dblUnitQty) + '</dblUnitQty>'

			SELECT @strXML = @strXML + '<dblPhysicalCount>' + Ltrim(@dblPhysicalCount) + '</dblPhysicalCount>'

			SELECT @strXML = @strXML + '<intPhysicalItemUOMId>' + Ltrim(@intPhysicalItemUOMId) + '</intPhysicalItemUOMId>'

			SELECT @strXML = @strXML + '<intUserId>' + Ltrim(@intUserId) + '</intUserId>'

			SELECT @strXML = @strXML + '<strOutputLotNumber>' + Ltrim(@strLotNumber) + '</strOutputLotNumber>'

			IF @strVendorLotNo IS NOT NULL
				SELECT @strXML = @strXML + '<strVendorLotNo>' + Ltrim(@strVendorLotNo) + '</strVendorLotNo>'

			SELECT @strXML = @strXML + '<dblReadingQuantity>' + Ltrim(@dblProduceQty) + '</dblReadingQuantity>'

			SELECT @strXML = @strXML + '<intLocationId>' + Ltrim(@intLocationId) + '</intLocationId>'

			SELECT @strXML = @strXML + '<intStorageLocationId>' + Ltrim(@intStorageLocationId) + '</intStorageLocationId>'

			SELECT @strXML = @strXML + '<intSubLocationId>' + Ltrim(@intSubLocationId) + '</intSubLocationId>'

			IF @intContainerId IS NOT NULL
				SELECT @strXML = @strXML + '<intContainerId >' + Ltrim(@intContainerId) + '</intContainerId >'

			SELECT @strXML = @strXML + '<ysnSubLotAllowed>False</ysnSubLotAllowed>'

			SELECT @strXML = @strXML + '<intProductionTypeId>2</intProductionTypeId>'

			SELECT @strXML = @strXML + '<intMachineId>' + Ltrim(@intMachineId) + '</intMachineId>'

			SELECT @strXML = @strXML + '<ysnLotAlias>False</ysnLotAlias>'

			SELECT @strXML = @strXML + '<strLotAlias>' + Ltrim(@strWorkOrderNo) + '</strLotAlias>'

			SELECT @strXML = @strXML + '<strParentLotNumber>' + Ltrim(@strParentLotNumber) + '</strParentLotNumber>'

			IF @strReferenceNo IS NOT NULL
				SELECT @strXML = @strXML + '<strReferenceNo>' + Ltrim(@strReferenceNo) + '</strReferenceNo>'

			SELECT @strXML = @strXML + '<intStatusId>10</intStatusId>'

			SELECT @strXML = @strXML + '<ysnPostProduction>0</ysnPostProduction>'

			SELECT @strXML = @strXML + '<intLotStatusId>' + Ltrim(@intLotStatusId) + '</intLotStatusId>'

			SELECT @strXML = @strXML + '<ysnFillPartialPallet>False</ysnFillPartialPallet>'

			SELECT @strXML = @strXML + '</root>'

			IF @strXML IS NULL
			BEGIN
				RAISERROR (
						'Unable to change the item.'
						,16
						,1
						)

				RETURN
			END

			EXEC [dbo].[uspMFCompleteWorkOrder] @strXML = @strXML
				,@strOutputLotNumber = @strOutputLotNumber OUTPUT
				,@intParentLotId = @intParentLotId OUTPUT
				,@dtmCurrentDate = NULL
				,@ysnRecap = 0
				,@strRetBatchId = @strRetBatchId OUTPUT

			IF @intCurrentStatusId <> 10
			BEGIN
				UPDATE tblMFWorkOrder
				SET intStatusId = @intCurrentStatusId
				WHERE intWorkOrderId = @intWorkOrderId
			END
		END
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	SELECT @strNewLotNumber AS strNewLotNumber
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
