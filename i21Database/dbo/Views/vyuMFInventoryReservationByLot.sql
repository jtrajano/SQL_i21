CREATE VIEW vyuMFInventoryReservationByLot
AS
	SELECT
	l.strLotNumber,
	r.intLotId,
	strTransactionId AS [strWorkOrderBOLNo],
	i.strItemNo AS strBlend,
	i1.strItemNo,
	i1.strDescription,
	r.dblQty,
	um.strUnitMeasure,
	itt.strName strTransactionType
	FROM tblICStockReservation r
	JOIN tblICItem i1 ON i1.intItemId = r.intItemId
	JOIN tblICLot l ON l.intLotId = r.intLotId
	JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = r.intInventoryTransactionType
	JOIN tblICItemUOM iu ON iu.intItemUOMId = r.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	LEFT JOIN tblMFWorkOrder o ON o.intWorkOrderId = r.intTransactionId
	LEFT JOIN tblICItem i ON i.intItemId = o.intItemId