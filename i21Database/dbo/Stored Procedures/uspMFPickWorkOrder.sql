CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] @intWorkOrderId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@intBatchId int
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(Max)
		,@strItemNo nvarchar(50)

	BEGIN TRAN

	DECLARE @tblItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		,intStorageLocationId INT
		)
	DECLARE @tblLot TABLE (
		intLotRecordKey INT Identity(1, 1)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(18, 6)
		,dblIssuedQuantity NUMERIC(18, 6)
		,dblWeightPerUnit NUMERIC(18, 6)
		,intItemUOMId INT
		,intItemIssuedUOMId INT
		)
	DECLARE @intItemId INT
		,@intRecipeId INT
		,@intItemRecordKey INT
		,@intLotRecordKey INT
		,@dblReqQty NUMERIC(18, 6)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@intLocationId INT
		,@intSequenceNo int

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
	FROM tblMFRecipe a
	WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

	INSERT INTO @tblItem (
		intItemId
		,dblReqQty
		,intStorageLocationId
		)
	SELECT ri.intItemId
		,CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / r.dblQuantity))) AS RequiredQty
		,ri.intStorageLocationId
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE ri.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
AND ri.intConsumptionMethodId in (2,3)
		

	INSERT INTO @tblLot (
		intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		)
	SELECT L.intLotId
		,L.intItemId
		,Case When L.dblWeight=0 or L.dblWeight is null then L.dblQty else L.dblWeight end
		,Case When L.dblWeight=0 or L.dblWeight is null then L.dblQty else (L.dblWeight / (Case When L.dblWeightPerQty=0 or L.dblWeightPerQty is null then 1 else L.dblWeightPerQty end ) ) end
		,Case When L.dblWeight=0 or L.dblWeight is null or L.dblWeightPerQty is null or L.dblWeightPerQty=0 then 1 else L.dblWeightPerQty end
		,Case When L.dblWeight=0 or L.dblWeight is null or L.intWeightUOMId is null or L.intWeightUOMId=0 then L.intItemUOMId else L.intWeightUOMId end  
		,L.intItemUOMId
	FROM dbo.tblICLot L
	JOIN @tblItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblICLotStatus LS on LS.intLotStatusId =L.intLotStatusId 
	WHERE LS.strSecondaryStatus ='Active'
		AND dtmExpiryDate >= Getdate()
		--AND L.intStorageLocationId = (
		--	CASE 
		--		WHEN I.intStorageLocationId IS NULL
		--			THEN L.intStorageLocationId
		--		ELSE I.intStorageLocationId
		--		END
		--	)
	AND (L.dblWeight>0 or L.dblQty>0)
	ORDER BY L.dtmDateCreated ASC

	SELECT @intItemRecordKey = Min(intItemRecordKey)
	FROM @tblItem

	WHILE (@intItemRecordKey IS NOT NULL)
	BEGIN
		SET @intLotRecordKey = NULL
		
		SELECT @intItemId = intItemId
			,@dblReqQty = dblReqQty
		FROM @tblItem
		WHERE intItemRecordKey = @intItemRecordKey

		IF EXISTS(SELECT SUM(dblQty)FROM @tblLot WHERE intItemId=@intItemId Having SUM(dblQty)<@dblReqQty)
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			RAISERROR (
				51096
				,11
				,1
				,@strItemNo
				)
		END
		
		SELECT @intLotRecordKey = Min(intLotRecordKey)
		FROM @tblLot
		WHERE intItemId = @intItemId
			AND dblQty > 0

		WHILE (@intLotRecordKey IS NOT NULL)
		BEGIN
			SELECT @intLotId = intLotId
				,@dblQty = dblQty
			FROM @tblLot
			WHERE intLotRecordKey = @intLotRecordKey
			
			Select @intSequenceNo=Max(intSequenceNo)+1 From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId
			
			IF (@dblQty >= @dblReqQty)
			BEGIN
				
				INSERT INTO tblMFWorkOrderConsumedLot (
					intWorkOrderId
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
					)
				SELECT @intWorkOrderId
					,intLotId
					,@dblReqQty
					,intItemUOMId
					,@dblReqQty / (Case when dblWeightPerUnit=0 or dblWeightPerUnit is null then 1 else dblWeightPerUnit end)
					,intItemIssuedUOMId
					,@intBatchId
					,Isnull(@intSequenceNo,1)
					,GetDate()
					,@intUserId
					,GetDate()
					,@intUserId
				FROM @tblLot
				WHERE intLotRecordKey = @intLotRecordKey

				UPDATE @tblLot
				SET dblQty = dblQty - @dblReqQty
				WHERE intLotRecordKey = @intLotRecordKey

				GOTO NextItem
			END
			ELSE
			BEGIN
				INSERT INTO tblMFWorkOrderConsumedLot (
					intWorkOrderId
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
					)
				SELECT @intWorkOrderId
					,intLotId
					,@dblQty
					,intItemUOMId
					,@dblQty / (Case when dblWeightPerUnit=0 or dblWeightPerUnit is null then 1 else dblWeightPerUnit end)
					,intItemIssuedUOMId
					,@intBatchId
					,Isnull(@intSequenceNo,1)
					,GetDate()
					,@intUserId
					,GetDate()
					,@intUserId
				FROM @tblLot
				WHERE intLotRecordKey = @intLotRecordKey

				UPDATE @tblLot
				SET dblQty = 0
				WHERE intLotRecordKey = @intLotRecordKey

				SET @dblReqQty = @dblReqQty - @dblQty
			END

			SELECT @intLotRecordKey = Min(intLotRecordKey)
			FROM @tblLot
			WHERE intItemId = @intItemId
				AND dblQty > 0
				AND intLotRecordKey > @intLotRecordKey
		END

		NextItem:

		SELECT @intItemRecordKey = Min(intItemRecordKey)
		FROM @tblItem
		WHERE intItemRecordKey > @intItemRecordKey
	END

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
