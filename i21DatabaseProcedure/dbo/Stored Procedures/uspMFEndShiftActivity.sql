CREATE PROCEDURE uspMFEndShiftActivity
	@intManufacturingCellId INT
	,@intShiftActivityId INT
	,@intUserId INT
	,@strComment NVARCHAR(MAX)
	,@intLocationId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @TotalProducedQty INT
		,@intUnitMeasureId INT
	DECLARE @WorkOrderCreateDate DATETIME

	SELECT @WorkOrderCreateDate = dtmWorkOrderCreateDate
	FROM dbo.tblMFCompanyPreference

	DECLARE @shiftActivity TABLE (
		SeqKey INT IDENTITY
		,intManufacturingCellId INT
		,intLotId INT
		,dtmCreateDate DATETIME
		)

	INSERT INTO @shiftActivity (
		intManufacturingCellId
		,intLotId
		,dtmCreateDate
		)
	SELECT WO.intManufacturingCellId
		,WPL.intLotId
		,WPL.dtmCreated
	FROM dbo.tblMFWorkOrderProducedLot WPL
	JOIN dbo.tblMFWorkOrder WO ON WO.intWorkOrderId = WPL.intWorkOrderId
		AND WO.intManufacturingCellId = @intManufacturingCellId
	JOIN dbo.tblICLot L ON L.intLotId = WPL.intLotId
		AND L.intLocationId = @intLocationId
	WHERE WPL.intShiftActivityId IS NULL
		AND WPL.dtmCreated > @WorkOrderCreateDate

	DECLARE @SeqKey INT
		,@SAKey INT

	SELECT @SeqKey = MIN(SeqKey)
	FROM @shiftActivity

	WHILE @SeqKey IS NOT NULL
	BEGIN
		DECLARE @intLotId INT
			,@dtmLotCreateDate DATETIME

		SELECT @intManufacturingCellId = intManufacturingCellId
			,@intLotId = intLotId
			,@dtmLotCreateDate = dtmCreateDate
		FROM @shiftActivity
		WHERE SeqKey = @SeqKey

		SET @SAKey = NULL

		SELECT @SAKey = intShiftActivityId
		FROM dbo.tblMFShiftActivity
		WHERE intManufacturingCellId = @intManufacturingCellId
			AND @dtmLotCreateDate BETWEEN dtmShiftStartTime
				AND dtmShiftEndTime

		UPDATE dbo.tblMFWorkOrderProducedLot
		SET intShiftActivityId = @SAKey
		WHERE intLotId = @intLotId

		SELECT @SeqKey = MIN(SeqKey)
		FROM @shiftActivity
		WHERE SeqKey > @SeqKey
	END

	BEGIN TRANSACTION

	IF EXISTS (
			SELECT 1
			FROM dbo.tblMFShiftActivity
			WHERE intShiftActivityId = @intShiftActivityId
			)
	BEGIN
		SELECT @TotalProducedQty = ISNULL((SUM(dbo.fnCTConvertQuantityToTargetItemUOM(W.intItemId, IUOM1.intUnitMeasureId, IUOM.intUnitMeasureId, WPL.dblPhysicalCount))), 0)
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId
			AND IUOM.ysnStockUnit = 1
		WHERE WPL.intShiftActivityId = @intShiftActivityId

		SELECT @intUnitMeasureId = IUOM.intUnitMeasureId
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId
			AND IUOM.ysnStockUnit = 1
		WHERE WPL.intShiftActivityId = @intShiftActivityId

		UPDATE dbo.tblMFShiftActivity
		SET dblTotalSKUProduced = ISNULL(@TotalProducedQty, 0)
			,intSKUUnitMeasureId = @intUnitMeasureId
		WHERE intShiftActivityId = @intShiftActivityId

		-- Calculating efficiency for the shifts which are closed        
		DECLARE @dblTotalProducedQty INT
			,@dblTotalWeightofProducedQty NUMERIC(18, 6)
			,@intReduceAvailableTime INT
			,@intWeightUnitMeasureId INT
			,@intBaseUnitMeasureId INT

		SELECT @intWeightUnitMeasureId = intUnitMeasureId
		FROM dbo.tblICUnitMeasure
		WHERE strUnitMeasure = 'pound'
			OR strUnitMeasure = 'LB'

		SELECT @intBaseUnitMeasureId = intUnitMeasureId
		FROM dbo.tblICUnitMeasure
		WHERE strUnitMeasure = 'Each'
			OR strUnitMeasure = 'EA'

		SELECT @dblTotalProducedQty = ISNULL(SUM(WPL.dblPhysicalCount * PTD.dblConversionFactor), 0)
			,@dblTotalWeightofProducedQty = ISNULL(SUM(WPL.dblPhysicalCount * I.dblNetWeight), 0)
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblMFPackType PT ON PT.intPackTypeId = I.intPackTypeId
		JOIN dbo.tblMFPackTypeDetail PTD ON PTD.intPackTypeId = PT.intPackTypeId
			AND PTD.intTargetUnitMeasureId = IUOM1.intUnitMeasureId
			AND PTD.intSourceUnitMeasureId = @intBaseUnitMeasureId
		WHERE WPL.intShiftActivityId = @intShiftActivityId

		SELECT @intReduceAvailableTime = ISNULL(SUM(D.intDowntime) / 60, 0)
		FROM dbo.tblMFDowntimeMachines DM
		JOIN dbo.tblMFDowntime D ON D.intDowntimeId = DM.intDowntimeId
		JOIN dbo.tblMFReasonCode RC ON RC.intReasonCodeId = D.intReasonCodeId
		WHERE RC.ysnReduceavailabletime = 1
			AND D.intShiftActivityId = @intShiftActivityId

		IF ISNULL(@strComment, '') = ''
		BEGIN
			SELECT @strComment = strComments
			FROM dbo.tblMFShiftActivity
			WHERE intShiftActivityId = @intShiftActivityId
		END

		UPDATE dbo.tblMFShiftActivity
		SET dblTotalProducedQty = ISNULL(@dblTotalProducedQty, 0)
			,intShiftActivityStatusId = 3 -- Completed
			,dblTotalWeightofProducedQty = ISNULL(@dblTotalWeightofProducedQty, 0)
			,intWeightUnitMeasureId = @intWeightUnitMeasureId
			,intBaseUnitMeasureId = @intBaseUnitMeasureId
			,strComments = @strComment
			,intReduceAvailableTime = @intReduceAvailableTime
			,dtmLastModified = GETDATE()
			,intLastModifiedUserId = @intUserId
		WHERE intShiftActivityId = @intShiftActivityId
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
