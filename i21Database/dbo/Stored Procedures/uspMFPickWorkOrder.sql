﻿CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] @intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT = NULL
	,@intUserId INT
	,@intBatchId INT
	,@PickPreference NVARCHAR(50) = ''
	,@ysnExcessConsumptionAllowed BIT = 0
	,@dblUnitQty NUMERIC(38, 20)
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
		,@dblQty NUMERIC(38, 20)
		,@intLocationId INT
		,@intSequenceNo INT
		,@ysnSubstituteItem BIT
		,@dblSubstituteRatio NUMERIC(18, 6)
		,@dblMaxSubstituteRatio NUMERIC(18, 6)
		,@intStorageLocationId INT
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@intConsumptionMethodId INT
		,@intWeightUOMId INT
		,@dblAdjustByQuantity NUMERIC(38, 20)
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intInventoryAdjustmentId INT
		,@intTransactionCount INT
		,@intAttributeId INT
		,@strYieldAdjustmentAllowed NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@strAllInputItemsMandatoryforConsumption NVARCHAR(50)
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Is Yield Adjustment Allowed'

	SELECT @strYieldAdjustmentAllowed = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	SELECT @ysnExcessConsumptionAllowed = 0

	IF @strYieldAdjustmentAllowed = 'True'
	BEGIN
		SELECT @ysnExcessConsumptionAllowed = 1
	END

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	IF @intTransactionCount = 0
		BEGIN TRAN

	DECLARE @tblItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		,intStorageLocationId INT
		,intConsumptionMethodId INT
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
		,strLotNumber NVARCHAR(50)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,dblIssuedQuantity NUMERIC(38, 20)
		,dblWeightPerUnit NUMERIC(38, 20)
		,intItemUOMId INT
		,intItemIssuedUOMId INT
		,ysnSubstituteItem BIT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
		)

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
		AND WI.ysnConsumptionReversed = 0

	INSERT INTO @tblItem (
		intItemId
		,dblReqQty
		,intStorageLocationId
		,intConsumptionMethodId
		)
	SELECT ri.intItemId
		,CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN (
						--CASE 
						--	WHEN @dblUnitQty > P.dblWeight
						--		THEN CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / P.dblMaxWeightPerPack)))
						--	ELSE CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / @dblUnitQty)))
						--	END
						CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / P.dblMaxWeightPerPack)))
						)
			ELSE CEILING((ri.dblCalculatedQuantity * (@dblProduceQty / r.dblQuantity)))
			END AS RequiredQty
		,ri.intStorageLocationId
		,ri.intConsumptionMethodId
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
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
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
			AND rs.intWorkOrderId = ri.intWorkOrderId
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
			,@intStorageLocationId = intStorageLocationId
			,@intConsumptionMethodId = intConsumptionMethodId
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
				,(
					CASE 
						WHEN intWeightUOMId IS NOT NULL
							THEN dblWeight
						ELSE dblQty
						END
					)
				,(
					CASE 
						WHEN intWeightUOMId IS NOT NULL
							THEN L.dblQty
						ELSE dblQty / (
								CASE 
									WHEN L.dblWeightPerQty = 0
										OR L.dblWeightPerQty IS NULL
										THEN 1
									ELSE L.dblWeightPerQty
									END
								)
						END
					)
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
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				AND SL.ysnAllowConsume = 1
			JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId
			WHERE SI.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1
				AND dtmExpiryDate >= @dtmCurrentDateTime
				AND L.intStorageLocationId = (
					CASE 
						WHEN @intStorageLocationId IS NULL
							THEN L.intStorageLocationId
						ELSE (
								CASE 
									WHEN @intConsumptionMethodId = 2
										THEN @intStorageLocationId
									ELSE L.intStorageLocationId
									END
								) --By location, then apply location filter
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
			,(
				CASE 
					WHEN intWeightUOMId IS NOT NULL
						THEN dblWeight
					ELSE dblQty
					END
				)
			,(
				CASE 
					WHEN intWeightUOMId IS NOT NULL
						THEN L.dblQty
					ELSE dblQty / (
							CASE 
								WHEN L.dblWeightPerQty = 0
									OR L.dblWeightPerQty IS NULL
									THEN 1
								ELSE L.dblWeightPerQty
								END
							)
					END
				)
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
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			AND SL.ysnAllowConsume = 1
		WHERE L.intItemId = @intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1
			AND dtmExpiryDate >= @dtmCurrentDateTime
			AND L.intStorageLocationId = (
				CASE 
					WHEN @intStorageLocationId IS NULL
						THEN L.intStorageLocationId
					ELSE (
							CASE 
								WHEN @intConsumptionMethodId = 2
									THEN @intStorageLocationId
								ELSE L.intStorageLocationId
								END
							) --By location, then apply location filter
					END
				)
			AND L.dblQty > 0
		ORDER BY L.dtmDateCreated ASC

		IF NOT EXISTS (
				SELECT *
				FROM @tblLot
				)
			AND @ysnExcessConsumptionAllowed = 1
		BEGIN
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
				,intParentLotId INT
				,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				)

			-- Create and validate the lot numbers
			BEGIN
				DECLARE @strLifeTimeType NVARCHAR(50)
					,@intLifeTime INT
					,@dtmExpiryDate DATETIME
					,@strLotTracking NVARCHAR(50)
					,@intItemLocationId INT
					,@strLotNumber NVARCHAR(50)
					,@intItemUOMId INT
					,@intSubLocationId INT

				SELECT @strLifeTimeType = strLifeTimeType
					,@intLifeTime = intLifeTime
					,@strLotTracking = strLotTracking
				FROM dbo.tblICItem
				WHERE intItemId = @intItemId

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE ysnStockUnit = 1
					AND intItemId = @intItemId

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

				IF @intConsumptionMethodId = 2
				BEGIN
					SELECT @intSubLocationId = intSubLocationId
					FROM tblICStorageLocation
					WHERE intStorageLocationId = @intStorageLocationId
				END
				ELSE
				BEGIN
					SELECT @intStorageLocationId = intNewLotBin
					FROM tblSMCompanyLocationSubLocation
					WHERE intCompanyLocationId = @intLocationId

					SELECT @intSubLocationId = intSubLocationId
					FROM tblICStorageLocation
					WHERE intStorageLocationId = @intStorageLocationId
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
					,intGradeId
					,strBOLNo
					,strVessel
					,strReceiptNumber
					,strMarkings
					,strNotes
					,intEntityVendorId
					,strVendorLotNo
					,strGarden
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
					,intGradeId = NULL
					,strBOLNo = NULL
					,strVessel = NULL
					,strReceiptNumber = NULL
					,strMarkings = NULL
					,strNotes = NULL
					,intEntityVendorId = NULL
					,strVendorLotNo = NULL
					,strGarden = NULL
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
				,(
					CASE 
						WHEN intWeightUOMId IS NOT NULL
							THEN dblWeight
						ELSE dblQty
						END
					)
				,(
					CASE 
						WHEN intWeightUOMId IS NOT NULL
							THEN L.dblQty
						ELSE dblQty / (
								CASE 
									WHEN L.dblWeightPerQty = 0
										OR L.dblWeightPerQty IS NULL
										THEN 1
									ELSE L.dblWeightPerQty
									END
								)
						END
					)
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
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				AND SL.ysnAllowConsume = 1
			WHERE L.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1
				AND dtmExpiryDate >= @dtmCurrentDateTime
				AND L.intStorageLocationId = (
					CASE 
						WHEN @intStorageLocationId IS NULL
							THEN L.intStorageLocationId
						ELSE (
								CASE 
									WHEN @intConsumptionMethodId = 2
										THEN @intStorageLocationId
									ELSE L.intStorageLocationId
									END
								) --By location, then apply location filter
						END
					)
				AND L.dblQty > 0
			ORDER BY L.dtmDateCreated ASC
		END

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
				IF @ysnExcessConsumptionAllowed = 0
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
				ELSE
				BEGIN
					SELECT @dblAdjustByQuantity = @dblReqQty - SUM(dblQty)
					FROM @tblLot

					SELECT @strLotNumber = strLotNumber
						,@intWeightUOMId = intItemUOMId
						,@dblWeightPerQty = dblWeightPerUnit
					FROM @tblLot

					IF @intConsumptionMethodId = 2
					BEGIN
						SELECT @intSubLocationId = intSubLocationId
						FROM tblICStorageLocation
						WHERE intStorageLocationId = @intStorageLocationId
					END
					ELSE
					BEGIN
						--Select @intStorageLocationId=intNewLotBin from tblSMCompanyLocationSubLocation Where intCompanyLocationId=@intLocationId 
						--Select @intSubLocationId=intSubLocationId From tblICStorageLocation Where intStorageLocationId =@intStorageLocationId
						SELECT @intStorageLocationId = intStorageLocationId
							,@intSubLocationId = intSubLocationId
						FROM tblICLot
						WHERE strLotNumber = @strLotNumber
					END

					SELECT @dblAdjustByQuantity = @dblAdjustByQuantity / (
							CASE 
								WHEN @intWeightUOMId IS NULL
									THEN 1
								ELSE @dblWeightPerQty
								END
							)

					EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
						-- Parameters for filtering:
						@intItemId = @intItemId
						,@dtmDate = @dtmCurrentDateTime
						,@intLocationId = @intLocationId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber
						-- Parameters for the new values: 
						,@dblAdjustByQuantity = @dblAdjustByQuantity
						,@dblNewUnitCost = NULL
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intEntityUserSecurityId = @intUserId
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

				IF NOT EXISTS (
						SELECT *
						FROM tblMFProductionSummary
						WHERE intWorkOrderId = @intWorkOrderId
							AND intItemId = @intItemId
						)
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
					UPDATE tblMFProductionSummary
					SET dblConsumedQuantity = dblConsumedQuantity + @dblReqQty
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemId = @intItemId
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

				IF NOT EXISTS (
						SELECT *
						FROM tblMFProductionSummary
						WHERE intWorkOrderId = @intWorkOrderId
							AND intItemId = @intItemId
						)
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
					UPDATE tblMFProductionSummary
					SET dblConsumedQuantity = dblConsumedQuantity + @dblQty
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemId = @intItemId
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

	SELECT @intAttributeId = NULL

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'All input items mandatory for consumption'

	SELECT @strAllInputItemsMandatoryforConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strAllInputItemsMandatoryforConsumption = 'True'
		AND EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderRecipeItem ri
			LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = ri.intRecipeItemId
				AND ri.intWorkOrderId = SI.intWorkOrderId
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
				AND ri.intConsumptionMethodId <> 4
				AND NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrderConsumedLot WC
					JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
					WHERE (
							L.intItemId = ri.intItemId
							OR L.intItemId = SI.intSubstituteItemId
							)
						AND WC.intWorkOrderId = @intWorkOrderId
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
		AND @@TRANCOUNT > 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
