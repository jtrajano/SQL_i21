CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] @intWorkOrderId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@intBatchId INT
	,@PickPreference NVARCHAR(50) = ''
	,@ysnExcessConsumptionAllowed bit=0
AS
BEGIN TRY

	Select @ysnExcessConsumptionAllowed=1

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
		,@intWeightUOMId int
		,@dblAdjustByQuantity numeric(18,6)
		,@dblWeightPerQty numeric(18,6)
		,@intInventoryAdjustmentId int
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)
	
	IF @intTransactionCount = 0
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
		,strLotNumber nvarchar(50)
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
	FROM dbo.tblMFWorkOrderRecipe a
	WHERE intWorkOrderId = @intWorkOrderId

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
	JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intItemId = WI.intItemId
		WHERE ri.intWorkOrderId = @intWorkOrderId
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
		AND WI.intWorkOrderId = @intWorkOrderId
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
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId and r.intWorkOrderId =ri.intWorkOrderId 
	WHERE r.intWorkOrderId = @intWorkOrderId
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
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId and rs.intWorkOrderId =ri.intWorkOrderId 
		WHERE ri.intWorkOrderId = @intWorkOrderId
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
				strLotNumber
				,intLotId
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
			SELECT L.strLotNumber
				,L.intLotId
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
			strLotNumber
			,intLotId
			,intItemId
			,dblQty
			,dblIssuedQuantity
			,dblWeightPerUnit
			,intItemUOMId
			,intItemIssuedUOMId
			,ysnSubstituteItem
			)
		SELECT L.strLotNumber
			,L.intLotId
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

		If Not Exists(Select *from @tblLot) and @ysnExcessConsumptionAllowed=1
		Begin
				--*****************************************************
				--Create staging lot
				--*****************************************************
				DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

				IF OBJECT_ID('tempdb..#GeneratedLotItems') IS NOT NULL  
				DROP TABLE #GeneratedLotItems  

				CREATE TABLE #GeneratedLotItems (
					intLotId INT
					,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
					,intDetailId INT
					)

				-- Create and validate the lot numbers
				BEGIN
					DECLARE @strLifeTimeType NVARCHAR(50)
						,@intLifeTime INT
						,@dtmExpiryDate DATETIME
						,@strLotTracking NVARCHAR(50)
						,@intItemLocationId int
						,@strLotNumber nvarchar(50)
						,@intItemUOMId int
						,@intSubLocationId int

					SELECT @strLifeTimeType = strLifeTimeType
						,@intLifeTime = intLifeTime
						,@strLotTracking = strLotTracking
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId

					SELECT @intItemUOMId=intItemUOMId
					FROM tblICItemUOM 
					Where ysnStockUnit=1 and intItemId= @intItemId

					IF @strLifeTimeType = 'Years'
						SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmCurrentDateTime)
					ELSE IF @strLifeTimeType = 'Months'
						SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)
					ELSE IF @strLifeTimeType = 'Days'
						SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, @dtmCurrentDateTime)
					ELSE IF @strLifeTimeType = 'Hours'
						SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, @dtmCurrentDateTime)
					ELSE IF @strLifeTimeType = 'Minutes'
						SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, @dtmCurrentDateTime)
					ELSE
						SET @dtmExpiryDate = DateAdd(yy, 1, @dtmCurrentDateTime)

					SELECT @intItemLocationId = intItemLocationId
					FROM dbo.tblICItemLocation
					WHERE intItemId = @intItemId

					IF @strLotTracking <> 'Yes - Serial Number'
					BEGIN
						EXEC dbo.uspSMGetStartingNumber 55
							,@strLotNumber OUTPUT
					END

					IF @intConsumptionMethodId=2 
					BEGIN
						Select @intSubLocationId=intSubLocationId From tblICStorageLocation Where intStorageLocationId =@intStorageLocationId
					END
					ELSE
					BEGIN
						Select @intStorageLocationId=intNewLotBin from tblSMCompanyLocationSubLocation Where intCompanyLocationId=@intLocationId 
						Select @intSubLocationId=intSubLocationId From tblICStorageLocation Where intStorageLocationId =@intStorageLocationId
					END

					INSERT INTO @ItemsThatNeedLotId (
						intLotId
						,strLotNumber
						,strLotAlias
						,intItemId
						,intItemLocationId
						,intSubLocationId
						,intStorageLocationId
						,dblQty
						,intItemUOMId
						,dblWeight
						,intWeightUOMId
						,dtmExpiryDate
						,dtmManufacturedDate
						,intOriginId
						,strBOLNo
						,strVessel
						,strReceiptNumber
						,strMarkings
						,strNotes
						,intEntityVendorId
						,strVendorLotNo
						,intVendorLocationId
						,strVendorLocation
						,intDetailId
						,ysnProduced
						)
					SELECT intLotId = NULL
						,strLotNumber = @strLotNumber
						,strLotAlias = NULL
						,intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intSubLocationId = @intSubLocationId
						,intStorageLocationId = @intStorageLocationId
						,dblQty = @dblReqQty
						,intItemUOMId = @intItemUOMId
						,dblWeight = NULL
						,intWeightUOMId = NULL
						,dtmExpiryDate = @dtmExpiryDate
						,dtmManufacturedDate = @dtmCurrentDateTime
						,intOriginId = NULL
						,strBOLNo = NULL
						,strVessel = NULL
						,strReceiptNumber = NULL
						,strMarkings = NULL
						,strNotes = NULL
						,intEntityVendorId = NULL
						,strVendorLotNo = NULL
						,intVendorLocationId = NULL
						,strVendorLocation = NULL
						,intDetailId = @intWorkOrderId
						,ysnProduced = 1

					EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
						,@intUserId

				END

				--*****************************************************
				--End of create staging lot
				--*****************************************************
				INSERT INTO @tblLot (
					strLotNumber
					,intLotId
					,intItemId
					,dblQty
					,dblIssuedQuantity
					,dblWeightPerUnit
					,intItemUOMId
					,intItemIssuedUOMId
					,ysnSubstituteItem
					)
				SELECT L.strLotNumber
					,L.intLotId
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
		End

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
				If @ysnExcessConsumptionAllowed=0
				Begin
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
				ELSE
				BEGIN
					SELECT @dblAdjustByQuantity=@dblReqQty-SUM(dblQty)
					FROM @tblLot

					SELECT @strLotNumber=strLotNumber 
						,@intWeightUOMId=intItemUOMId
						,@dblWeightPerQty=dblWeightPerUnit
					FROM @tblLot

					IF @intConsumptionMethodId=2 
					BEGIN
						Select @intSubLocationId=intSubLocationId From tblICStorageLocation Where intStorageLocationId =@intStorageLocationId
					END
					ELSE
					BEGIN
						--Select @intStorageLocationId=intNewLotBin from tblSMCompanyLocationSubLocation Where intCompanyLocationId=@intLocationId 
						--Select @intSubLocationId=intSubLocationId From tblICStorageLocation Where intStorageLocationId =@intStorageLocationId
						Select @intStorageLocationId=intStorageLocationId,@intSubLocationId=intSubLocationId from tblICLot Where strLotNumber=@strLotNumber
					END

					Select @dblAdjustByQuantity=@dblAdjustByQuantity/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

					EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
							-- Parameters for filtering:
							@intItemId = @intItemId
							,@dtmDate = @dtmCurrentDateTime
							,@intLocationId = @intLocationId
							,@intSubLocationId = @intSubLocationId
							,@intStorageLocationId = @intStorageLocationId
							,@strLotNumber = @strLotNumber	
							-- Parameters for the new values: 
							,@dblAdjustByQuantity =@dblAdjustByQuantity
							,@dblNewUnitCost =NULL
							-- Parameters used for linking or FK (foreign key) relationships
							,@intSourceId = 1
							,@intSourceTransactionTypeId = 8
							,@intUserId = @intUserId
							,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
				END
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

				IF NOT EXISTS(SELECT *FROM tblMFProductionSummary WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId)
				BEGIN
					INSERT INTO tblMFProductionSummary (
						intWorkOrderId
						,intItemId
						,dblOpeningQuantity
						,dblOpeningOutputQuantity
						,dblOpeningConversionQuantity
						,dblInputQuantity
						,dblConsumedQuantity
						,dblOutputQuantity
						,dblOutputConversionQuantity
						,dblCountQuantity
						,dblCountOutputQuantity
						,dblCountConversionQuantity
						,dblCalculatedQuantity
						)
					SELECT @intWorkOrderId
						,@intItemId
						,0
						,0
						,0
						,0
						,@dblReqQty
						,0
						,0
						,0
						,0
						,0
						,0
				END
				ELSE
				BEGIN
					UPDATE tblMFProductionSummary SET dblConsumedQuantity=dblConsumedQuantity+@dblReqQty WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId
				END

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

				IF NOT EXISTS(SELECT *FROM tblMFProductionSummary WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId)
				BEGIN
					INSERT INTO tblMFProductionSummary (
						intWorkOrderId
						,intItemId
						,dblOpeningQuantity
						,dblOpeningOutputQuantity
						,dblOpeningConversionQuantity
						,dblInputQuantity
						,dblConsumedQuantity
						,dblOutputQuantity
						,dblOutputConversionQuantity
						,dblCountQuantity
						,dblCountOutputQuantity
						,dblCountConversionQuantity
						,dblCalculatedQuantity
						)
					SELECT @intWorkOrderId
						,@intItemId
						,0
						,0
						,0
						,0
						,@dblQty
						,0
						,0
						,0
						,0
						,0
						,0
				END
				ELSE
				BEGIN
					UPDATE tblMFProductionSummary SET dblConsumedQuantity=dblConsumedQuantity+@dblQty WHERE intWorkOrderId=@intWorkOrderId AND intItemId=@intItemId
				END

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

	IF EXISTS (
		SELECT *
		FROM dbo.tblMFWorkOrderRecipeItem ri
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = ri.intRecipeItemId and ri.intWorkOrderId =SI.intWorkOrderId 
		AND SI.intRecipeId = ri.intRecipeId
		WHERE ri.intWorkOrderId = @intWorkOrderId
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
			AND ri.intConsumptionMethodId <>4
			AND NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderConsumedLot WC
				JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
				WHERE (L.intItemId = ri.intItemId OR L.intItemId = SI.intSubstituteItemId)and WC.intWorkOrderId =@intWorkOrderId 
				)
		)
		BEGIN
			RAISERROR (
					51095
					,11
					,1
					)

			RETURN
		END
	
	IF @intTransactionCount = 0
	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0 AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
