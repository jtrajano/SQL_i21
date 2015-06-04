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

	BEGIN TRAN

	DECLARE @tblItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		,intStorageLocationId INT
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
	FROM tblMFRecipe a
	WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

	INSERT INTO tblMFWorkOrderConsumedLot (
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
		,L.intItemId
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
	FROM tblMFWorkOrderInputLot WI
	JOIN tblICLot L ON L.intLotId = WI.intLotId
	JOIN tblMFRecipeItem ri ON ri.intItemId = L.intItemId
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
		AND ri.intConsumptionMethodId = 1
		AND intWorkOrderId = @intWorkOrderId

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
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
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
				,CASE 
					WHEN L.dblWeight = 0
						OR L.dblWeight IS NULL
						THEN L.dblQty
					ELSE L.dblWeight
					END
				,CASE 
					WHEN L.dblWeight = 0
						OR L.dblWeight IS NULL
						THEN L.dblQty
					ELSE (
							L.dblWeight / (
								CASE 
									WHEN L.dblWeightPerQty = 0
										OR L.dblWeightPerQty IS NULL
										THEN 1
									ELSE L.dblWeightPerQty
									END
								)
							)
					END
				,CASE 
					WHEN L.dblWeight = 0
						OR L.dblWeight IS NULL
						OR L.dblWeightPerQty IS NULL
						OR L.dblWeightPerQty = 0
						THEN 1
					ELSE L.dblWeightPerQty
					END
				,CASE 
					WHEN L.dblWeight = 0
						OR L.dblWeight IS NULL
						OR L.intWeightUOMId IS NULL
						OR L.intWeightUOMId = 0
						THEN L.intItemUOMId
					ELSE L.intWeightUOMId
					END
				,L.intItemUOMId
				,1 AS ysnSubstituteItem
				,SI.dblSubstituteRatio
				,SI.dblMaxSubstituteRatio
			FROM dbo.tblICLot L
			JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId
			JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			WHERE LS.strSecondaryStatus = 'Active'
				AND dtmExpiryDate >= Getdate()
				AND L.intStorageLocationId = (
					CASE 
						WHEN @intStorageLocationId IS NULL
							THEN L.intStorageLocationId
						ELSE @intStorageLocationId
						END
					)
				AND (
					L.dblWeight > 0
					OR L.dblQty > 0
					)
				AND SI.intItemId = @intItemId
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
			,CASE 
				WHEN L.dblWeight = 0
					OR L.dblWeight IS NULL
					THEN L.dblQty
				ELSE L.dblWeight
				END
			,CASE 
				WHEN L.dblWeight = 0
					OR L.dblWeight IS NULL
					THEN L.dblQty
				ELSE (
						L.dblWeight / (
							CASE 
								WHEN L.dblWeightPerQty = 0
									OR L.dblWeightPerQty IS NULL
									THEN 1
								ELSE L.dblWeightPerQty
								END
							)
						)
				END
			,CASE 
				WHEN L.dblWeight = 0
					OR L.dblWeight IS NULL
					OR L.dblWeightPerQty IS NULL
					OR L.dblWeightPerQty = 0
					THEN 1
				ELSE L.dblWeightPerQty
				END
			,CASE 
				WHEN L.dblWeight = 0
					OR L.dblWeight IS NULL
					OR L.intWeightUOMId IS NULL
					OR L.intWeightUOMId = 0
					THEN L.intItemUOMId
				ELSE L.intWeightUOMId
				END
			,L.intItemUOMId
			,0 AS ysnSubstituteItem
		FROM dbo.tblICLot L
		JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
		WHERE LS.strSecondaryStatus = 'Active'
			AND dtmExpiryDate >= Getdate()
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE @intStorageLocationId
					END
				)
			AND (
				L.dblWeight > 0
				OR L.dblQty > 0
				)
			AND L.intItemId = @intItemId
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
			FROM tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId

			IF (@dblQty >= @dblReqQty)
			BEGIN
				INSERT INTO tblMFWorkOrderConsumedLot (
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
					,GetDate()
					,@intUserId
					,GetDate()
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
				INSERT INTO tblMFWorkOrderConsumedLot (
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
					,GetDate()
					,@intUserId
					,GetDate()
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
