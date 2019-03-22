CREATE PROCEDURE uspMFGetYieldViewTransaction @strXML NVARCHAR(MAX)
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
		,@idoc INT
		,@intLocationId INT
		,@intManufacturingProcessId INT
		,@strMode NVARCHAR(50)
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@intOwnerId INT
	DECLARE @tblMFWorkOrder TABLE (
		intWorkOrderId INT
		,dtmPlannedDate DATETIME
		,intPlannedShiftId INT
		,intItemId INT
		)

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
		SELECT DISTINCT W.intWorkOrderId
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
		SELECT DISTINCT W.intWorkOrderId
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
		,WI.dblQuantity AS dblQuantity
		,WI.intItemUOMId
		,WI.intWorkOrderId
		,W.intItemId
		,I.intCategoryId
	FROM dbo.tblMFWorkOrderInputLot WI
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = WI.intItemId

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
				)) AS UnPvt
	JOIN @tblMFWorkOrder W ON W.intWorkOrderId = UnPvt.intWorkOrderId
		AND UnPvt.dblQuantity > 0
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = UnPvt.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICItem I ON I.intItemId = UnPvt.intItemId

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

		SELECT CONVERT(INT, ROW_NUMBER() OVER (
					ORDER BY T.dtmDate DESC
					)) AS intRowId
		,W.strWorkOrderNo 
		,T.dtmDate
		,S.strShiftName 
		,T.strTransactionType
		,T.intTransactionId
		,I.strItemNo 
		,I.strDescription 
		,T.dblQuantity
		,UM.strUnitMeasure 
		,C.strCategoryCode 
	FROM ##tblMFTransaction T
	JOIN tblMFWorkOrder W on W.intWorkOrderId =T.intWorkOrderId 
	JOIN tblICItem I on I.intItemId=intInputItemId
	JOIN tblICCategory C on C.intCategoryId =I.intCategoryId 
	JOIN tblICItemUOM IU on IU.intItemUOMId =T.intItemUOMId 
	JOIN tblICUnitMeasure UM on UM.intUnitMeasureId =IU.intUnitMeasureId 
	Left JOIN tblMFShift S on S.intShiftId =T.intShiftId 
END TRY

BEGIN CATCH
	IF OBJECT_ID('tempdb..##tblMFTransaction') IS NOT NULL
		DROP TABLE ##tblMFTransaction

	SET @strErrMsg = 'uspMFGetYieldView - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO



