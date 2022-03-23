CREATE PROCEDURE uspMFWODetailConfirm (
	@intProducedItemId INT
	,@intItemId INT
	,@dblQuantity NUMERIC(18, 6)
	,@dblLowerToleranceQty NUMERIC(18, 6) = 0
	,@dblUpperToleranceQty NUMERIC(18, 6) = 0
	,@intItemUOMId INT
	,@intStorageLocationId INT
	,@intSubLocationId INT
	,@intUserId INT
	,@intLocationId INT
	,@intTransactionTypeId INT
	)
AS
BEGIN
	DECLARE @dblWOScannedQty NUMERIC(18, 6)
		,@strError NVARCHAR(50)

	IF @intStorageLocationId = 0
		SELECT @intStorageLocationId = NULL

	IF @intSubLocationId = 0
		SELECT @intSubLocationId = NULL

	IF ISNULL(@intTransactionTypeId, 0) = 8
	BEGIN
		SELECT @dblWOScannedQty = sum(dblQuantity)
		FROM dbo.tblMFWODetail
		WHERE intItemId = @intItemId
			AND ysnProcessed = 0
			AND intProducedItemId = @intProducedItemId
			AND intTransactionTypeId = 8

		IF @dblWOScannedQty IS NULL
			SELECT @dblWOScannedQty = 0

		IF @dblWOScannedQty + @dblQuantity > @dblUpperToleranceQty
		BEGIN
			SELECT @strError = 'SCANNED QTY CANNOT BE MORE THAN TOLERANCE QTY.'

			RAISERROR (
					@strError
					,16
					,1
					)

			RETURN
		END
	END
	ELSE
	BEGIN
		IF @intStorageLocationId IS NULL
		BEGIN
			DELETE
			FROM tblMFWODetail
			WHERE intProducedItemId = @intProducedItemId
				AND intItemId = @intItemId
				AND dblQuantity = @dblQuantity
				AND intItemUOMId = @intItemUOMId
				--AND intStorageLocationId = @intStorageLocationId
				--AND intSubLocationId = @intSubLocationId
				AND intUserId = @intUserId
				AND intLocationId = @intLocationId
				AND intTransactionTypeId = 9
				AND ysnProcessed = 0
		END
		ELSE
		BEGIN
			DELETE
			FROM tblMFWODetail
			WHERE intProducedItemId = @intProducedItemId
				AND intItemId = @intItemId
				AND dblQuantity = @dblQuantity
				AND intItemUOMId = @intItemUOMId
				AND intStorageLocationId = @intStorageLocationId
				AND intSubLocationId = @intSubLocationId
				AND intUserId = @intUserId
				AND intLocationId = @intLocationId
				AND intTransactionTypeId = 9
				AND ysnProcessed = 0
		END
	END

	INSERT INTO dbo.tblMFWODetail (
		intProducedItemId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,intStorageLocationId
		,intSubLocationId
		,intUserId
		,ysnProcessed
		,intLocationId
		,intTransactionTypeId
		)
	SELECT @intProducedItemId
		,@intItemId
		,@dblQuantity
		,@intItemUOMId
		,@intStorageLocationId
		,@intSubLocationId
		,@intUserId
		,0 AS ysnProcessed
		,@intLocationId
		,@intTransactionTypeId
END
