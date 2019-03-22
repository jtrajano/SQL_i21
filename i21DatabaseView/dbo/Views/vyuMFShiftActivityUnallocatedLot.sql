CREATE VIEW vyuMFShiftActivityUnallocatedLot
AS
SELECT WPL.intWorkOrderProducedLotId
	,L.intLotId
	,I.intItemId
	,L.intParentLotId
	,W.intLocationId
	,L.strLotNumber
	,WPL.dblPhysicalCount
	,UOM.strUnitMeasure
	,I.strItemNo
	,I.strDescription
	,WPL.dtmCreated
	,S.strShiftName
	,US.strUserName
	,MC.strCellName
FROM dbo.tblMFWorkOrderProducedLot WPL
JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
	AND WPL.dtmCreated > (
		SELECT TOP 1 dtmWorkOrderCreateDate
		FROM dbo.tblMFCompanyPreference
		)
	AND WPL.intShiftActivityId IS NULL
JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblMFShift S ON S.intShiftId = WPL.intBusinessShiftId
JOIN dbo.tblICLot L ON L.intLotId = WPL.intLotId
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = L.intCreatedEntityId
