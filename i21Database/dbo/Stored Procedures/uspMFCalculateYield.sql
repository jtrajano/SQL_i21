CREATE PROCEDURE [dbo].[uspMFCalculateYield] 
(
	@intWorkOrderId				INT
  , @ysnYieldAdjustmentAllowed	BIT = 1
  , @intUserId					INT
) 
AS
BEGIN TRY
	SET @ysnYieldAdjustmentAllowed = 1

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intItemId						INT
		  , @intRecipeId					INT
		  , @intManufacturingProcessId		INT
		  , @intLocationId					INT
		  , @ErrMsg							NVARCHAR(MAX)
		  , @dtmCurrentDate					DATETIME = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))
		  , @dtmCurrentDateTime				DATETIME = GETDATE()
		  , @intDayOfYear					INT = DATEPART(dy, GETDATE())
		  , @intShiftId						INT
		  , @intManufacturingCellId			INT
		  , @strWorkOrderNo					NVARCHAR(50)
		  , @intProductionStagingId			INT
		  , @intProductionStageLocationId	INT
		  , @intAttributeId					INT
		  , @strAttributeValue				NVARCHAR(50)
		  , @dtmBusinessDate				DATETIME
		  , @intBusinessShiftId				INT
		  , @intPMStageLocationId			INT
		  , @strPMCategoryCode				NVARCHAR(50)
		  , @intPMCategoryId				INT
		  , @strInstantConsumption			NVARCHAR(50)
		  , @strItemNo						NVARCHAR(50)
		  , @strMsg							NVARCHAR(MAX)
		  , @dblWeight						DECIMAL(24, 10)
		  , @intMachineId					INT
		  , @ysnLifeTimeByEndOfMonth		BIT
		  , @intBatchId						INT
		  , @dblTotalProducedQty			NUMERIC(18, 6)
		  , @dblQuantity					NUMERIC(18, 6)
		  , @dblItemYieldQuantity			NUMERIC(18, 6)
		  , @dblRatio						NUMERIC(18, 6)
		  , @dblTotalRatio					NUMERIC(38, 20)
		  , @dblVariance					NUMERIC(38, 20)
		  , @intProductionSummaryId			INT
		  , @dblYieldQuantity				NUMERIC(38, 20)
		  , @intStorageLocationId			INT
		  , @strLotNumber					NVARCHAR(MAX)
		  , @intLotId						INT
		  , @dblQty							NUMERIC(38, 20)
		  , @dblNewQty						NUMERIC(38, 20)
		  , @intItemUOMId					INT
		  , @intInventoryAdjustmentId		INT
		  , @dblAdjustByQuantity			NUMERIC(18, 6)
		  , @intWeightUOMId					INT
		  , @dblWeightPerQty				NUMERIC(18, 6)
		  , @intSubLocationId				INT
		  , @strInventoryTracking			NVARCHAR(50)
		  , @intYieldItemUOMId				INT
		  , @strLifeTimeType				NVARCHAR(50)
		  , @intLifeTime					INT
		  , @dtmExpiryDate					DATETIME
		  , @strLotTracking					NVARCHAR(50)
		  , @intItemLocationId				INT
		  , @intCategoryId					INT
		  , @intWorkOrderProducedLotId		INT
		  , @ysnYieldLoss					BIT
		  , @intConsumedLotId				INT
		  , @ItemsThatNeedLotId 			dbo.ItemLotTableType
		  , @dblOnHand						NUMERIC(18, 6)
		  , @strError						NVARCHAR(MAX)
		  , @strConsumedQuantity			NVARCHAR(50)
		  , @strUpperToleranceQty			NVARCHAR(50)
		  , @strLowerToleranceQty			NVARCHAR(50)
		  , @intInputItemId					INT

	DECLARE @tblMFWorkOrderInputLot TABLE 
	(
		strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	  , intMachineId INT
	);

	DECLARE @tblMFWorkOrderOutputLot TABLE 
	(
		intWorkOrderProducedLotId	INT
	  , dblQuantity					NUMERIC(18, 6)
	  , intItemUOMId				INT
	  , intBatchId					INT
	  , dblRatio					NUMERIC(38, 20)
	);

	DECLARE @tblInputItem TABLE 
	(
		intItemRecordKey		INT IDENTITY(1, 1)
	  , intItemId				INT
	  , dblCalculatedQuantity	NUMERIC(18, 6)
	  , ysnScaled				BIT
	  , intStorageLocationId	INT
	  , ysnSubstituteItem		BIT
	  , intItemUOMId			INT
	  , intMainItemId			INT
	);

	DECLARE @tblOutputItem TABLE 
	(
		intItemRecordKey		INT IDENTITY(1, 1)
	  , intItemId				INT
	  , dblCalculatedQuantity	NUMERIC(18, 6)
	);

	DECLARE @tblMFMachine TABLE 
	(
		intMachineId INT
	);

	DECLARE @tblMFProcessedItem TABLE 
	(
		intItemId INT
	);

	INSERT INTO @tblMFWorkOrderInputLot 
	(
		strLotNumber
	  , intMachineId
	)
	SELECT DISTINCT L.strLotNumber
				  , WI.intMachineId
	FROM dbo.tblICLot L
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intLotId = L.intLotId AND WI.ysnConsumptionReversed = 0
	WHERE WI.intWorkOrderId = @intWorkOrderId

	SELECT @dblTotalProducedQty = SUM(dblOutputQuantity)
	FROM tblMFProductionSummary
	WHERE intWorkOrderId = @intWorkOrderId AND intItemTypeId IN (2, 4)

	INSERT INTO @tblMFWorkOrderOutputLot 
	(
		intWorkOrderProducedLotId
	  , dblQuantity
	  , intItemUOMId
	  , intBatchId
	  , dblRatio
	)
	SELECT intWorkOrderProducedLotId
		,dblQuantity
		,intItemUOMId
		,intBatchId
		,ROUND((dblQuantity / @dblTotalProducedQty) * 100, 0)
	FROM dbo.tblMFWorkOrderProducedLot WP
	WHERE WP.intWorkOrderId = @intWorkOrderId 
	  AND WP.ysnProductionReversed = 0
	  AND WP.intItemTypeId IN (2, 4)

	SELECT @dblTotalRatio = SUM(dblRatio)
	FROM @tblMFWorkOrderOutputLot

	IF @dblTotalRatio <> 100
		BEGIN
			SET @dblVariance = 100 - @dblTotalRatio

			SELECT @intWorkOrderProducedLotId = MAX(intWorkOrderProducedLotId)
			FROM @tblMFWorkOrderOutputLot

			UPDATE @tblMFWorkOrderOutputLot
			SET dblRatio = dblRatio + (@dblVariance)
			WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId
		END

	SELECT @intItemId				= intItemId
		 , @intLocationId			= intLocationId
		 , @intManufacturingCellId	= intManufacturingCellId
		 , @strWorkOrderNo			= strWorkOrderNo
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecipeId					= intRecipeId
		 , @intManufacturingProcessId	= intManufacturingProcessId
	FROM dbo.tblMFWorkOrderRecipe a
	WHERE intWorkOrderId = @intWorkOrderId


	INSERT INTO @tblMFMachine 
	(
		intMachineId
	)
	SELECT intMachineId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
	  AND ysnProductionReversed = 0

	IF NOT EXISTS (SELECT * FROM @tblMFMachine)
		BEGIN
			INSERT INTO @tblMFMachine (intMachineId)
			SELECT intMachineId
			FROM tblMFWorkOrderInputLot
			WHERE intWorkOrderId = @intWorkOrderId
			  AND ysnConsumptionReversed = 0
		END

	IF @intProductionStageLocationId IS NULL
		BEGIN
			SELECT @intProductionStageLocationId = intProductionStagingLocationId
			FROM tblMFManufacturingProcessMachine
			WHERE intManufacturingProcessId = @intManufacturingProcessId
			  AND intMachineId IN (SELECT intMachineId
								   FROM @tblMFMachine)
			  AND intProductionStagingLocationId IS NOT NULL
		END

	IF @intProductionStageLocationId IS NULL
		BEGIN
			SELECT @intProductionStagingId = intAttributeId
			FROM tblMFAttribute
			WHERE strAttributeName = 'Production Staging Location'

			SELECT @intProductionStageLocationId = strAttributeValue
			FROM tblMFManufacturingProcessAttribute
			WHERE intManufacturingProcessId = @intManufacturingProcessId
			  AND intLocationId = @intLocationId
			  AND intAttributeId = @intProductionStagingId
		END

	SELECT @intPMStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
	  AND intLocationId = @intLocationId
	  AND intAttributeId = 90 --PM Production Staging Location

	SELECT @intPMCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 46 --Packaging Category

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Add yield cost to output item'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 20

	INSERT INTO @tblInputItem 
	(
		intItemId
	  , dblCalculatedQuantity
	  , ysnScaled
	  , intStorageLocationId
	  , ysnSubstituteItem
	  , intItemUOMId
	  , intMainItemId
	)
	SELECT ri.intItemId
		 , ri.dblCalculatedQuantity
		 , ri.ysnScaled
		 , CASE WHEN ri.intConsumptionMethodId = 1 THEN (CASE WHEN @intPMCategoryId = intCategoryId THEN @intPMStageLocationId
															  ELSE @intProductionStageLocationId
														 END)
				ELSE ri.intStorageLocationId
		   END
		 , 0
		 , ri.intItemUOMId
		 , ri.intItemId
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	WHERE ri.intWorkOrderId = @intWorkOrderId
	  AND ri.intRecipeItemTypeId = 1
	  AND (
			  (ri.ysnYearValidationRequired = 1 AND @dtmCurrentDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
		   OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo))
		  )
	  AND ri.intConsumptionMethodId <> 4

	INSERT INTO @tblInputItem 
	(
		intItemId
	  , dblCalculatedQuantity
	  , ysnScaled
	  , intStorageLocationId
	  , ysnSubstituteItem
	  , intItemUOMId
	  , intMainItemId
	)
	SELECT rs.intSubstituteItemId
		 , ri.dblCalculatedQuantity
		 , ri.ysnScaled
		 , CASE WHEN ri.intConsumptionMethodId = 1 THEN (CASE WHEN @intPMCategoryId = intCategoryId THEN @intPMStageLocationId 
															  ELSE @intProductionStageLocationId
														 END)
				ELSE ri.intStorageLocationId
		   END
		 , 1
		 , rs.intItemUOMId
		 , rs.intItemId
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId AND rs.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = rs.intSubstituteItemId
	WHERE ri.intWorkOrderId = @intWorkOrderId
	  AND ri.intRecipeItemTypeId = 1
	  AND (
			   (ri.ysnYearValidationRequired = 1 AND @dtmCurrentDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
			OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo))
		  )
	  AND ri.intConsumptionMethodId <> 4

	INSERT INTO @tblOutputItem 
	(
		intItemId
	  , dblCalculatedQuantity
	)
	SELECT ri.intItemId
		 , r.dblQuantity --It is product standard qty.
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId AND r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intWorkOrderId = @intWorkOrderId
	  AND ri.intRecipeItemTypeId = 2

	UPDATE tblMFProductionSummary
	SET dblCalculatedQuantity = I.dblCalculatedQuantity
	FROM tblMFProductionSummary PS
	JOIN @tblInputItem I ON I.intItemId = PS.intItemId

	UPDATE tblMFProductionSummary
	SET dblCalculatedQuantity = O.dblCalculatedQuantity
	FROM tblMFProductionSummary PS
	JOIN @tblOutputItem O ON O.intItemId = PS.intItemId

	
	UPDATE tblMFProductionSummary
	SET dblYieldQuantity	= (dblConsumedQuantity + dblCountQuantity) - (dblOpeningQuantity + dblInputQuantity)
	  , dblYieldPercentage	= (CASE WHEN dblOpeningQuantity > 0 THEN ROUND((dblConsumedQuantity + dblCountQuantity) / (dblOpeningQuantity + dblInputQuantity) * 100, 2)
								    ELSE 100
							   END)
	WHERE intWorkOrderId = @intWorkOrderId

	IF EXISTS (SELECT * 
			  FROM tblMFProductionSummary 
			  WHERE intWorkOrderId = @intWorkOrderId AND intItemTypeId IN (1, 3)
				AND dblYieldQuantity > 0
				AND dblConsumedQuantity - (dblYieldQuantity) < dblLowerToleranceQty
				AND dblRequiredQty <> dblLowerToleranceQty)
		BEGIN
			SELECT @strConsumedQuantity		= dblConsumedQuantity - dblYieldQuantity
				 , @strLowerToleranceQty	= dblLowerToleranceQty
				 , @intInputItemId			= intItemId
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
			  AND intItemTypeId IN (1, 3)
			  AND dblYieldQuantity > 0
			  AND dblConsumedQuantity - dblYieldQuantity < dblLowerToleranceQty

			SELECT @strItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intInputItemId

			SET @strError = 'System is trying to consume ' + [dbo].[fnRemoveTrailingZeroes](@strConsumedQuantity) + ' for the item ' + @strItemNo + ' that is less than the lower tolerance qty of ' + [dbo].[fnRemoveTrailingZeroes](@strLowerToleranceQty) + '. It can consume only within the tolerance limits specified at the recipe level.'

			RAISERROR 
			(
				@strError
			  , 16
			  , 1
			)

			RETURN
		END

	IF EXISTS (SELECT *
			   FROM tblMFProductionSummary
			   WHERE intWorkOrderId = @intWorkOrderId AND intItemTypeId IN (1, 3)
				 AND dblYieldQuantity < 0
				 AND dblConsumedQuantity + ABS(dblYieldQuantity) > dblUpperToleranceQty
				 AND dblRequiredQty <> dblUpperToleranceQty)
		BEGIN
			SELECT @strConsumedQuantity		= dblConsumedQuantity + ABS(dblYieldQuantity)
				 , @strUpperToleranceQty	= dblUpperToleranceQty
				 , @intInputItemId			= intItemId
			FROM tblMFProductionSummary
			WHERE intWorkOrderId = @intWorkOrderId
			  AND intItemTypeId IN (1, 3)
			  AND dblYieldQuantity < 0
			  AND dblConsumedQuantity + ABS(dblYieldQuantity) > dblUpperToleranceQty

			SELECT @strItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intInputItemId

			SET @strError = 'System is trying to consume ' + [dbo].[fnRemoveTrailingZeroes](@strConsumedQuantity) + ' for the item ' + @strItemNo + ' that is more than the upper tolerance qty of ' + [dbo].[fnRemoveTrailingZeroes](@strUpperToleranceQty) + '. It can consume only within the tolerance limits specified at the recipe level.'

			RAISERROR 
			(
				@strError
			  , 16
			  , 1
			)

			RETURN
		END


	SELECT @intProductionSummaryId = MIN(F.intItemId)
	FROM tblMFProductionSummary F
	JOIN @tblInputItem I ON I.intItemId = F.intItemId AND ISNULL(F.intMainItemId, I.intMainItemId) = I.intMainItemId
	WHERE F.intWorkOrderId = @intWorkOrderId
	  AND F.dblYieldQuantity <> 0
	  AND F.intItemTypeId IN (1, 3)

	WHILE @intProductionSummaryId IS NOT NULL
		BEGIN
			SELECT @intItemId				= NULL
				 , @dblYieldQuantity		= NULL
				 , @dblItemYieldQuantity	= NULL
				 , @intStorageLocationId	= NULL
				 , @intMachineId			= NULL
				 , @intYieldItemUOMId		= NULL
				 , @ysnYieldLoss			= NULL

			SELECT @intItemId				= F.intItemId
				 , @dblYieldQuantity		= SUM(ABS(F.dblYieldQuantity))
				 , @dblItemYieldQuantity	= SUM(ABS(F.dblYieldQuantity))
				 , @intStorageLocationId	= ISNULL(F.intStageLocationId, (SELECT TOP 1 I.intStorageLocationId
																			FROM @tblInputItem I
																			WHERE I.intItemId = F.intItemId))
				 , @intMachineId			= F.intMachineId
				 , @intYieldItemUOMId		= (SELECT TOP 1 I.intItemUOMId
											   FROM @tblInputItem I
											   WHERE I.intItemId = F.intItemId)
				 , @ysnYieldLoss			= CASE WHEN SUM(F.dblYieldQuantity) < 0 THEN 1
												   ELSE 0
											  END
			FROM tblMFProductionSummary F
			WHERE F.intItemId = @intProductionSummaryId
			  AND F.dblYieldQuantity < 0
			  AND F.intWorkOrderId = @intWorkOrderId
			GROUP BY F.intItemId
				   , F.intStageLocationId
				   , F.intMachineId

			INSERT INTO @tblMFProcessedItem
			SELECT ISNULL(@intItemId, @intProductionSummaryId)

			IF @strInstantConsumption = 'False'
				BEGIN
					SELECT @strInventoryTracking = strInventoryTracking
					FROM tblICItem
					WHERE intItemId = @intItemId

					SELECT @intItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE intItemId = @intItemId
						AND ysnStockUnit = 1

					IF @strInventoryTracking = 'Item Level'
						BEGIN
							SELECT @intWeightUOMId		= NULL
								 , @intSubLocationId	= NULL
								 , @dblOnHand			= NULL

							SELECT @intWeightUOMId = S.intItemUOMId
								,@intSubLocationId = S.intSubLocationId
								,@dblOnHand = S.dblOnHand - S.dblUnitReserved
							FROM dbo.tblICItemStockUOM S
							JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
								AND S.intItemId = @intItemId
								AND S.dblOnHand - S.dblUnitReserved > 0
							JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
								AND IU.ysnStockUnit = 1
							JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
							WHERE S.intItemId = @intItemId
								AND IL.intLocationId = @intLocationId
								AND S.intStorageLocationId = @intStorageLocationId
								AND S.dblOnHand - S.dblUnitReserved > 0

							IF ISNULL(@dblOnHand, 0) = 0 OR ISNULL(@dblOnHand, 0) < ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intYieldItemUOMId, @intWeightUOMId, @dblYieldQuantity), 0)
								BEGIN
									SELECT @strItemNo = strItemNo
									FROM tblICItem
									WHERE intItemId = @intItemId

									SET @strMsg = 'Unable to pick a lot/pallet to adjust the yield qty for the item ' + @strItemNo

									RAISERROR 
									(
										@strMsg
									  , 16
									  , 1
									)
								END

							SELECT @intShiftId = intShiftId
							FROM dbo.tblMFShift
							WHERE intLocationId = @intLocationId AND CONVERT(CHAR, GETDATE(), 108) BETWEEN dtmShiftStartTime AND dtmShiftEndTime + intEndOffset

							INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction 
							(
								intWorkOrderId
							  , intLotId
							  , dblQuantity
							  , intItemUOMId
							  , intItemId
							  , intTransactionId
							  , intTransactionTypeId
							  , strTransactionType
							  , dtmTransactionDate
							  , intProcessId
							  , intShiftId
							  , intStorageLocationId
							  , intSubLocationId
							)
							SELECT @intWorkOrderId
								 , NULL
								 , dbo.fnMFConvertQuantityToTargetItemUOM(@intYieldItemUOMId, @intWeightUOMId, @dblYieldQuantity)
								 , @intWeightUOMId
								 , @intItemId
								 , @intInventoryAdjustmentId
								 , 25
								 , 'Cycle Count Adj'
								 , GetDate()
								 , @intManufacturingProcessId
								 , @intShiftId
								 , @intStorageLocationId
								 , @intSubLocationId

							PRINT 'Call Adjust Qty procedure'
						END
					ELSE
						BEGIN
							IF @dblYieldQuantity > 0
								AND NOT EXISTS (
									SELECT *
									FROM dbo.tblICLot
									WHERE intStorageLocationId = @intStorageLocationId
										AND intItemId = @intItemId
										AND intLotStatusId = 1
										AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									)
								AND NOT EXISTS (
									SELECT *
									FROM tblMFWorkOrderInputLot
									WHERE intWorkOrderId = @intWorkOrderId
										AND intItemId = @intItemId
									) --and @strAttributeValue='False'
							BEGIN
								PRINT 'CREATE A LOT'

								--*****************************************************
								--Create a lot
								--*****************************************************
								CREATE TABLE #GeneratedLotItems (
									intLotId INT
									,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
									,intDetailId INT
									,intParentLotId INT
									,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
									)

								-- Create and validate the lot numbers
								BEGIN
									SELECT @strLifeTimeType = strLifeTimeType
										,@intLifeTime = intLifeTime
										,@strLotTracking = strLotTracking
										,@intCategoryId = intCategoryId
									FROM dbo.tblICItem
									WHERE intItemId = @intItemId

									SELECT @ysnLifeTimeByEndOfMonth = ysnLifeTimeByEndOfMonth
									FROM tblMFCompanyPreference

									IF @strLifeTimeType = 'Years'
										SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmCurrentDateTime)
									ELSE IF @strLifeTimeType = 'Months'
										AND @ysnLifeTimeByEndOfMonth = 0
										SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)
									ELSE IF @strLifeTimeType = 'Months'
										AND @ysnLifeTimeByEndOfMonth = 1
										SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)) + 1, 0))
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
										SELECT @intSubLocationId = @intSubLocationId
										FROM dbo.tblICStorageLocation
										WHERE intStorageLocationId = @intStorageLocationId

										SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

										SELECT @intBusinessShiftId = intShiftId
										FROM dbo.tblMFShift
										WHERE intLocationId = @intLocationId
											AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
												AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

										EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
											,@intItemId = @intItemId
											,@intManufacturingId = @intManufacturingCellId
											,@intSubLocationId = @intSubLocationId
											,@intLocationId = @intLocationId
											,@intOrderTypeId = NULL
											,@intBlendRequirementId = NULL
											,@intPatternCode = 24
											,@ysnProposed = 0
											,@strPatternString = @strLotNumber OUTPUT
											,@intShiftId = @intBusinessShiftId
									END

									SELECT @intItemUOMId = intItemUOMId
									FROM dbo.tblICItemUOM
									WHERE intItemId = @intItemId
										AND ysnStockUnit = 1

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
										,strTransactionId
										,strSourceTransactionId
										,intSourceTransactionTypeId
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
										,strGarden = NULL
										,intDetailId = @intWorkOrderId
										,ysnProduced = 1
										,strTransactionId = @strWorkOrderNo
										,strSourceTransactionId = @strWorkOrderNo
										,intSourceTransactionTypeId = 8

									EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
										,@intUserId
								END
									--*****************************************************
									--End of create lot
									--*****************************************************
							END

							WHILE @dblYieldQuantity > 0
								BEGIN
									SELECT @strLotNumber		= NULL
										 , @intLotId			= NULL
										 , @dblQty				= NULL
										 , @intItemUOMId		= NULL
										 , @intSubLocationId	= NULL
										 , @intWeightUOMId		= NULL
										 , @dblWeightPerQty		= NULL
										 , @dblNewQty			= NULL

									SELECT TOP 1 @strLotNumber		= L.strLotNumber
											   , @intLotId			= L.intLotId
											   , @intSubLocationId	= L.intSubLocationId
											   , @intWeightUOMId	= ISNULL(L.intWeightUOMId, L.intItemUOMId)
											   , @dblWeight			= dbo.fnMFConvertQuantityToTargetItemUOM
																	  (
																		ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																																		   ELSE L.dblWeight
																																	   END
																	  ) - StockReserved.dblReservedQty
									FROM dbo.tblICLot L
									LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
																	  AND SR.intTransactionId <> @intWorkOrderId
																	  AND SR.strTransactionId <> @strWorkOrderNo
																	  AND ISNULL(ysnPosted, 0) = 0
									OUTER APPLY (SELECT ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0))), 0) AS dblReservedQty
												 FROM tblICStockReservation AS SR
												 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												 WHERE SR.intLotId = L.intLotId 
												   AND SR.intTransactionId <> @intWorkOrderId
												   AND SR.strTransactionId <> @strWorkOrderNo
												   AND ISNULL(ysnPosted, 0) = 0) AS StockReserved
									WHERE L.intStorageLocationId = @intStorageLocationId
									  AND L.intItemId = @intItemId
									  AND L.intLotStatusId = 1
									  AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									  AND 
									  (
										dbo.fnMFConvertQuantityToTargetItemUOM(ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
									  																											  ELSE L.dblWeight
									  																										  END) - StockReserved.dblReservedQty
									  ) - ABS(@dblYieldQuantity) >= 0
									  AND L.strLotNumber IN 
									  (
									  	SELECT WI.strLotNumber
									  	FROM @tblMFWorkOrderInputLot WI
									  	WHERE WI.intMachineId = @intMachineId
									  )
									  AND NOT EXISTS 
									  (
									  	SELECT *
									  	FROM tblMFWorkOrderProducedLotTransaction LT
									  	WHERE LT.intWorkOrderId = @intWorkOrderId AND LT.intLotId = L.intLotId
									  )
									ORDER BY L.dtmDateCreated DESC

									IF @intLotId IS NOT NULL
										BEGIN
											SET @dblNewQty = @dblYieldQuantity;

											SET @dblYieldQuantity = 0;
										END

									IF @intLotId IS NULL
										BEGIN
											SELECT TOP 1 @strLotNumber		= L.strLotNumber
													   , @intLotId			= L.intLotId
													   , @intSubLocationId	= L.intSubLocationId
													   , @intWeightUOMId	= ISNULL(L.intWeightUOMId, L.intItemUOMId)
													   , @dblWeight			= dbo.fnMFConvertQuantityToTargetItemUOM
																			  (
																				ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																																				   ELSE L.dblWeight
																																			   END
																			  ) - StockReserved.dblReservedQty
											FROM dbo.tblICLot L
											LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
																		AND SR.intTransactionId <> @intWorkOrderId
																		AND SR.strTransactionId <> @strWorkOrderNo
																		AND ISNULL(ysnPosted, 0) = 0
											OUTER APPLY (SELECT ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0))), 0) AS dblReservedQty
														 FROM tblICStockReservation AS SR
														 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
														 WHERE SR.intLotId = L.intLotId 
														   AND SR.intTransactionId <> @intWorkOrderId
														   AND SR.strTransactionId <> @strWorkOrderNo
														   AND ISNULL(ysnPosted, 0) = 0) AS StockReserved
											WHERE L.intStorageLocationId = @intStorageLocationId
												AND L.intItemId = @intItemId
												AND L.intLotStatusId = 1
												AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
												AND 
												(
													dbo.fnMFConvertQuantityToTargetItemUOM
													(
														ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																														   ELSE L.dblWeight
																													  END
													) - StockReserved.dblReservedQty
												) > 0
												AND L.strLotNumber IN 
												(
													SELECT WI.strLotNumber
													FROM @tblMFWorkOrderInputLot WI
													WHERE WI.intMachineId = @intMachineId
												)
												AND NOT EXISTS 
												(
													SELECT *
													FROM tblMFWorkOrderProducedLotTransaction LT
													WHERE LT.intWorkOrderId = @intWorkOrderId
														AND LT.intLotId = L.intLotId
												)
											ORDER BY L.dtmDateCreated DESC

											IF @intLotId IS NOT NULL
												BEGIN
													SET @dblNewQty = CASE WHEN @dblYieldQuantity >= @dblWeight THEN @dblWeight
																		  ELSE @dblYieldQuantity
																	 END;

													SET @dblYieldQuantity = @dblYieldQuantity - @dblNewQty;

													IF @dblYieldQuantity < 0.0001
														BEGIN
															SET @dblYieldQuantity = 0;
														END
												END
										END

									IF @intLotId IS NULL
										BEGIN
											SELECT TOP 1 @strLotNumber		= L.strLotNumber
													   , @intLotId			= L.intLotId
													   , @intSubLocationId	= L.intSubLocationId
													   , @intWeightUOMId	= ISNULL(L.intWeightUOMId, L.intItemUOMId)
													   , @dblWeight			= dbo.fnMFConvertQuantityToTargetItemUOM
																			  (
																				ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																																				   ELSE L.dblWeight
																																			   END
																			  ) - StockReserved.dblReservedQty
											FROM dbo.tblICLot L
											LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
																			  AND SR.intTransactionId <> @intWorkOrderId
																			  AND SR.strTransactionId <> @strWorkOrderNo
																			  AND ISNULL(ysnPosted, 0) = 0
											OUTER APPLY (SELECT ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0))), 0) AS dblReservedQty
														 FROM tblICStockReservation AS SR
														 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
														 WHERE SR.intLotId = L.intLotId 
														   AND SR.intTransactionId <> @intWorkOrderId
														   AND SR.strTransactionId <> @strWorkOrderNo
														   AND ISNULL(ysnPosted, 0) = 0) AS StockReserved
											WHERE L.intStorageLocationId = @intStorageLocationId
											  AND L.intItemId = @intItemId
											  AND L.intLotStatusId = 1
											  AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
											  AND 
											  (
												dbo.fnMFConvertQuantityToTargetItemUOM
												(
													ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																													   ELSE L.dblWeight
																												  END
												) - StockReserved.dblReservedQty
											  ) - ABS(@dblYieldQuantity) >= 0
											  AND NOT EXISTS 
											  (
												SELECT *
												FROM tblMFWorkOrderProducedLotTransaction LT
												WHERE LT.intWorkOrderId = @intWorkOrderId AND LT.intLotId = L.intLotId
											  )
											ORDER BY L.dtmDateCreated DESC

											IF @intLotId IS NOT NULL
												BEGIN
													SET @dblNewQty = @dblYieldQuantity;

													SET @dblYieldQuantity = 0;
												END
										END

									IF @intLotId IS NULL
										BEGIN
											SELECT TOP 1 @strLotNumber		= L.strLotNumber
													   , @intLotId			= L.intLotId
													   , @intSubLocationId	= L.intSubLocationId
													   , @intWeightUOMId	= ISNULL(L.intWeightUOMId, L.intItemUOMId)
													   , @dblWeight			= dbo.fnMFConvertQuantityToTargetItemUOM
																			  (
																				ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																																				   ELSE L.dblWeight
																																			   END
																			  ) - StockReserved.dblReservedQty
											FROM dbo.tblICLot L
											LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
																		AND SR.intTransactionId <> @intWorkOrderId
																		AND SR.strTransactionId <> @strWorkOrderNo
																		AND ISNULL(ysnPosted, 0) = 0
											OUTER APPLY (SELECT ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0))), 0) AS dblReservedQty
														 FROM tblICStockReservation AS SR
														 JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
														 WHERE SR.intLotId = L.intLotId 
														   AND SR.intTransactionId <> @intWorkOrderId
														   AND SR.strTransactionId <> @strWorkOrderNo
														   AND ISNULL(ysnPosted, 0) = 0) AS StockReserved
											WHERE L.intStorageLocationId = @intStorageLocationId
												AND L.intItemId = @intItemId
												AND L.intLotStatusId = 1
												AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
												AND 
												(
													dbo.fnMFConvertQuantityToTargetItemUOM
													(
														ISNULL(L.intWeightUOMId, L.intItemUOMId), @intYieldItemUOMId, CASE WHEN L.intWeightUOMId IS NULL THEN L.dblQty
																														   ELSE L.dblWeight
																													  END
													) - StockReserved.dblReservedQty
												) > 0
												AND NOT EXISTS 
												(
													SELECT *
													FROM tblMFWorkOrderProducedLotTransaction LT
													WHERE LT.intWorkOrderId = @intWorkOrderId AND LT.intLotId = L.intLotId
												)
											ORDER BY L.dtmDateCreated DESC

											IF @intLotId IS NOT NULL
												BEGIN
													SELECT @dblNewQty = CASE WHEN @dblYieldQuantity >= @dblWeight THEN @dblWeight
																			 ELSE @dblYieldQuantity
																		END

													SELECT @dblYieldQuantity = @dblYieldQuantity - @dblNewQty

													IF @dblYieldQuantity < 0.0001
														BEGIN
															SELECT @dblYieldQuantity = 0;
														END
												END
										END

									IF @intLotId IS NULL
										BEGIN
											SELECT @strItemNo = strItemNo
											FROM tblICItem
											WHERE intItemId = @intItemId

											SELECT @strMsg = 'Unable to pick a lot/pallet to adjust the yield qty for the item ' + @strItemNo

											RAISERROR 
											(
												@strMsg
											  , 16
											  ,1
											)

											RETURN
										END

									IF @intLotId IS NOT NULL
									BEGIN
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

										IF @ysnYieldAdjustmentAllowed = 1
											AND @dblNewQty <> 0
										BEGIN
											IF (@strAttributeValue = 'False')
												--OR (
												--	@strAttributeValue = 'True'
												--	AND @strInstantConsumption = 'True'
												--	)
											BEGIN
												EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
													-- Parameters for filtering:
													@intItemId = @intItemId
													,@dtmDate = @dtmCurrentDateTime
													,@intLocationId = @intLocationId
													,@intSubLocationId = @intSubLocationId
													,@intStorageLocationId = @intStorageLocationId
													,@strLotNumber = @strLotNumber
													-- Parameters for the new values: 
													,@dblAdjustByQuantity = @dblNewQty
													,@dblNewUnitCost = NULL
													,@intItemUOMId = @intWeightUOMId
													-- Parameters used for linking or FK (foreign key) relationships
													,@intSourceId = 1
													,@intSourceTransactionTypeId = 8
													,@intEntityUserSecurityId = @intUserId
													,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
											END

											SELECT @intShiftId = intShiftId
											FROM dbo.tblMFShift
											WHERE intLocationId = @intLocationId
												AND Convert(CHAR, GetDate(), 108) BETWEEN dtmShiftStartTime
													AND dtmShiftEndTime + intEndOffset

											INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction (
												intWorkOrderId
												,intLotId
												,dblQuantity
												,intItemUOMId
												,intItemId
												,intTransactionId
												,intTransactionTypeId
												,strTransactionType
												,dtmTransactionDate
												,intProcessId
												,intShiftId
												)
											SELECT @intWorkOrderId
												,@intLotId
												,dbo.fnMFConvertQuantityToTargetItemUOM(@intYieldItemUOMId, @intWeightUOMId, @dblNewQty)
												,@intWeightUOMId
												,@intItemId
												,@intInventoryAdjustmentId
												,25
												,'Cycle Count Adj'
												,GetDate()
												,@intManufacturingProcessId
												,@intShiftId

											PRINT 'Call Adjust Qty procedure'
										END
									END
								END
						END
				END
			ELSE
			BEGIN -- This is for Instant consumption turn on
				SELECT @strInventoryTracking = strInventoryTracking
				FROM tblICItem
				WHERE intItemId = @intItemId

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND ysnStockUnit = 1

				SELECT @intWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
				FROM @tblMFWorkOrderOutputLot

				WHILE @intWorkOrderProducedLotId IS NOT NULL
				BEGIN
					SELECT @intBatchId = NULL
						,@dblQuantity = NULL
						,@dblRatio = NULL

					SELECT @intBatchId = intBatchId
						--,@dblQuantity = dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId, @intYieldItemUOMId, dblQuantity)
						,@dblQuantity = dblQuantity
						,@dblRatio = dblRatio
					FROM @tblMFWorkOrderOutputLot
					WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId

					SELECT @dblYieldQuantity = @dblRatio / 100 * @dblItemYieldQuantity

					IF @strInventoryTracking = 'Item Level'
					BEGIN
						IF @dblYieldQuantity > 0
						BEGIN
							SELECT @dblYieldQuantity = - @dblYieldQuantity

							SELECT @intSubLocationId = NULL

							SELECT @intSubLocationId = intSubLocationId
							FROM tblICStorageLocation
							WHERE intStorageLocationId = @intStorageLocationId

							EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
								-- Parameters for filtering:
								@intItemId = @intItemId
								,@dtmDate = @dtmCurrentDateTime
								,@intLocationId = @intLocationId
								,@intSubLocationId = @intSubLocationId
								,@intStorageLocationId = @intStorageLocationId
								,@strLotNumber = NULL
								-- Parameters for the new values: 
								,@dblAdjustByQuantity = @dblYieldQuantity
								,@dblNewUnitCost = NULL
								,@intItemUOMId = @intItemUOMId
								-- Parameters used for linking or FK (foreign key) relationships
								,@intSourceId = 1
								,@intSourceTransactionTypeId = 8
								,@intEntityUserSecurityId = @intUserId
								,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
						END
					END
					ELSE
					BEGIN
						IF @dblYieldQuantity > 0
							AND NOT EXISTS (
								SELECT *
								FROM dbo.tblICLot
								WHERE intStorageLocationId = @intStorageLocationId
									AND intItemId = @intItemId
									AND intLotStatusId = 1
									AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
								)
							AND NOT EXISTS (
								SELECT *
								FROM tblMFWorkOrderInputLot
								WHERE intWorkOrderId = @intWorkOrderId
									AND intItemId = @intItemId
								) --and @strAttributeValue='False'
						BEGIN
							PRINT 'CREATE A LOT'

							--*****************************************************
							--Create a lot
							--*****************************************************
							CREATE TABLE #GeneratedLotItems1 (
								intLotId INT
								,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
								,intDetailId INT
								,intParentLotId INT
								,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
								)

							-- Create and validate the lot numbers
							BEGIN
								SELECT @strLifeTimeType = strLifeTimeType
									,@intLifeTime = intLifeTime
									,@strLotTracking = strLotTracking
									,@intCategoryId = intCategoryId
								FROM dbo.tblICItem
								WHERE intItemId = @intItemId

								SELECT @ysnLifeTimeByEndOfMonth = ysnLifeTimeByEndOfMonth
								FROM tblMFCompanyPreference

								IF @strLifeTimeType = 'Years'
									SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmCurrentDateTime)
								ELSE IF @strLifeTimeType = 'Months'
									AND @ysnLifeTimeByEndOfMonth = 0
									SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)
								ELSE IF @strLifeTimeType = 'Months'
									AND @ysnLifeTimeByEndOfMonth = 1
									SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, @dtmCurrentDateTime)) + 1, 0))
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
									SELECT @intSubLocationId = @intSubLocationId
									FROM dbo.tblICStorageLocation
									WHERE intStorageLocationId = @intStorageLocationId

									SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

									SELECT @intBusinessShiftId = intShiftId
									FROM dbo.tblMFShift
									WHERE intLocationId = @intLocationId
										AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
											AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

									EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
										,@intItemId = @intItemId
										,@intManufacturingId = @intManufacturingCellId
										,@intSubLocationId = @intSubLocationId
										,@intLocationId = @intLocationId
										,@intOrderTypeId = NULL
										,@intBlendRequirementId = NULL
										,@intPatternCode = 24
										,@ysnProposed = 0
										,@strPatternString = @strLotNumber OUTPUT
										,@intShiftId = @intBusinessShiftId
								END

								SELECT @intItemUOMId = intItemUOMId
								FROM dbo.tblICItemUOM
								WHERE intItemId = @intItemId
									AND ysnStockUnit = 1

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
									,strTransactionId
									,strSourceTransactionId
									,intSourceTransactionTypeId
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
									,strGarden = NULL
									,intDetailId = @intWorkOrderId
									,ysnProduced = 1
									,strTransactionId = @strWorkOrderNo
									,strSourceTransactionId = @strWorkOrderNo
									,intSourceTransactionTypeId = 8

								EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
									,@intUserId
							END
								--*****************************************************
								--End of create lot
								--*****************************************************
						END

						WHILE @dblYieldQuantity > 0
						BEGIN
							SELECT @strLotNumber = NULL
								,@intLotId = NULL
								,@dblQty = NULL
								,@intItemUOMId = NULL
								,@intSubLocationId = NULL
								,@intWeightUOMId = NULL
								,@dblWeightPerQty = NULL
								,@dblNewQty = NULL
								,@intConsumedLotId = NULL

							IF @ysnYieldLoss = 0
							BEGIN
								SELECT @intLotId = WC.intLotId
									,@intWeightUOMId = intItemUOMId
									,@dblWeight = dblQuantity
								FROM tblMFWorkOrderConsumedLot WC
								WHERE intWorkOrderId = @intWorkOrderId
									AND intBatchId = @intBatchId
									AND NOT EXISTS (
										SELECT *
										FROM tblMFWorkOrderProducedLotTransaction LT
										WHERE LT.intWorkOrderId = @intWorkOrderId
											AND LT.intBatchId = @intBatchId
											AND LT.intLotId = WC.intLotId
										)

								SELECT @dblNewQty = CASE 
										WHEN @dblYieldQuantity >= @dblWeight
											THEN @dblWeight
										ELSE @dblYieldQuantity
										END

								SELECT @dblYieldQuantity = @dblYieldQuantity - @dblNewQty
							END
							ELSE
							BEGIN
								SELECT TOP 1 @strLotNumber = L.strLotNumber
									,@intLotId = L.intLotId
									,@intSubLocationId = L.intSubLocationId
									,@intWeightUOMId = @intYieldItemUOMId
									,@dblWeight = (
										(
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0) - ISNULL((
												SELECT SUM(dblQuantity)
												FROM tblMFWorkOrderProducedLotTransaction LT
												WHERE LT.intWorkOrderId = @intWorkOrderId
													AND LT.intLotId = L.intLotId
												), 0)
										)
								FROM dbo.tblICLot L
								LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
									AND SR.intTransactionId <> @intWorkOrderId
									AND SR.strTransactionId <> @strWorkOrderNo
									AND ISNULL(ysnPosted, 0) = 0
								WHERE L.intStorageLocationId = @intStorageLocationId
									AND L.intItemId = @intItemId
									AND L.intLotStatusId = 1
									AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									AND (
										(
											--@intYieldItemUOMId
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0)
										) - ISNULL((
											SELECT SUM(dblQuantity)
											FROM tblMFWorkOrderProducedLotTransaction LT
											WHERE LT.intWorkOrderId = @intWorkOrderId
												AND LT.intLotId = L.intLotId
											), 0) - abs(@dblYieldQuantity) >= 0
									AND L.strLotNumber IN (
										SELECT WI.strLotNumber
										FROM @tblMFWorkOrderInputLot WI
										WHERE IsNULL(WI.intMachineId, @intMachineId) = @intMachineId
										)
								ORDER BY L.dtmDateCreated DESC

								IF @intLotId IS NOT NULL
								BEGIN
									SELECT @dblNewQty = @dblYieldQuantity

									SELECT @dblYieldQuantity = 0
								END
							END

							IF @intLotId IS NULL
							BEGIN
								SELECT TOP 1 @strLotNumber = L.strLotNumber
									,@intLotId = L.intLotId
									,@intSubLocationId = L.intSubLocationId
									,@intWeightUOMId = @intYieldItemUOMId
									,@dblWeight = (
										(
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0) - ISNULL((
												SELECT SUM(dblQuantity)
												FROM tblMFWorkOrderProducedLotTransaction LT
												WHERE LT.intWorkOrderId = @intWorkOrderId
													AND LT.intLotId = L.intLotId
												), 0)
										)
								FROM dbo.tblICLot L
								LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
									AND SR.intTransactionId <> @intWorkOrderId
									AND SR.strTransactionId <> @strWorkOrderNo
									AND ISNULL(ysnPosted, 0) = 0
								WHERE L.intStorageLocationId = @intStorageLocationId
									AND L.intItemId = @intItemId
									AND L.intLotStatusId = 1
									AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									AND (
										(
											--@intYieldItemUOMId
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0)
										) - ISNULL((
											SELECT SUM(dblQuantity)
											FROM tblMFWorkOrderProducedLotTransaction LT
											WHERE LT.intWorkOrderId = @intWorkOrderId
												AND LT.intLotId = L.intLotId
											), 0) >= 0
									AND L.strLotNumber IN (
										SELECT WI.strLotNumber
										FROM @tblMFWorkOrderInputLot WI
										WHERE IsNULL(WI.intMachineId, @intMachineId) = @intMachineId
										)
								ORDER BY L.dtmDateCreated DESC

								IF @intLotId IS NOT NULL
								BEGIN
									SELECT @dblNewQty = CASE 
											WHEN @dblYieldQuantity >= @dblWeight
												THEN @dblWeight
											ELSE @dblYieldQuantity
											END

									SELECT @dblYieldQuantity = @dblYieldQuantity - @dblNewQty

									IF @dblYieldQuantity < 0.0001
										SELECT @dblYieldQuantity = 0
								END
							END

							IF @intLotId IS NULL
							BEGIN
								SELECT TOP 1 @strLotNumber = L.strLotNumber
									,@intLotId = L.intLotId
									,@intSubLocationId = L.intSubLocationId
									,@intWeightUOMId = @intYieldItemUOMId
									,@dblWeight = (
										(
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0) - ISNULL((
												SELECT SUM(dblQuantity)
												FROM tblMFWorkOrderProducedLotTransaction LT
												WHERE LT.intWorkOrderId = @intWorkOrderId
													AND LT.intLotId = L.intLotId
												), 0)
										)
								FROM dbo.tblICLot L
								LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
									AND SR.intTransactionId <> @intWorkOrderId
									AND SR.strTransactionId <> @strWorkOrderNo
									AND ISNULL(ysnPosted, 0) = 0
								WHERE L.intStorageLocationId = @intStorageLocationId
									AND L.intItemId = @intItemId
									AND L.intLotStatusId = 1
									AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									AND (
										(
											--@intYieldItemUOMId
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0)
										) - ISNULL((
											SELECT SUM(dblQuantity)
											FROM tblMFWorkOrderProducedLotTransaction LT
											WHERE LT.intWorkOrderId = @intWorkOrderId
												AND LT.intLotId = L.intLotId
											), 0) - abs(@dblYieldQuantity) >= 0
								ORDER BY L.dtmDateCreated DESC

								IF @intLotId IS NOT NULL
								BEGIN
									SELECT @dblNewQty = @dblYieldQuantity

									SELECT @dblYieldQuantity = 0
								END
							END

							IF @intLotId IS NULL
							BEGIN
								SELECT TOP 1 @strLotNumber = L.strLotNumber
									,@intLotId = L.intLotId
									,@intSubLocationId = L.intSubLocationId
									,@intWeightUOMId = @intYieldItemUOMId
									,@dblWeight = (
										(
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0) - ISNULL((
												SELECT SUM(dblQuantity)
												FROM tblMFWorkOrderProducedLotTransaction LT
												WHERE LT.intWorkOrderId = @intWorkOrderId
													AND LT.intLotId = L.intLotId
												), 0)
										)
								FROM dbo.tblICLot L
								LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
									AND SR.intTransactionId <> @intWorkOrderId
									AND SR.strTransactionId <> @strWorkOrderNo
									AND ISNULL(ysnPosted, 0) = 0
								WHERE L.intStorageLocationId = @intStorageLocationId
									AND L.intItemId = @intItemId
									AND L.intLotStatusId = 1
									AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
									AND (
										(
											--@intYieldItemUOMId
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intYieldItemUOMId, L.dblQty)
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, @intYieldItemUOMId, L.dblWeight)
												END
											) - ISNULL((
												SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, @intYieldItemUOMId, ISNULL(SR.dblQty, 0)))
												FROM tblICStockReservation SR
												JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
												WHERE SR.intLotId = L.intLotId
													AND SR.intTransactionId <> @intWorkOrderId
													AND SR.strTransactionId <> @strWorkOrderNo
													AND ISNULL(ysnPosted, 0) = 0
												), 0)
										) - ISNULL((
											SELECT SUM(dblQuantity)
											FROM tblMFWorkOrderProducedLotTransaction LT
											WHERE LT.intWorkOrderId = @intWorkOrderId
												AND LT.intLotId = L.intLotId
											), 0) >= 0
								ORDER BY L.dtmDateCreated DESC

								IF @intLotId IS NOT NULL
								BEGIN
									SELECT @dblNewQty = CASE 
											WHEN @dblYieldQuantity >= @dblWeight
												THEN @dblWeight
											ELSE @dblYieldQuantity
											END

									SELECT @dblYieldQuantity = @dblYieldQuantity - @dblNewQty
								END
							END

							IF @intLotId IS NULL
							BEGIN
								SELECT @strItemNo = strItemNo
								FROM tblICItem
								WHERE intItemId = @intItemId

								SELECT @strMsg = 'Unable to pick a lot/pallet to adjust the yield qty for the item ' + @strItemNo

								RAISERROR (
										@strMsg
										,16
										,1
										)

								RETURN
							END

							IF @intLotId IS NOT NULL
							BEGIN
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

								IF @ysnYieldAdjustmentAllowed = 1
									AND @dblNewQty <> 0
								BEGIN
									IF (@strAttributeValue = 'False')
										--OR (
										--	@strAttributeValue = 'True'
										--	AND @strInstantConsumption = 'True'
										--	)
									BEGIN
										EXEC [uspICInventoryAdjustment_CreatePostQtyChange]
											-- Parameters for filtering:
											@intItemId = @intItemId
											,@dtmDate = @dtmCurrentDateTime
											,@intLocationId = @intLocationId
											,@intSubLocationId = @intSubLocationId
											,@intStorageLocationId = @intStorageLocationId
											,@strLotNumber = @strLotNumber
											-- Parameters for the new values: 
											,@dblAdjustByQuantity = @dblNewQty
											,@dblNewUnitCost = NULL
											,@intItemUOMId = @intWeightUOMId
											-- Parameters used for linking or FK (foreign key) relationships
											,@intSourceId = 1
											,@intSourceTransactionTypeId = 8
											,@intEntityUserSecurityId = @intUserId
											,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
									END

									SELECT @intShiftId = intShiftId
									FROM dbo.tblMFShift
									WHERE intLocationId = @intLocationId
										AND Convert(CHAR, GetDate(), 108) BETWEEN dtmShiftStartTime
											AND dtmShiftEndTime + intEndOffset

									INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction (
										intWorkOrderId
										,intLotId
										,dblQuantity
										,intItemUOMId
										,intItemId
										,intTransactionId
										,intTransactionTypeId
										,strTransactionType
										,dtmTransactionDate
										,intProcessId
										,intShiftId
										,intBatchId
										)
									SELECT @intWorkOrderId
										,@intLotId
										,CASE 
											WHEN @ysnYieldLoss = 1
												THEN (dbo.fnMFConvertQuantityToTargetItemUOM(@intYieldItemUOMId, @intWeightUOMId, @dblNewQty))
											ELSE - (dbo.fnMFConvertQuantityToTargetItemUOM(@intYieldItemUOMId, @intWeightUOMId, @dblNewQty))
											END
										,@intWeightUOMId
										,@intItemId
										,@intInventoryAdjustmentId
										,25
										,'Cycle Count Adj'
										,GetDate()
										,@intManufacturingProcessId
										,@intShiftId
										,@intBatchId

									PRINT 'Call Adjust Qty procedure'
								END
							END
						END
					END

					SELECT @intWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
					FROM @tblMFWorkOrderOutputLot
					WHERE intWorkOrderProducedLotId > @intWorkOrderProducedLotId
				END
			END

			SELECT @intProductionSummaryId = Min(F.intItemId)
			FROM tblMFProductionSummary F
			JOIN @tblInputItem I ON I.intItemId = F.intItemId
				AND IsNULL(F.intMainItemId, I.intMainItemId) = I.intMainItemId
			WHERE F.intItemId > @intProductionSummaryId
				AND F.intWorkOrderId = @intWorkOrderId
				AND F.dblYieldQuantity < 0
				AND I.intItemId NOT IN (
					SELECT I1.intItemId
					FROM @tblMFProcessedItem I1
					)
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
