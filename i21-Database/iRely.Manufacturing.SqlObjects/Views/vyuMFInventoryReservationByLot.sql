CREATE VIEW vyuMFInventoryReservationByLot
AS
	SELECT
	l.strLotNumber,
	r.intLotId,
	r.strTransactionId AS [strWorkOrderBOLNo],
	i.strItemNo AS strBlend,
	i1.intItemId,
	i1.strItemNo,
	i1.strDescription,
	r.dblQty,
	um.strUnitMeasure,
	itt.strName strTransactionType
	FROM tblICStockReservation r
	JOIN tblICItem i1 ON i1.intItemId = r.intItemId AND ISNULL(r.ysnPosted,0)=0
	JOIN tblICLot l ON l.intLotId = r.intLotId
	JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = r.intInventoryTransactionType AND r.ysnPosted = 0
	JOIN tblICItemUOM iu ON iu.intItemUOMId = r.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	LEFT JOIN tblMFWorkOrder o ON o.intWorkOrderId = r.intTransactionId
	LEFT JOIN tblICItem i ON i.intItemId = o.intItemId