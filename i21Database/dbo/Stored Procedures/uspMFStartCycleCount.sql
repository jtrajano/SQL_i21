CREATE PROCEDURE [dbo].uspMFStartCycleCount (@strXML NVARCHAR(MAX))
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
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@TRANCOUNT INT
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT
		,@intPMStageLocationId INT
		,@intNoOfDecimalPlacesOnConsumption INT
		,@ysnConsumptionByRatio BIT
		,@intPhysicalItemUOMId INT
		,@strPrefillCountedQty NVARCHAR(50)
		,@strMultipleMachinesShareCommonStagingLocation NVARCHAR(50)
		,@intItemUOMId INT
		,@intUnitMeasureId INT
	DECLARE @tblMFProcessCycleCount TABLE (
		intItemId INT
		,intMachineId INT
		,dblQuantity NUMERIC(38, 20)
		)

	SELECT @TRANCOUNT = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intNoOfDecimalPlacesOnConsumption = intNoOfDecimalPlacesOnConsumption
		,@ysnConsumptionByRatio = ysnConsumptionByRatio
	FROM tblMFCompanyPreference

	IF @intNoOfDecimalPlacesOnConsumption IS NULL
	BEGIN
		SELECT @intNoOfDecimalPlacesOnConsumption = 4
	END

	IF @ysnConsumptionByRatio IS NULL
	BEGIN
		SELECT @ysnConsumptionByRatio = 0
	END

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
		,@dblProducedQuantity NUMERIC(38, 20)

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
				AND intCountStatusId = 10
			)
	BEGIN
		RAISERROR (
				'The cycle count is already started by other user. you cannot continue.'
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
				AND intCountStatusId = 13
			)
	BEGIN
		RAISERROR (
				'The run is already trued up. you cannot continue.'
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
		WHERE [intEntityId] = @intUserSecurityID

		RAISERROR (
				'The cycle count for this run is already started by ''%s'' on ''%s''. you cannot continue. The current run already cyclecounted by another user. you cannot continue.'
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
		,@strWorkOrderNo = strWorkOrderNo
		,@intItemUOMId = intItemUOMId
		,@dblProducedQuantity = dblProducedQuantity
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intItemUOMId

	IF @dtmPlannedDateTime > @dtmCurrentDateTime
	BEGIN
		RAISERROR (
				'Cannot do the cycle count for future production date.'
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
				'No machines are configured for cyclecount this process.'
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
				'No valid input item is configured against the selected run, in Recipe configuration.'
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
		AND intStatusId = 10
		AND intCountStatusId = 10
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
				'The run ''%s'' prior to the current run has no cycle count entries. Please do cycle count and close the previous run before starting the cycle count for the current run.'
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
				AND intCountStatusId = 10
				AND intStatusId = 10
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
			AND intCountStatusId = 10
			AND intStatusId = 10
		ORDER BY W.dtmPlannedDate DESC
			,W.intPlannedShiftId DESC

		RAISERROR (
				'A cycle count for the item ''%s'' is already started for work order %s on %s for the target item ''%s''. Please complete the prior cycle count to continue.'
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
				AND intCountStatusId = 10
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
			AND intCountStatusId = 10
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
				'A run for ''%s'' already exists for work order %s on %s which is using the same ingredient item ''%s''. Please complete the prior run to continue.'
				,11
				,1
				,@strProductItem
				,@strWorkOrderNo
				,@strPlannedDate
				,@strInputItem
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrderRecipeItem ri
			WHERE ri.intWorkOrderId = @intWorkOrderId
				AND ri.intRecipeItemTypeId = 2
				AND ri.ysnOutputItemMandatory = 1
				AND NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrderProducedLot WP
					WHERE WP.intWorkOrderId = ri.intWorkOrderId
						AND WP.intItemId = ri.intItemId
						AND WP.ysnProductionReversed = 0
					)
			)
		AND @dblProducedQuantity > 0
	BEGIN
		RAISERROR (
				'Cannot start the cycle count. One or more mandatory items are not produced.'
				,16
				,1
				)

		RETURN
	END

	DECLARE @tblICItem TABLE (
		intItemId INT
		,intConsumptionMethodId INT
		,intStorageLocationId INT
		,dblRequiredQty NUMERIC(38, 20)
		,ysnMainItem BIT
		,intItemUOMId INT
		,intCategoryId INT
		,intMainItemId INT
		,intRecipeItemId INT
		,intMachineId INT
		,strLotTracking NVARCHAR(50)
		)
	DECLARE @tblICFinalItem TABLE (
		intRecordId INT identity(1, 1)
		,intItemId INT
		,intConsumptionMethodId INT
		,intStorageLocationId INT
		,dblRequiredQty NUMERIC(38, 20)
		,ysnMainItem BIT
		,intItemUOMId INT
		,intCategoryId INT
		,intMainItemId INT
		,intRecipeItemId INT
		,intMachineId INT
		,intRowNumber INT
		,strLotTracking NVARCHAR(50)
		)
	DECLARE @dblProduceQty NUMERIC(38, 20)
		,@intProduceUOMId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPackagingCategoryId INT
		,@intPMCategoryId INT
		,@strInstantConsumption NVARCHAR(40)
		,@dblProduceParialQty NUMERIC(38, 20)
		,@strMachineId NVARCHAR(50)
	DECLARE @tblMFProducedQtyByMachine TABLE (
		intMachineId INT
		,intStagingLocationId INT
		,dblProduceQty NUMERIC(38, 20)
		,dblProducePartialQty NUMERIC(38, 20)
		,intProduceUOMId INT
		)
	DECLARE @tblMFFinalProducedQtyByMachine TABLE (
		intMachineId INT
		,intStagingLocationId INT
		,dblProduceQty NUMERIC(38, 20)
		,dblProducePartialQty NUMERIC(38, 20)
		,intProduceUOMId INT
		)

	INSERT INTO @tblMFProducedQtyByMachine (
		intMachineId
		,intStagingLocationId
		,dblProduceQty
		,intProduceUOMId
		)
	SELECT WP.intMachineId
		,isNULL((
				SELECT intProductionStagingLocationId
				FROM tblMFManufacturingProcessMachine MPM
				WHERE MPM.intManufacturingProcessId = @intManufacturingProcessId
					AND MPM.intMachineId = WP.intMachineId
					AND MPM.intProductionStagingLocationId IS NOT NULL
				), (
				SELECT strAttributeValue
				FROM tblMFManufacturingProcessAttribute
				WHERE intManufacturingProcessId = @intManufacturingProcessId
					AND intLocationId = @intLocationId
					AND intAttributeId = 75 --'Production Staging Location'
				))
		,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(WP.intPhysicalItemUOMId, IsNULL(IU.intItemUOMId, WP.intPhysicalItemUOMId), WP.dblPhysicalCount))
		,MIN(WP.intPhysicalItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot WP
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = WP.intItemId
		AND IU.intUnitMeasureId = @intUnitMeasureId
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
	GROUP BY WP.intMachineId

	IF @dblProduceQty IS NULL
		SELECT @dblProduceQty = 0

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @intPMCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	INSERT INTO @tblMFProducedQtyByMachine (
		intMachineId
		,intStagingLocationId
		,dblProducePartialQty
		,intProduceUOMId
		)
	SELECT WP.intMachineId
		,isNULL((
				SELECT intProductionStagingLocationId
				FROM tblMFManufacturingProcessMachine MPM
				WHERE MPM.intManufacturingProcessId = @intManufacturingProcessId
					AND MPM.intMachineId = WP.intMachineId
					AND MPM.intProductionStagingLocationId IS NOT NULL
				), (
				SELECT strAttributeValue
				FROM tblMFManufacturingProcessAttribute
				WHERE intManufacturingProcessId = @intManufacturingProcessId
					AND intLocationId = @intLocationId
					AND intAttributeId = 75 --'Production Staging Location'
				))
		,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(WP.intPhysicalItemUOMId, IsNULL(IU.intItemUOMId, WP.intPhysicalItemUOMId), WP.dblPhysicalCount))
		,MIN(WP.intPhysicalItemUOMId)
	FROM dbo.tblMFWorkOrderProducedLot WP
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemId = WP.intItemId
		AND IU.intUnitMeasureId = @intUnitMeasureId
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
	GROUP BY WP.intMachineId

	SELECT @strMultipleMachinesShareCommonStagingLocation = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 102 --Multiple machines share common staging location

	IF @strMultipleMachinesShareCommonStagingLocation IS NULL
	BEGIN
		SELECT @strMultipleMachinesShareCommonStagingLocation = 'False'
	END

	INSERT INTO @tblMFFinalProducedQtyByMachine (
		intMachineId
		,intStagingLocationId
		,dblProduceQty
		,dblProducePartialQty
		,intProduceUOMId
		)
	SELECT CASE 
			WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
				THEN NULL
			ELSE intMachineId
			END
		,intStagingLocationId
		,IsNULL(SUM(dblProduceQty), 0)
		,IsNULL(SUM(dblProducePartialQty), 0)
		,MIN(intProduceUOMId)
	FROM @tblMFProducedQtyByMachine
	GROUP BY CASE 
			WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
				THEN NULL
			ELSE intMachineId
			END
		,intStagingLocationId

	SELECT @intPMStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 90 --PM Staging Location

	IF @intProduceUOMId IS NULL
		SELECT @intProduceUOMId = @intPhysicalItemUOMId

	IF @dblProduceParialQty IS NULL
		SELECT @dblProduceParialQty = 0

	IF @dblProduceQty IS NOT NULL
		OR @dblProduceParialQty IS NOT NULL
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,intConsumptionMethodId
			,intStorageLocationId
			,dblRequiredQty
			,ysnMainItem
			,intItemUOMId
			,intCategoryId
			,intMainItemId
			,intRecipeItemId
			,intMachineId
			,strLotTracking
			)
		SELECT ri.intItemId
			,ri.intConsumptionMethodId
			,CASE 
				WHEN ri.intConsumptionMethodId = 2
					THEN ri.intStorageLocationId
				ELSE (
						CASE 
							WHEN I.intCategoryId = @intPMCategoryId
								THEN @intPMStageLocationId
							ELSE M.intStagingLocationId
							END
						)
				END
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
										WHEN ri.ysnPartialFillConsumption = 1
											THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / P.dblMaxWeightPerPack))
										ELSE 0
										END) AS NUMERIC(38, 20))
							)
				WHEN I.intCategoryId = @intPMCategoryId
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / r.dblQuantity)) + CASE 
									WHEN ri.ysnPartialFillConsumption = 1
										THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / r.dblQuantity))
									ELSE 0
									END) AS NUMERIC(38, 20))
				ELSE (
						ri.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							) + CASE 
							WHEN ri.ysnPartialFillConsumption = 1
								THEN ri.dblCalculatedQuantity * (
										dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / (
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
			,1 AS ysnMainItem
			,ri.intItemUOMId
			,I.intCategoryId
			,ri.intItemId
			,ri.intRecipeItemId
			,M.intMachineId
			,I.strLotTracking
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		--JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN @tblMFFinalProducedQtyByMachine M ON 1 = 1
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
			,CASE 
				WHEN RI.intConsumptionMethodId = 2
					THEN RI.intStorageLocationId
				ELSE (
						CASE 
							WHEN I.intCategoryId = @intPMCategoryId
								THEN @intPMStageLocationId
							ELSE M.intStagingLocationId
							END
						)
				END
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					AND P.dblMaxWeightPerPack > 0
					THEN (
							CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / P.dblMaxWeightPerPack)) + CASE 
										WHEN RI.ysnPartialFillConsumption = 1
											THEN (RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / P.dblMaxWeightPerPack))
										ELSE 0
										END) AS NUMERIC(38, 20))
							)
				WHEN I.intCategoryId = @intPMCategoryId
					THEN CAST(CEILING((RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / r.dblQuantity)) + CASE 
									WHEN RI.ysnPartialFillConsumption = 1
										THEN (RI.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / r.dblQuantity))
									ELSE 0
									END) AS NUMERIC(38, 20))
				ELSE (
						RI.dblCalculatedQuantity * (
							dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProduceQty) / (
								CASE 
									WHEN r.intRecipeTypeId = 1
										THEN r.dblQuantity
									ELSE 1
									END
								)
							) + CASE 
							WHEN RI.ysnPartialFillConsumption = 1
								THEN RI.dblCalculatedQuantity * (
										dbo.fnMFConvertQuantityToTargetItemUOM(M.intProduceUOMId, r.intItemUOMId, M.dblProducePartialQty) / (
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
			,0 AS ysnMainItem
			,IU.intItemUOMId
			,I.intCategoryId
			,RSI.intItemId
			,RI.intRecipeItemId
			,M.intMachineId
			,I.strLotTracking
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
			AND RI.intWorkOrderId = RSI.intWorkOrderId
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = RI.intRecipeId
			AND r.intWorkOrderId = RI.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		--JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RSI.intItemUOMId
		JOIN @tblMFFinalProducedQtyByMachine M ON 1 = 1
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
		,intMainItemId
		,intRecipeItemId
		,intMachineId
		,intRowNumber
		,strLotTracking
		)
	SELECT intItemId
		,intConsumptionMethodId
		,intStorageLocationId
		,SUM(dblRequiredQty) OVER (
			PARTITION BY intItemId
			,intStorageLocationId
			)
		,ysnMainItem
		,intItemUOMId
		,intCategoryId
		,intMainItemId
		,intRecipeItemId
		,intMachineId
		,Row_Number() OVER (
			PARTITION BY intItemId
			,intStorageLocationId ORDER BY intMachineId
			)
		,strLotTracking
	FROM @tblICItem

	UPDATE @tblICFinalItem
	SET intMachineId = NULL
	WHERE intItemId IN (
			SELECT intItemId
			FROM @tblICFinalItem
			WHERE intRowNumber > 1
			)

	DELETE
	FROM @tblICFinalItem
	WHERE intRowNumber > 1

	DELETE t1
	FROM @tblICFinalItem t1
		,@tblICFinalItem t2
	WHERE t1.intItemId = t2.intItemId
		AND t1.intStorageLocationId = t2.intStorageLocationId
		AND t1.intMachineId = t2.intMachineId
		AND t1.intRecordId > t2.intRecordId

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
	SELECT DISTINCT intMachineId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFMachine
			)
	BEGIN
		INSERT INTO @tblMFMachine (intMachineId)
		SELECT DISTINCT intMachineId
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

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 20

	DECLARE @tblMFQtyInProductionStagingLocation TABLE (
		intItemId INT
		,dblQtyInProductionStagingLocation NUMERIC(18, 6)
		,dblOpeningQty NUMERIC(18, 6)
		,dblQtyInProdStagingLocation NUMERIC(18, 6)
		,intCategoryId INT
		,dblRequiredQty NUMERIC(18, 6)
		,intStorageLocationId INT
		)
	DECLARE @tblMFFinalQtyInProductionStagingLocation TABLE (
		intItemId INT
		,dblQtyInProductionStagingLocation NUMERIC(18, 6)
		,dblOpeningQty NUMERIC(18, 6)
		,dblQtyInProdStagingLocation NUMERIC(18, 6)
		,intCategoryId INT
		,dblRequiredQty NUMERIC(18, 6)
		,intMachineId INT
		)
	DECLARE @tblMFLot TABLE (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		)

	INSERT INTO @tblMFLot
	SELECT I.intItemId
		,SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, I.intItemUOMId, S.dblOnHand), 0))
		,I.intItemUOMId
		,I.intStorageLocationId
	FROM @tblICFinalItem I
	JOIN tblICItemStockUOM S ON S.intItemId = I.intItemId
		AND I.strLotTracking = 'No'
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
		AND S.intStorageLocationId = I.intStorageLocationId
		AND S.dblOnHand > 0
		AND IL.intLocationId = @intLocationId
	GROUP BY I.intItemId
		,I.intItemUOMId
		,I.intStorageLocationId

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
		,I.intStorageLocationId
	FROM @tblICFinalItem I
	JOIN tblICLot L ON L.intItemId = I.intItemId
		AND I.strLotTracking <> 'No'
		AND L.intLotStatusId = 1
		AND ISNULL(L.dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
		AND L.dblQty > 0
		AND L.intStorageLocationId = I.intStorageLocationId
	GROUP BY I.intItemId
		,I.intItemUOMId
		,I.intStorageLocationId

	DECLARE @tblMFReservation TABLE (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		)

	INSERT INTO @tblMFReservation
	SELECT I.intItemId
		,IsNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, I.intItemUOMId, ISNULL(SR.dblQty, 0))), 0)
		,I.intItemUOMId
		,I.intStorageLocationId
	FROM @tblICFinalItem I
	LEFT JOIN tblICStockReservation SR ON SR.intItemId = I.intItemId
		AND SR.intTransactionId <> @intWorkOrderId
		AND SR.strTransactionId <> @strWorkOrderNo
		AND ISNULL(ysnPosted, 0) = 0
		AND SR.intInventoryTransactionType = 8
		AND I.intStorageLocationId = SR.intStorageLocationId
	GROUP BY I.intItemId
		,I.intItemUOMId
		,I.intStorageLocationId

	UPDATE L
	SET dblQty = L.dblQty - IsNULL(R.dblQty, 0)
	FROM @tblMFLot L
	LEFT JOIN @tblMFReservation R ON L.intItemId = R.intItemId
		AND L.intStorageLocationId = R.intStorageLocationId

	DECLARE @tblMFWorkOrderInputLot TABLE (
		intItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,dblRatio NUMERIC(18, 6)
		,intMainItemId INT
		,intMachineId INT
		)

	IF @ysnConsumptionByRatio = 0
	BEGIN
		INSERT INTO @tblMFWorkOrderInputLot
		SELECT I.intItemId
			,SUM(IsNULL(WI.dblQuantity, 0))
			,WI.intItemUOMId
			,100
			,I.intMainItemId
			,WI.intMachineId
		FROM @tblICFinalItem I
		JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND WI.intWorkOrderId = @intWorkOrderId
			AND WI.ysnConsumptionReversed = 0
		GROUP BY I.intItemId
			,WI.intItemUOMId
			,I.intMainItemId
			,WI.intMachineId

		INSERT INTO @tblMFQtyInProductionStagingLocation (
			intItemId
			,dblQtyInProductionStagingLocation ---System Qty
			,dblOpeningQty
			,dblQtyInProdStagingLocation
			,intCategoryId
			,dblRequiredQty
			,intStorageLocationId
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
			,IsNULL(I.dblRequiredQty, 0)
			,I.intStorageLocationId
		FROM @tblICFinalItem I
		LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
			AND L.intStorageLocationId = I.intStorageLocationId
		LEFT JOIN @tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND WI.intMachineId = I.intMachineId
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFWorkOrderInputLot
		SELECT DISTINCT I.intItemId
			,SUM(IsNULL(WI.dblQuantity, 0)) OVER (
				PARTITION BY I.intItemId
				,CASE 
					WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
						THEN NULL
					ELSE WI.intMachineId
					END
				)
			,WI.intItemUOMId
			,(
				SUM(IsNULL(WI.dblQuantity, 0)) OVER (
					PARTITION BY I.intItemId
					,CASE 
						WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
							THEN NULL
						ELSE WI.intMachineId
						END
					) / SUM(IsNULL(WI.dblQuantity, 0)) OVER (
					PARTITION BY I.intMainItemId
					,CASE 
						WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
							THEN NULL
						ELSE WI.intMachineId
						END
					)
				) * 100
			,I.intMainItemId
			,CASE 
				WHEN @strMultipleMachinesShareCommonStagingLocation = 'True'
					THEN NULL
				ELSE WI.intMachineId
				END
		FROM @tblICFinalItem I
		JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND WI.intMachineId = CASE 
				WHEN I.intMachineId IS NOT NULL
					THEN I.intMachineId
				ELSE WI.intMachineId
				END
			AND WI.intWorkOrderId = @intWorkOrderId
			AND WI.ysnConsumptionReversed = 0

		DELETE I
		FROM @tblICFinalItem I
		WHERE I.intItemId IN (
				SELECT WI.intMainItemId
				FROM @tblMFWorkOrderInputLot WI
				WHERE WI.intItemId <> WI.intMainItemId
				GROUP BY WI.intMainItemId
				HAVING Round(SUM(dblRatio), 0) = 100
				)

		INSERT INTO @tblMFQtyInProductionStagingLocation (
			intItemId
			,dblQtyInProductionStagingLocation ---System Qty
			,dblOpeningQty
			,dblQtyInProdStagingLocation
			,intCategoryId
			,dblRequiredQty
			,intStorageLocationId
			)
		SELECT I.intItemId
			,IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - Round((IsNULL(I.dblRequiredQty, 0) * IsNULL(dblRatio, 100) / 100), @intNoOfDecimalPlacesOnConsumption)
			,CASE 
				WHEN IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0) > 0
					THEN IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0) - IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, I.intItemUOMId, WI.dblQuantity), 0)
				ELSE 0
				END
			,IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty), 0)
			,I.intCategoryId
			,Round(IsNULL(I.dblRequiredQty, 0) * IsNULL(dblRatio, 100) / 100, @intNoOfDecimalPlacesOnConsumption)
			,I.intStorageLocationId
		FROM @tblICFinalItem I
		LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
			AND L.intStorageLocationId = I.intStorageLocationId
		LEFT JOIN @tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND IsNULL(WI.intMachineId, 0) = CASE 
				WHEN I.intMachineId IS NOT NULL
					THEN I.intMachineId
				ELSE IsNULL(WI.intMachineId, 0)
				END
	END

	DELETE
	FROM @tblICFinalItem
	WHERE ysnMainItem = 0
		AND intItemId NOT IN (
			SELECT WI.intItemId
			FROM @tblMFWorkOrderInputLot WI
			)

	DELETE FI
	FROM @tblICFinalItem FI
	WHERE ysnMainItem = 1
		AND intItemId IN (
			SELECT SL.intItemId
			FROM @tblMFQtyInProductionStagingLocation SL
			WHERE SL.dblQtyInProdStagingLocation = 0
			)
		AND EXISTS (
			SELECT *
			FROM @tblICFinalItem I
			WHERE I.intMainItemId = FI.intItemId
				AND ysnMainItem = 0
			)

	IF @strInstantConsumption = 'True'
	BEGIN
		INSERT INTO @tblMFQtyInProductionStagingLocation (
			intItemId
			,dblQtyInProductionStagingLocation
			,dblOpeningQty
			)
		SELECT I.intItemId
			,IsNULL(L.dblQty, 0)
			,(IsNULL(L.dblQty, 0) + IsNULL(I.dblRequiredQty, 0)) - IsNULL(WI.dblQuantity, 0)
		FROM @tblICItem I
		LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
			AND I.intStorageLocationId = L.intStorageLocationId
		LEFT JOIN @tblMFWorkOrderInputLot WI ON WI.intItemId = I.intItemId
			AND IsNULL(WI.intMachineId, 0) = CASE 
				WHEN I.intMachineId IS NOT NULL
					THEN I.intMachineId
				ELSE IsNULL(WI.intMachineId, 0)
				END
	END

	SELECT @strPrefillCountedQty = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 101

	IF @strPrefillCountedQty IS NULL
		OR @strPrefillCountedQty = ''
	BEGIN
		SELECT @strPrefillCountedQty = 'False'
	END

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
		,intProductionStagingLocationId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT DISTINCT @intCycleCountSessionId
		,NULL
		,NULL
		,I.intItemId
		,(
			CASE 
				WHEN @strPrefillCountedQty = 'True'
					THEN (
							SELECT SUM(PS.dblQtyInProductionStagingLocation)
							FROM @tblMFQtyInProductionStagingLocation PS
							WHERE PS.intItemId = I.intItemId
								AND PS.intStorageLocationId = I.intStorageLocationId
							)
				ELSE NULL
				END
			)
		,(
			SELECT SUM(PS.dblQtyInProdStagingLocation)
			FROM @tblMFQtyInProductionStagingLocation PS
			WHERE PS.intItemId = I.intItemId
				AND PS.intStorageLocationId = I.intStorageLocationId
			)
		,(
			SELECT MAX(PS.dblRequiredQty)
			FROM @tblMFQtyInProductionStagingLocation PS
			WHERE PS.intItemId = I.intItemId
				AND PS.intStorageLocationId = I.intStorageLocationId
			) dblRequiredQty
		,(
			SELECT SUM(PS.dblQtyInProductionStagingLocation)
			FROM @tblMFQtyInProductionStagingLocation PS
			WHERE PS.intItemId = I.intItemId
				AND PS.intStorageLocationId = I.intStorageLocationId
			)
		,I.intItemUOMId
		,I.intStorageLocationId
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,1
	FROM @tblICFinalItem I

	INSERT INTO tblMFProcessCycleCountMachine (
		intCycleCountId
		,intMachineId
		)
	SELECT (
			SELECT PCC.intCycleCountId
			FROM tblMFProcessCycleCount PCC
			WHERE PCC.intCycleCountSessionId = @intCycleCountSessionId
				AND PCC.intItemId = I.intItemId
				AND PCC.intProductionStagingLocationId = I.intStorageLocationId
			)
		,I.intMachineId
	FROM @tblICFinalItem I
	WHERE I.intMachineId IS NOT NULL

	INSERT INTO tblMFProcessCycleCountMachine (
		intCycleCountId
		,intMachineId
		)
	SELECT (
			SELECT PCC.intCycleCountId
			FROM tblMFProcessCycleCount PCC
			WHERE PCC.intCycleCountSessionId = @intCycleCountSessionId
				AND PCC.intItemId = I.intItemId
				AND PCC.intProductionStagingLocationId = I.intStorageLocationId
			)
		,I1.intMachineId
	FROM @tblICFinalItem I
		,(
			SELECT intMachineId
			FROM @tblMFMachine
			) I1
	WHERE I.intMachineId IS NULL

	UPDATE dbo.tblMFWorkOrder
	SET intCountStatusId = 10
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO @tblMFFinalQtyInProductionStagingLocation (
		dblOpeningQty
		,dblQtyInProdStagingLocation
		,dblQtyInProductionStagingLocation
		,dblRequiredQty
		,intItemId
		,intCategoryId
		,intMachineId
		)
	SELECT SUm(PS.dblOpeningQty)
		,SUM(PS.dblQtyInProdStagingLocation)
		,SUM(PS.dblQtyInProductionStagingLocation)
		,SUM(PS.dblRequiredQty)
		,PS.intItemId
		,PS.intCategoryId
		,I.intMachineId
	FROM @tblMFQtyInProductionStagingLocation PS
	JOIN @tblICFinalItem I ON I.intItemId = PS.intItemId
		AND I.intStorageLocationId = PS.intStorageLocationId
	GROUP BY PS.intItemId
		,PS.intCategoryId
		,I.intMachineId

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
		,dblRequiredQty = PSL.dblRequiredQty
	FROM @tblMFFinalQtyInProductionStagingLocation PSL
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = PSL.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId = PSL.intItemId
		AND RSI.intWorkOrderId = @intWorkOrderId
	JOIN dbo.tblMFProductionSummary PS ON PS.intItemId = PSL.intItemId
		AND IsNULL(PS.intMachineId, 0) = CASE 
			WHEN PS.intMachineId IS NOT NULL
				THEN PSL.intMachineId
			ELSE IsNULL(PS.intMachineId, 0)
			END
		AND PS.intWorkOrderId = @intWorkOrderId
		AND intItemTypeId IN (
			1
			,3
			)

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
		,dblRequiredQty
		,intMachineId
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
		,PSL.dblRequiredQty
		,NULL --,PSL.intMachineId 
	FROM @tblMFFinalQtyInProductionStagingLocation PSL
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = PSL.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	WHERE NOT EXISTS (
			SELECT *
			FROM dbo.tblMFProductionSummary PS
			WHERE PS.intWorkOrderId = @intWorkOrderId
				AND PS.intItemId = PSL.intItemId
				AND IsNULL(PS.intMachineId, 0) = CASE 
					WHEN PS.intMachineId IS NOT NULL
						THEN PSL.intMachineId
					ELSE IsNULL(PS.intMachineId, 0)
					END
				AND intItemTypeId IN (
					1
					,3
					)
			)

	IF @strPrefillCountedQty = 'True'
	BEGIN
		INSERT INTO @tblMFProcessCycleCount
		SELECT intItemId
			,PCCM.intMachineId
			,SUM(dblQuantity)
		FROM tblMFProcessCycleCount PCC
		LEFT JOIN tblMFProcessCycleCountMachine PCCM ON PCCM.intCycleCountId = PCC.intCycleCountId
		WHERE intCycleCountSessionId = @intCycleCountSessionId
		GROUP BY PCC.intItemId
			,PCCM.intMachineId

		UPDATE tblMFProductionSummary
		SET dblCountQuantity = CASE 
				WHEN RI.intRecipeItemTypeId = 1
					OR RSI.intRecipeItemTypeId = 1
					THEN ISNULL(CC.dblQuantity, 0)
				ELSE 0
				END
			,dblCountOutputQuantity = CASE 
				WHEN RI.intRecipeItemTypeId = 2
					THEN ISNULL(CC.dblQuantity, 0)
				ELSE 0
				END
		FROM @tblMFProcessCycleCount CC
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = CC.intItemId
			AND RI.intWorkOrderId = @intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId = CC.intItemId
			AND RSI.intWorkOrderId = @intWorkOrderId
		JOIN dbo.tblMFProductionSummary PS ON PS.intItemId = CC.intItemId
			AND IsNULL(PS.intMachineId, 0) = CASE 
				WHEN PS.intMachineId IS NOT NULL
					THEN IsNULL(CC.intMachineId, 0)
				ELSE IsNULL(PS.intMachineId, 0)
				END
			AND PS.intWorkOrderId = @intWorkOrderId
			AND PS.intItemTypeId IN (
				1
				,3
				)

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
			)
		SELECT DISTINCT @intWorkOrderId
			,CC.intItemId
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			,CASE 
				WHEN RI.intRecipeItemTypeId = 1
					OR RI.intRecipeItemTypeId IS NULL
					THEN ISNULL(CC.dblQuantity, 0)
				ELSE 0
				END
			,CASE 
				WHEN RI.intRecipeItemTypeId = 2
					THEN ISNULL(CC.dblQuantity, 0)
				ELSE 0
				END
			,0
			,0
		FROM @tblMFProcessCycleCount CC
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = CC.intItemId
			AND RI.intWorkOrderId = @intWorkOrderId
		WHERE NOT EXISTS (
				SELECT *
				FROM dbo.tblMFProductionSummary PS
				WHERE PS.intWorkOrderId = @intWorkOrderId
					AND PS.intItemId = CC.intItemId
					AND IsNULL(PS.intMachineId, 0) = CASE 
						WHEN PS.intMachineId IS NOT NULL
							THEN IsNULL(CC.intMachineId, 0)
						ELSE IsNULL(PS.intMachineId, 0)
						END
					AND PS.intItemTypeId IN (
						1
						,3
						)
				)
	END

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
