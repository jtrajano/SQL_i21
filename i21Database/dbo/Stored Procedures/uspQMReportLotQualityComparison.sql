CREATE PROCEDURE uspQMReportLotQualityComparison
     @intWorkOrderId INT = NULL
	,@strProcessName NVARCHAR(50) = NULL
	,@dtmPlannedDate DATETIME = NULL
	,@strShiftName NVARCHAR(50) = NULL
	,@strItemNo NVARCHAR(50) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF ISNULL(@intWorkOrderId, 0) = 0
	BEGIN
		IF ISNULL(@strProcessName, '') = ''
			RAISERROR (
					'Provide a process.'
					,16
					,1
					)

		IF ISNULL(@dtmPlannedDate, '') = ''
			RAISERROR (
					'Provide a date.'
					,16
					,1
					)

		IF ISNULL(@strShiftName, '') = ''
			RAISERROR (
					'Provide a shift.'
					,16
					,1
					)

		IF ISNULL(@strItemNo, '') = ''
			RAISERROR (
					'Provide a item.'
					,16
					,1
					)

		SELECT @intWorkOrderId = W.intWorkOrderId
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
			AND MP.strProcessName = @strProcessName
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			AND I.strItemNo = @strItemNo
		JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
			AND S.strShiftName = @strShiftName
		WHERE W.dtmPlannedDate = DATEADD(dd, DATEDIFF(dd, 0, @dtmPlannedDate), 0)
	END
	ELSE
	BEGIN
		SELECT @strProcessName = MP.strProcessName
			,@strShiftName = S.strShiftName
			,@strItemNo = I.strItemNo
			,@dtmPlannedDate = W.dtmPlannedDate
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
		WHERE W.intWorkOrderId = @intWorkOrderId
			AND W.dtmPlannedDate IS NOT NULL
	END

	SELECT @intWorkOrderId AS intWorkOrderId
		,'INPUT' AS InputLot
		,'OUTPUT' AS OutputLot
		,@strProcessName AS strProcessName
		,@strShiftName AS strShiftName
		,@strItemNo AS strItemNo
		,@dtmPlannedDate AS dtmPlannedDate
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportLotQualityComparison - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
