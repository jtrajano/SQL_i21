﻿CREATE PROCEDURE uspMFAdjustInventory (
	@dtmDate DATETIME
	,@intTransactionTypeId INT
	,@intItemId INT
	,@intSourceLotId INT
	,@intDestinationLotId INT
	,@dblQty NUMERIC(38, 20)
	,@intItemUOMId INT
	,@intOldItemId INT
	,@dtmOldExpiryDate DATETIME
	,@dtmNewExpiryDate DATETIME
	,@intOldLotStatusId INT
	,@intNewLotStatusId INT
	,@intUserId INT
	,@strNote NVARCHAR(MAX)
	,@strReason NVARCHAR(MAX)
	,@intLocationId INT
	,@intInventoryAdjustmentId INT
	,@intOldItemOwnerId INT = NULL
	,@intNewItemOwnerId INT = NULL
	,@strOldLotAlias nvarchar(50)= NULL
	,@strNewLotAlias nvarchar(50)= NULL
	,@strOldVendorLotNumber nvarchar(50)= NULL
	,@strNewVendorLotNumber nvarchar(50)= NULL
	,@dtmOldDueDate DATETIME= NULL
	,@dtmNewDueDate DATETIME= NULL
	,@intStorageLocationId INT = NULL
	,@intDestinationStorageLocationId INT = NULL
	,@intWorkOrderInputLotId INT = NULL
	,@intWorkOrderProducedLotId INT = NULL
	,@intWorkOrderId INT = NULL
	,@intWorkOrderConsumedLotId INT=NULL
	,@strOldLoadNo nvarchar(50)= NULL
	,@strNewLoadNo nvarchar(50)= NULL
	)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmDate, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intStorageLocationId IS NULL
		SELECT @intStorageLocationId = intStorageLocationId
		FROM dbo.tblICLot
		WHERE intLotId = @intSourceLotId

	IF @intDestinationStorageLocationId IS NULL
		AND @intDestinationLotId IS NOT NULL
		SELECT @intDestinationStorageLocationId = intStorageLocationId
		FROM dbo.tblICLot
		WHERE intLotId = @intDestinationLotId

	INSERT INTO tblMFInventoryAdjustment (
		dtmDate
		,intTransactionTypeId
		,intItemId
		,intStorageLocationId
		,intSourceLotId
		,intDestinationStorageLocationId
		,intDestinationLotId
		,dblQty
		,intItemUOMId
		,intOldItemId
		,dtmOldExpiryDate
		,dtmNewExpiryDate
		,intOldLotStatusId
		,intNewLotStatusId
		,intUserId
		,strNote
		,strReason
		,intLocationId
		,dtmBusinessDate
		,intBusinessShiftId
		,intInventoryAdjustmentId
		,intOldItemOwnerId
		,intNewItemOwnerId
		,strOldLotAlias 
		,strNewLotAlias 
		,strOldVendorLotNumber 
		,strNewVendorLotNumber 
		,dtmOldDueDate 
		,dtmNewDueDate
		,intWorkOrderInputLotId
		,intWorkOrderProducedLotId
		,intWorkOrderId
		,intWorkOrderConsumedLotId
		,strOldLoadNo
		,strNewLoadNo
		)
	SELECT @dtmDate
		,@intTransactionTypeId
		,@intItemId
		,@intStorageLocationId
		,@intSourceLotId
		,@intDestinationStorageLocationId
		,@intDestinationLotId
		,@dblQty
		,@intItemUOMId
		,@intOldItemId
		,@dtmOldExpiryDate
		,@dtmNewExpiryDate
		,@intOldLotStatusId
		,@intNewLotStatusId
		,@intUserId
		,@strNote
		,@strReason
		,@intLocationId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@intInventoryAdjustmentId
		,@intOldItemOwnerId
		,@intNewItemOwnerId
		,@strOldLotAlias 
		,@strNewLotAlias 
		,@strOldVendorLotNumber 
		,@strNewVendorLotNumber 
		,@dtmOldDueDate 
		,@dtmNewDueDate 
		,@intWorkOrderInputLotId
		,@intWorkOrderProducedLotId
		,@intWorkOrderId
		,@intWorkOrderConsumedLotId
		,@strOldLoadNo
		,@strNewLoadNo

	Update tblMFLotInventory
	Set dtmLastMoveDate =@dtmDate
	WHERE intLotId =@intSourceLotId

	if @intDestinationLotId is not null
	Update tblMFLotInventory
	Set dtmLastMoveDate =@dtmDate
	WHERE intLotId =@intDestinationLotId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
