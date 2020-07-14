CREATE PROCEDURE uspMFGetYieldView @strXML NVARCHAR(MAX)
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
		,@idoc INT
		,@intWorkOrderId INT
		,@strRunNo NVARCHAR(50)
		,@dtmRunDate DATETIME
		,@strShiftName NVARCHAR(50)
		,@dblTInput NUMERIC(18, 6)
		,@dblTOutput NUMERIC(18, 6)
		,@dblYieldP NUMERIC(18, 6)
		,@dblInput NUMERIC(18, 6)
		,@dblOutput NUMERIC(18, 6)
		,@dblInputCC NUMERIC(18, 6)
		,@dblInputOB NUMERIC(18, 6)
		,@dblOutputCC NUMERIC(18, 6)
		,@dblOutputOB NUMERIC(18, 6)
		,@dblRequiredQty NUMERIC(18, 6)
		,@strCFormula NVARCHAR(MAX)
		,@strIFormula NVARCHAR(MAX)
		,@strOFormula NVARCHAR(MAX)
		,@dblCalculatedQuantity NUMERIC(18, 6)
		,@intItemId INT
		,@intLocationId INT
		,@intRowNum INT
		,@dblDecimal INT
		,@dblQueuedQtyAdj NUMERIC(18, 6)
		,@dblCycleCountAdj NUMERIC(18, 6)
		,@dblEmptyOutAdj NUMERIC(18, 6)
		,@intTransactionsCount INT
		,@strDestinationUOMName NVARCHAR(50)
		,@intDestinationUOMId INT
		,@ysnPackaging BIT
		,@intCurTransactionsCount INT
		,@intAttributeId INT
		,@intManufacturingProcessId INT
		,@strSQL NVARCHAR(MAX)
		,@strMode NVARCHAR(50)
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@ysnIncludeIngredientItem BIT
		,@intInputItemId INT
		,@intRecipeId INT
		,@intYieldId INT
		,@dtmDate DATETIME
		,@intShiftId INT
		,@strAttributeValue NVARCHAR(50)
		,@intPrimaryItemId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPackagingCategoryId INT
		,@intCategoryId INT
		,@intOwnerId INT
		,@intItemUOMId INT
		,@intInputItemUOMId INT
		,@intFromUnitMeasureId INT
		,@intToUnitMeasureId INT
		,@dblConversionToStock NUMERIC(18, 6)
	DECLARE @tblMFWorkOrder TABLE (
		intWorkOrderId INT
		,dtmPlannedDate DATETIME
		,intPlannedShiftId INT
		,intItemId INT
		)

	SELECT @dblDecimal = 4

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strMode = strMode
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = ISNULL(dtmToDate, @dtmFromDate)
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
		,@intOwnerId = intOwnerId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strMode NVARCHAR(50)
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			,intManufacturingProcessId INT
			,intLocationId INT
			,intOwnerId INT
			)

	SELECT @strIFormula = strInputFormula
		,@strOFormula = strOutputFormula
	FROM dbo.tblMFYield
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Show Input Item In Yield View'

	SELECT @ysnIncludeIngredientItem = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @ysnIncludeIngredientItem IS NULL
		SELECT @ysnIncludeIngredientItem = 0

	IF OBJECT_ID('tempdb..##tblMFTransaction') IS NOT NULL
		DROP TABLE ##tblMFTransaction

	CREATE TABLE ##tblMFTransaction (
		dtmDate DATETIME
		,intShiftId INT
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intTransactionId INT
		,intInputItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,intWorkOrderId INT
		,intItemId INT
		,intCategoryId INT
		)

	IF @intOwnerId IS NULL
	BEGIN
		INSERT INTO @tblMFWorkOrder (
			intWorkOrderId
			,dtmPlannedDate
			,intPlannedShiftId
			,intItemId
			)
		SELECT W.intWorkOrderId
			,ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
			,W.intPlannedShiftId
			,W.intItemId
		FROM dbo.tblMFWorkOrder W
		WHERE W.intManufacturingProcessId = @intManufacturingProcessId
			AND intStatusId = 13
			AND ISNULL(W.dtmPlannedDate, W.dtmExpectedDate) BETWEEN @dtmFromDate
				AND @dtmToDate
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFWorkOrder (
			intWorkOrderId
			,dtmPlannedDate
			,intPlannedShiftId
			,intItemId
			)
		SELECT W.intWorkOrderId
			,ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
			,W.intPlannedShiftId
			,W.intItemId
		FROM dbo.tblMFWorkOrder W
		LEFT JOIN dbo.tblICItemOwner IO1 ON IO1.intItemId = W.intItemId
		WHERE W.intManufacturingProcessId = @intManufacturingProcessId
			AND intStatusId = 13
			AND ISNULL(W.dtmPlannedDate, W.dtmExpectedDate) BETWEEN @dtmFromDate
				AND @dtmToDate
			AND IO1.intOwnerId = @intOwnerId
	END

	INSERT INTO ##tblMFTransaction (
		dtmDate
		,intShiftId
		,strTransactionType
		,intTransactionId
		,intInputItemId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderId
		,intItemId
		,intCategoryId
		)
	SELECT W.dtmPlannedDate
		,W.intPlannedShiftId
		,'INPUT' COLLATE Latin1_General_CI_AS AS strTransactionType
		,WI.intWorkOrderInputLotId AS intTransactionId
		,WI.intItemId
		,dbo.fnMFConvertQuantityToTargetItemUOM(WI.intEnteredItemUOMId, IsNULL(RI.intItemUOMId, RS.intItemUOMId), WI.dblEnteredQty) AS dblQuantity
		,IsNULL(RI.intItemUOMId, RS.intItemUOMId) AS intItemUOMId
		,WI.intWorkOrderId
		,W.intItemId
		,I.intCategoryId
	FROM dbo.tblMFWorkOrderInputLot WI
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
		AND WI.ysnConsumptionReversed = 0
	JOIN dbo.tblICItem I ON I.intItemId = WI.intItemId
	LEFT JOIN tblMFWorkOrderRecipeItem RI ON RI.intWorkOrderId = W.intWorkOrderId
		AND RI.intItemId = WI.intItemId
		AND RI.intRecipeItemTypeId = 1
	LEFT JOIN tblMFWorkOrderRecipeSubstituteItem RS ON RS.intWorkOrderId = W.intWorkOrderId
		AND RS.intSubstituteItemId = WI.intItemId
	WHERE WI.intWorkOrderInputLotId NOT IN (
			SELECT x.intTransactionId
			FROM OPENXML(@idoc, 'root/Transactions/Transaction', 2) WITH (
					intTransactionId INT
					,strTransactionType NVARCHAR(50)
					) x
			WHERE x.strTransactionType = 'INPUT'
			)

	INSERT INTO ##tblMFTransaction (
		dtmDate
		,intShiftId
		,strTransactionType
		,intTransactionId
		,intInputItemId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderId
		,intItemId
		,intCategoryId
		)
	SELECT W.dtmPlannedDate
		,W.intPlannedShiftId
		,'OUTPUT' COLLATE Latin1_General_CI_AS AS strTransactionType
		,WP.intWorkOrderProducedLotId AS intTransactionId
		,WP.intItemId
		,WP.dblQuantity
		,WP.intItemUOMId
		,WP.intWorkOrderId
		,W.intItemId
		,I.intCategoryId
	FROM dbo.tblMFWorkOrderProducedLot WP
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = WP.intWorkOrderId
		AND WP.ysnProductionReversed = 0
	JOIN dbo.tblICItem I ON I.intItemId = WP.intItemId
	WHERE WP.intWorkOrderProducedLotId NOT IN (
			SELECT x.intTransactionId
			FROM OPENXML(@idoc, 'root/Transactions/Transaction', 2) WITH (
					intTransactionId INT
					,strTransactionType NVARCHAR(50)
					) x
			WHERE x.strTransactionType = 'OUTPUT'
			)

	INSERT INTO ##tblMFTransaction (
		dtmDate
		,intShiftId
		,strTransactionType
		,intTransactionId
		,intInputItemId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderId
		,intItemId
		,intCategoryId
		)
	SELECT W.dtmPlannedDate
		,W.intPlannedShiftId AS intShiftId
		,strTransactionType
		,intProductionSummaryId AS intTransactionId
		,UnPvt.intItemId
		,UnPvt.dblQuantity
		,IU.intItemUOMId
		,UnPvt.intWorkOrderId
		,W.intItemId
		,I.intCategoryId
	FROM dbo.tblMFProductionSummary
	UNPIVOT(dblQuantity FOR strTransactionType IN (
				dblOpeningQuantity
				,dblCountQuantity
				,dblOpeningOutputQuantity
				,dblCountOutputQuantity
				,dblConsumedQuantity
				)) AS UnPvt
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = UnPvt.intWorkOrderId
		AND UnPvt.dblQuantity > 0
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = UnPvt.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICItem I ON I.intItemId = UnPvt.intItemId
	WHERE UnPvt.strTransactionType NOT IN (
			SELECT x.strTransactionType
			FROM OPENXML(@idoc, 'root/Transactions/Transaction', 2) WITH (
					intTransactionId INT
					,strTransactionType NVARCHAR(50)
					) x
			WHERE x.strTransactionType IN (
					'dblOpeningQuantity'
					,'dblCountQuantity'
					,'dblOpeningOutputQuantity'
					,'dblCountOutputQuantity'
					)
				AND x.intTransactionId = UnPvt.intProductionSummaryId
			)

	INSERT INTO ##tblMFTransaction (
		dtmDate
		,intShiftId
		,strTransactionType
		,intTransactionId
		,intInputItemId
		,dblQuantity
		,intItemUOMId
		,intWorkOrderId
		,intItemId
		,intCategoryId
		)
	SELECT W.dtmPlannedDate
		,W.intPlannedShiftId
		,strTransactionType
		,WLT.intWorkOrderProducedLotTransactionId AS intTransactionId
		,WLT.intItemId
		,WLT.dblQuantity
		,WLT.intItemUOMId
		,WLT.intWorkOrderId
		,W.intItemId
		,I.intCategoryId
	FROM tblMFWorkOrderProducedLotTransaction WLT
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = WLT.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = WLT.intItemId
	WHERE WLT.intWorkOrderProducedLotTransactionId NOT IN (
			SELECT x.intTransactionId
			FROM OPENXML(@idoc, 'root/Transactions/Transaction', 2) WITH (
					intTransactionId INT
					,strTransactionType NVARCHAR(50)
					) x
			WHERE x.strTransactionType IN (
					'Queued Qty Adj'
					,'Cycle Count Adj'
					)
			)

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @intCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId
		AND strAttributeValue <> ''

	IF @strMode = 'Run'
		AND @ysnIncludeIngredientItem = 0
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFYield') IS NOT NULL
			DROP TABLE ##tblMFYield

		SELECT DISTINCT TR.intWorkOrderId
			,W.strWorkOrderNo
			,TR.intItemId
			,TR.dtmDate
			,TR.intShiftId
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,W.intItemUOMId
		INTO ##tblMFYield
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		WHERE strTransactionType = 'OUTPUT'

		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM ##tblMFYield

		WHILE ISNULL(@intWorkOrderId, 0) > 0
		BEGIN
			SELECT @intItemId = MIN(intItemId)
			FROM ##tblMFYield
			WHERE intWorkOrderId = @intWorkOrderId

			WHILE @intItemId IS NOT NULL
			BEGIN
				SELECT @dblInput = NULL
					,@dblOutput = NULL
					,@dblInputCC = NULL
					,@dblInputOB = NULL
					,@dblOutputCC = NULL
					,@dblOutputOB = NULL
					,@dblTInput = NULL
					,@dblTOutput = NULL
					,@dblQueuedQtyAdj = NULL
					,@dblCycleCountAdj = NULL
					,@dblEmptyOutAdj = NULL

				SELECT @dblInput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'Input'

				SELECT @dblInput = 0

				SELECT @dblOutput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'Output'
					AND intItemId = @intItemId

				SELECT @dblInputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'dblCountQuantity'

				SELECT @dblInputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'dblOpeningQuantity'

				SELECT @dblOutputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'dblCountOutputQuantity'

				SELECT @dblOutputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'dblOpeningOutputQuantity'

				SELECT @dblQueuedQtyAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'Queued Qty Adj'

				SELECT @dblCycleCountAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'Cycle Count Adj'

				SELECT @dblEmptyOutAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND strTransactionType = 'Empty Out Adj'

				SELECT @dblCalculatedQuantity = 100 * (
						SELECT SUM(dblQuantity)
						FROM dbo.tblMFWorkOrderRecipeItem
						WHERE intWorkOrderId = @intWorkOrderId
							AND intRecipeItemTypeId = 2
							AND intItemId = @intItemId
						) / (
						SELECT SUM(dblCalculatedQuantity)
						FROM dbo.tblMFWorkOrderRecipeItem
						WHERE intWorkOrderId = @intWorkOrderId
							AND intRecipeItemTypeId = 1
						)

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTOutput OUTPUT

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTInput OUTPUT

				SET @dblYieldP = @dblTOutput / CASE 
						WHEN ISNULL(@dblTInput, 0) = 0
							THEN 1
						ELSE @dblTInput
						END

				UPDATE ##tblMFYield
				SET dblActualYield = ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
					,dblTotalInput = @dblTInput
					,dblTotalOutput = @dblTOutput
					,dblStandardYield = 100
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = @intItemId

				SELECT @intItemId = MIN(intItemId)
				FROM ##tblMFYield
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId > @intItemId
			END

			SELECT @intWorkOrderId = MIN(intWorkOrderId)
			FROM ##tblMFYield
			WHERE intWorkOrderId > @intWorkOrderId
		END

		SELECT dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId
			,SUM(dblTotalOutput) dblTotalOutput
			,SUM(dblTotalInput) dblTotalInput
			,SUM(dblDifference) dblDifference
			,AVG(dblActualYield) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM (
			SELECT @dtmFromDate AS dtmFromDate
				,@dtmToDate AS dtmToDate
				,@intManufacturingProcessId AS intManufacturingProcessId
				,@intLocationId AS intLocationId
				,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
				,ROUND(MIN(dblTotalInput), @dblDecimal) dblTotalInput
				,ROUND(ABS(MIN(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
				,ROUND(AVG(dblActualYield), @dblDecimal) dblActualYield
				--,CONVERT(INT, 1) AS intConcurrencyId
				,intWorkOrderId
			FROM ##tblMFYield
			GROUP BY intWorkOrderId
			) AS DT
		GROUP BY dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY Y.dtmDate
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,I.strItemNo
			,I.strDescription
			,Y.strWorkOrderNo AS strRunNo
			,Y.dtmDate AS dtmRunDate
			,S.strShiftName AS strShift
			,'' AS strInputItemNo
			,'' AS strInputItemDescription
			,ROUND(Y.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(Y.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(0.0, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(Y.dblActualYield, @dblDecimal) dblActualYield
			,ROUND(Y.dblStandardYield, @dblDecimal) dblStandardYield
			,ROUND(Y.dblActualYield - Y.dblStandardYield, @dblDecimal) dblVariance
			,'Output' AS strTransaction
		FROM ##tblMFYield Y
		JOIN dbo.tblICItem I ON I.intItemId = Y.intItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = Y.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = Y.intShiftId
	END

	IF @strMode = 'Run'
		AND @ysnIncludeIngredientItem = 1
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFInputItemYield') IS NOT NULL
			DROP TABLE ##tblMFInputItemYield

		SELECT DISTINCT TR.intWorkOrderId
			,W.strWorkOrderNo
			,TR.intItemId
			,TR.dtmDate
			,TR.intShiftId
			,TR.intInputItemId
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,isNULL(PS.dblRequiredQty, 0) AS dblRequiredQty
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,TR.intItemUOMId
			,strTransactionType
			,TR.intCategoryId
			,PS.intItemTypeId AS intRecipeItemTypeId
		INTO ##tblMFInputItemYield
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		JOIN dbo.tblMFProductionSummary PS ON PS.intWorkOrderId = W.intWorkOrderId
			AND PS.intItemId = TR.intInputItemId
		--JOIN dbo.tblICItem I ON I.intItemId = TR.intInputItemId
		--LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intSubstituteItemId  = TR.intInputItemId
		--	AND RS.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipeItem RI ON (RI.intItemId = TR.intInputItemId or RI.intItemId = RS.intItemId)
		--	AND RI.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = W.intItemId
		--	AND R.intWorkOrderId = W.intWorkOrderId
		--	AND R.intRecipeId = RI.intRecipeId
		WHERE strTransactionType IN (
				'INPUT'
				,'OUTPUT'
				,'dblOpeningQuantity'
				)

		--INSERT INTO ##tblMFInputItemYield
		--SELECT DISTINCT TR.intWorkOrderId
		--	,W.strWorkOrderNo
		--	,TR.intItemId
		--	,TR.dtmDate
		--	,TR.intShiftId
		--	,TR.intInputItemId
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
		--	,CASE 
		--		WHEN I.intCategoryId = @intCategoryId
		--			THEN CEILING(CAST(
		--				(Isnull((
		--									SELECT SUm(Case When W1.intItemUOMId =WP.intPhysicalItemUOMId Then  WP.dblPhysicalCount
		--									Else WP.dblQuantity End)
		--									FROM tblMFWorkOrderProducedLot WP
		--									JOIN tblMFWorkOrder W1 on W1.intWorkOrderId =WP.intWorkOrderId 
		--									WHERE WP.ysnFillPartialPallet =1
		--										AND WP.ysnProductionReversed = 0
		--										AND WP.intWorkOrderId = W.intWorkOrderId
		--									), 0)
		--							) 
		--							* RI.dblCalculatedQuantity / (
		--							CASE 
		--								WHEN R.dblQuantity = 0
		--									THEN 1
		--								ELSE R.dblQuantity
		--								END
		--							) AS NUMERIC(18, 6)))
		--		ELSE CAST(
		--				(Isnull((
		--									SELECT SUM(Case When W1.intItemUOMId =WP.intPhysicalItemUOMId Then  WP.dblPhysicalCount
		--									Else WP.dblQuantity End)
		--									FROM tblMFWorkOrderProducedLot WP
		--									JOIN tblMFWorkOrder W1 on W1.intWorkOrderId =WP.intWorkOrderId 
		--									WHERE WP.ysnFillPartialPallet =1
		--										AND WP.ysnProductionReversed = 0
		--										AND WP.intWorkOrderId = W.intWorkOrderId
		--									), 0)
		--							) 
		--							* RI.dblCalculatedQuantity / (
		--							CASE 
		--								WHEN R.dblQuantity = 0
		--									THEN 1
		--								ELSE R.dblQuantity
		--								END
		--							) AS NUMERIC(18, 6))
		--		END AS dblRequiredQty
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
		--	,TR.intItemUOMId
		--	,strTransactionType
		--	,TR.intCategoryId
		--	,RI.intRecipeItemTypeId
		--FROM ##tblMFTransaction TR
		--JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		--JOIN dbo.tblICItem I ON I.intItemId = TR.intInputItemId
		--LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intSubstituteItemId  = TR.intInputItemId
		--	AND RS.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipeItem RI ON (RI.intItemId = TR.intInputItemId or RI.intItemId = RS.intItemId)
		--	AND RI.intWorkOrderId = W.intWorkOrderId
		--LEFT JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = W.intItemId
		--	AND R.intWorkOrderId = W.intWorkOrderId
		--	AND R.intRecipeId = RI.intRecipeId
		--WHERE strTransactionType IN (
		--		'INPUT'
		--		,'OUTPUT'
		--		,'dblOpeningQuantity'
		--		)
		SELECT intWorkOrderId
			,strWorkOrderNo
			,intItemId
			,dtmDate
			,intShiftId
			,intInputItemId
			,dblTotalInput
			,SUM(dblRequiredQty) AS dblRequiredQty
			,dblTotalOutput
			,dblActualYield
			,dblStandardYield
			,dblVariance
			,intItemUOMId
			,strTransactionType
			,intCategoryId
			,intRecipeItemTypeId
		INTO ##tblMFFinalInputItemYield
		FROM ##tblMFInputItemYield
		GROUP BY intWorkOrderId
			,strWorkOrderNo
			,intItemId
			,dtmDate
			,intShiftId
			,intInputItemId
			,dblTotalInput
			,dblTotalOutput
			,dblActualYield
			,dblStandardYield
			,dblVariance
			,intItemUOMId
			,strTransactionType
			,intCategoryId
			,intRecipeItemTypeId

		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM ##tblMFFinalInputItemYield

		WHILE ISNULL(@intWorkOrderId, 0) > 0
		BEGIN
			SELECT @intInputItemId = NULL

			SELECT @intInputItemId = MIN(intInputItemId)
			FROM ##tblMFFinalInputItemYield
			WHERE intWorkOrderId = @intWorkOrderId

			WHILE ISNULL(@intInputItemId, 0) > 0
			BEGIN
				SELECT @dblInput = NULL
					,@dblOutput = NULL
					,@dblInputCC = NULL
					,@dblInputOB = NULL
					,@dblOutputCC = NULL
					,@dblOutputOB = NULL
					,@dblTInput = NULL
					,@dblTOutput = NULL
					,@dblQueuedQtyAdj = NULL
					,@dblCycleCountAdj = NULL
					,@dblEmptyOutAdj = NULL
					,@intInputItemUOMId = NULL
					,@intItemUOMId = NULL

				SELECT @intItemId = intItemId
				FROM ##tblMFFinalInputItemYield
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = @intInputItemId

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInput = SUM(dblQuantity)
						,@intInputItemUOMId = MIN(intItemUOMId)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND strTransactionType = 'Input'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInput = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND intInputItemId = @intInputItemId
						AND strTransactionType = 'Input'
				END

				SELECT @dblOutput = SUM(dblQuantity)
					,@intItemUOMId = MIN(intItemUOMId)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = @intInputItemId
					AND strTransactionType = 'Output'

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInputCC = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND strTransactionType = 'dblCountQuantity'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInputCC = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND intInputItemId = @intInputItemId
						AND strTransactionType = 'dblCountQuantity'
				END

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInputOB = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND strTransactionType = 'dblOpeningQuantity'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInputOB = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND strTransactionType = 'dblOpeningQuantity'
						AND intInputItemId = @intInputItemId
				END

				SELECT @dblOutputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblCountOutputQuantity'

				SELECT @dblOutputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblOpeningOutputQuantity'

				SELECT @dblQueuedQtyAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (
						CASE 
							WHEN @intInputItemId = @intItemId
								THEN intItemId
							ELSE @intInputItemId
							END
						)
					AND strTransactionType = 'Queued Qty Adj'

				SELECT @dblCycleCountAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Cycle Count Adj'

				SELECT @dblEmptyOutAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Empty Out Adj'

				SELECT @dblCalculatedQuantity = 100

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTOutput OUTPUT

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTInput OUTPUT

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblRequiredQty = 0

					--SELECT @dblRequiredQty = Sum(dblRequiredQty)
					--FROM ##tblMFFinalInputItemYield
					--WHERE intWorkOrderId = @intWorkOrderId
					--	AND intCategoryId <> @intCategoryId
					--	AND strTransactionType ='INPUT'
					SELECT @dblRequiredQty = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intWorkOrderId = @intWorkOrderId
						AND intCategoryId <> @intCategoryId
						AND strTransactionType = 'dblConsumedQuantity'

					SELECT @intFromUnitMeasureId = intUnitMeasureId
					FROM tblICItemUOM
					WHERE intItemUOMId = @intInputItemUOMId

					SELECT @intToUnitMeasureId = intUnitMeasureId
					FROM tblICItemUOM
					WHERE intItemUOMId = @intItemUOMId

					SELECT @dblConversionToStock = NULL

					IF @intFromUnitMeasureId <> @intToUnitMeasureId
						SELECT @dblConversionToStock = dblConversionToStock
						FROM tblICUnitMeasureConversion
						WHERE intUnitMeasureId = @intFromUnitMeasureId
							AND intStockUnitMeasureId = @intToUnitMeasureId

					IF @dblConversionToStock IS NULL
						SELECT @dblConversionToStock = 1

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL(@dblTInput, 0) = 0
								THEN 1
							ELSE @dblTInput
							END

					UPDATE ##tblMFFinalInputItemYield
					SET dblActualYield = @dblYieldP * 100
						,dblTotalInput = @dblTInput * @dblConversionToStock
						,dblTotalOutput = @dblTOutput
						,dblStandardYield = 100
					WHERE intWorkOrderId = @intWorkOrderId
						AND intInputItemId = @intInputItemId
				END
				ELSE
				BEGIN
					SELECT @dblRequiredQty = 0

					SELECT @dblRequiredQty = dblRequiredQty
					FROM tblMFProductionSummary
					WHERE intWorkOrderId = @intWorkOrderId
						AND intItemId = @intInputItemId

					IF @dblRequiredQty = 0
						OR @dblRequiredQty IS NULL
						SELECT @dblRequiredQty = dblRequiredQty
						FROM ##tblMFFinalInputItemYield
						WHERE intWorkOrderId = @intWorkOrderId
							AND intInputItemId = @intInputItemId

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL((@dblTInput - @dblTOutput), 0) = 0
								THEN 1
							ELSE (@dblTInput - @dblTOutput)
							END

					UPDATE ##tblMFFinalInputItemYield
					SET dblActualYield = @dblYieldP * 100
						,dblTotalInput = @dblTInput
						,dblTotalOutput = @dblTOutput
						,dblStandardYield = CASE 
							WHEN @dblRequiredQty = 0
								OR @dblRequiredQty IS NULL
								THEN 0
							ELSE 100
							END
						,dblRequiredQty = @dblRequiredQty
					WHERE intWorkOrderId = @intWorkOrderId
						AND intInputItemId = @intInputItemId
				END

				SELECT @intInputItemId = MIN(intInputItemId)
				FROM ##tblMFFinalInputItemYield
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId > @intInputItemId
			END

			SELECT @intWorkOrderId = MIN(intWorkOrderId)
			FROM ##tblMFFinalInputItemYield
			WHERE intWorkOrderId > @intWorkOrderId
		END

		DELETE
		FROM ##tblMFFinalInputItemYield
		WHERE strTransactionType = 'dblOpeningQuantity'
			AND intInputItemId IN (
				SELECT Y.intInputItemId
				FROM ##tblMFFinalInputItemYield Y
				WHERE Y.strTransactionType = 'Input'
				)

		SELECT dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId
			,SUM(dblTotalOutput) dblTotalOutput
			,SUM(dblTotalInput) dblTotalInput
			,SUM(dblDifference) dblDifference
			,AVG(dblActualYield) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM (
			SELECT @dtmFromDate AS dtmFromDate
				,@dtmToDate AS dtmToDate
				,@intManufacturingProcessId AS intManufacturingProcessId
				,@intLocationId AS intLocationId
				,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
				,ROUND(MIN(dblTotalInput), @dblDecimal) dblTotalInput
				,ROUND(ABS(MIN(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
				,ROUND(AVG(dblActualYield), @dblDecimal) dblActualYield
				,intWorkOrderId
			FROM ##tblMFFinalInputItemYield
			WHERE intInputItemId = intItemId
			GROUP BY intWorkOrderId
			) AS DT
		GROUP BY dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.intWorkOrderId
						,IY.dtmDate
						,IY.intShiftId
						,(
							CASE 
								WHEN intRecipeItemTypeId = 2
									THEN 'Output'
								ELSE 'Input'
								END
							)
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,I.strItemNo
			,I.strDescription
			,IY.strWorkOrderNo AS strRunNo
			,IY.dtmDate AS dtmRunDate
			,S.strShiftName AS strShift
			,II.strItemNo AS strInputItemNo
			,II.strDescription AS strInputItemDescription
			,ROUND(IY.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(IY.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(dblRequiredQty, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(IY.dblActualYield, @dblDecimal) dblActualYield
			,ROUND(IY.dblStandardYield, @dblDecimal) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, @dblDecimal) dblVariance
			,CASE 
				WHEN intRecipeItemTypeId = 2
					THEN 'Output'
				ELSE 'Input'
				END AS strTransaction
		FROM ##tblMFFinalInputItemYield IY
		JOIN dbo.tblICItem I ON I.intItemId = IY.intItemId
		JOIN dbo.tblICItem II ON II.intItemId = IY.intInputItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = IY.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = IY.intShiftId
	END

	IF @strMode = 'Date'
		AND @ysnIncludeIngredientItem = 0
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFYieldByDate') IS NOT NULL
			DROP TABLE ##tblMFYieldByDate

		SELECT DISTINCT Dense_Rank() OVER (
				ORDER BY TR.intItemId
					,TR.dtmDate
					,TR.intShiftId
				) AS intYieldId
			,TR.intItemId
			,TR.dtmDate
			,TR.intShiftId
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblRequiredQty
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,TR.intItemUOMId
			,W.intItemId AS intPrimaryItemId
		INTO ##tblMFYieldByDate
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		WHERE strTransactionType = 'OUTPUT'

		SELECT @intYieldId = MIN(intYieldId)
		FROM ##tblMFYieldByDate

		WHILE ISNULL(@intYieldId, 0) > 0
		BEGIN
			SELECT @intItemId = MIN(intItemId)
			FROM ##tblMFYieldByDate
			WHERE intYieldId = @intYieldId

			WHILE @intItemId IS NOT NULL
			BEGIN
				SELECT @dtmDate = NULL
					,@intShiftId = NULL
					,@dblInput = NULL
					,@dblOutput = NULL
					,@dblInputCC = NULL
					,@dblInputOB = NULL
					,@dblOutputCC = NULL
					,@dblOutputOB = NULL
					,@intItemId = NULL
					,@dblTInput = NULL
					,@dblTOutput = NULL
					,@dblQueuedQtyAdj = NULL
					,@dblCycleCountAdj = NULL
					,@dblEmptyOutAdj = NULL
					,@intPrimaryItemId = NULL

				SELECT @intItemId = intItemId
					,@dtmDate = dtmDate
					,@intShiftId = intShiftId
					,@intPrimaryItemId = intPrimaryItemId
				FROM ##tblMFYieldByDate
				WHERE intYieldId = @intYieldId

				SELECT @dblInput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intPrimaryItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'Input'

				SELECT @dblInput = 0

				SELECT @dblOutput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'Output'
					AND intItemId = @intItemId

				SELECT @dblInputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intPrimaryItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'dblCountQuantity'

				SELECT @dblInputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intPrimaryItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'dblOpeningQuantity'

				SELECT @dblOutputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'dblCountOutputQuantity'

				SELECT @dblOutputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'dblOpeningOutputQuantity'

				SELECT @dblQueuedQtyAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'Queued Qty Adj'

				SELECT @dblCycleCountAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'Cycle Count Adj'

				SELECT @dblEmptyOutAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND strTransactionType = 'Empty Out Adj'

				SELECT @intRecipeId = NULL

				SELECT @intRecipeId = intRecipeId
				FROM dbo.tblMFRecipe
				WHERE intItemId = @intPrimaryItemId
					AND intLocationId = @intLocationId
					AND ysnActive = 1

				SELECT @dblCalculatedQuantity = 100 * (
						SELECT SUM(dblQuantity)
						FROM dbo.tblMFRecipeItem
						WHERE intRecipeId = @intRecipeId
							AND intRecipeItemTypeId = 2
							AND intItemId = @intItemId
						) / (
						SELECT SUM(dblCalculatedQuantity)
						FROM dbo.tblMFRecipeItem
						WHERE intRecipeId = @intRecipeId
							AND intRecipeItemTypeId = 1
						)

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTOutput OUTPUT

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTInput OUTPUT

				SET @dblYieldP = @dblTOutput / CASE 
						WHEN ISNULL(@dblTInput, 0) = 0
							THEN 1
						ELSE @dblTInput
						END

				UPDATE ##tblMFYieldByDate
				SET dblActualYield = ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
					,dblTotalInput = @dblTInput
					,dblTotalOutput = @dblTOutput
					,dblStandardYield = 100
				WHERE intYieldId = @intYieldId
					AND intItemId = @intItemId

				SELECT @intItemId = MIN(intItemId)
				FROM ##tblMFYieldByDate
				WHERE intYieldId = @intYieldId
					AND intItemId > @intItemId
			END

			SELECT @intYieldId = MIN(intYieldId)
			FROM ##tblMFYieldByDate
			WHERE intYieldId > @intYieldId
		END

		SELECT dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId
			,SUM(dblTotalOutput) dblTotalOutput
			,SUM(dblTotalInput) dblTotalInput
			,SUM(dblDifference) dblDifference
			,AVG(dblActualYield) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM (
			SELECT @dtmFromDate AS dtmFromDate
				,@dtmToDate AS dtmToDate
				,@intManufacturingProcessId AS intManufacturingProcessId
				,@intLocationId AS intLocationId
				,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
				,ROUND(MIN(dblTotalInput), @dblDecimal) dblTotalInput
				,ROUND(ABS(MIN(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
				,ROUND(AVG(dblActualYield), @dblDecimal) dblActualYield
				,dtmDate
				,intShiftId
				,intPrimaryItemId
			FROM ##tblMFYieldByDate
			GROUP BY dtmDate
				,intShiftId
				,intPrimaryItemId
			) AS DT
		GROUP BY dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmDate
						,IY.intShiftId
						,IY.intPrimaryItemId
						,IY.intItemId
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,I.strItemNo
			,I.strDescription
			,'' AS strRunNo
			,IY.dtmDate AS dtmRunDate
			,S.strShiftName AS strShift
			,'' AS strInputItemNo
			,'' AS strInputItemDescription
			,ROUND(IY.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(IY.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(0.0, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(IY.dblActualYield, @dblDecimal) dblActualYield
			,ROUND(IY.dblStandardYield, @dblDecimal) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, @dblDecimal) dblVariance
			,'Output' AS strTransaction
		FROM ##tblMFYieldByDate IY
		JOIN dbo.tblICItem I ON I.intItemId = IY.intItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = IY.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = IY.intShiftId
	END

	IF @strMode = 'Date'
		AND @ysnIncludeIngredientItem = 1
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFInputItemYieldByDate') IS NOT NULL
			DROP TABLE ##tblMFInputItemYieldByDate

		SELECT DISTINCT Dense_Rank() OVER (
				ORDER BY TR.intItemId
					,TR.dtmDate
					,TR.intShiftId
				) AS intYieldId
			,TR.intItemId
			,TR.dtmDate
			,TR.intShiftId
			,TR.intInputItemId
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,isNULL(SUM(CASE 
						WHEN strTransactionType = 'INPUT'
							THEN PS.dblRequiredQty
						ELSE 0
						END), 0) AS dblRequiredQty
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,TR.intItemUOMId
			,W.intItemId AS intPrimaryItemId
			,strTransactionType
			,TR.intCategoryId
			,PS.intItemTypeId intRecipeItemTypeId
		INTO ##tblMFInputItemYieldByDate
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = TR.intInputItemId
		JOIN dbo.tblMFProductionSummary PS ON PS.intWorkOrderId = W.intWorkOrderId
			AND PS.intItemId = TR.intInputItemId
		--LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intSubstituteItemId  = TR.intInputItemId
		--	AND RS.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipeItem RI ON (RI.intItemId = TR.intInputItemId or RI.intItemId = RS.intItemId)
		--	AND RI.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = TR.intItemId
		--	AND R.intWorkOrderId = TR.intWorkOrderId
		--	AND R.intRecipeId = RI.intRecipeId
		WHERE strTransactionType IN (
				'INPUT'
				,'OUTPUT'
				,'dblOpeningQuantity'
				)
		GROUP BY TR.intItemId
			,TR.dtmDate
			,TR.intShiftId
			,TR.intInputItemId
			,TR.intItemUOMId
			,W.intItemId
			,strTransactionType
			,TR.intCategoryId
			,PS.intItemTypeId

		--INSERT INTO ##tblMFInputItemYieldByDate
		--SELECT DISTINCT Dense_Rank() OVER (
		--		ORDER BY TR.intItemId
		--			,TR.dtmDate
		--			,TR.intShiftId
		--		) AS intYieldId
		--	,TR.intItemId
		--	,TR.dtmDate
		--	,TR.intShiftId
		--	,TR.intInputItemId
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
		--	,CASE 
		--		WHEN I.intCategoryId = @intCategoryId
		--			THEN CEILING(CAST(
		--				(Isnull((
		--									SELECT SUm(Case When W1.intItemUOMId =WP.intPhysicalItemUOMId Then  WP.dblPhysicalCount
		--									Else WP.dblQuantity End)
		--									FROM tblMFWorkOrderProducedLot WP
		--									JOIN tblMFWorkOrder W1 on W1.intWorkOrderId =WP.intWorkOrderId 
		--									WHERE WP.ysnFillPartialPallet =1
		--										AND WP.ysnProductionReversed = 0
		--										AND WP.intWorkOrderId = W.intWorkOrderId
		--									), 0)
		--							) 
		--							* RI.dblCalculatedQuantity / (
		--							CASE 
		--								WHEN R.dblQuantity = 0
		--									THEN 1
		--								ELSE R.dblQuantity
		--								END
		--							) AS NUMERIC(18, 6)))
		--		ELSE CAST(
		--				(Isnull((
		--									SELECT SUM(Case When W1.intItemUOMId =WP.intPhysicalItemUOMId Then  WP.dblPhysicalCount
		--									Else WP.dblQuantity End)
		--									FROM tblMFWorkOrderProducedLot WP
		--									JOIN tblMFWorkOrder W1 on W1.intWorkOrderId =WP.intWorkOrderId 
		--									WHERE WP.ysnFillPartialPallet =1
		--										AND WP.ysnProductionReversed = 0
		--										AND WP.intWorkOrderId = W.intWorkOrderId
		--									), 0)
		--							) 
		--							* RI.dblCalculatedQuantity / (
		--							CASE 
		--								WHEN R.dblQuantity = 0
		--									THEN 1
		--								ELSE R.dblQuantity
		--								END
		--							) AS NUMERIC(18, 6))
		--		END AS dblRequiredQty
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
		--	,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
		--	,TR.intItemUOMId
		--	,W.intItemId AS intPrimaryItemId
		--	,strTransactionType
		--	,TR.intCategoryId
		--	,RI.intRecipeItemTypeId 
		--FROM ##tblMFTransaction TR
		--JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		--JOIN dbo.tblICItem I ON I.intItemId = TR.intInputItemId
		--LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intSubstituteItemId  = TR.intInputItemId
		--	AND RS.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipeItem RI ON (RI.intItemId = TR.intInputItemId or RI.intItemId = RS.intItemId)
		--	AND RI.intWorkOrderId = W.intWorkOrderId
		--JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = TR.intItemId
		--	AND R.intWorkOrderId = TR.intWorkOrderId
		--	AND R.intRecipeId = RI.intRecipeId
		--WHERE strTransactionType IN (
		--		'INPUT'
		--		,'OUTPUT'
		--		,'dblOpeningQuantity'
		--		)
		SELECT intYieldId
			,intItemId
			,dtmDate
			,intShiftId
			,intInputItemId
			,dblTotalInput
			,SUM(dblRequiredQty) AS dblRequiredQty
			,dblTotalOutput
			,dblActualYield
			,dblStandardYield
			,dblVariance
			,intItemUOMId
			,intPrimaryItemId
			,strTransactionType
			,intCategoryId
			,intRecipeItemTypeId
		INTO ##tblMFFinalInputItemYieldByDate
		FROM ##tblMFInputItemYieldByDate
		GROUP BY intYieldId
			,intItemId
			,dtmDate
			,intShiftId
			,intInputItemId
			,dblTotalInput
			,dblTotalOutput
			,dblActualYield
			,dblStandardYield
			,dblVariance
			,intItemUOMId
			,intPrimaryItemId
			,strTransactionType
			,intCategoryId
			,intRecipeItemTypeId

		SELECT @intYieldId = MIN(intYieldId)
		FROM ##tblMFFinalInputItemYieldByDate

		WHILE ISNULL(@intYieldId, 0) > 0
		BEGIN
			SELECT @dtmDate = NULL
				,@intShiftId = NULL

			SELECT @intInputItemId = NULL

			SELECT @intInputItemId = MIN(intInputItemId)
			FROM ##tblMFFinalInputItemYieldByDate
			WHERE intYieldId = @intYieldId

			WHILE ISNULL(@intInputItemId, 0) > 0
			BEGIN
				SELECT @dblInput = NULL
					,@dblOutput = NULL
					,@dblInputCC = NULL
					,@dblInputOB = NULL
					,@dblOutputCC = NULL
					,@dblOutputOB = NULL
					,@dblTInput = NULL
					,@dblTOutput = NULL
					,@dblQueuedQtyAdj = NULL
					,@dblCycleCountAdj = NULL
					,@dblEmptyOutAdj = NULL
					,@intPrimaryItemId = NULL
					,@intInputItemUOMId = NULL
					,@intItemUOMId = NULL

				SELECT @intItemId = intItemId
					,@dtmDate = dtmDate
					,@intShiftId = intShiftId
					,@intPrimaryItemId = intPrimaryItemId
				FROM ##tblMFFinalInputItemYieldByDate
				WHERE intYieldId = @intYieldId
					AND intInputItemId = @intInputItemId

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInput = SUM(dblQuantity)
						,@intInputItemUOMId = MIN(intItemUOMId)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intInputItemId = CASE 
							WHEN @intInputItemId = @intItemId
								THEN intInputItemId
							ELSE @intInputItemId
							END
						AND strTransactionType = 'Input'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInput = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intInputItemId = CASE 
							WHEN @intInputItemId = @intItemId
								THEN intInputItemId
							ELSE @intInputItemId
							END
						AND strTransactionType = 'Input'
				END

				SELECT @dblOutput = SUM(dblQuantity)
					,@intItemUOMId = MIN(intItemUOMId)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = @intInputItemId
					AND strTransactionType = 'Output'

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInputCC = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intInputItemId = CASE 
							WHEN @intInputItemId = @intItemId
								THEN intInputItemId
							ELSE @intInputItemId
							END
						AND strTransactionType = 'dblCountQuantity'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInputCC = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intInputItemId = CASE 
							WHEN @intInputItemId = @intItemId
								THEN intInputItemId
							ELSE @intInputItemId
							END
						AND strTransactionType = 'dblCountQuantity'
				END

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblInputOB = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND strTransactionType = 'dblOpeningQuantity'
						AND intCategoryId <> @intCategoryId
				END
				ELSE
				BEGIN
					SELECT @dblInputOB = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intInputItemId = @intInputItemId
						AND strTransactionType = 'dblOpeningQuantity'
				END

				SELECT @dblOutputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblCountOutputQuantity'

				SELECT @dblOutputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblOpeningOutputQuantity'

				SELECT @dblQueuedQtyAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Queued Qty Adj'

				SELECT @dblCycleCountAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Cycle Count Adj'

				SELECT @dblEmptyOutAdj = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = @intInputItemId
					AND strTransactionType = 'Empty Out Adj'

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblCalculatedQuantity = 100
				END
				ELSE
				BEGIN
					SELECT @dblCalculatedQuantity = 100
				END

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTOutput OUTPUT

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTInput OUTPUT

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblRequiredQty = 0

					--SELECT @dblRequiredQty = SUM(dblRequiredQty)
					--FROM ##tblMFFinalInputItemYieldByDate
					--WHERE intItemId = @intPrimaryItemId
					--	AND dtmDate = @dtmDate
					--	AND intShiftId = IsNULL(@intShiftId, intShiftId)
					--	AND intCategoryId <> @intCategoryId
					--	AND strTransactionType ='INPUT'
					SELECT @dblRequiredQty = SUM(dblQuantity)
					FROM ##tblMFTransaction
					WHERE intItemId = @intPrimaryItemId
						AND dtmDate = @dtmDate
						AND intShiftId = IsNULL(@intShiftId, intShiftId)
						AND intCategoryId <> @intCategoryId
						AND strTransactionType = 'dblConsumedQuantity'

					SELECT @intFromUnitMeasureId = intUnitMeasureId
					FROM tblICItemUOM
					WHERE intItemUOMId = @intInputItemUOMId

					SELECT @intToUnitMeasureId = intUnitMeasureId
					FROM tblICItemUOM
					WHERE intItemUOMId = @intItemUOMId

					SELECT @dblConversionToStock = NULL

					IF @intFromUnitMeasureId <> @intToUnitMeasureId
						SELECT @dblConversionToStock = dblConversionToStock
						FROM tblICUnitMeasureConversion
						WHERE intUnitMeasureId = @intFromUnitMeasureId
							AND intStockUnitMeasureId = @intToUnitMeasureId

					IF @dblConversionToStock IS NULL
						SELECT @dblConversionToStock = 1

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL(@dblTInput, 0) = 0
								THEN 1
							ELSE @dblTInput
							END

					UPDATE ##tblMFFinalInputItemYieldByDate
					SET dblActualYield = CASE 
							WHEN @intInputItemId = @intItemId
								THEN ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
							ELSE ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
							END
						,dblTotalInput = @dblTInput * @dblConversionToStock
						,dblTotalOutput = @dblTOutput
						,dblStandardYield = 100
					WHERE intYieldId = @intYieldId
						AND intInputItemId = @intInputItemId
				END
				ELSE
				BEGIN
					SELECT @dblRequiredQty = 0

					SELECT @dblRequiredQty = SUM(dblRequiredQty)
					FROM ##tblMFFinalInputItemYieldByDate
					WHERE intInputItemId = @intInputItemId

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL((@dblTInput - @dblTOutput), 0) = 0
								THEN 1
							ELSE (@dblTInput - @dblTOutput)
							END

					UPDATE ##tblMFFinalInputItemYieldByDate
					SET dblActualYield = CASE 
							WHEN @intInputItemId = @intItemId
								THEN ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
							ELSE ((@dblYieldP * 100) / @dblCalculatedQuantity) * 100
							END
						,dblTotalInput = @dblTInput
						,dblTotalOutput = @dblTOutput
						,dblStandardYield = CASE 
							WHEN @dblRequiredQty IS NULL
								OR @dblRequiredQty = 0
								THEN 0
							ELSE 100
							END
					WHERE intYieldId = @intYieldId
						AND intInputItemId = @intInputItemId
				END

				SELECT @intInputItemId = MIN(intInputItemId)
				FROM ##tblMFFinalInputItemYieldByDate
				WHERE intYieldId = @intYieldId
					AND intInputItemId > @intInputItemId
			END

			SELECT @intYieldId = MIN(intYieldId)
			FROM ##tblMFFinalInputItemYieldByDate
			WHERE intYieldId > @intYieldId
		END

		DELETE
		FROM ##tblMFFinalInputItemYieldByDate
		WHERE strTransactionType = 'dblOpeningQuantity'
			AND intInputItemId IN (
				SELECT Y.intInputItemId
				FROM ##tblMFFinalInputItemYieldByDate Y
				WHERE Y.strTransactionType = 'Input'
				)

		SELECT dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId
			,SUM(dblTotalOutput) dblTotalOutput
			,SUM(dblTotalInput) dblTotalInput
			,SUM(dblDifference) dblDifference
			,AVG(dblActualYield) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM (
			SELECT @dtmFromDate AS dtmFromDate
				,@dtmToDate AS dtmToDate
				,@intManufacturingProcessId AS intManufacturingProcessId
				,@intLocationId AS intLocationId
				,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
				,ROUND(MIN(dblTotalInput), @dblDecimal) dblTotalInput
				,ROUND(ABS(MIN(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
				,ROUND(AVG(dblActualYield), @dblDecimal) dblActualYield
				,dtmDate
				,intShiftId
				,intPrimaryItemId
			FROM ##tblMFFinalInputItemYieldByDate
			WHERE intInputItemId = intItemId
			GROUP BY dtmDate
				,intShiftId
				,intPrimaryItemId
			) AS DT
		GROUP BY dtmFromDate
			,dtmToDate
			,intManufacturingProcessId
			,intLocationId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmDate
						,IY.intShiftId
						,(
							CASE 
								WHEN intRecipeItemTypeId = 2
									THEN 'Output'
								ELSE 'Input'
								END
							)
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,I.strItemNo
			,I.strDescription
			,'' AS strRunNo
			,IY.dtmDate AS dtmRunDate
			,S.strShiftName AS strShift
			,II.strItemNo AS strInputItemNo
			,II.strDescription AS strInputItemDescription
			,ROUND(IY.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(IY.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(dblRequiredQty, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(IY.dblActualYield, @dblDecimal) dblActualYield
			,ROUND(IY.dblStandardYield, @dblDecimal) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, @dblDecimal) dblVariance
			,CASE 
				WHEN intRecipeItemTypeId = 2
					THEN 'Output'
				ELSE 'Input'
				END AS strTransaction
		FROM ##tblMFFinalInputItemYieldByDate IY
		JOIN dbo.tblICItem I ON I.intItemId = IY.intItemId
		JOIN dbo.tblICItem II ON II.intItemId = IY.intInputItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = IY.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = IY.intShiftId
	END

	IF OBJECT_ID('tempdb..##tblMFTransaction') IS NOT NULL
		DROP TABLE ##tblMFTransaction

	IF OBJECT_ID('tempdb..##tblMFYield') IS NOT NULL
		DROP TABLE ##tblMFYield

	IF OBJECT_ID('tempdb..##tblMFInputItemYield') IS NOT NULL
		DROP TABLE ##tblMFInputItemYield

	IF OBJECT_ID('tempdb..##tblMFFinalInputItemYield') IS NOT NULL
		DROP TABLE ##tblMFFinalInputItemYield

	IF OBJECT_ID('tempdb..##tblMFYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFYieldByDate

	IF OBJECT_ID('tempdb..##tblMFInputItemYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFInputItemYieldByDate

	IF OBJECT_ID('tempdb..##tblMFFinalInputItemYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFFinalInputItemYieldByDate
END TRY

BEGIN CATCH
	IF OBJECT_ID('tempdb..##tblMFTransaction') IS NOT NULL
		DROP TABLE ##tblMFTransaction

	IF OBJECT_ID('tempdb..##tblMFYield') IS NOT NULL
		DROP TABLE ##tblMFYield

	IF OBJECT_ID('tempdb..##tblMFInputItemYield') IS NOT NULL
		DROP TABLE ##tblMFInputItemYield

	IF OBJECT_ID('tempdb..##tblMFFinalInputItemYield') IS NOT NULL
		DROP TABLE ##tblMFFinalInputItemYield

	IF OBJECT_ID('tempdb..##tblMFYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFYieldByDate

	IF OBJECT_ID('tempdb..##tblMFInputItemYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFInputItemYieldByDate

	IF OBJECT_ID('tempdb..##tblMFFinalInputItemYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFFinalInputItemYieldByDate

	SET @strErrMsg = 'uspMFGetYieldView - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


