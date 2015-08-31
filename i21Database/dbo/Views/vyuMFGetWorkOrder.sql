CREATE VIEW vyuMFGetWorkOrder
AS
SELECT C.intManufacturingCellId
	,C.strCellName
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dblQuantity
	,W.dtmExpectedDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,W.dblProducedQuantity
	,W.strComment AS strWorkOrderComments
	,W.dtmOrderDate
	,(
		SELECT TOP 1 strItemNo
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
		WHERE RI.intRecipeId = R.intRecipeId
			AND WI.strType = 'Assembly/Blend'
		) AS strWIPItemNo
	,IC.intCategoryId
	,IC.strCategoryCode
	,IC.strDescription AS strCategoryDesc
	,I.strType
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,IU.intItemUOMId
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,WS.intStatusId
	,WS.strName AS strStatusName
	,PT.intProductionTypeId
	,PT.strName AS strProductionType
	,W.dtmPlannedDate
	,SH.intShiftId
	,SH.strShiftName
	,P.intPackTypeId
	,P.strPackName
	,W.dtmCreated
	,W.intCreatedUserId
	,W.dtmLastModified
	,W.intLastModifiedUserId
	,W.intExecutionOrder
	,W.strVendorLotNo
	,W.strLotNumber
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
	AND W.intStatusId <> 13
JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICCategory IC ON IC.intCategoryId = I.intCategoryId
LEFT JOIN dbo.tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
	AND R.intLocationId = C.intLocationId
	AND R.ysnActive = 1
