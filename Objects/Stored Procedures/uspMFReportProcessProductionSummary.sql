CREATE PROCEDURE [dbo].[uspMFReportProcessProductionSummary] @xmlParam NVARCHAR(MAX) = NULL
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
	WHERE [fieldname] = 'strCompanyLocationSubLocation'

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

	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,W.dtmPlannedDate
		,I1.strItemNo AS strTargetItemNo
		,I1.strDescription AS strTargetDescription
		,W.dblQuantity
		,UM1.intUnitMeasureId
		,UM1.strUnitMeasure AS strTargetUnitMeasure
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,(PS.dblOpeningQuantity + PS.dblOpeningOutputQuantity) AS dblOpeningQuantity
		,PS.dblInputQuantity AS dblInputQuantity
		,PS.dblConsumedQuantity
		,PS.dblOutputQuantity AS dblOutputQuantity
		,(PS.dblCountQuantity + PS.dblCountOutputQuantity) AS dblCountQuantity
		,(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) - (dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) AS dblYieldQuantity
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,MC.intManufacturingCellId
		,MC.strCellName + MC.strDescription AS strCellDesc
		,MP.intManufacturingProcessId
		,MP.strProcessName
		,CLS.intCompanyLocationSubLocationId
		,CLS.strSubLocationName
		,CL.intCompanyLocationId
		,CL.strLocationName
		,S.intShiftId
		,S.strShiftName
	FROM dbo.tblMFProductionSummary PS
	JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PS.intWorkOrderId
	JOIN dbo.tblICItem I1 ON I1.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
	JOIN dbo.tblSMCompanyLocationSubLocation CLS ON CLS.intCompanyLocationSubLocationId = W.intSubLocationId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	Left JOIN dbo.tblMFShift S on S.intShiftId=W.intPlannedShiftId
	WHERE PS.intWorkOrderId = @intWorkOrderId
	ORDER BY I.strItemNo
END



