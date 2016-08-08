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

	SELECT @ysnIncludeIngredientItem = 1

	SELECT @dblDecimal = 2

	SELECT @strDestinationUOMName = strUnitMeasure
		,@intDestinationUOMId = intUnitMeasureId
	FROM dbo.tblICUnitMeasure
	WHERE strUnitMeasure IN (
			'pound'
			,'LB'
			)

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
		intTransactionTypeId INT
		,dtmProductionDate DATETIME
		,strShiftName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmTransactionDate DATETIME
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intTransactionId INT
		,intItemId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(150) COLLATE Latin1_General_CI_AS
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblTransactionQuantity NUMERIC(18, 6)
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intUnitMeasureId INT
		,intWorkOrderId INT
		,strProcess NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,ysnIncluded BIT
		)

	SELECT @strSQL = 
		'
		SELECT 3 AS intTransactionTypeId
			,WI.dtmProductionDate
			,S.strShiftName
			,WI.dtmBusinessDate AS dtmTransactionDate
			,''INPUT'' COLLATE Latin1_General_CI_AS AS strTransactionType
			,WI.intWorkOrderInputLotId AS intTransactionId
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,L.strLotNumber
			,WI.dblQuantity AS dblTransactionQuantity
			,UM.strUnitMeasure
			,UM.intUnitMeasureId
			,WI.intWorkOrderId
			,''Yes'' COLLATE Latin1_General_CI_AS AS strProcess
			,CAST(1 AS BIT) AS IsIncluded
		FROM dbo.tblMFWorkOrderInputLot WI
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
		JOIN dbo.tblMFManufacturingProcess P ON P.intManufacturingProcessId = W.intManufacturingProcessId
		JOIN dbo.tblICLot L ON L.intLotId = WI.intLotId
		JOIN dbo.tblICItem I on I.intItemId=L.intItemId
		JOIN dbo.tblICItemUOM IU on IU.intItemUOMId=WI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S on S.intShiftId=WI.intShiftId
		WHERE W.intManufacturingProcessId = ' 
		+ ltrim(@intManufacturingProcessId) + '
			AND WI.dtmProductionDate BETWEEN ''' + ltrim(@dtmFromDate) + '''
				AND ''' + ltrim(@dtmToDate) + 
		'''
		UNION
		SELECT 4 AS intTransactionTypeId
			,WP.dtmProductionDate
			,S.strShiftName
			,WP.dtmProductionDate AS dtmTransactionDate
			,''OUTPUT'' COLLATE Latin1_General_CI_AS AS strTransactionType
			,WP.intWorkOrderProducedLotId AS intTransactionId
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,L.strLotNumber
			,WP.dblQuantity AS dblTransactionQuantity
			,UM.strUnitMeasure
			,UM.intUnitMeasureId
			,WP.intWorkOrderId
			,''Yes'' COLLATE Latin1_General_CI_AS AS strProcess
			,CAST(1 AS BIT) AS IsIncluded
		FROM dbo.tblMFWorkOrderProducedLot WP
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WP.intWorkOrderId
		JOIN dbo.tblMFManufacturingProcess P ON P.intManufacturingProcessId = W.intManufacturingProcessId
		JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
		JOIN dbo.tblICItem I on I.intItemId=L.intItemId
		JOIN dbo.tblICItemUOM IU on IU.intItemUOMId=WP.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblMFShift S on S.intShiftId=WP.intShiftId
		WHERE W.intManufacturingProcessId = ' 
		+ ltrim(@intManufacturingProcessId) + '
			AND WP.dtmProductionDate BETWEEN ''' + ltrim(@dtmFromDate) + '''
				AND ''' + ltrim(@dtmToDate) + 
		'''
		UNION

		SELECT 36 AS intTransactionTypeId
			,ISNULL(W.dtmPlannedDate,W.dtmExpectedDate)
			,NULL strShiftName
			,ISNULL(W.dtmPlannedDate,W.dtmExpectedDate) AS dtmTransactionDate
			,strTransactionType
			,intProductionSummaryId AS intTransactionId
			,UnPvt.intItemId
			,I.strItemNo
			,I.strDescription
			,NULL strLotNumber
			,UnPvt.dblTransactionQuantity
			,NULL strUnitMeasure
			,NULL intUnitMeasureId
			,UnPvt.intWorkOrderId
			,''Yes'' COLLATE Latin1_General_CI_AS AS strProcess
			,CAST(1 AS BIT) AS IsIncluded
		FROM dbo.tblMFProductionSummary
		UNPIVOT(dblTransactionQuantity FOR strTransactionType IN (
					dblOpeningQuantity
					,dblCountQuantity
					,dblOpeningOutputQuantity
					,dblCountOutputQuantity
					)) AS UnPvt

		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = UnPvt.intWorkOrderId
		JOIN dbo.tblMFManufacturingProcess P ON P.intManufacturingProcessId = W.intManufacturingProcessId
		JOIN dbo.tblICItem I ON I.intItemId=UnPvt.intItemId
		WHERE dblTransactionQuantity>0 and W.intManufacturingProcessId = ' 
		+ ltrim(@intManufacturingProcessId) + '
			AND ISNULL(W.dtmPlannedDate,W.dtmExpectedDate) BETWEEN ''' + ltrim(@dtmFromDate) + '''
				AND ''' + ltrim(@dtmToDate) + 
		'''
		UNION

		SELECT 
			intTransactionTypeId
			,ISNULL(W.dtmPlannedDate,W.dtmExpectedDate)
			,S.strShiftName
			,WLT.dtmTransactionDate
			,strTransactionType
			,WLT.intWorkOrderProducedLotTransactionId AS intTransactionId
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,L.strLotNumber
			,WLT.dblQuantity AS dblTransactionQuantity
			,UM.strUnitMeasure
			,UM.intUnitMeasureId
			,WLT.intWorkOrderId
			,''No'' COLLATE Latin1_General_CI_AS AS strProcess
			,CAST(1 AS BIT) AS IsIncluded
		FROM tblMFWorkOrderProducedLotTransaction WLT
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WLT.intWorkOrderId
		JOIN dbo.tblICLot L ON L.intLotId = WLT.intLotId
		JOIN dbo.tblICItem I on I.intItemId=L.intItemId
		JOIN dbo.tblICItemUOM IU on IU.intItemUOMId=WLT.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFShift S on S.intShiftId=WLT.intShiftId
		JOIN dbo.tblMFManufacturingProcess P ON P.intManufacturingProcessId = W.intManufacturingProcessId
		WHERE W.intManufacturingProcessId = ' 
		+ ltrim(@intManufacturingProcessId) + '
			AND WLT.dtmTransactionDate BETWEEN ''' + ltrim(@dtmFromDate) + '''
				AND ''' + ltrim(@dtmToDate) + '''
		ORDER BY 4
		'

	--Select @strSQL
	INSERT INTO ##tblMFTransaction
	EXEC (@strSQL)

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Time based production'

	SELECT @strTimeBasedProduction = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strTimeBasedProduction IS NULL
		SELECT @strTimeBasedProduction = 'False'

	IF @strMode = 'Run'
		AND @ysnIncludeIngredientItem = 0
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFYield') IS NOT NULL
			DROP TABLE ##tblMFYield

		SELECT DISTINCT TR.intWorkOrderId
			,I.strItemNo
			,I.strDescription
			,CAST('' AS NVARCHAR(50)) AS strRunNo
			,CAST(NULL AS DATETIME) AS dtmRunDate
			,CAST('' AS NVARCHAR(50)) AS strShift
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalOutput
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblActualYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblStandardYield
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblVariance
		INTO ##tblMFYield
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId

		--Select *from ##tblMFTransaction
		SELECT @intWorkOrderId = MIN(intWorkOrderId)
		FROM ##tblMFYield

		WHILE ISNULL(@intWorkOrderId, 0) > 0
		BEGIN
			SELECT @strRunNo = NULL
				,@dtmRunDate = NULL
				,@strShiftName = NULL
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

			SELECT @strRunNo = strWorkOrderNo
				,@intItemId = intItemId
				,@dtmRunDate = ISNULL(dtmPlannedDate, dtmExpectedDate)
				,@intManufacturingProcessId = intManufacturingProcessId
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @strShiftName = MAX(strShiftName)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @dblInput = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Input'

			SELECT @dblOutput = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Output'

			SELECT @dblInputCC = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblCountQuantity'

			SELECT @dblInputOB = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblOpeningQuantity'

			--SELECT @dblInputOB
			SELECT @dblOutputCC = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblCountOutputQuantity'

			SELECT @dblOutputOB = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'dblOpeningOutputQuantity'

			SELECT @dblQueuedQtyAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Queued Qty Adj'

			SELECT @dblCycleCountAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Cycle Count Adj'

			SELECT @dblEmptyOutAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransaction
			WHERE intWorkOrderId = @intWorkOrderId
				AND strTransactionType = 'Empty Out Adj'

			IF @strTimeBasedProduction = 'True'
			BEGIN
				SELECT @dblCalculatedQuantity = 100 * (
						SELECT TOP 1 dblCalculatedQuantity
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
				SELECT @dblCalculatedQuantity = (
						SELECT TOP 1 dblCalculatedQuantity
						FROM dbo.tblMFRecipeItem
						WHERE intRecipeId = R.intRecipeId
							AND intRecipeItemTypeId = 2
							AND intItemId = @intItemId
						) * CASE 
						WHEN C2.strCategoryCode = 'FINISHED GOODS'
							THEN MAX(I2.dblNetWeight)
						ELSE 1
						END / SUM(dblCalculatedQuantity) * 100
				FROM dbo.tblMFRecipe R
				JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
				JOIN dbo.tblICItem I1 ON I1.intItemId = RI.intItemId
				JOIN dbo.tblICCategory C1 ON C1.intCategoryId = I1.intCategoryId
					AND C1.strCategoryCode <> 'PACK MATERIAL'
				JOIN dbo.tblICItem I2 ON I2.intItemId = R.intItemId
				JOIN dbo.tblICCategory C2 ON C2.intCategoryId = I2.intCategoryId
				WHERE R.intItemId = @intItemId
					AND R.intLocationId = @intLocationId
					AND R.ysnActive = 1
					AND RI.intRecipeItemTypeId = 1
				GROUP BY R.intRecipeId
					,C1.strCategoryCode
					,C2.strCategoryCode
			END

			SET @strCFormula = ''

			SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

			EXEC sp_executesql @strCFormula
				,N'@strYieldValue Numeric(18, 6) OUTPUT'
				,@strYieldValue = @dblTOutput OUTPUT

			SET @strCFormula = ''

			SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

			EXEC sp_executesql @strCFormula
				,N'@strYieldValue Numeric(18, 6) OUTPUT'
				,@strYieldValue = @dblTInput OUTPUT

			SET @dblYieldP = @dblTOutput / CASE 
					WHEN ISNULL(@dblTInput, 0) = 0
						THEN 1
					ELSE @dblTInput
					END

			UPDATE ##tblMFYield
			SET strRunNo = @strRunNo
				,dtmRunDate = @dtmRunDate
				,strShift = @strShiftName
				,dblActualYield = @dblYieldP * 100
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
					ORDER BY dtmRunDate
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,strItemNo
			,strDescription
			,strRunNo
			,dtmRunDate
			,strShift
			,ROUND(dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(dblTotalInput, @dblDecimal) dblTotalInput
			,@strDestinationUOMName strUnitMeasure
			,ROUND(dblActualYield, 2) dblActualYield
			,ROUND(dblStandardYield, 2) dblStandardYield
			,ROUND(dblActualYield - dblStandardYield, 2) dblVariance
		FROM ##tblMFYield
	END

	IF @strMode = 'Run'
		AND @ysnIncludeIngredientItem = 1
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFInputItemYield') IS NOT NULL
			DROP TABLE ##tblMFInputItemYield

		SELECT DISTINCT TR.intWorkOrderId
			,I.strItemNo
			,I.strDescription
			,CAST('' AS NVARCHAR(50)) AS strRunNo
			,CAST(NULL AS DATETIME) AS dtmRunDate
			,CAST('' AS NVARCHAR(50)) AS strShift
			,TR.intItemId AS intInputItemId
			,CAST(0.0 AS NUMERIC(18, 6)) AS dblTotalInput
			,CAST(W.dblQuantity * RI.dblCalculatedQuantity / (
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
		INTO ##tblMFInputItemYield
		FROM ##tblMFTransaction TR
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = TR.intItemId
			AND RI.intWorkOrderId = W.intWorkOrderId
		LEFT JOIN dbo.tblMFWorkOrderRecipeItem R ON R.intItemId = W.intItemId
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
				SELECT @strRunNo = NULL
					,@dtmRunDate = NULL
					,@strShiftName = NULL
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

				SELECT @strRunNo = strWorkOrderNo
					,@intItemId = intItemId
					,@dtmRunDate = ISNULL(dtmPlannedDate, dtmExpectedDate)
					,@intManufacturingProcessId = intManufacturingProcessId
				FROM tblMFWorkOrder
				WHERE intWorkOrderId = @intWorkOrderId

				SELECT @strShiftName = MAX(strShiftName)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId

				SELECT @dblInput = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'Input'

				SELECT @dblOutput = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'Output'

				SELECT @dblInputCC = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'dblCountQuantity'

				SELECT @dblInputOB = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'dblOpeningQuantity'

				SELECT @dblOutputCC = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'dblCountOutputQuantity'

				SELECT @dblOutputOB = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'dblOpeningOutputQuantity'

				SELECT @dblQueuedQtyAdj = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'Queued Qty Adj'

				SELECT @dblCycleCountAdj = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
					AND strTransactionType = 'Cycle Count Adj'

				SELECT @dblEmptyOutAdj = SUM(dblTransactionQuantity)
				FROM ##tblMFTransaction
				WHERE intWorkOrderId = @intWorkOrderId
					AND intItemId = (Case When @intInputItemId = @intItemId Then intItemId Else @intInputItemId End)
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

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

				EXEC sp_executesql @strCFormula
					,N'@strYieldValue Numeric(18, 6) OUTPUT'
					,@strYieldValue = @dblTOutput OUTPUT

				SET @strCFormula = ''

				SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

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
							WHEN ISNULL(@dblTInput, 0) = 0
								THEN 1
							ELSE @dblTInput
							END
				END

				UPDATE ##tblMFInputItemYield
				SET strRunNo = @strRunNo
					,dtmRunDate = @dtmRunDate
					,strShift = @strShiftName
					,dblActualYield = @dblYieldP * 100
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

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY IY.dtmRunDate
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,IY.strItemNo
			,IY.strDescription
			,IY.strRunNo
			,IY.dtmRunDate
			,IY.strShift
			,I.strItemNo
			,I.strDescription
			,ROUND(IY.dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(IY.dblTotalInput, @dblDecimal) dblTotalInput
			,ROUND(dblRequiredQty, @dblDecimal) dblRequiredQty
			,@strDestinationUOMName strUnitMeasure
			,ROUND(IY.dblActualYield, 2) dblActualYield
			,ROUND(IY.dblStandardYield, 2) dblStandardYield
			,ROUND(IY.dblActualYield - dblStandardYield, 2) dblVariance
		FROM ##tblMFInputItemYield IY
		JOIN dbo.tblICItem I ON I.intItemId = IY.intInputItemId
	END

	IF @strMode = 'Date'
		OR @strMode = 'Both'
	BEGIN
		IF OBJECT_ID('tempdb..##tblMFTransactionByDate') IS NOT NULL
			DROP TABLE ##tblMFTransactionByDate

		CREATE TABLE ##tblMFTransactionByDate (
			intRowNum INT
			,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,strItemNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			,strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			,dtmTransactionDate DATETIME
			,dblTransactionQuantity NUMERIC(18, 6)
			,dblStandardYield NUMERIC(18, 6)
			)

		IF @strTimeBasedProduction = 'True'
		BEGIN
			INSERT INTO ##tblMFTransactionByDate
			SELECT DENSE_RANK() OVER (
					ORDER BY ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
						,W.intItemId
					) intRowNum
				,strTransactionType
				,I.strItemNo
				,I.strDescription
				,ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
				,CASE 
					WHEN strTransactionType = 'Output'
						THEN SUM(dblTransactionQuantity)
					ELSE SUM(dblTransactionQuantity)
					END dblTransactionQuantity
				,100 * (
					SELECT TOP 1 dblCalculatedQuantity
					FROM tblMFWorkOrderRecipeItem
					WHERE intWorkOrderId = W.intWorkOrderId
						AND intRecipeItemTypeId = 2
						AND intRecipeItemId = W.intItemId
					) / (
					SELECT SUM(dblCalculatedQuantity)
					FROM tblMFWorkOrderRecipeItem
					WHERE intWorkOrderId = W.intWorkOrderId
						AND intRecipeItemId = 1
					)
			FROM ##tblMFTransaction TR
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
			JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			JOIN (
				SELECT WRI.intWorkOrderId
					,SUM(dblCalculatedQuantity) dblCalculatedQuantity
				FROM dbo.tblMFWorkOrderRecipeItem WRI
				WHERE intRecipeItemTypeId = 1
				GROUP BY WRI.intWorkOrderId
				) BM ON BM.intWorkOrderId = W.intWorkOrderId
			GROUP BY ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
				,I.strItemNo
				,I.strDescription
				,W.intItemId
				,strTransactionType
				,W.intWorkOrderId
				,dblCalculatedQuantity
		END
		ELSE
		BEGIN
			INSERT INTO ##tblMFTransactionByDate
			SELECT DENSE_RANK() OVER (
					ORDER BY ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
						,W.intItemId
					) intRowNum
				,strTransactionType
				,I.strItemNo
				,I.strDescription
				,ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
				,CASE 
					WHEN strTransactionType = 'Output'
						THEN SUM(dblTransactionQuantity)
					ELSE SUM(dblTransactionQuantity)
					END dblTransactionQuantity
				,100 * (
					SELECT dblCalculatedQuantity * CASE 
							WHEN C.strCategoryCode = 'FINISHED GOODS'
								THEN I.dblNetWeight
							ELSE 1
							END
					FROM tblMFRecipeItem RI
					JOIN tblICItem I ON I.intItemId = RI.intItemId
					JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
					WHERE RI.intRecipeId = BM.intRecipeId
						AND RI.intRecipeItemTypeId = 2
						AND RI.intItemId = W.intItemId
					) / dblCalculatedQuantity
			FROM ##tblMFTransaction TR
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = TR.intWorkOrderId
			JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			JOIN (
				SELECT R.intRecipeId
					,R.intItemId
					,SUM(RI.dblCalculatedQuantity) dblCalculatedQuantity
				FROM dbo.tblMFRecipe R
				JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
				JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
				JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
					AND C.strCategoryCode <> 'PACK MATERIAL'
				WHERE R.intLocationId = @intLocationId
					AND R.ysnActive = 1
					AND intRecipeItemTypeId = 1
				GROUP BY R.intRecipeId
					,R.intItemId
				) BM ON BM.intItemId = W.intItemId
			GROUP BY BM.intRecipeId
				,ISNULL(W.dtmPlannedDate, W.dtmExpectedDate)
				,W.intItemId
				,I.strItemNo
				,I.strDescription
				,I.intItemId
				,strTransactionType
				,W.intWorkOrderId
				,dblCalculatedQuantity
		END

		IF OBJECT_ID('tempdb..##tblMFYieldByDate') IS NOT NULL
			DROP TABLE ##tblMFYieldByDate

		SELECT intRowNum
			,TD.strItemNo
			,strDescription
			,CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS AS strRunNo
			,dtmTransactionDate AS dtmRunDate
			,CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS AS strShift
			,CAST(0.0 AS DECIMAL(24, 10)) AS dblTotalInput
			,CAST(0.0 AS DECIMAL(24, 10)) AS dblTotalOutput
			,CAST(0.0 AS DECIMAL(24, 2)) AS dblActualYield
			,dblStandardYield AS dblStandardYield
			,CAST(0.0 AS DECIMAL(24, 2)) AS dblVariance
		INTO ##tblMFYieldByDate
		FROM ##tblMFTransactionByDate TD
		GROUP BY intRowNum
			,dtmTransactionDate
			,TD.strItemNo
			,strDescription
			,dblStandardYield

		SELECT @intRowNum = MIN(intRowNum)
		FROM ##tblMFYieldByDate

		WHILE ISNULL(@intRowNum, 0) > 0
		BEGIN
			SELECT @strRunNo = NULL
				,@dtmRunDate = NULL
				,@strShiftName = NULL
				,@dblInput = NULL
				,@dblOutput = NULL
				,@dblInputCC = NULL
				,@dblInputOB = NULL
				,@dblOutputCC = NULL
				,@dblOutputOB = NULL
				--,@intProductionTypeId = NULL
				--,@intProductionId = NULL
				,@intItemId = NULL
				,@dblTInput = NULL
				,@dblTOutput = NULL
				,@dblQueuedQtyAdj = NULL
				,@dblCycleCountAdj = NULL
				,@dblEmptyOutAdj = NULL

			SELECT @dblInput = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'Input'

			SELECT @dblOutput = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'Output'

			SELECT @dblInputCC = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'dblCountQuantity'

			SELECT @dblInputOB = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'dblOpeningQuantity'

			SELECT @dblOutputCC = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'dblCountOutputQuantity'

			SELECT @dblOutputOB = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'dblOpeningOutputQuantity'

			SELECT @dblQueuedQtyAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'Queued Qty Adj'

			SELECT @dblCycleCountAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'Cycle Count Adj'

			SELECT @dblEmptyOutAdj = SUM(dblTransactionQuantity)
			FROM ##tblMFTransactionByDate
			WHERE intRowNum = @intRowNum
				AND strTransactionType = 'Empty Out Adj'

			SET @strCFormula = ''

			SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strOFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

			EXEC sp_executesql @strCFormula
				,N'@strYieldValue Numeric(18, 6) OUTPUT'
				,@strYieldValue = @dblTOutput OUTPUT

			SET @strCFormula = ''

			SELECT @strCFormula = 'SELECT @strYieldValue = ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@strIFormula, 'Output Opening Quantity', ' ' + ISNULL(LTRIM(@dblInputOB), '0')), 'Output Count Quantity', ' ' + ISNULL(LTRIM(@dblInputCC), '0')), 'Opening Quantity', ' ' + ISNULL(LTRIM(@dblOutputOB), '0')), 'Count Quantity', ' ' + ISNULL(LTRIM(@dblOutputCC), '0')), 'Output', ' ' + ISNULL(LTRIM(@dblOutput), '0')), 'Input', ' ' + ISNULL(LTRIM(@dblInput), '0')), 'Queued Qty Adj', ' ' + ISNULL(LTRIM(@dblQueuedQtyAdj), '0')), 'Cycle Count Adj', ' ' + ISNULL(LTRIM(@dblCycleCountAdj), '0')), 'Empty Out Adj', ' ' + ISNULL(LTRIM(@dblEmptyOutAdj), '0'))

			EXEC sp_executesql @strCFormula
				,N'@strYieldValue DECIMAL(24,10) OUTPUT'
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
			WHERE intRowNum = @intRowNum

			SELECT @intRowNum = MIN(intRowNum)
			FROM ##tblMFYieldByDate
			WHERE intRowNum > @intRowNum
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
					ORDER BY dtmRunDate
					)) AS intRowId
			,@intManufacturingProcessId AS intManufacturingProcessId
			,strItemNo
			,strDescription
			,CAST('' AS NVARCHAR(50)) AS strRunNo
			,dtmRunDate
			,CAST('' AS NVARCHAR(50)) AS strShift
			,ROUND(dblTotalOutput, @dblDecimal) dblTotalOutput
			,ROUND(dblTotalInput, @dblDecimal) dblTotalInput
			,@strDestinationUOMName strUnitMeasure
			,ROUND(dblActualYield, 2) dblActualYield
			,ROUND(dblStandardYield, 2) dblStandardYield
			,ROUND(dblActualYield - dblStandardYield, 2) dblVariance
		FROM ##tblMFYieldByDate
	END
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


