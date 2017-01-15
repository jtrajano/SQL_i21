﻿CREATE PROCEDURE [dbo].uspMFStartCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intSubLocationId INT
		,@intWorkOrderId INT
		,@intManufacturingProcessId INT
		,@dtmPlannedDate DATETIME
		,@intItemId INT
		,@intUserId INT
		,@intCycleCountSessionId INT
		,@ysnIncludeOutputItem BIT
		,@strExcludeItemType NVARCHAR(MAX)
		,@strWorkOrderNo NVARCHAR(MAX)
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@TRANCOUNT INT
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT

	SELECT @TRANCOUNT = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intUserId = intUserId
		,@intWorkOrderId = intWorkOrderId
		,@ysnIncludeOutputItem = ysnIncludeOutputItem
		,@strExcludeItemType = strExcludeItemType
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intSubLocationId INT
			,intUserId INT
			,intWorkOrderId INT
			,ysnIncludeOutputItem BIT
			,strExcludeItemType NVARCHAR(MAX)
			)

	DECLARE @intUserSecurityID INT
		,@dtmSessionStartDateTime DATETIME
		,@strSessionStartDateTime NVARCHAR(50)
		,@dtmShiftStartTime DATETIME
		,@dtmPlannedDateTime DATETIME
		,@intPlannedShiftId INT
		,@intStartOffset INT
		,@strUserName NVARCHAR(50)
		,@intPriorWorkOrderId INT
		,@strPriorWorkOrderNo NVARCHAR(50)
		,@strProductItem NVARCHAR(50)
		,@strInputItem NVARCHAR(50)
		,@strPlannedDate NVARCHAR(50)

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
				AND intCountStatusId = 13
			)
	BEGIN
		RAISERROR (
				51108
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		SELECT @intUserSecurityID = intUserId
			,@strSessionStartDateTime = dtmSessionStartDateTime
		FROM dbo.tblMFProcessCycleCountSession
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strUserName = strUserName
		FROM dbo.tblSMUserSecurity
		WHERE [intEntityUserSecurityId] = @intUserSecurityID

		RAISERROR (
				51109
				,11
				,1
				,@strSessionStartDateTime
				,@strUserName
				)
	END

	SELECT @dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@dtmPlannedDateTime = (
			CASE 
				WHEN intPlannedShiftId IS NOT NULL
					THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
				ELSE dtmPlannedDate
				END
			)
		,@intItemId = intItemId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intWorkOrderId = @intWorkOrderId

	IF @dtmPlannedDateTime > @dtmCurrentDateTime
	BEGIN
		RAISERROR (
				51102
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFManufacturingProcessMachine PM
			JOIN dbo.tblMFMachine M ON M.intMachineId = PM.intMachineId
			WHERE PM.intManufacturingProcessId = @intManufacturingProcessId
				AND M.ysnCycleCounted = 1
			)
	BEGIN
		RAISERROR (
				51103
				,11
				,1
				)
	END

	IF NOT EXISTS (
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
			)
	BEGIN
		RAISERROR (
				51104
				,11
				,1
				)
	END

	SELECT TOP 1 @intPriorWorkOrderId = intWorkOrderId
		,@strPriorWorkOrderNo = strWorkOrderNo
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intItemId = @intItemId
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND intStatusId <> 13
		AND (
			CASE 
				WHEN intPlannedShiftId IS NOT NULL
					THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
				ELSE dtmPlannedDate
				END
			) < @dtmPlannedDateTime
		AND intWorkOrderId <> @intWorkOrderId
	ORDER BY CASE 
			WHEN intPlannedShiftId IS NOT NULL
				THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
			ELSE dtmPlannedDate
			END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intPriorWorkOrderId
			)
		AND @intPriorWorkOrderId IS NOT NULL
	BEGIN
		RAISERROR (
				51105
				,11
				,1
				,@strPriorWorkOrderNo
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
			JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
			JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intItemId = CC.intItemId
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
				AND intCountStatusId <> 13
				AND intStatusId <> 13
			)
	BEGIN
		SELECT TOP 1 @strWorkOrderNo = strWorkOrderNo
			,@strProductItem = Product.strItemNo + ' - ' + Product.strDescription
			,@strInputItem = Input.strItemNo + ' - ' + Input.strDescription
			,@strPlannedDate = ltrim(W.dtmPlannedDate) + (
				CASE 
					WHEN W.intPlannedShiftId IS NULL
						THEN ''
					ELSE ' - ' + S.strShiftName
					END
				)
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
		JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
		JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intItemId = CC.intItemId
		JOIN dbo.tblICItem Product ON Product.intItemId = W.intItemId
		JOIN dbo.tblICItem Input ON Input.intItemId = ri.intItemId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
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
			AND intCountStatusId <> 13
			AND intStatusId <> 13
		ORDER BY W.dtmPlannedDate DESC
			,W.intPlannedShiftId DESC

		RAISERROR (
				51106
				,11
				,1
				,@strInputItem
				,@strWorkOrderNo
				,@strPlannedDate
				,@strProductItem
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
			JOIN dbo.tblMFWorkOrderRecipe Product ON Product.intItemId = W.intItemId
			JOIN dbo.tblMFWorkOrderRecipeItem ProductItem ON ProductItem.intRecipeId = Product.intRecipeId
				AND ProductItem.intWorkOrderId = Product.intWorkOrderId
			JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intItemId = ProductItem.intItemId
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
				AND intCountStatusId <> 13
				AND intStatusId <> 13
				AND (
					CASE 
						WHEN intPlannedShiftId IS NOT NULL
							THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
						ELSE dtmPlannedDate
						END
					) < @dtmPlannedDateTime
				AND W.intWorkOrderId <> @intWorkOrderId
			)
	BEGIN
		SELECT TOP 1 @strProductItem = Product.strItemNo + ' - ' + Product.strDescription
			,@strInputItem = Input.strItemNo + ' - ' + Input.strDescription
			,@strPlannedDate = ltrim(W.dtmPlannedDate) + (
				CASE 
					WHEN W.intPlannedShiftId IS NULL
						THEN ''
					ELSE ' - ' + S.strShiftName
					END
				)
			,@strWorkOrderNo = strWorkOrderNo
		FROM dbo.tblMFWorkOrder W
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
		JOIN dbo.tblMFWorkOrderRecipe P ON P.intItemId = W.intItemId
		JOIN dbo.tblMFWorkOrderRecipeItem PI ON PI.intRecipeId = P.intRecipeId
			AND PI.intWorkOrderId = P.intWorkOrderId
		JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intItemId = PI.intItemId
		JOIN dbo.tblICItem Product ON Product.intItemId = W.intItemId
		JOIN dbo.tblICItem Input ON Input.intItemId = PI.intItemId
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
			AND intCountStatusId <> 13
			AND intStatusId <> 13
			AND (
				CASE 
					WHEN intPlannedShiftId IS NOT NULL
						THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
					ELSE dtmPlannedDate
					END
				) < @dtmPlannedDateTime
			AND W.intWorkOrderId <> @intWorkOrderId

		RAISERROR (
				51107
				,11
				,1
				,@strProductItem
				,@strWorkOrderNo
				,@strPlannedDate
				,@strInputItem
				)
	END

	DECLARE @tblICItem TABLE (
		intItemId INT
		,intConsumptionMethodId INT
		,intStorageLocationId INT
		,dblRequiredQty NUMERIC(38, 20)
		,ysnMainItem BIT
		,intItemUOMId INT
		,intCategoryId INT
		)
	DECLARE @tblICFinalItem TABLE (
		intItemId INT
		,intConsumptionMethodId INT
		,intStorageLocationId INT
		,dblRequiredQty NUMERIC(38, 20)
		,ysnMainItem BIT
		,intItemUOMId INT
		,intCategoryId INT
		)
	DECLARE @dblProduceQty NUMERIC(38, 20)
		,@intProduceUOMId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPackagingCategoryId INT

	SELECT @dblProduceQty = SUM(dblPhysicalCount)
		,@intProduceUOMId = MIN(intPhysicalItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot WP
	WHERE WP.intWorkOrderId = @intWorkOrderId
		AND WP.ysnProductionReversed = 0
		AND WP.ysnFillPartialPallet = 0
		AND WP.intItemId IN (
			SELECT intItemId
			FROM dbo.tblMFWorkOrderRecipeItem
			WHERE intRecipeItemTypeId = 2
				AND ysnConsumptionRequired = 1
				AND intWorkOrderId = @intWorkOrderId
			)

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	IF @dblProduceQty IS NOT NULL
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,intConsumptionMethodId
			,intStorageLocationId
			,dblRequiredQty
			,ysnMainItem
			,intItemUOMId
			,intCategoryId
			)
		SELECT ri.intItemId
			,ri.intConsumptionMethodId
			,ri.intStorageLocationId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND P.dblMaxWeightPerPack > 0
					THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (
						ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							)
						)
				END AS RequiredQty
			,1 AS ysnMainItem
			,ri.intItemUOMId
			,I.intCategoryId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		WHERE ri.intWorkOrderId = @intWorkOrderId
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
			AND ri.intRecipeItemTypeId = 1
			AND ri.intConsumptionMethodId IN (
				1
				,2
				)
		
		UNION
		
		SELECT RSI.intSubstituteItemId
			,RI.intConsumptionMethodId
			,RI.intStorageLocationId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					AND P.dblMaxWeightPerPack > 0
					THEN (CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (
						RI.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							)
						)
				END AS RequiredQty
			,0 AS ysnMainItem
			,IU.intItemUOMId
			,I.intCategoryId
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
			AND RI.intWorkOrderId = RSI.intWorkOrderId
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = RI.intRecipeId
			AND r.intWorkOrderId = RI.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = RSI.intItemUOMId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = RSI.intSubstituteItemId
			AND IU.intUnitMeasureId = IU1.intUnitMeasureId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND (
				(
					RI.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN RI.dtmValidFrom
						AND RI.dtmValidTo
					)
				OR (
					RI.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, RI.dtmValidFrom)
						AND DATEPART(dy, RI.dtmValidTo)
					)
				)
			AND RI.intRecipeItemTypeId = 1
			AND RI.intConsumptionMethodId IN (
				1
				,2
				)
	END

	SELECT @dblProduceQty = NULL
		,@intProduceUOMId = NULL

	SELECT @dblProduceQty = SUM(dblPhysicalCount)
		,@intProduceUOMId = MIN(intPhysicalItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot WP
	WHERE WP.intWorkOrderId = @intWorkOrderId
		AND WP.ysnProductionReversed = 0
		AND WP.ysnFillPartialPallet = 1
		AND WP.intItemId IN (
			SELECT intItemId
			FROM dbo.tblMFWorkOrderRecipeItem
			WHERE intRecipeItemTypeId = 2
				AND ysnConsumptionRequired = 1
				AND intWorkOrderId = @intWorkOrderId
			)

	IF @dblProduceQty IS NOT NULL
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,intConsumptionMethodId
			,intStorageLocationId
			,dblRequiredQty
			,ysnMainItem
			,intItemUOMId
			,intCategoryId
			)
		SELECT ri.intItemId
			,ri.intConsumptionMethodId
			,ri.intStorageLocationId
			,CASE 
				WHEN ri.ysnPartialFillConsumption = 0
					THEN 0
				ELSE (
						CASE 
							WHEN C.strCategoryCode = @strPackagingCategory
								AND P.dblMaxWeightPerPack > 0
								THEN (CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
							WHEN C.strCategoryCode = @strPackagingCategory
								THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) AS NUMERIC(38, 20))
							ELSE (
									ri.dblCalculatedQuantity * (
										(
											CASE 
												WHEN @intProduceUOMId = r.intItemUOMId
													THEN @dblProduceQty
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty)
												END
											) / (
											CASE 
												WHEN r.intRecipeTypeId = 1
													THEN r.dblQuantity
												ELSE 1
												END
											)
										)
									)
							END
						)
				END AS RequiredQty
			,1 AS ysnMainItem
			,ri.intItemUOMId
			,I.intCategoryId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		WHERE ri.intWorkOrderId = @intWorkOrderId
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
			AND ri.intRecipeItemTypeId = 1
			AND ri.intConsumptionMethodId IN (
				1
				,2
				)
		
		UNION
		
		SELECT RSI.intSubstituteItemId
			,RI.intConsumptionMethodId
			,RI.intStorageLocationId
			,CASE 
				WHEN RI.ysnPartialFillConsumption = 0
					THEN 0
				ELSE (
						CASE 
							WHEN C.strCategoryCode = @strPackagingCategory
								AND P.dblMaxWeightPerPack > 0
								THEN (CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / P.dblMaxWeightPerPack))) AS NUMERIC(38, 20)))
							WHEN C.strCategoryCode = @strPackagingCategory
								THEN CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty) / r.dblQuantity))) AS NUMERIC(38, 20))
							ELSE (
									RI.dblCalculatedQuantity * (
										(
											CASE 
												WHEN @intProduceUOMId = r.intItemUOMId
													THEN @dblProduceQty
												ELSE dbo.fnMFConvertQuantityToTargetItemUOM(@intProduceUOMId, r.intItemUOMId, @dblProduceQty)
												END
											) / (
											CASE 
												WHEN r.intRecipeTypeId = 1
													THEN r.dblQuantity
												ELSE 1
												END
											)
										)
									)
							END
						)
				END AS RequiredQty
			,0 AS ysnMainItem
			,IU.intItemUOMId
			,I.intCategoryId
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
			AND RI.intWorkOrderId = RSI.intWorkOrderId
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = RI.intRecipeId
			AND r.intWorkOrderId = RI.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = RSI.intItemUOMId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = RSI.intSubstituteItemId
			AND IU.intUnitMeasureId = IU1.intUnitMeasureId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND (
				(
					RI.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN RI.dtmValidFrom
						AND RI.dtmValidTo
					)
				OR (
					RI.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, RI.dtmValidFrom)
						AND DATEPART(dy, RI.dtmValidTo)
					)
				)
			AND RI.intRecipeItemTypeId = 1
			AND RI.intConsumptionMethodId IN (
				1
				,2
				)
	END

	INSERT INTO @tblICFinalItem (
		intItemId
		,intConsumptionMethodId
		,intStorageLocationId
		,dblRequiredQty
		,ysnMainItem
		,intItemUOMId
		,intCategoryId
		)
	SELECT intItemId
		,intConsumptionMethodId
		,intStorageLocationId
		,SUM(dblRequiredQty)
		,ysnMainItem
		,intItemUOMId
		,intCategoryId
	FROM @tblICItem
	GROUP BY intItemId
		,intConsumptionMethodId
		,intStorageLocationId
		,ysnMainItem
		,intItemUOMId
		,intCategoryId

	IF @ysnIncludeOutputItem = 1
	BEGIN
		INSERT INTO @tblICFinalItem (intItemId)
		SELECT ri.intItemId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND ri.intRecipeItemTypeId = 2
	END

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

	DECLARE @tblMFQtyInProductionStagingLocation TABLE (
		intItemId INT
		,dblQtyInProductionStagingLocation NUMERIC(18, 6)
		,dblOpeningQty NUMERIC(18, 6)
		,dblQtyInProdStagingLocation NUMERIC(18, 6)
		,intCategoryId INT
		)
	DECLARE @tblMFLot TABLE (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intItemUOMId INT
		)

	INSERT INTO @tblMFLot
	SELECT I.intItemId
		,SUM(IsNULL((
					CASE 
						WHEN L.intWeightUOMId IS NULL
							THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty)
						ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, I.intItemUOMId, L.dblWeight)
						END
					), 0))
		,I.intItemUOMId
	FROM @tblICFinalItem I
	JOIN tblICLot L ON L.intItemId = I.intItemId
		AND L.intLotStatusId = 1
		AND L.dtmExpiryDate > GETDATE()
		AND L.dblQty > 0
		AND L.intStorageLocationId = CASE 
			WHEN I.intConsumptionMethodId = 2
				THEN I.intStorageLocationId
			ELSE @intProductionStageLocationId
			END
	GROUP BY I.intItemId
		,I.intItemUOMId

	DECLARE @tblMFWorkOrderInputLot TABLE (
		intItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		)

	INSERT INTO @tblMFWorkOrderInputLot
	SELECT I.intItemId
		,SUM(IsNULL(WI.dblQuantity, 0))
		,WI.intItemUOMId
	FROM @tblICFinalItem I
	JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
		AND WI.intWorkOrderId = @intWorkOrderId
	GROUP BY I.intItemId
		,WI.intItemUOMId

	INSERT INTO @tblMFQtyInProductionStagingLocation (
		intItemId
		,dblQtyInProductionStagingLocation ---System Qty
		,dblOpeningQty
		,dblQtyInProdStagingLocation
		,intCategoryId
		)
	SELECT I.intItemId
		,IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - IsNULL(I.dblRequiredQty, 0)
		,CASE 
			WHEN IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0) > 0
				THEN IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0)
			ELSE 0
			END
		,IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0)
		,I.intCategoryId
	FROM @tblICFinalItem I
	LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
	LEFT JOIN @tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId

	DELETE
	FROM @tblICFinalItem
	WHERE ysnMainItem = 0
		AND intItemId IN (
			SELECT SL.intItemId
			FROM @tblMFQtyInProductionStagingLocation SL
			WHERE SL.dblQtyInProdStagingLocation = 0
			)

	--BEGIN TRANSACTION
	INSERT INTO dbo.tblMFProcessCycleCountSession (
		intSubLocationId
		,intUserId
		,dtmSessionStartDateTime
		,dtmSessionEndDateTime
		,ysnCycleCountCompleted
		,intWorkOrderId
		)
	SELECT @intSubLocationId
		,@intUserId
		,@dtmCurrentDateTime
		,NULL
		,0
		,@intWorkOrderId

	SELECT @intCycleCountSessionId = SCOPE_IDENTITY()

	INSERT INTO dbo.tblMFProcessCycleCount (
		intCycleCountSessionId
		,intMachineId
		,intLotId
		,intItemId
		,dblQuantity
		,dblQtyInProdStagingLocation
		,dblRequiredQty
		,dblSystemQty
		,intItemUOMId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT @intCycleCountSessionId
		,MP.intMachineId
		,NULL
		,I.intItemId
		,NULL
		,(
			SELECT SUM(PS.dblQtyInProdStagingLocation)
			FROM @tblMFQtyInProductionStagingLocation PS
			WHERE PS.intItemId = I.intItemId
			)
		,I.dblRequiredQty
		,(
			SELECT SUM(PS.dblQtyInProductionStagingLocation)
			FROM @tblMFQtyInProductionStagingLocation PS
			WHERE PS.intItemId = I.intItemId
			)
		,I.intItemUOMId
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,1
	FROM dbo.tblMFManufacturingProcessMachine MP
	CROSS JOIN @tblICFinalItem I
	WHERE MP.intManufacturingProcessId = @intManufacturingProcessId
		AND MP.intMachineId IN (
			SELECT M.intMachineId
			FROM @tblMFMachine M
			)

	UPDATE dbo.tblMFWorkOrder
	SET intCountStatusId = 10
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFProductionSummary
	SET dblOpeningQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 1
				OR RSI.intRecipeItemTypeId = 1
				THEN ISNULL(PSL.dblOpeningQty, 0)
			ELSE 0
			END
		,dblOpeningOutputQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 2
				THEN ISNULL(PSL.dblOpeningQty, 0)
			ELSE 0
			END
	FROM @tblMFQtyInProductionStagingLocation PSL
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = PSL.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId = PSL.intItemId
		AND RSI.intWorkOrderId = @intWorkOrderId
	JOIN dbo.tblMFProductionSummary PS ON PS.intItemId = PSL.intItemId
		AND PS.intWorkOrderId = @intWorkOrderId And intItemTypeId IN (1,3)

	INSERT INTO dbo.tblMFProductionSummary (
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
	SELECT DISTINCT @intWorkOrderId
		,PSL.intItemId
		,CASE 
			WHEN RI.intRecipeItemTypeId = 1
				OR RI.intRecipeItemTypeId IS NULL
				THEN ISNULL(PSL.dblOpeningQty, 0)
			ELSE 0
			END
		,CASE 
			WHEN RI.intRecipeItemTypeId = 2
				THEN ISNULL(PSL.dblOpeningQty, 0)
			ELSE 0
			END
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,PSL.intCategoryId
		,(
			CASE 
				WHEN RI.intItemId IS NOT NULL
					THEN 1
				ELSE 3
				END
			)
	FROM @tblMFQtyInProductionStagingLocation PSL
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = PSL.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFProductionSummary PS
			WHERE PS.intWorkOrderId = @intWorkOrderId
				AND PS.intItemId = PSL.intItemId
				And intItemTypeId IN (1,3)
			)

	--COMMIT TRANSACTION
	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	--IF XACT_STATE() != 0 
	--ROLLBACK TRANSACTION
	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


