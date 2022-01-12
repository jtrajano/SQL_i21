CREATE PROCEDURE uspMFMoveItemValidation @intItemId INT
	,@intItemUOMId INT
	,@intLocationId INT
	,@intStorageLocationId INT = NULL
	,@dblQuantity NUMERIC(18, 6)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intItemLocationId INT
		,@dblOnHand NUMERIC(18, 6)

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

	SELECT @dblOnHand = dblOnHand
	FROM tblICItemStockUOM
	WHERE intItemId = @intItemId
		AND intItemUOMId = @intItemUOMId
		AND ISNULL(intStorageLocationId, ISNULL(@intStorageLocationId, 0)) = ISNULL(@intStorageLocationId, 0)
		AND intItemLocationId = @intItemLocationId
		AND dblOnHand > 0

	IF @dblQuantity > ISNULL(@dblOnHand, 0)
	BEGIN
		RAISERROR (
				'Move qty cannot be greater than stock qty.'
				,16
				,1
				)
	END
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
