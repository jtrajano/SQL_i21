CREATE VIEW vyuMFInventoryReservationByLot
AS
SELECT Lot.strLotNumber
	 , StockReservation.intLotId
	 , StockReservation.strTransactionId AS [strWorkOrderBOLNo]
	 , ItemBlend.strItemNo AS strBlend
	 , Item.intItemId
	 , Item.strItemNo
	 , Item.strDescription
	 , StockReservation.dblQty
	 , um.strUnitMeasure
	 , itt.strName strTransactionType
	 , StockReservation.intTransactionId 
	 , StockReservation.intInventoryTransactionType 
	 , ISNULL(LotInventory.dblReservedQtyInTBS, 0) AS dblReservedQtyInTBS
FROM tblICStockReservation AS StockReservation
JOIN tblICItem AS Item ON Item.intItemId = StockReservation.intItemId AND ISNULL(StockReservation.ysnPosted, 0) = 0
JOIN tblICLot AS Lot ON Lot.intLotId = StockReservation.intLotId
JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = StockReservation.intInventoryTransactionType AND StockReservation.ysnPosted = 0
JOIN tblICItemUOM iu ON iu.intItemUOMId = StockReservation.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN tblMFWorkOrder o ON o.intWorkOrderId = StockReservation.intTransactionId AND (StockReservation.intInventoryTransactionType = 8 OR StockReservation.intInventoryTransactionType = 9)
LEFT JOIN tblICItem AS ItemBlend ON ItemBlend.intItemId = o.intItemId
LEFT JOIN tblMFLotInventory LotInventory ON LotInventory.intLotId = Lot.intLotId
UNION
SELECT Lot.strLotNumber
	 , Lot.intLotId
	 , WorkOrder.strWorkOrderNo AS [strWorkOrderBOLNo]
	 , ItemBlend.strItemNo AS strBlend
	 , Item.intItemId
	 , Item.strItemNo
	 , Item.strDescription
	 , WI.dblQuantity
	 , UnitMeasure.strUnitMeasure
	 , 'Trial BlendSheet' strTransactionType
	 , 0 intTransactionId 
	 , 0 intInventoryTransactionType 
	 , ISNULL(LotInventory.dblReservedQtyInTBS, 0) AS dblReservedQtyInTBS
FROM tblMFWorkOrderInputLot WI
JOIN tblMFWorkOrder AS WorkOrder on WorkOrder.intWorkOrderId = WI.intWorkOrderId
JOIN tblICItem AS Item ON Item.intItemId = WI.intItemId
JOIN tblICLot AS Lot ON Lot.intLotId = WI.intLotId
JOIN tblICItemUOM AS ItemUOM ON ItemUOM.intItemUOMId = WI.intItemUOMId
JOIN tblICUnitMeasure AS UnitMeasure ON UnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
JOIN tblICItem AS ItemBlend ON ItemBlend.intItemId = WorkOrder.intItemId
LEFT JOIN tblMFLotInventory LotInventory ON LotInventory.intLotId = Lot.intLotId
WHERE WorkOrder.intTrialBlendSheetStatusId IS NOT NULL AND WorkOrder.intStatusId = 2 --Not Released