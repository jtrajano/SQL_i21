CREATE PROCEDURE uspMFAdjustInventory (
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
	)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intStorageLocationId int

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmDate, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @intStorageLocationId=intStorageLocationId FROM dbo.tblICLot WHERE intLotId =@intSourceLotId 

	INSERT INTO tblMFInventoryAdjustment (
		dtmDate
		,intTransactionTypeId
		,intItemId
		,intStorageLocationId 
		,intSourceLotId
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
		)
	SELECT @dtmDate
		,@intTransactionTypeId
		,@intItemId
		,@intStorageLocationId
		,@intSourceLotId
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
