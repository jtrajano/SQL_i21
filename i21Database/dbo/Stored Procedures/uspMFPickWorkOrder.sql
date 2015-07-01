CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] @intWorkOrderId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@intBatchId INT
	,@PickPreference NVARCHAR(50) = ''
AS
BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(Max)
		,@strItemNo NVARCHAR(50)
		,@intItemId INT
		,@intRecipeId INT
		,@intItemRecordKey INT
		,@intLotRecordKey INT
		,@dblReqQty NUMERIC(18, 6)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@intLocationId INT
		,@intSequenceNo INT
		,@ysnSubstituteItem BIT
		,@dblSubstituteRatio NUMERIC(18, 6)
		,@dblMaxSubstituteRatio NUMERIC(18, 6)
		,@intStorageLocationId int
		,@dtmCurrentDate datetime
		,@dtmCurrentDateTime datetime
		,@intDayOfYear int
		,@intConsumptionMethodId int

	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)

	BEGIN TRAN

	DECLARE @tblItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		,intStorageLocationId INT
		,intConsumptionMethodId int
		)

	DECLARE @tblSubstituteItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,intSubstituteItemId INT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
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
		,ysnSubstituteItem BIT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
		)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
	FROM dbo.tblMFRecipe a
	WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

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
		)
	SELECT WI.intWorkOrderId
		,WI.intItemId
		,WI.intLotId
		,WI.dblQuantity
		,WI.intItemUOMId
		,WI.dblIssuedQuantity
		,WI.intItemIssuedUOMId
		,@intBatchId
		,WI.intSequenceNo
		,WI.dtmCreated
		,WI.intCreatedUserId
		,WI.dtmLastModified
		,WI.intLastModifiedUserId
	FROM dbo.tblMFWorkOrderInputLot WI
	JOIN dbo.tblMFRecipeItem ri ON ri.intItemId = WI.intItemId
	WHERE ri.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId = 1
		AND intWorkOrderId = @intWorkOrderId
		AND WI.ysnConsumptionReversed=0
	INSERT INTO @tblItem (
		intItemId
		,dblReqQty
		,intStorageLocationId
		,intConsumptionMethodId
		)
	SELECT ri.intItemId
		,CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / r.dblQuantity))) AS RequiredQty
		,ri.intStorageLocationId
		,ri.intConsumptionMethodId
	FROM dbo.tblMFRecipeItem ri
	JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE ri.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId IN (
			2
			,3
			)

	IF @PickPreference = 'Substitute Item'
	BEGIN
		INSERT INTO @tblSubstituteItem (
			intItemId
			,intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
			)
		SELECT ri.intItemId
			,rs.intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
		WHERE ri.intRecipeId = @intRecipeId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId IN (
				2
				,3
				)
	END

	SELECT @intItemRecordKey = Min(intItemRecordKey)
	FROM @tblItem

	WHILE (@intItemRecordKey IS NOT NULL)
	BEGIN
		SET @intLotRecordKey = NULL

		SELECT @intItemId = intItemId
			,@dblReqQty = dblReqQty
			,@intStorageLocationId=intStorageLocationId
			,@intConsumptionMethodId=intConsumptionMethodId
		FROM @tblItem
		WHERE intItemRecordKey = @intItemRecordKey

		DELETE
		FROM @tblLot

		IF @PickPreference = 'Substitute Item'
		BEGIN
			INSERT INTO @tblLot (
				intLotId
				,intItemId
				,dblQty
				,dblIssuedQuantity
				,dblWeightPerUnit
				,intItemUOMId
				,intItemIssuedUOMId
				,ysnSubstituteItem
				,dblSubstituteRatio
				,dblMaxSubstituteRatio
				)
			SELECT L.intLotId
				,L.intItemId
				,(CASE WHEN intWeightUOMId IS NOT NULL THEN dblWeight ELSE dblQty END)
				,(CASE WHEN intWeightUOMId IS NOT NULL THEN L.dblQty ELSE dblQty/(
								CASE 
									WHEN L.dblWeightPerQty = 0
										OR L.dblWeightPerQty IS NULL
										THEN 1
									ELSE L.dblWeightPerQty
									END
								) END)
				
				,CASE 
					WHEN L.dblWeightPerQty IS NULL
						OR L.dblWeightPerQty = 0
						THEN 1
					ELSE L.dblWeightPerQty
					END
				,CASE 
					WHEN L.intWeightUOMId IS NULL
						OR L.intWeightUOMId = 0
						THEN L.intItemUOMId
					ELSE L.intWeightUOMId
					END
				,L.intItemUOMId
				,1 AS ysnSubstituteItem
				,SI.dblSubstituteRatio
				,SI.dblMaxSubstituteRatio
			FROM dbo.tblICLot L
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId =L.intStorageLocationId  and SL.ysnAllowConsume =1
			JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId
			WHERE SI.intItemId = @intItemId
				AND L.intLocationId=@intLocationId 
				and L.intLotStatusId=1
				AND dtmExpiryDate >= @dtmCurrentDateTime
				AND L.intStorageLocationId = (
					CASE 
						WHEN @intStorageLocationId IS NULL
							THEN L.intStorageLocationId
						ELSE (Case When @intConsumptionMethodId=2 Then @intStorageLocationId Else L.intStorageLocationId End)--By location, then apply location filter
						END
					)
				AND L.dblQty > 0
			ORDER BY L.dtmDateCreated ASC
		END

		INSERT INTO @tblLot (
			intLotId
			,intItemId
			,dblQty
			,dblIssuedQuantity
			,dblWeightPerUnit
			,intItemUOMId
			,intItemIssuedUOMId
			,ysnSubstituteItem
			)
		SELECT L.intLotId
			,L.intItemId
			,(CASE WHEN intWeightUOMId IS NOT NULL THEN dblWeight ELSE dblQty END)
			,(CASE WHEN intWeightUOMId IS NOT NULL THEN L.dblQty ELSE dblQty/(
							CASE 
								WHEN L.dblWeightPerQty = 0
									OR L.dblWeightPerQty IS NULL
									THEN 1
								ELSE L.dblWeightPerQty
								END
							) END)
				
			,CASE 
				WHEN L.dblWeightPerQty IS NULL
					OR L.dblWeightPerQty = 0
					THEN 1
				ELSE L.dblWeightPerQty
				END
			,CASE 
				WHEN L.intWeightUOMId IS NULL
					OR L.intWeightUOMId = 0
					THEN L.intItemUOMId
				ELSE L.intWeightUOMId
				END
			,L.intItemUOMId
			,0 AS ysnSubstituteItem
		FROM dbo.tblICLot L
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId =L.intStorageLocationId  and SL.ysnAllowConsume =1
		WHERE L.intItemId = @intItemId
			AND L.intLocationId=@intLocationId
			AND L.intLotStatusId=1
			AND dtmExpiryDate >= @dtmCurrentDateTime
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE (Case When @intConsumptionMethodId=2 Then @intStorageLocationId Else L.intStorageLocationId End)--By location, then apply location filter
					END
				)
			AND L.dblQty > 0
		ORDER BY L.dtmDateCreated ASC

		SELECT @intLotRecordKey = Min(intLotRecordKey)
		FROM @tblLot
		WHERE dblQty > 0

		WHILE (@intLotRecordKey IS NOT NULL)
		BEGIN
			SELECT @intLotId = intLotId
				,@dblQty = dblQty
				,@ysnSubstituteItem = ysnSubstituteItem
				,@dblMaxSubstituteRatio = dblMaxSubstituteRatio
				,@dblSubstituteRatio = dblSubstituteRatio
			FROM @tblLot
			WHERE intLotRecordKey = @intLotRecordKey

			IF @ysnSubstituteItem = 1
			BEGIN
				SELECT @dblReqQty = @dblReqQty * (@dblMaxSubstituteRatio / 100) * @dblSubstituteRatio
			END

			IF EXISTS (
					SELECT SUM(dblQty)
					FROM @tblLot
					HAVING SUM(dblQty) < @dblReqQty
					)
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

			SELECT @intSequenceNo = Max(intSequenceNo) + 1
			FROM dbo.tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId

			IF (@dblQty >= @dblReqQty)
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
					)
				SELECT @intWorkOrderId
					,@intItemId
					,intLotId
					,@dblReqQty
					,intItemUOMId
					,@dblReqQty / (
						CASE 
							WHEN dblWeightPerUnit = 0
								OR dblWeightPerUnit IS NULL
								THEN 1
							ELSE dblWeightPerUnit
							END
						)
					,intItemIssuedUOMId
					,@intBatchId
					,Isnull(@intSequenceNo, 1)
					,@dtmCurrentDateTime
					,@intUserId
					,@dtmCurrentDateTime
					,@intUserId
				FROM @tblLot
				WHERE intLotRecordKey = @intLotRecordKey

				UPDATE @tblLot
				SET dblQty = dblQty - @dblReqQty
				WHERE intLotRecordKey = @intLotRecordKey

				IF @ysnSubstituteItem = 1
					AND @dblMaxSubstituteRatio <> 100
				BEGIN
					SET @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) * (100 - @dblMaxSubstituteRatio) / 100
				END
				ELSE
				BEGIN
					GOTO NextItem
				END
			END
			ELSE
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
					)
				SELECT @intWorkOrderId
					,@intItemId
					,intLotId
					,@dblQty
					,intItemUOMId
					,@dblQty / (
						CASE 
							WHEN dblWeightPerUnit = 0
								OR dblWeightPerUnit IS NULL
								THEN 1
							ELSE dblWeightPerUnit
							END
						)
					,intItemIssuedUOMId
					,@intBatchId
					,Isnull(@intSequenceNo, 1)
					,@dtmCurrentDateTime
					,@intUserId
					,@dtmCurrentDateTime
					,@intUserId
				FROM @tblLot
				WHERE intLotRecordKey = @intLotRecordKey

				UPDATE @tblLot
				SET dblQty = 0
				WHERE intLotRecordKey = @intLotRecordKey

				IF @ysnSubstituteItem = 1
				BEGIN
					SET @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) - (@dblQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio)
				END
				ELSE
				BEGIN
					SET @dblReqQty = @dblReqQty - @dblQty
				END
			END

			SELECT @intLotRecordKey = Min(intLotRecordKey)
			FROM @tblLot
			WHERE dblQty > 0
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
