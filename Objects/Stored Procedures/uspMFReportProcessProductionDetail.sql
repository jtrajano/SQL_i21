CREATE PROCEDURE uspMFReportProcessProductionDetail @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strLocationName NVARCHAR(50)
		,@idoc INT
		,@strSubLocationName NVARCHAR(50)
		,@dtmPlannedDate DATETIME
		,@strShiftName NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strWorkorderNo NVARCHAR(50)
		,@intCompanyLocationId INT
		,@intCompanyLocationSubLocationId INT
		,@intItemId INT
		,@intWorkOrderId INT
		,@intLocationId INT
		,@intPlannedShiftId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	DECLARE @temp_Params TABLE (
		fieldname NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	INSERT INTO @temp_Params
	SELECT *
	FROM OPENXML(@idoc, 'filterinfo/parameter', 2) WITH (
			fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strLocationName = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'strLocationName'

	SELECT @strSubLocationName = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'strSubLocationName'

	SELECT @dtmPlannedDate = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'dtmPlannedDate'

	SELECT @strShiftName = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'strShiftName'

	SELECT @strItemNo = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'strItemNo'

	SELECT @strWorkorderNo = [from]
	FROM @temp_Params
	WHERE [fieldname] = 'strWorkorderNo'

	SELECT @intWorkOrderId = intWorkOrderId
	FROM tblMFWorkOrder
	WHERE strWorkOrderNo = @strWorkorderNo

	IF @intWorkOrderId IS NULL
	BEGIN
		SELECT @intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblSMCompanyLocation
		WHERE strLocationName = @strLocationName

		SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
		FROM dbo.tblSMCompanyLocationSubLocation
		WHERE strSubLocationName = @strSubLocationName
			AND intCompanyLocationId = @intLocationId

		SELECT @intItemId = intItemId
		FROM dbo.tblICItem
		WHERE CASE 
				WHEN IsNull(strShortName, '') = ''
					THEN strItemNo
				ELSE strShortName
				END = @strItemNo

		SELECT @intPlannedShiftId = intShiftId
		FROM tblMFShift
		WHERE strShiftName = @strShiftName

		SELECT @intWorkOrderId = intWorkOrderId
		FROM dbo.tblMFWorkOrder
		WHERE dtmPlannedDate = @dtmPlannedDate
			AND ISNULL(intPlannedShiftId, @intPlannedShiftId) = @intPlannedShiftId
			AND intItemId = @intItemId
			AND intLocationId = @intCompanyLocationId
			AND intSubLocationId = @intCompanyLocationSubLocationId
	END

	--Finding Opening Balance  
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,(PS.dblOpeningQuantity + PS.dblOpeningOutputQuantity) AS dblOpeningQuantity
		,NULL AS dblInputQuantity
		,NULL AS dblConsumeQuantity
		,NULL AS dblProducedQuantity
		,NULL AS dblCountQuantity
		,0 AS intStorageLocationId
		,'' AS strName
		,1 AS intRowNumber
	FROM tblMFProductionSummary PS
	JOIN tblICItem I ON PS.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE PS.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	--Finding Input Quantity  
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,NULL AS dblOpeningQuantity
		,WI.dblQuantity AS dblInputQty
		,NULL AS dblConsumeQuantity
		,NULL AS dblProducedQuantity
		,NULL AS dblCountQuantity
		,SL.intStorageLocationId
		,SL.strName
		,2 AS intRowNumber
	FROM tblMFWorkOrderInputLot WI
	JOIN tblICItem I ON WI.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WI.intStorageLocationId
	WHERE WI.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	--Finding FG Produced Quantity  
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,NULL AS dblOpeningQuantity
		,NULL AS dblInputQuantity
		,NULL AS dblConsumeQuantity
		,WP.dblQuantity
		,NULL AS dblCountQuantity
		,SL.intStorageLocationId
		,SL.strName
		,3 AS intRowNumber
	FROM tblMFWorkOrderProducedLot WP
	JOIN tblICItem I ON WP.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WP.intStorageLocationId
	WHERE WP.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	--Finding Consume Quantity  
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,NULL AS dblOpeningQuantity
		,NULL AS dblInputQuantity
		,WC.dblQuantity
		,NULL AS dblProducedQuantity
		,NULL AS dblCountQuantity
		,SL.intStorageLocationId
		,SL.strName
		,4 AS intRowNumber
	FROM tblMFWorkOrderConsumedLot WC
	JOIN tblICItem I ON WC.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = WC.intStorageLocationId
	WHERE WC.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	--Finding Current Cyclecount Qty  
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,NULL AS dblOpeningQuantity
		,NULL AS dblInputQuantity
		,NULL AS dblConsumeQuantity
		,NULL AS dblProducedQuantity
		,(PS.dblCountQuantity + PS.dblCountOutputQuantity) AS dblCountQuantity
		,0 AS intStorageLocationId
		,'' AS strName
		,5 AS intRowNumber
	FROM tblMFProductionSummary PS
	JOIN tblICItem I ON PS.intItemId = I.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE PS.intWorkOrderId = @intWorkOrderId
	ORDER BY intRowNumber
		,strItemNo
END
GO


