﻿CREATE PROCEDURE uspMFWODetailConfirm (
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
	)
AS
BEGIN
	DECLARE @dblWOScannedQty NUMERIC(18, 6)
		,@strError NVARCHAR(50)

	IF @intProducedItemId <> @intItemId
	BEGIN
		SELECT @dblWOScannedQty = sum(dblQuantity)
		FROM dbo.tblMFWODetail
		WHERE intItemId = @intItemId
			AND ysnProcessed = 0
			AND intProducedItemId = @intProducedItemId

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
		,CASE 
			WHEN @intProducedItemId = @intItemId
				THEN 9
			ELSE 8
			END
END