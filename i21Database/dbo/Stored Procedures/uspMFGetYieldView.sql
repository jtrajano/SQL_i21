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
		,@strTimeBasedProduction NVARCHAR(50)
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

	SELECT @ysnIncludeIngredientItem = ysnShowInputItemInYieldView
	FROM dbo.tblMFCompanyPreference

	SELECT @dblDecimal = 2

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @strMode = strMode
		,@dtmFromDate = dtmFromDate
		,@dtmToDate = ISNULL(dtmToDate, @dtmFromDate)
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strMode NVARCHAR(50)
			,dtmFromDate DATETIME
			,dtmToDate DATETIME
			,intManufacturingProcessId INT
			,intLocationId INT
			)

	SELECT @strIFormula = strInputFormula
		,@strOFormula = strOutputFormula
	FROM dbo.tblMFYield
	WHERE intManufacturingProcessId = @intManufacturingProcessId

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
		)
	SELECT WI.dtmProductionDate
		,WI.intShiftId
		,'INPUT' COLLATE Latin1_General_CI_AS AS strTransactionType
		,WI.intWorkOrderInputLotId AS intTransactionId
		,WI.intItemId
		,WI.dblQuantity AS dblQuantity
		,WI.intItemUOMId
		,WI.intWorkOrderId
		,W.intItemId
	FROM dbo.tblMFWorkOrderInputLot WI
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
	WHERE W.intManufacturingProcessId = @intManufacturingProcessId
		AND WI.dtmProductionDate BETWEEN @dtmFromDate
			AND @dtmToDate

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
		)
	SELECT WP.dtmProductionDate
		,WP.intShiftId
		,'OUTPUT' COLLATE Latin1_General_CI_AS AS strTransactionType
		,WP.intWorkOrderProducedLotId AS intTransactionId
		,WP.intItemId
		,WP.dblQuantity
		,WP.intItemUOMId
		,WP.intWorkOrderId
		,W.intItemId
	FROM dbo.tblMFWorkOrderProducedLot WP
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WP.intWorkOrderId
	WHERE W.intManufacturingProcessId = @intManufacturingProcessId
		AND WP.dtmProductionDate BETWEEN @dtmFromDate
			AND @dtmToDate

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
		)
	SELECT ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
		,W.intPlannedShiftId As intShiftId
		,strTransactionType
		,intProductionSummaryId AS intTransactionId
		,UnPvt.intItemId
		,UnPvt.dblQuantity
		,NULL intItemUOMId
		,UnPvt.intWorkOrderId
		,W.intItemId
	FROM dbo.tblMFProductionSummary
	UNPIVOT(dblQuantity FOR strTransactionType IN (
				dblOpeningQuantity
				,dblCountQuantity
				,dblOpeningOutputQuantity
				,dblCountOutputQuantity
				)) AS UnPvt
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = UnPvt.intWorkOrderId
		AND UnPvt.dblQuantity > 0
	WHERE W.intManufacturingProcessId = @intManufacturingProcessId
		AND ISNULL(W.dtmPlannedDate, W.dtmExpectedDate) BETWEEN @dtmFromDate
			AND @dtmToDate

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
		)
	SELECT ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
		,WLT.intShiftId
		,strTransactionType
		,WLT.intWorkOrderProducedLotTransactionId AS intTransactionId
		,WLT.intItemId
		,WLT.dblQuantity
		,WLT.intItemUOMId
		,WLT.intWorkOrderId
		,W.intItemId
	FROM tblMFWorkOrderProducedLotTransaction WLT
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WLT.intWorkOrderId
	WHERE W.intManufacturingProcessId = @intManufacturingProcessId
		AND ISNULL(W.dtmPlannedDate, W.dtmExpectedDate) BETWEEN @dtmFromDate
			AND @dtmToDate

	IF @strMode = 'Run'
		AND @ysnIncludeIngredientItem = 0
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFYield') IS NOT NULL
			DROP TABLE ##tblMFYield

		SELECT DISTINCT TR.intWorkOrderId
			,W.strWorkOrderNo
			,W.intItemId
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

		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM ##tblMFYield

		WHILE ISNULL(@intWorkOrderId, 0) > 0
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

			SELECT @intItemId = intItemId
			FROM ##tblMFYield
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @dblInput = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Input'

			SELECT @dblOutput = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Output'

			SELECT @dblInputCC = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblCountQuantity'

			SELECT @dblInputOB = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblOpeningQuantity'

			--SELECT @dblInputOB
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
					SELECT TOP 1 dblQuantity
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
			SET dblActualYield = @dblYieldP * 100
				,dblTotalInput = @dblTInput
				,dblTotalOutput = @dblTOutput
				,dblStandardYield = @dblCalculatedQuantity
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @intWorkOrderId = MIN(intWorkOrderId)
			FROM ##tblMFYield
			WHERE intWorkOrderId > @intWorkOrderId
		END

		SELECT @dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
			,@intManufacturingProcessId AS intManufacturingProcessId
			,@intLocationId AS intLocationId
			,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
			,ROUND(SUM(dblTotalInput), @dblDecimal) dblTotalInput
			,ROUND(ABS(SUM(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
			,ROUND(AVG(dblActualYield), 2) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM ##tblMFYield

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
			,ROUND(0, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(Y.dblActualYield, 2) dblActualYield
			,ROUND(Y.dblStandardYield, 2) dblStandardYield
			,ROUND(Y.dblActualYield - Y.dblStandardYield, 2) dblVariance
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
			,CAST(W.dblProducedQuantity  * RI.dblCalculatedQuantity / (
					CASE 
						WHEN R.dblQuantity = 0
							THEN 1
						ELSE R.dblQuantity
						END
					) AS NUMERIC(18, 6)) AS dblRequiredQty
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,RI.intItemUOMId
		INTO ##tblMFInputItemYield
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = TR.intInputItemId
			AND RI.intWorkOrderId = W.intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = W.intItemId
			AND R.intWorkOrderId = W.intWorkOrderId
			AND R.intRecipeId = RI.intRecipeId

		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM ##tblMFInputItemYield

		WHILE ISNULL(@intWorkOrderId, 0) > 0
		BEGIN
			SELECT @intInputItemId = NULL

			SELECT @intInputItemId = MIN(intInputItemId)
			FROM ##tblMFInputItemYield
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

				SELECT @intItemId = intItemId
				FROM ##tblMFInputItemYield
				WHERE intWorkOrderId = @intWorkOrderId

				SELECT @dblInput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Input'

				SELECT @dblOutput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Output'

				SELECT @dblInputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblCountQuantity'

				SELECT @dblInputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblOpeningQuantity'

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

				IF @intInputItemId = @intItemId
				BEGIN
					SELECT @dblCalculatedQuantity = 100 * (
							SELECT TOP 1 dblQuantity
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
					SET @dblYieldP = @dblTOutput / CASE 
							WHEN ISNULL(@dblTInput, 0) = 0
								THEN 1
							ELSE @dblTInput
							END
				END
				ELSE
				BEGIN
					SELECT @dblRequiredQty = 0

					SELECT @dblRequiredQty = dblRequiredQty
					FROM ##tblMFInputItemYield
					WHERE intWorkOrderId = @intWorkOrderId
						AND intInputItemId = @intInputItemId

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL((@dblTInput-@dblTOutput), 0) = 0
								THEN 1
							ELSE (@dblTInput-@dblTOutput)
							END
				END

				UPDATE ##tblMFInputItemYield
				SET dblActualYield = @dblYieldP * 100
					,dblTotalInput = @dblTInput
					,dblTotalOutput = @dblTOutput
					,dblStandardYield = @dblCalculatedQuantity
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId = @intInputItemId

				SELECT @intInputItemId = MIN(intInputItemId)
				FROM ##tblMFInputItemYield
				WHERE intWorkOrderId = @intWorkOrderId
					AND intInputItemId > @intInputItemId
			END

			SELECT @intWorkOrderId = MIN(intWorkOrderId)
			FROM ##tblMFInputItemYield
			WHERE intWorkOrderId > @intWorkOrderId
		END

		SELECT @dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
			,@intManufacturingProcessId AS intManufacturingProcessId
			,@intLocationId AS intLocationId
			,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
			,ROUND(SUM(dblTotalInput), @dblDecimal) dblTotalInput
			,ROUND(ABS(SUM(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
			,ROUND(AVG(dblActualYield), 2) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM ##tblMFInputItemYield
		WHERE intInputItemId = intItemId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmDate
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
			,ROUND(IY.dblActualYield, 2) dblActualYield
			,ROUND(IY.dblStandardYield, 2) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, 2) dblVariance
		FROM ##tblMFInputItemYield IY
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
			,W.intItemUOMId
		INTO ##tblMFYieldByDate
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId

		SELECT @intYieldId = MIN(intYieldId)
		FROM ##tblMFYieldByDate

		WHILE ISNULL(@intYieldId, 0) > 0
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

			SELECT @intItemId = intItemId
				,@dtmDate = dtmDate
				,@intShiftId = intShiftId
			FROM ##tblMFYieldByDate
			WHERE intYieldId = @intYieldId

			SELECT @dblInput = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intItemId = @intItemId
				AND dtmDate = @dtmDate
				AND intShiftId = IsNULL(@intShiftId, intShiftId)
				AND strTransactionType = 'Input'

			SELECT @dblOutput = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intItemId = @intItemId
				AND dtmDate = @dtmDate
				AND intShiftId = IsNULL(@intShiftId, intShiftId)
				AND strTransactionType = 'Output'

			SELECT @dblInputCC = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intItemId = @intItemId
				AND dtmDate = @dtmDate
				AND intShiftId = IsNULL(@intShiftId, intShiftId)
				AND strTransactionType = 'dblCountQuantity'

			SELECT @dblInputOB = SUM(dblQuantity)
			FROM ##tblMFTransaction
			WHERE intItemId = @intItemId
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
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND ysnActive = 1

			SELECT @dblCalculatedQuantity = 100 * (
					SELECT TOP 1 dblQuantity
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
			SET dblActualYield = @dblYieldP * 100
				,dblTotalInput = @dblTInput
				,dblTotalOutput = @dblTOutput
				,dblStandardYield = @dblCalculatedQuantity
			WHERE intYieldId = @intYieldId

			SELECT @intYieldId = MIN(intYieldId)
			FROM ##tblMFYieldByDate
			WHERE intYieldId > @intYieldId
		END

		SELECT @dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
			,@intManufacturingProcessId AS intManufacturingProcessId
			,@intLocationId AS intLocationId
			,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
			,ROUND(SUM(dblTotalInput), @dblDecimal) dblTotalInput
			,ROUND(ABS(SUM(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
			,ROUND(AVG(dblActualYield), 2) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM ##tblMFYieldByDate

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmDate
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
			,ROUND(0, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(IY.dblActualYield, 2) dblActualYield
			,ROUND(IY.dblStandardYield, 2) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, 2) dblVariance
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
			,CAST(W.dblProducedQuantity  * RI.dblCalculatedQuantity / (
					CASE 
						WHEN R.dblQuantity = 0
							THEN 1
						ELSE R.dblQuantity
						END
					) AS NUMERIC(18, 6)) AS dblRequiredQty
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
			,RI.intItemUOMId
		INTO ##tblMFInputItemYieldByDate
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = TR.intInputItemId
			AND RI.intWorkOrderId = TR.intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipe R ON R.intItemId = TR.intItemId
			AND R.intWorkOrderId = TR.intWorkOrderId
			AND R.intRecipeId = RI.intRecipeId

		SELECT @intYieldId = MIN(intYieldId)
		FROM ##tblMFInputItemYieldByDate

		WHILE ISNULL(@intYieldId, 0) > 0
		BEGIN
			SELECT @dtmDate = NULL
				,@intShiftId = NULL

			SELECT @intItemId = intItemId
				,@dtmDate = dtmDate
				,@intShiftId = intShiftId
			FROM ##tblMFInputItemYieldByDate
			WHERE intYieldId = @intYieldId

			SELECT @intInputItemId = NULL

			SELECT @intInputItemId = MIN(intInputItemId)
			FROM ##tblMFInputItemYieldByDate
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

				SELECT @dblInput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Input'

				SELECT @dblOutput = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'Output'

				SELECT @dblInputCC = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblCountQuantity'

				SELECT @dblInputOB = SUM(dblQuantity)
				FROM ##tblMFTransaction
				WHERE intItemId = @intItemId
					AND dtmDate = @dtmDate
					AND intShiftId = IsNULL(@intShiftId, intShiftId)
					AND intInputItemId = CASE 
						WHEN @intInputItemId = @intItemId
							THEN intInputItemId
						ELSE @intInputItemId
						END
					AND strTransactionType = 'dblOpeningQuantity'

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
					SELECT @intRecipeId = NULL

					SELECT @intRecipeId = intRecipeId
					FROM dbo.tblMFRecipe
					WHERE intItemId = @intItemId
						AND intLocationId = @intLocationId
						AND ysnActive = 1

					SELECT @dblCalculatedQuantity = 100 * (
							SELECT TOP 1 dblQuantity
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
					SET @dblYieldP = @dblTOutput / CASE 
							WHEN ISNULL(@dblTInput, 0) = 0
								THEN 1
							ELSE @dblTInput
							END
				END
				ELSE
				BEGIN
					SELECT @dblRequiredQty = 0

					SELECT @dblRequiredQty = dblRequiredQty
					FROM ##tblMFInputItemYieldByDate
					WHERE intYieldId = @intYieldId
						AND intInputItemId = @intInputItemId

					SET @dblYieldP = @dblRequiredQty / CASE 
							WHEN ISNULL((@dblTInput-@dblTOutput), 0) = 0
								THEN 1
							ELSE (@dblTInput-@dblTOutput)
							END
				END

				UPDATE ##tblMFInputItemYieldByDate
				SET dblActualYield = @dblYieldP * 100
					,dblTotalInput = @dblTInput
					,dblTotalOutput = @dblTOutput
					,dblStandardYield = @dblCalculatedQuantity
				WHERE intYieldId = @intYieldId
					AND intInputItemId = @intInputItemId

				SELECT @intInputItemId = MIN(intInputItemId)
				FROM ##tblMFInputItemYieldByDate
				WHERE intYieldId = @intYieldId
					AND intInputItemId > @intInputItemId
			END

			SELECT @intYieldId = MIN(intYieldId)
			FROM ##tblMFInputItemYieldByDate
			WHERE intYieldId > @intYieldId
		END

		SELECT @dtmFromDate AS dtmFromDate
			,@dtmToDate AS dtmToDate
			,@intManufacturingProcessId AS intManufacturingProcessId
			,@intLocationId AS intLocationId
			,ROUND(SUM(dblTotalOutput), @dblDecimal) dblTotalOutput
			,ROUND(SUM(dblTotalInput), @dblDecimal) dblTotalInput
			,ROUND(ABS(SUM(dblTotalInput) - SUM(dblTotalOutput)), @dblDecimal) dblDifference
			,ROUND(AVG(dblActualYield), 2) dblActualYield
			,CONVERT(INT, 1) AS intConcurrencyId
		FROM ##tblMFInputItemYieldByDate
		WHERE intInputItemId = intItemId

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmDate
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,I.strItemNo
			,I.strDescription
			,'' AS strRunNo
			,IY.dtmDate AS dtmRunDate
			,S.strShiftName AS strShift
			,II.strItemNo
			,II.strDescription
			,ROUND(IY.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(IY.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(dblRequiredQty, @dblDecimal) dblRequiredQty
			,U.strUnitMeasure
			,ROUND(IY.dblActualYield, 2) dblActualYield
			,ROUND(IY.dblStandardYield, 2) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, 2) dblVariance
		FROM ##tblMFInputItemYieldByDate IY
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

	IF OBJECT_ID('tempdb..##tblMFYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFYieldByDate

	IF OBJECT_ID('tempdb..##tblMFInputItemYieldByDate') IS NOT NULL
		DROP TABLE ##tblMFInputItemYieldByDate
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFGetYieldView - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


