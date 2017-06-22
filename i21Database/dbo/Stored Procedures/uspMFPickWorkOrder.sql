CREATE PROCEDURE [dbo].[uspMFPickWorkOrder] @intWorkOrderId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMId INT = NULL
	,@intUserId INT
	,@intBatchId INT
	,@strPickPreference NVARCHAR(50) = ''
	,@ysnExcessConsumptionAllowed BIT = 0
	,@dblUnitQty NUMERIC(38, 20)
	,@ysnProducedQtyByWeight BIT = 1
	,@ysnFillPartialPallet BIT = 0
	,@dblProducePartialQty NUMERIC(38, 20) = 0
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
		,@intItemRecordId INT
		,@intLotRecordId INT
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
		,@intManufacturingCellId INT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intInputItemId INT
		,@strReqQty NVARCHAR(50)
		,@strQty NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strLotTracking NVARCHAR(50)
		,@strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate DATETIME
		,@intItemLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intItemUOMId INT
		,@intSubLocationId INT
		,@intCategoryId INT
		,@intItemIssuedUOMId INT
		,@intStorageLocationId1 NUMERIC(18, 6)
		,@intRecipeItemUOMId INT
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT
		,@dblLowerToleranceReqQty NUMERIC(18, 6)
		,@intLotItemId INT
		,@intPMCategoryId INT
		,@intPMStageLocationId INT

	Declare @tblMFWorkOrderInputLot table (strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS)

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@strWorkOrderNo = strWorkOrderNo
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO @tblMFWorkOrderInputLot(strLotNumber)
	Select L.strLotNumber 
	from dbo.tblICLot L 
	JOIN dbo.tblMFWorkOrderInputLot WI on WI.intLotId=L.intLotId and ysnConsumptionReversed =0
	Where WI.intWorkOrderId=@intWorkOrderId

	DECLARE @tblMFMachine TABLE (intMachineId INT)

	INSERT INTO @tblMFMachine (intMachineId)
	SELECT intMachineId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFMachine
			)
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
			AND intMachineId IN (
				SELECT intMachineId
				FROM @tblMFMachine
				)
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
		AND intAttributeId = 90 --PM Staging Location

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

	SELECT @intPMCategoryId = intCategoryId
	FROM tblICCategory
	WHERE strCategoryCode = @strPackagingCategory

	IF @intTransactionCount = 0
		BEGIN TRAN

	DECLARE @tblItem TABLE (
		intItemRecordId INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		,intConsumptionMethodId INT
		,strLotTracking NVARCHAR(50)
		,dblLowerToleranceReqQty NUMERIC(18, 6)
		)
	DECLARE @tblSubstituteItem TABLE (
		intItemRecordId INT Identity(1, 1)
		,intItemId INT
		,intSubstituteItemId INT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
		)
	DECLARE @tblLot TABLE (
		intLotRecordId INT Identity(1, 1)
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
		,intStorageLocationId INT
		,intSubLocationId INT
		)

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @intRecipeId = intRecipeId
	FROM dbo.tblMFWorkOrderRecipe a
	WHERE intWorkOrderId = @intWorkOrderId

	DELETE
	FROM tblICStockReservation
	WHERE intTransactionId = @intWorkOrderId
		AND strTransactionId = @strWorkOrderNo

	UPDATE WC
	SET intBatchId = @intBatchId
	FROM tblMFWorkOrderConsumedLot WC
	JOIN tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = WC.intWorkOrderId
		AND WP.intSpecialPalletLotId = WC.intLotId
	WHERE WC.intWorkOrderId = @intWorkOrderId
		AND intSpecialPalletLotId IS NOT NULL
		AND WC.intBatchId IS NULL

	INSERT INTO @tblItem (
		intItemId
		,dblReqQty
		,intItemUOMId
		,intStorageLocationId
		,intConsumptionMethodId
		,strLotTracking
		,dblLowerToleranceReqQty
		)
	SELECT ri.intItemId
		,CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				AND @ysnProducedQtyByWeight = 1
				AND P.dblMaxWeightPerPack > 0
				THEN (
						CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
									WHEN ri.ysnPartialFillConsumption = 1
										THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
									ELSE 0
									END) AS NUMERIC(38, 20))
						)
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + CASE 
								WHEN ri.ysnPartialFillConsumption = 1
									THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
								ELSE 0
								END) AS NUMERIC(38, 20))
			ELSE (
					ri.dblCalculatedQuantity * (
						dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
							CASE 
								WHEN r.intRecipeTypeId = 1
									THEN r.dblQuantity
								ELSE 1
								END
							)
						) + CASE 
						WHEN ri.ysnPartialFillConsumption = 1
							THEN ri.dblCalculatedQuantity * (
									dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
										CASE 
											WHEN r.intRecipeTypeId = 1
												THEN r.dblQuantity
											ELSE 1
											END
										)
									)
						ELSE 0
						END
					)
			END AS RequiredQty
		,ri.intItemUOMId
		,ri.intStorageLocationId
		,ri.intConsumptionMethodId
		,I.strLotTracking
		,CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				AND @ysnProducedQtyByWeight = 1
				AND P.dblMaxWeightPerPack > 0
				THEN (
						CAST(CEILING((ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
									WHEN ri.ysnPartialFillConsumption = 1
										THEN (ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
									ELSE 0
									END) AS NUMERIC(38, 20))
						)
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN CAST(CEILING((ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + CASE 
								WHEN ri.ysnPartialFillConsumption = 1
									THEN (ri.dblCalculatedLowerTolerance * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
								ELSE 0
								END) AS NUMERIC(38, 20))
			ELSE (
					ri.dblCalculatedLowerTolerance * (
						dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
							CASE 
								WHEN r.intRecipeTypeId = 1
									THEN r.dblQuantity
								ELSE 1
								END
							)
						) + CASE 
						WHEN ri.ysnPartialFillConsumption = 1
							THEN ri.dblCalculatedLowerTolerance * (
									dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
										CASE 
											WHEN r.intRecipeTypeId = 1
												THEN r.dblQuantity
											ELSE 1
											END
										)
									)
						ELSE 0
						END
					)
			END
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
		AND ri.intConsumptionMethodId <> 4
		--AND ri.ysnPartialFillConsumption = (
		--	CASE 
		--		WHEN @ysnFillPartialPallet = 1
		--			THEN 1
		--		ELSE ri.ysnPartialFillConsumption
		--		END
		--	)
		AND NOT EXISTS (
			SELECT 1
			FROM dbo.tblMFWorkOrderConsumedLot WC
			JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON WC.intWorkOrderId = SI.intWorkOrderId
				AND WC.intWorkOrderId = @intWorkOrderId
				AND IsNull(WC.intBatchId, @intBatchId) = @intBatchId
				AND WC.intItemId = SI.intSubstituteItemId
				AND SI.intItemId = ri.intItemId
			--AND @ysnFillPartialPallet = 0
			
			UNION
			
			SELECT 1
			FROM dbo.tblMFWorkOrderConsumedLot WC
			WHERE WC.intWorkOrderId = @intWorkOrderId
				AND IsNull(WC.intBatchId, @intBatchId) = @intBatchId
				AND WC.intItemId = ri.intItemId
			)
	--AND @ysnFillPartialPallet = 0
	
	UNION
	
	SELECT ri.intItemId
		,(
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND @ysnProducedQtyByWeight = 1
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
										WHEN ri.ysnPartialFillConsumption = 1
											THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))
										ELSE 0
										END) AS NUMERIC(38, 20))
							)
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + CASE 
									WHEN ri.ysnPartialFillConsumption = 1
										THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
									ELSE 0
									END) AS NUMERIC(38, 20))
				ELSE (
						ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							) + CASE 
							WHEN ri.ysnPartialFillConsumption = 1
								THEN ri.dblCalculatedQuantity * (
										dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
											CASE 
												WHEN r.intRecipeTypeId = 1
													THEN r.dblQuantity
												ELSE 1
												END
											)
										)
							ELSE 0
							END
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio AS RequiredQty
		,IU.intItemUOMId
		,ri.intStorageLocationId
		,ri.intConsumptionMethodId
		,I.strLotTracking
		,(
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND @ysnProducedQtyByWeight = 1
					AND P.dblMaxWeightPerPack > 0
					THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) + CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (
						ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							) + ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							)
						)
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio AS RequiredQty
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
		AND rs.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intWorkOrderId = rs.intWorkOrderId
		AND IsNull(WC.intBatchId, @intBatchId) = @intBatchId
		AND WC.intItemId = rs.intSubstituteItemId
		AND rs.intItemId = ri.intItemId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = rs.intSubstituteItemId
		AND IU.intUnitMeasureId = IU1.intUnitMeasureId
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
		AND ri.intConsumptionMethodId <> 4
		--AND ri.ysnPartialFillConsumption = (
		--CASE 
		--	WHEN @ysnFillPartialPallet = 1
		--		THEN 1
		--	ELSE ri.ysnPartialFillConsumption
		--	END
		--)
		AND (
			CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN (CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack)))) + (CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / P.dblMaxWeightPerPack))))
				ELSE (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity)) + (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProducePartialQty) / r.dblQuantity))
				END
			) - WC.dblQuantity / rs.dblSubstituteRatio > 0

	IF @strPickPreference = 'Substitute Item'
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
			AND ri.intConsumptionMethodId <> 4
			AND ri.ysnPartialFillConsumption = (
				CASE 
					WHEN @ysnFillPartialPallet = 1
						THEN 1
					ELSE ri.ysnPartialFillConsumption
					END
				)
	END

	SELECT @intItemRecordId = Min(intItemRecordId)
	FROM @tblItem

	WHILE (@intItemRecordId IS NOT NULL)
	BEGIN
		SET @intLotRecordId = NULL

		SELECT @intItemId = intItemId
			,@dblReqQty = dblReqQty
			,@intRecipeItemUOMId = intItemUOMId
			,@intStorageLocationId = intStorageLocationId
			,@intConsumptionMethodId = intConsumptionMethodId
			,@strLotTracking = strLotTracking
			,@dblLowerToleranceReqQty = dblLowerToleranceReqQty
		FROM @tblItem
		WHERE intItemRecordId = @intItemRecordId

		DELETE
		FROM @tblLot

		IF @strLotTracking = 'No'
		BEGIN
			INSERT INTO @tblLot (
				intItemId
				,dblQty
				,dblIssuedQuantity
				,dblWeightPerUnit
				,intItemUOMId
				,intItemIssuedUOMId
				,ysnSubstituteItem
				,intStorageLocationId
				,intSubLocationId
				)
			SELECT S.intItemId
				,S.dblOnHand - S.dblUnitReserved AS dblQty
				,S.dblOnHand - S.dblUnitReserved AS dblIssuedQuantity
				,1 AS dblWeightPerUnit
				,S.intItemUOMId
				,S.intItemUOMId
				,0 AS ysnSubstituteItem
				,S.intStorageLocationId
				,SL.intSubLocationId
			FROM dbo.tblICItemStockUOM S
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
				AND SL.ysnAllowConsume = 1
			JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
				AND IU.ysnStockUnit = 1
			WHERE S.intItemId = @intItemId
				AND IL.intLocationId = @intLocationId
				AND (
					S.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intProductionStageLocationId, S.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, S.intStorageLocationId)
							ELSE S.intStorageLocationId
							END
						)
					OR S.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intPMStageLocationId, S.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, S.intStorageLocationId)
							ELSE S.intStorageLocationId
							END
						)
					)
				AND S.dblOnHand - S.dblUnitReserved > 0
		END
		ELSE
		BEGIN
			IF @strPickPreference = 'Substitute Item'
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
					,intStorageLocationId
					,intSubLocationId
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
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0)
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
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0) / (
						CASE 
							WHEN L.dblWeightPerQty = 0
								OR L.dblWeightPerQty IS NULL
								THEN 1
							ELSE L.dblWeightPerQty
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
					,L.intStorageLocationId
					,L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE SI.intItemId = @intItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND (
						L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						OR L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						)
					AND L.dblQty > 0
					AND L.strLotNumber IN (Select WI.strLotNumber 
										from @tblMFWorkOrderInputLot WI)
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
						END ASC
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
					,intStorageLocationId
					,intSubLocationId
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
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0)
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
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0) / (
						CASE 
							WHEN L.dblWeightPerQty = 0
								OR L.dblWeightPerQty IS NULL
								THEN 1
							ELSE L.dblWeightPerQty
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
					,L.intStorageLocationId
					,L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				JOIN @tblSubstituteItem SI ON L.intItemId = SI.intSubstituteItemId
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE SI.intItemId = @intItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND (
						L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						OR L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						)
					AND L.dblQty > 0
					AND L.strLotNumber Not IN (Select WI.strLotNumber 
										from @tblMFWorkOrderInputLot WI)
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
						END ASC
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
				,intStorageLocationId
				,intSubLocationId
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
					) - ISNULL((
						SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
						FROM tblICStockReservation SR
						JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
						WHERE SR.intLotId = L.intLotId
							AND SR.intTransactionId <> @intWorkOrderId
							AND SR.strTransactionId <> @strWorkOrderNo
							AND ISNULL(ysnPosted, 0) = 0
						), 0)
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
					) - ISNULL((
						SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
						FROM tblICStockReservation SR
						JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
						WHERE SR.intLotId = L.intLotId
							AND SR.intTransactionId <> @intWorkOrderId
							AND SR.strTransactionId <> @strWorkOrderNo
							AND ISNULL(ysnPosted, 0) = 0
						), 0) / (
					CASE 
						WHEN L.dblWeightPerQty = 0
							OR L.dblWeightPerQty IS NULL
							THEN 1
						ELSE L.dblWeightPerQty
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
				,L.intStorageLocationId
				,L.intSubLocationId
			FROM dbo.tblICLot L
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				AND SL.ysnAllowConsume = 1
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
			JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
				AND BS.strPrimaryStatus = 'Active'
			JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			WHERE L.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus = 'Active'
				AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				AND (
					L.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
							ELSE L.intStorageLocationId
							END
						)
					OR L.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intPMStageLocationId, L.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
							ELSE L.intStorageLocationId
							END
						)
					)
				AND L.dblQty > 0
				AND L.strLotNumber IN (Select WI.strLotNumber 
										from @tblMFWorkOrderInputLot WI)
			ORDER BY CASE 
					WHEN @ysnPickByLotCode = 0
						THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
					END ASC

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
				,intStorageLocationId
				,intSubLocationId
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
					) - ISNULL((
						SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
						FROM tblICStockReservation SR
						JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
						WHERE SR.intLotId = L.intLotId
							AND SR.intTransactionId <> @intWorkOrderId
							AND SR.strTransactionId <> @strWorkOrderNo
							AND ISNULL(ysnPosted, 0) = 0
						), 0)
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
					) - ISNULL((
						SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
						FROM tblICStockReservation SR
						JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
						WHERE SR.intLotId = L.intLotId
							AND SR.intTransactionId <> @intWorkOrderId
							AND SR.strTransactionId <> @strWorkOrderNo
							AND ISNULL(ysnPosted, 0) = 0
						), 0) / (
					CASE 
						WHEN L.dblWeightPerQty = 0
							OR L.dblWeightPerQty IS NULL
							THEN 1
						ELSE L.dblWeightPerQty
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
				,L.intStorageLocationId
				,L.intSubLocationId
			FROM dbo.tblICLot L
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				AND SL.ysnAllowConsume = 1
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
			JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
				AND BS.strPrimaryStatus = 'Active'
			JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			WHERE L.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus = 'Active'
				AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				AND (
					L.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
							ELSE L.intStorageLocationId
							END
						)
					OR L.intStorageLocationId = (
						CASE 
							WHEN @intConsumptionMethodId = 1
								THEN ISNULL(@intPMStageLocationId, L.intStorageLocationId)
							WHEN @intConsumptionMethodId = 2
								THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
							ELSE L.intStorageLocationId
							END
						)
					)
				AND L.dblQty > 0
				AND L.strLotNumber Not IN (Select WI.strLotNumber 
										from @tblMFWorkOrderInputLot WI)
			ORDER BY CASE 
					WHEN @ysnPickByLotCode = 0
						THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
					END ASC

			IF NOT EXISTS (
					SELECT *
					FROM @tblLot
					)
				AND @ysnExcessConsumptionAllowed = 1
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
					,intStorageLocationId
					,intSubLocationId
					)
				SELECT TOP 1 L.strLotNumber
					,L.intLotId
					,L.intItemId
					,(
						CASE 
							WHEN intWeightUOMId IS NOT NULL
								THEN dblWeight
							ELSE dblQty
							END
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0)
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
						) - ISNULL((
							SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
							FROM tblICStockReservation SR
							JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
							WHERE SR.intLotId = L.intLotId
								AND SR.intTransactionId <> @intWorkOrderId
								AND SR.strTransactionId <> @strWorkOrderNo
								AND ISNULL(ysnPosted, 0) = 0
							), 0) / (
						CASE 
							WHEN L.dblWeightPerQty = 0
								OR L.dblWeightPerQty IS NULL
								THEN 1
							ELSE L.dblWeightPerQty
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
					,L.intStorageLocationId
					,L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intItemId = @intItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND (
						L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						OR L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intPMStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						)
					AND L.dblQty = 0
				ORDER BY IsNULL(L.dtmManufacturedDate, L.dtmDateCreated) DESC

				IF EXISTS (
						SELECT *
						FROM @tblLot
						)
				BEGIN
					SELECT @strLotNumber = strLotNumber
						,@intWeightUOMId = intItemUOMId
						,@dblWeightPerQty = dblWeightPerUnit
						,@intStorageLocationId1 = intStorageLocationId
						,@intItemIssuedUOMId = intItemIssuedUOMId
					FROM @tblLot

					SELECT @dblAdjustByQuantity = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intWeightUOMId, @dblReqQty)

					IF @intConsumptionMethodId = 2
					BEGIN
						SELECT @intSubLocationId = intSubLocationId
						FROM tblICStorageLocation
						WHERE intStorageLocationId = @intStorageLocationId
					END
					ELSE
					BEGIN
						SELECT @intStorageLocationId = intStorageLocationId
							,@intSubLocationId = intSubLocationId
						FROM tblICLot
						WHERE strLotNumber = @strLotNumber
							AND intStorageLocationId = @intStorageLocationId1
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
						,@intItemUOMId = @intItemIssuedUOMId
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intEntityUserSecurityId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

					UPDATE @tblLot
					SET dblQty = dblQty + (
							@dblAdjustByQuantity * (
								CASE 
									WHEN @dblWeightPerQty IS NULL
										OR @dblWeightPerQty = 0
										THEN 1
									ELSE @dblWeightPerQty
									END
								)
							)
						,dblIssuedQuantity = dblIssuedQuantity + @dblAdjustByQuantity
				END
			END

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
				SELECT @strLifeTimeType = strLifeTimeType
					,@intLifeTime = intLifeTime
					,@strLotTracking = strLotTracking
					,@intCategoryId = intCategoryId
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
					SELECT @intSubLocationId = @intSubLocationId
					FROM dbo.tblICStorageLocation
					WHERE intStorageLocationId = @intStorageLocationId

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
					,dblQty = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
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

				SELECT TOP 1 @intLotId = intLotId
				FROM #GeneratedLotItems
				WHERE intDetailId = @intWorkOrderId

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
					,intStorageLocationId
					,intSubLocationId
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
					,L.intStorageLocationId
					,L.intSubLocationId
				FROM dbo.tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intItemId = @intItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND (
						L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intProductionStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						OR L.intStorageLocationId = (
							CASE 
								WHEN @intConsumptionMethodId = 1
									THEN ISNULL(@intPMStageLocationId, L.intStorageLocationId)
								WHEN @intConsumptionMethodId = 2
									THEN ISNULL(@intStorageLocationId, L.intStorageLocationId)
								ELSE L.intStorageLocationId
								END
							)
						)
					AND L.dblQty > 0
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE CONVERT(INT, Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits))
						END ASC
			END
		END

		IF EXISTS (
				SELECT SUM(dblQty)
				FROM @tblLot
				HAVING SUM(dblQty) < (
						CASE 
							WHEN (
									SELECT Count(*)
									FROM @tblLot
									WHERE ysnSubstituteItem = 1
									) >= 1
								THEN @dblLowerToleranceReqQty
							ELSE [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, MIN(intItemUOMId), @dblLowerToleranceReqQty)
							END
						)
				)
		BEGIN
			IF @ysnExcessConsumptionAllowed = 0
			BEGIN
				SELECT @strQty = CONVERT(DECIMAL(24, 4), SUM(dblQty))
				FROM @tblLot

				SELECT @strReqQty = CONVERT(DECIMAL(24, 4), @dblReqQty)

				SELECT @strItemNo = strItemNo
				FROM dbo.tblICItem
				WHERE intItemId = @intItemId

				DECLARE @intUnitMeasureId INT
					,@strUnitMeasure NVARCHAR(50)

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM dbo.tblICItemUOM
				WHERE intItemUOMId = @intRecipeItemUOMId

				SELECT @strUnitMeasure = ' ' + strUnitMeasure
				FROM dbo.tblICUnitMeasure
				WHERE intUnitMeasureId = @intUnitMeasureId

				RAISERROR (
						'Item %s is having %s%s quantity which is less than the required quantity %s%s.'
						,11
						,1
						,@strItemNo
						,@strQty
						,@strUnitMeasure
						,@strReqQty
						,@strUnitMeasure
						)
			END
		END

		SELECT @intLotRecordId = Min(intLotRecordId)
		FROM @tblLot
		WHERE dblQty > 0

		WHILE (@intLotRecordId IS NOT NULL)
		BEGIN
			SELECT @intLotId = NULL
				,@intLotItemId = NULL
				,@dblQty = NULL
				,@ysnSubstituteItem = NULL
				,@dblMaxSubstituteRatio = NULL
				,@dblSubstituteRatio = NULL
				,@intItemUOMId = NULL
				,@intItemIssuedUOMId = NULL

			SELECT @intLotId = intLotId
				,@intLotItemId = intItemId
				,@dblQty = dblQty
				,@ysnSubstituteItem = ysnSubstituteItem
				,@dblMaxSubstituteRatio = dblMaxSubstituteRatio
				,@dblSubstituteRatio = dblSubstituteRatio
				,@intItemUOMId = intItemUOMId
				,@intItemIssuedUOMId = intItemIssuedUOMId
			FROM @tblLot
			WHERE intLotRecordId = @intLotRecordId

			IF @ysnSubstituteItem = 1
			BEGIN
				SELECT @dblReqQty = @dblReqQty * (@dblMaxSubstituteRatio / 100) * @dblSubstituteRatio

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICItemUOM
				WHERE intItemUOMId = @intRecipeItemUOMId

				SELECT @intRecipeItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intLotItemId
					AND intUnitMeasureId = @intUnitMeasureId
			END

			IF EXISTS (
					SELECT SUM(dblQty)
					FROM @tblLot
					HAVING SUM(dblQty) < (
							CASE 
								WHEN @ysnSubstituteItem = 0
									THEN [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, MIN(intItemUOMId), @dblLowerToleranceReqQty)
								ELSE @dblLowerToleranceReqQty
								END
							)
					)
			BEGIN
				IF @ysnExcessConsumptionAllowed = 1
				BEGIN
					SELECT @dblAdjustByQuantity = [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, MIN(intItemUOMId), @dblReqQty) - SUM(dblQty)
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
						@intItemId = @intLotItemId
						,@dtmDate = @dtmCurrentDateTime
						,@intLocationId = @intLocationId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber
						-- Parameters for the new values: 
						,@dblAdjustByQuantity = @dblAdjustByQuantity
						,@dblNewUnitCost = NULL
						,@intItemUOMId = @intItemIssuedUOMId
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = 1
						,@intSourceTransactionTypeId = 8
						,@intEntityUserSecurityId = @intUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

					SELECT @dblQty = @dblQty + @dblAdjustByQuantity * (
							CASE 
								WHEN @dblWeightPerQty IS NULL
									OR @dblWeightPerQty = 0
									THEN 1
								ELSE @dblWeightPerQty
								END
							)
				END
			END

			SELECT @intSequenceNo = Max(intSequenceNo) + 1
			FROM dbo.tblMFWorkOrderConsumedLot
			WHERE intWorkOrderId = @intWorkOrderId

			IF (@dblQty >= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty))
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
					,intShiftId
					,dtmActualInputDateTime
					,intStorageLocationId
					,intSubLocationId
					)
				SELECT @intWorkOrderId
					,@intLotItemId
					,intLotId
					,[dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
					,intItemUOMId
					,[dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty) / (
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
					,@intBusinessShiftId
					,@dtmBusinessDate
					,intStorageLocationId
					,intSubLocationId
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF NOT EXISTS (
						SELECT *
						FROM tblMFProductionSummary
						WHERE intWorkOrderId = @intWorkOrderId
							AND intItemId = @intLotItemId
							AND intItemTypeId IN (
								1
								,3
								)
						)
				BEGIN
					SELECT @intCategoryId = intCategoryId
					FROM tblICItem
					WHERE intItemId = @intLotItemId

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
						,intCategoryId
						,intItemTypeId
						)
					SELECT @intWorkOrderId
						,@intLotItemId
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
						,@intCategoryId
						,CASE 
							WHEN @ysnSubstituteItem = 1
								THEN 3
							ELSE 1
							END
				END
				ELSE
				BEGIN
					UPDATE tblMFProductionSummary
					SET dblConsumedQuantity = dblConsumedQuantity + @dblReqQty
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemId = @intLotItemId
						AND intItemTypeId IN (
							1
							,3
							)
				END

				UPDATE @tblLot
				SET dblQty = dblQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intItemUOMId, @dblReqQty)
				WHERE intLotRecordId = @intLotRecordId

				IF @ysnSubstituteItem = 1
					AND @dblMaxSubstituteRatio <> 100
				BEGIN
					SELECT @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) * (100 - @dblMaxSubstituteRatio) / 100

					SELECT @dblLowerToleranceReqQty = (@dblLowerToleranceReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) * (100 - @dblMaxSubstituteRatio) / 100
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
					,intShiftId
					,dtmActualInputDateTime
					,intStorageLocationId
					,intSubLocationId
					)
				SELECT @intWorkOrderId
					,@intLotItemId
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
					,@intBusinessShiftId
					,@dtmBusinessDate
					,intStorageLocationId
					,intSubLocationId
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF NOT EXISTS (
						SELECT *
						FROM tblMFProductionSummary
						WHERE intWorkOrderId = @intWorkOrderId
							AND intItemId = @intLotItemId
							AND intItemTypeId IN (
								1
								,3
								)
						)
				BEGIN
					SELECT @intCategoryId = intCategoryId
					FROM tblICItem
					WHERE intItemId = @intLotItemId

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
						,intCategoryId
						,intItemTypeId
						)
					SELECT @intWorkOrderId
						,@intLotItemId
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
						,@intCategoryId
						,CASE 
							WHEN @ysnSubstituteItem = 1
								THEN 3
							ELSE 1
							END
				END
				ELSE
				BEGIN
					UPDATE tblMFProductionSummary
					SET dblConsumedQuantity = dblConsumedQuantity + @dblQty
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemId = @intLotItemId
						AND intItemTypeId IN (
							1
							,3
							)
				END

				UPDATE @tblLot
				SET dblQty = 0
				WHERE intLotRecordId = @intLotRecordId

				IF @ysnSubstituteItem = 1
				BEGIN
					SELECT @dblReqQty = (@dblReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) - (@dblQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio)

					SELECT @dblLowerToleranceReqQty = (@dblLowerToleranceReqQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio) - (@dblQty / @dblSubstituteRatio * 100 / @dblMaxSubstituteRatio)
				END
				ELSE
				BEGIN
					SELECT @dblReqQty = @dblReqQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)

					SELECT @dblLowerToleranceReqQty = @dblLowerToleranceReqQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRecipeItemUOMId, @dblQty)
				END
			END

			SELECT @intLotRecordId = Min(intLotRecordId)
			FROM @tblLot
			WHERE dblQty > 0
				AND intLotRecordId > @intLotRecordId
		END

		NextItem:

		SELECT @intItemRecordId = Min(intItemRecordId)
		FROM @tblItem
		WHERE intItemRecordId > @intItemRecordId
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
				AND ri.ysnPartialFillConsumption = (
					CASE 
						WHEN @ysnFillPartialPallet = 1
							THEN 1
						ELSE ri.ysnPartialFillConsumption
						END
					)
				AND NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrderConsumedLot WC
					WHERE (
							WC.intItemId = ri.intItemId
							OR WC.intItemId in (Select SI.intSubstituteItemId From dbo.tblMFWorkOrderRecipeSubstituteItem SI Where SI.intRecipeItemId = ri.intRecipeItemId
				AND SI.intWorkOrderId = ri.intWorkOrderId
				AND SI.intRecipeId = ri.intRecipeId
							))
						AND WC.intWorkOrderId = @intWorkOrderId
						AND IsNULL(WC.intBatchId, @intBatchId) = @intBatchId
					)
			)
	BEGIN
		SELECT @intInputItemId = ri.intItemId
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
			AND ri.intConsumptionMethodId <> 4
			AND NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderConsumedLot WC
				WHERE (
						WC.intItemId = ri.intItemId
						OR WC.intItemId in (Select SI.intSubstituteItemId From dbo.tblMFWorkOrderRecipeSubstituteItem SI Where SI.intRecipeItemId = ri.intRecipeItemId
				AND SI.intWorkOrderId = ri.intWorkOrderId
				AND SI.intRecipeId = ri.intRecipeId
						))
					AND WC.intWorkOrderId = @intWorkOrderId
					AND IsNULL(WC.intBatchId, @intBatchId) = @intBatchId
				)

		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intInputItemId

		RAISERROR (
				'The input lots for the item %s are expired / inactive / unavailable. Cannot produce.'
				,11
				,1
				,@strItemNo
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
