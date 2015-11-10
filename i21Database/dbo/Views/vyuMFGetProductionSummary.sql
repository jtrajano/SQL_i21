CREATE VIEW vyuMFGetProductionSummary
AS
SELECT W.intWorkOrderId
	,W.strWorkOrderNo
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.strShortName
	,W.dtmPlannedDate
	,W.intPlannedShiftId
	,S.strShiftName
	,W.dblQuantity
	,W.intItemUOMId
	,IU.intUnitMeasureId
	,UM.strUnitMeasure
	,WS.strName
	,SUM(PS.dblOpeningQuantity + PS.dblOpeningOutputQuantity) AS dblOpeningQuantity
	,SUM(PS.dblInputQuantity) AS dblInputQuantity
	,SUM(PS.dblOutputQuantity) AS dblOutputQuantity
	,SUM(PS.dblCountQuantity + PS.dblCountOutputQuantity) AS dblCountQuantity
	,CLS.intCompanyLocationSubLocationId
	,CLS.strSubLocationName
	,CL.intCompanyLocationId
	,CL.strLocationName
	,W.dtmLastModified
	,W.intLastModifiedUserId
	,US.strUserName
FROM dbo.tblMFProductionSummary PS
JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = PS.intWorkOrderId
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblSMUserSecurity US ON US.intEntityUserSecurityId = W.intLastModifiedUserId
JOIN dbo.tblSMCompanyLocationSubLocation CLS ON CLS.intCompanyLocationSubLocationId = W.intSubLocationId
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
GROUP BY W.intWorkOrderId
	,W.strWorkOrderNo
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.strShortName
	,W.dtmPlannedDate
	,W.intPlannedShiftId
	,S.strShiftName
	,W.dblQuantity
	,W.intItemUOMId
	,IU.intUnitMeasureId
	,UM.strUnitMeasure
	,WS.strName
	,CLS.intCompanyLocationSubLocationId
	,CLS.strSubLocationName
	,CL.intCompanyLocationId
	,CL.strLocationName
	,W.dtmLastModified
	,W.intLastModifiedUserId
	,US.strUserName
