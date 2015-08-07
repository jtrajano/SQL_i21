CREATE PROCEDURE [dbo].[uspMFCalculateYield] @intWorkOrderId INT
	,@ysnYieldAdjustmentAllowed BIT = 1
	,@intUserId INT
AS
BEGIN TRY
	Select @ysnYieldAdjustmentAllowed=1
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intItemId INT
		,@intRecipeId INT
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@ErrMsg NVARCHAR(MAX)
		,@dtmCurrentDate datetime
		,@dtmCurrentDateTime datetime
		,@intDayOfYear int
	
	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)

	DECLARE @tblInputItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblCalculatedQuantity NUMERIC(18, 6)
		,ysnScaled BIT
		,intStorageLocationId INT
		,ysnSubstituteItem BIT
		)
	DECLARE @tblOutputItem TABLE (
		intItemRecordKey INT Identity(1, 1)
		,intItemId INT
		,dblCalculatedQuantity NUMERIC(18, 6)
		)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrderRecipe a
	WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO @tblInputItem (
		intItemId
		,dblCalculatedQuantity
		,ysnScaled
		,intStorageLocationId
		,ysnSubstituteItem
		)
	SELECT ri.intItemId
		,ri.dblCalculatedQuantity
		,ri.ysnScaled
		,ri.intStorageLocationId
		,0
	FROM dbo.tblMFWorkOrderRecipeItem ri
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

	INSERT INTO @tblInputItem (
		intItemId
		,dblCalculatedQuantity
		,ysnScaled
		,intStorageLocationId
		,ysnSubstituteItem
		)
	SELECT rs.intSubstituteItemId
		,ri.dblCalculatedQuantity
		,ri.ysnScaled
		,ri.intStorageLocationId
		,1
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId and rs.intWorkOrderId=ri.intWorkOrderId
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

	INSERT INTO @tblOutputItem (
		intItemId
		,dblCalculatedQuantity
		)
	SELECT ri.intItemId
		,r.dblQuantity--It is product standard qty.
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId and r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 2
		AND ri.ysnConsumptionRequired = 1
	
	Update tblMFProductionSummary
	Set dblCalculatedQuantity=I.dblCalculatedQuantity
	From tblMFProductionSummary PS
	JOIN @tblInputItem I on I.intItemId=PS.intItemId

	Update tblMFProductionSummary
	Set dblCalculatedQuantity=O.dblCalculatedQuantity
	From tblMFProductionSummary PS
	JOIN @tblOutputItem O on O.intItemId=PS.intItemId

	UPDATE tblMFProductionSummary
	SET dblOpeningConversionQuantity = dblOpeningConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblOpeningOutputQuantity / F.dblCalculatedQuantity)
							FROM tblMFProductionSummary F
							WHERE F.dblOpeningOutputQuantity > 0 AND F.intWorkOrderId =@intWorkOrderId 
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
		,dblOutputConversionQuantity = dblOutputConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblOutputQuantity / F.dblCalculatedQuantity)
							FROM tblMFProductionSummary F
							WHERE F.dblOutputQuantity > 0 AND F.intWorkOrderId =@intWorkOrderId
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
		,dblCountConversionQuantity = dblCountConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblCountOutputQuantity / F.dblCalculatedQuantity)
							FROM tblMFProductionSummary F
							WHERE F.dblCountOutputQuantity > 0 AND F.intWorkOrderId =@intWorkOrderId
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
	FROM tblMFProductionSummary S
	JOIN @tblInputItem I ON I.intItemId = S.intItemId
	WHERE S.intWorkOrderId=@intWorkOrderId

	IF @intManufacturingProcessId = 6 --SD process
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblYieldQuantity = dblCountQuantity,dblYieldPercentage=100
		Where intWorkOrderId=@intWorkOrderId
	END
	ELSE
	BEGIN
		UPDATE tblMFProductionSummary
		SET dblYieldQuantity = (dblConsumedQuantity + dblCountQuantity + dblCountConversionQuantity) - (dblOpeningQuantity + dblOpeningConversionQuantity + dblInputQuantity)
			,dblYieldPercentage=(Case When dblInputQuantity>0 Then Round((dblConsumedQuantity + dblCountQuantity + dblCountConversionQuantity) / (dblOpeningQuantity + dblOpeningConversionQuantity + dblInputQuantity)*100,2) else 100 End)
		Where intWorkOrderId=@intWorkOrderId
	END

	DECLARE @intProductionSummaryId INT
		,@dblYieldQuantity INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(MAX)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@dblNewQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intSubLocationId int
		,@intInventoryAdjustmentId int
		,@dblAdjustByQuantity numeric(18,6)
		,@intWeightUOMId int
		,@dblWeightPerQty numeric(18,6)

	SELECT @intProductionSummaryId = Min(intProductionSummaryId)
	FROM tblMFProductionSummary F
	JOIN @tblInputItem I ON I.intItemId = F.intItemId
	Where F.intWorkOrderId=@intWorkOrderId

	WHILE @intProductionSummaryId IS NOT NULL
	BEGIN
		SELECT @intItemId = F.intItemId
			,@dblYieldQuantity = F.dblYieldQuantity
			,@intStorageLocationId = I.intStorageLocationId
		FROM tblMFProductionSummary F
		JOIN @tblInputItem I ON I.intItemId = F.intItemId
		WHERE F.intProductionSummaryId = @intProductionSummaryId

		IF @dblYieldQuantity > 0
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND intItemId = @intItemId
					AND intLotStatusId = 1
					AND dtmExpiryDate > @dtmCurrentDateTime
				)
		BEGIN
			PRINT 'CREATE STAGING LOT'

				--*****************************************************
				--Create staging lot
				--*****************************************************
				DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

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

					SELECT @strLifeTimeType = strLifeTimeType
						,@intLifeTime = intLifeTime
						,@strLotTracking = strLotTracking
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId

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
						,intVendorLocationId
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
						,dblQty = @dblYieldQuantity
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
						,intVendorLocationId = NULL
						,intDetailId = @intWorkOrderId
						,ysnProduced = 1

					EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
						,@intUserId

				END

				--*****************************************************
				--End of create staging lot
				--*****************************************************
		END
		SELECT TOP 1 @strLotNumber = NULL
			,@intLotId = NULL
			,@dblQty = NULL
			,@intItemUOMId = NULL
			,@intSubLocationId=NULL
			,@intWeightUOMId=NULL
			,@dblWeightPerQty=NULL

		SELECT TOP 1 @strLotNumber = strLotNumber
			,@intLotId = intLotId
			,@dblQty = dblQty
			,@intItemUOMId = intItemUOMId
			,@intSubLocationId=intSubLocationId
			,@intWeightUOMId=intWeightUOMId
			,@dblWeightPerQty=dblWeightPerQty
		FROM dbo.tblICLot
		WHERE intStorageLocationId = @intStorageLocationId
			AND intItemId = @intItemId
			AND intLotStatusId = 1
			AND dtmExpiryDate > @dtmCurrentDateTime
			AND dblQty > 0
		ORDER BY dtmDateCreated DESC

		IF @intLotId IS NULL
			--AND @dblYieldQuantity > 0
		BEGIN
			SELECT TOP 1 @strLotNumber = strLotNumber
				,@intLotId = intLotId
				,@dblQty = dblQty
				,@intItemUOMId = intItemUOMId
				,@intSubLocationId=intSubLocationId
				,@intWeightUOMId=intWeightUOMId
				,@dblWeightPerQty=dblWeightPerQty
			FROM dbo.tblICLot
			WHERE intStorageLocationId = @intStorageLocationId
				AND intItemId = @intItemId
				AND intLotStatusId = 1
				AND dtmExpiryDate > @dtmCurrentDateTime
			ORDER BY dtmDateCreated DESC
		END

		IF @intLotId IS NOT NULL
		BEGIN
			IF @dblYieldQuantity < 0
				AND ABS(@dblYieldQuantity) > @dblQty
				SET @dblNewQty = -@dblQty
			ELSE
				SET @dblNewQty = @dblYieldQuantity

			IF @intManufacturingProcessId = 6
				SET @dblQty = -@dblQty+@dblYieldQuantity

			UPDATE dbo.tblMFProcessCycleCount
			SET intLotId = @intLotId
			FROM dbo.tblMFProcessCycleCount CC
			JOIN dbo.tblMFProcessCycleCountSession CS ON CS.intCycleCountSessionId = CC.intCycleCountSessionId
			WHERE CS.intWorkOrderId = @intWorkOrderId
				AND intItemId = @intItemId
				AND (
					dblQuantity > 0
					OR dblSystemQty > 0
					)

			IF @dblQty <> @dblNewQty
				AND @ysnYieldAdjustmentAllowed = 1
			BEGIN
				Select @dblAdjustByQuantity=@dblNewQty/(Case When @intWeightUOMId is null Then 1 Else @dblWeightPerQty End)

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
				PRINT 'Call Adjust Qty procedure'

				IF EXISTS(SELECT *FROM tblICLot Where intLotId=@intLotId and dblQty=0)
				Begin
					UPDATE dbo.tblICLot
					SET intLotStatusId = 3
					WHERE intLotId = @intLotId
				End
			END
		END
		SELECT @intProductionSummaryId = Min(intProductionSummaryId)
		FROM tblMFProductionSummary F
		JOIN @tblInputItem I ON I.intItemId = F.intItemId
		Where intProductionSummaryId>@intProductionSummaryId and F.intWorkOrderId=@intWorkOrderId
	END

	UPDATE dbo.tblMFWorkOrder
	SET intCountStatusId = 13
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFProcessCycleCountSession
	SET dtmSessionEndDateTime = @dtmCurrentDateTime
		,ysnCycleCountCompleted = 1
	WHERE intWorkOrderId = @intWorkOrderId
	
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
