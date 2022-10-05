CREATE VIEW vyuMFInventoryReservationByLot
AS
SELECT l.strLotNumber
	,r.intLotId
	,r.strTransactionId AS [strWorkOrderBOLNo]
	,i.strItemNo AS strBlend
	,i1.intItemId
	,i1.strItemNo
	,i1.strDescription
	,r.dblQty
	,um.strUnitMeasure
	,itt.strName strTransactionType
	,r.intTransactionId 
	,r.intInventoryTransactionType 
FROM tblICStockReservation r
JOIN tblICItem i1 ON i1.intItemId = r.intItemId
	AND ISNULL(r.ysnPosted, 0) = 0
JOIN tblICLot l ON l.intLotId = r.intLotId
JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = r.intInventoryTransactionType
	AND r.ysnPosted = 0
JOIN tblICItemUOM iu ON iu.intItemUOMId = r.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN tblMFWorkOrder o ON o.intWorkOrderId = r.intTransactionId
	AND (
		r.intInventoryTransactionType = 8
		OR r.intInventoryTransactionType = 9
		)
LEFT JOIN tblICItem i ON i.intItemId = o.intItemId
UNION
SELECT l.strLotNumber
	,l.intLotId
	,W.strWorkOrderNo AS [strWorkOrderBOLNo]
	,i.strItemNo AS strBlend
	,i1.intItemId
	,i1.strItemNo
	,i1.strDescription
	,WI.dblQuantity
	,um.strUnitMeasure
	,'Trial BlendSheet' strTransactionType
	,0 intTransactionId 
	,0 intInventoryTransactionType 
FROM tblMFWorkOrderInputLot WI
JOIN tblMFWorkOrder W on W.intWorkOrderId=WI.intWorkOrderId
JOIN tblICItem i1 ON i1.intItemId = WI.intItemId
JOIN tblICLot l ON l.intLotId = WI.intLotId
JOIN tblICItemUOM iu ON iu.intItemUOMId = WI.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
JOIN tblICItem i ON i.intItemId = W.intItemId
Where W.intTrialBlendSheetStatusId IS NOT NULL and W.intStatusId=2--Not Released
