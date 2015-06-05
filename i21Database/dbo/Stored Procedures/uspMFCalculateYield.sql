CREATE PROCEDURE [dbo].[uspMFCalculateYield] @intWorkOrderId INT
	,@ysnYieldAdjustmentAllowed BIT = 1
	,@intUserId INT
AS
BEGIN TRY
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
	DECLARE @tblMFProductionSummary TABLE (
		intWorkOrderId INT NOT NULL
		,intItemId INT NOT NULL
		,intMachineId INT
		,dblOpeningQuantity NUMERIC(18, 6)
		,dblOpeningOutputQuantity NUMERIC(18, 6)
		,dblOpeningConversionQuantity NUMERIC(18, 6)
		,dblInputQuantity NUMERIC(18, 6)
		,dblConsumedQuantity NUMERIC(18, 6)
		,dblOutputQuantity NUMERIC(18, 6)
		,dblOutputConversionQuantity NUMERIC(18, 6)
		,dblCountQuantity NUMERIC(18, 6)
		,dblCountOutputQuantity NUMERIC(18, 6)
		,dblCountConversionQuantity NUMERIC(18, 6)
		,dblCalculatedQuantity NUMERIC(18, 6)
		,dblYieldQuantity NUMERIC(18, 6)
		,dblYieldPercentage NUMERIC(18, 6)
		)
	DECLARE @tblMFProductionSummaryFinal TABLE (
		intProductionSummaryId INT identity(1, 1)
		,intWorkOrderId INT NOT NULL
		,intItemId INT NOT NULL
		,intMachineId INT
		,dblOpeningQuantity NUMERIC(18, 6)
		,dblOpeningOutputQuantity NUMERIC(18, 6)
		,dblOpeningConversionQuantity NUMERIC(18, 6)
		,dblInputQuantity NUMERIC(18, 6)
		,dblConsumedQuantity NUMERIC(18, 6)
		,dblOutputQuantity NUMERIC(18, 6)
		,dblOutputConversionQuantity NUMERIC(18, 6)
		,dblCountQuantity NUMERIC(18, 6)
		,dblCountOutputQuantity NUMERIC(18, 6)
		,dblCountConversionQuantity NUMERIC(18, 6)
		,dblCalculatedQuantity NUMERIC(18, 6)
		,dblYieldQuantity NUMERIC(18, 6)
		,dblYieldPercentage NUMERIC(18, 6)
		)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId = intRecipeId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFRecipe a
	WHERE a.intItemId = @intItemId
		AND a.intLocationId = @intLocationId
		AND ysnActive = 1

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

	INSERT INTO @tblOutputItem (
		intItemId
		,dblCalculatedQuantity
		)
	SELECT ri.intItemId
		,r.dblQuantity--It is product standard qty.
	FROM dbo.tblMFRecipeItem ri
	JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE ri.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 2
		AND ri.ysnConsumptionRequired = 1

	--BEGIN TRAN
	--COMMIT TRAN
	INSERT INTO @tblMFProductionSummary (
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
		,I.intItemId
		,0
		,0
		,0
		,ISNULL(SUM(WC.dblQuantity),0)
		,0
		,0
		,0
		,0
		,0
		,0
		,I.dblCalculatedQuantity
	FROM @tblInputItem I
	LEFT JOIN dbo.tblMFWorkOrderInputLot WC ON WC.intItemId = I.intItemId
		AND WC.intWorkOrderId = @intWorkOrderId
	GROUP BY I.intItemId
		,I.dblCalculatedQuantity

	INSERT INTO @tblMFProductionSummary (
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
		,I.intItemId
		,0
		,0
		,0
		,0
		,ISNULL(SUM(WC.dblQuantity),0)
		,0
		,0
		,0
		,0
		,0
		,I.dblCalculatedQuantity
	FROM @tblInputItem I
	LEFT JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intItemId = I.intItemId
		AND WC.intWorkOrderId = @intWorkOrderId
	GROUP BY I.intItemId
		,I.dblCalculatedQuantity

	INSERT INTO @tblMFProductionSummary (
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
		,I.intItemId
		,0
		,0
		,0
		,0
		,0
		,ISNULL(SUM(WC.dblQuantity),0)
		,0
		,0
		,0
		,0
		,I.dblCalculatedQuantity
	FROM @tblOutputItem I
	LEFT JOIN dbo.tblMFWorkOrderProducedLot WC ON WC.intItemId = I.intItemId
		AND WC.intWorkOrderId = @intWorkOrderId
	GROUP BY I.intItemId
		,I.dblCalculatedQuantity

	INSERT INTO @tblMFProductionSummary (
		intWorkOrderId
		,intItemId
		,intMachineId
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
	SELECT DISTINCT @intWorkOrderId
		,CC.intItemId
		,CC.intMachineId
		,CASE 
			WHEN I.intItemId IS NOT NULL
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
		,CASE 
			WHEN O.intItemId IS NOT NULL
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
		,0
		,0
		,0
		,0
		,0
		,CASE 
			WHEN I.intItemId IS NOT NULL
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
		,CASE 
			WHEN O.intItemId IS NOT NULL
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
		,0
		,Isnull(I.dblCalculatedQuantity, O.dblCalculatedQuantity)
	FROM dbo.tblMFProcessCycleCount AS CC
	JOIN dbo.tblMFProcessCycleCountSession AS CS ON CS.intCycleCountSessionId = CC.intCycleCountSessionId
	LEFT JOIN @tblInputItem AS I ON I.intItemId = CC.intItemId
	LEFT JOIN @tblOutputItem AS O ON O.intItemId = CC.intItemId
	WHERE CS.intWorkOrderId = @intWorkOrderId

	Select *from @tblMFProductionSummary

	INSERT INTO @tblMFProductionSummaryFinal (
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
	SELECT intWorkOrderId
		,intItemId
		,ISNULL(SUM(dblOpeningQuantity),0)
		,ISNULL(SUM(dblOpeningOutputQuantity),0)
		,0
		,ISNULL(SUM(dblInputQuantity),0)
		,ISNULL(SUM(dblConsumedQuantity),0)
		,ISNULL(SUM(dblOutputQuantity),0)
		,0
		,ISNULL(SUM(dblCountQuantity),0)
		,ISNULL(SUM(dblCountOutputQuantity),0)
		,0
		,MIN(dblCalculatedQuantity)
	FROM @tblMFProductionSummary
	GROUP BY intWorkOrderId
		,intItemId

	UPDATE @tblMFProductionSummaryFinal
	SET dblOpeningConversionQuantity = dblOpeningConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblOpeningOutputQuantity / F.dblCalculatedQuantity)
							FROM @tblMFProductionSummaryFinal F
							WHERE F.dblOpeningOutputQuantity > 0
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
		,dblOutputConversionQuantity = dblOutputConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblOutputQuantity / F.dblCalculatedQuantity)
							FROM @tblMFProductionSummaryFinal F
							WHERE F.dblOutputQuantity > 0
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
		,dblCountConversionQuantity = dblCountConversionQuantity + (
			CASE 
				WHEN I.ysnScaled = 1
					THEN ISNULL((
							SELECT SUM(F.dblCountOutputQuantity / F.dblCalculatedQuantity)
							FROM @tblMFProductionSummaryFinal F
							WHERE F.dblCountOutputQuantity > 0
							) * I.dblCalculatedQuantity,0)
				ELSE I.dblCalculatedQuantity
				END
			)
	FROM @tblMFProductionSummaryFinal S
	JOIN @tblInputItem I ON I.intItemId = S.intItemId

	IF @intManufacturingProcessId = 6 --SD process
	BEGIN
		UPDATE @tblMFProductionSummaryFinal
		SET dblYieldQuantity = dblCountQuantity
	END
	ELSE
	BEGIN
		UPDATE @tblMFProductionSummaryFinal
		SET dblYieldQuantity = (dblConsumedQuantity + dblCountQuantity + dblCountConversionQuantity) - (dblOpeningQuantity + dblOpeningConversionQuantity + dblInputQuantity)
	END

	DECLARE @intProductionSummaryId INT
		,@dblYieldQuantity INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(MAX)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@dblNewQty NUMERIC(18, 6)
		,@intItemUOMId INT

	SELECT @intProductionSummaryId = Min(intProductionSummaryId)
	FROM @tblMFProductionSummaryFinal F
	JOIN @tblInputItem I ON I.intItemId = F.intItemId

	WHILE @intProductionSummaryId IS NOT NULL
	BEGIN
		SELECT @intItemId = F.intItemId
			,@dblYieldQuantity = F.dblYieldQuantity
			,@intStorageLocationId = I.intStorageLocationId
		FROM @tblMFProductionSummaryFinal F
		JOIN @tblInputItem I ON I.intItemId = F.intItemId
		WHERE intProductionSummaryId = @intProductionSummaryId

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
		END

		SELECT TOP 1 @strLotNumber = strLotNumber
			,@intLotId = intLotId
			,@dblQty = dblQty
			,@intItemUOMId = intItemUOMId
		FROM dbo.tblICLot
		WHERE intStorageLocationId = @intStorageLocationId
			AND intItemId = @intItemId
			AND intLotStatusId = 1
			AND dtmExpiryDate > @dtmCurrentDateTime
			AND dblQty > 0
		ORDER BY dtmDateCreated DESC

		IF @intLotId IS NULL
			AND @dblYieldQuantity > 0
		BEGIN
			SELECT TOP 1 @strLotNumber = strLotNumber
				,@intLotId = intLotId
				,@dblQty = dblQty
				,@intItemUOMId = intItemUOMId
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
				SET @dblNewQty = 0
			ELSE
				SET @dblNewQty = @dblQty + @dblYieldQuantity

			IF @intManufacturingProcessId = 6
				SET @dblQty = @dblYieldQuantity

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
				PRINT 'Call Adjust Qty procedure'
			END
		END
		SELECT @intProductionSummaryId = Min(intProductionSummaryId)
		FROM @tblMFProductionSummaryFinal F
		JOIN @tblInputItem I ON I.intItemId = F.intItemId
		Where intProductionSummaryId>@intProductionSummaryId
	END

	--UPDATE dbo.tblMFWorkOrder
	--SET intCountStatusId = 13
	--	,dtmLastModified = GETDATE()
	--	,intLastModifiedUserId = @intUserId
	--WHERE intWorkOrderId = @intWorkOrderId

	--UPDATE tblMFProcessCycleCountSession
	--SET dtmSessionEndDateTime = GETDATE()
	--	,ysnCycleCountCompleted = 1
	--WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO dbo.tblMFProductionSummary (
		intWorkOrderId
		,intItemId
		,intMachineId
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
		,dblYieldQuantity
		,dblYieldPercentage
		,intCreatedUserId
		)
	SELECT intWorkOrderId
		,intItemId
		,intMachineId
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
		,dblYieldQuantity
		,dblYieldPercentage
		,@intUserId 
	FROM @tblMFProductionSummaryFinal
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
