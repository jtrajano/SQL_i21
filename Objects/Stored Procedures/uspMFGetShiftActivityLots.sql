CREATE PROCEDURE uspMFGetShiftActivityLots
	@intManufacturingCellId INT
	,@dtmShiftDate DATETIME
	,@intShiftId INT
	,@intLocationId INT
	,@intAllocated INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @WorkOrderCreateDate DATETIME
	DECLARE @intShiftActivityId INT

	SELECT @WorkOrderCreateDate = dtmWorkOrderCreateDate
	FROM dbo.tblMFCompanyPreference

	SELECT @intShiftActivityId = intShiftActivityId
	FROM dbo.tblMFShiftActivity SA
	WHERE CONVERT(CHAR, SA.dtmShiftDate, 101) = CONVERT(CHAR, @dtmShiftDate, 101)
		AND SA.intManufacturingCellId = @intManufacturingCellId
		AND SA.intShiftId = @intShiftId

	IF @intAllocated = 1
	BEGIN -- Allocated Lots
		SELECT L.intLotId
			,L.strLotNumber
			,WPL.dblPhysicalCount
			,UOM.strUnitMeasure
			,I.strItemNo
			,I.strDescription
			,WPL.dtmCreated AS dtmDateCreated
			,S.strShiftName
			,US.strUserName
		FROM dbo.tblMFWorkOrderProducedLot WPL
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
			AND W.intManufacturingCellId = @intManufacturingCellId
			AND WPL.dtmCreated > @WorkOrderCreateDate
			AND WPL.intShiftActivityId = @intShiftActivityId
		JOIN dbo.tblMFShift S ON S.intShiftId = WPL.intBusinessShiftId
		JOIN dbo.tblICLot L ON L.intLotId = WPL.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = L.intCreatedEntityId
	END
	ELSE
	BEGIN -- UnAllocated Lots
		SELECT L.intLotId
			,L.strLotNumber
			,WPL.dblPhysicalCount
			,UOM.strUnitMeasure
			,I.strItemNo
			,I.strDescription
			,WPL.dtmCreated AS dtmDateCreated
			,S.strShiftName
			,US.strUserName
		FROM dbo.tblMFWorkOrderProducedLot WPL
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
			AND W.intManufacturingCellId = @intManufacturingCellId
			AND WPL.dtmCreated > @WorkOrderCreateDate
			AND WPL.intShiftActivityId IS NULL
		JOIN dbo.tblMFShift S ON S.intShiftId = WPL.intBusinessShiftId
		JOIN dbo.tblICLot L ON L.intLotId = WPL.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = L.intCreatedEntityId
	END
END
