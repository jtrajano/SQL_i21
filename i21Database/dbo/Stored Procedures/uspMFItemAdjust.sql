CREATE PROCEDURE uspMFItemAdjust (
	@intItemId INT
	,@dtmDate DATETIME
	,@intLocationId INT
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dblQuantity NUMERIC(18, 6)
	,@intItemUOMId INT
	,@intUserId INT
	)
AS
BEGIN TRY
	DECLARE @dblNewUnitCost NUMERIC(18, 6)
		,@dblAdjustByQuantity NUMERIC(18, 6)
		,@intInventoryAdjustmentId INT
		,@intItemLocationId INT
		,@dblOnHand NUMERIC(18, 6)
		,@ErrMsg NVARCHAR(MAX)

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

	SELECT @dblOnHand = dblOnHand
	FROM tblICItemStockUOM
	WHERE intItemId = @intItemId
		AND intItemUOMId = @intItemUOMId
		AND IsNULL(intSubLocationId, ISNULL(@intSubLocationId, 0)) = ISNULL(@intSubLocationId, 0)
		AND isNULL(intStorageLocationId, ISNULL(@intStorageLocationId, 0)) = ISNULL(@intStorageLocationId, 0)
		AND intItemLocationId = @intItemLocationId

	SELECT @dblAdjustByQuantity = @dblQuantity - @dblOnHand

	EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId = @intItemId
		,@dtmDate = @dtmDate
		,@intLocationId = @intLocationId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@strLotNumber = NULL
		,@dblAdjustByQuantity = @dblAdjustByQuantity
		,@dblNewUnitCost = NULL
		,@intItemUOMId = @intItemUOMId
		,@intSourceId = 1
		,@intSourceTransactionTypeId = 8
		,@intEntityUserSecurityId = @intUserId
		,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
		,@strDescription = ''
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