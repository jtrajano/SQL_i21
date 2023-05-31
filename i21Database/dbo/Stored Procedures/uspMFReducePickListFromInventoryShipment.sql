/****************************************************************
 * Title: Reduce Pick Ticket/List.
 * Desription: Reduce Pick Ticket/List Quantity upon unposting of inventory shipment referenced to sales order.
 * JIRA: IC-11114
 * Created By: Jonathan Valenzuela
 * Date: 01/12/2023
*****************************************************************/
CREATE PROCEDURE [dbo].[uspMFReducePickListFromInventoryShipment]
	@intInventoryShipmentId		INT
  , @intEntityUserSecurityId	INT
AS

DECLARE @tblSalesOrder TABLE 
(
	intRowNo			  INT IDENTITY(1, 1)
  , intSalesOrderId		  INT
  , strSalesOrder		  NVARCHAR(250)
)

DECLARE @intSalesOrderId INT = 0
	  , @intPickListId	 INT = 0
	  , @intRowPointer	 INT;


/* Retrieve Sales Order ID used on Inventory Shipment. */
INSERT INTO @tblSalesOrder (intSalesOrderId
						  , strSalesOrder)
SELECT DISTINCT SalesOrder.intSalesOrderId
			  , SalesOrder.strSalesOrderNumber
FROM tblICInventoryShipmentItem AS ShipmentItem
JOIN tblICInventoryShipment AS Shipment ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
LEFT JOIN tblSOSalesOrder AS SalesOrder ON ShipmentItem.intOrderId = SalesOrder.intSalesOrderId AND Shipment.intOrderType = 2
WHERE ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId;


SELECT @intRowPointer = MIN(intRowNo) 
FROM @tblSalesOrder

WHILE @intRowPointer IS NOT NULL
	BEGIN
		/* Retrieve Sales Data for Loop. */
		SELECT @intSalesOrderId = intSalesOrderId
		FROM @tblSalesOrder
		WHERE intRowNo = @intRowPointer;

		/* Retrieve Pick List ID. */
		SELECT 	@intPickListId	= ISNULL(PickList.intPickListId, 0)
		FROM tblSOSalesOrder AS SalesOrder
		INNER JOIN tblMFPickList AS PickList ON PickList.intSalesOrderId = SalesOrder.intSalesOrderId
		WHERE SalesOrder.intSalesOrderId = @intSalesOrderId;

		IF (@intPickListId = 0) 
		/* Do nothing if no pick list found. */
			BEGIN
				RETURN;
			END
		ELSE
		/* Reduce quantity of shipped quantity pick list upon unposting.*/
			BEGIN
				UPDATE PickListDetail
				SET PickListDetail.dblShippedQty = CASE WHEN ISNULL(PickListDetail.dblShippedQty, 0) <= 0  THEN 0 
														ELSE ISNULL(PickListDetail.dblShippedQty, 0) - (dblShippedQuantity)
												   END
				  , intLastModifiedUserId		 = @intEntityUserSecurityId
				  , dtmLastModified				 = GETDATE()
				FROM tblMFPickListDetail AS PickListDetail
				JOIN (SELECT ShipmentItemLot.intLotId
						   , Lot.intParentLotId
						   , ShipmentItem.intItemId
						   , ShipmentItem.intStorageLocationId
						   , ShipmentItem.intSubLocationId
						   , ShipmentItem.intItemUOMId
						   , SUM(ShipmentItem.dblQuantity) AS dblShippedQuantity
					  FROM tblICInventoryShipmentItem AS ShipmentItem
					  JOIN tblSOSalesOrderDetail AS OrderDetail ON ShipmentItem.intOrderId = OrderDetail.intSalesOrderId AND ShipmentItem.intLineNo = OrderDetail.intSalesOrderDetailId
					  LEFT JOIN tblICInventoryShipmentItemLot AS ShipmentItemLot ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemLot.intInventoryShipmentItemId
					  LEFT JOIN tblICLot AS Lot ON ShipmentItemLot.intLotId = Lot.intLotId
					  WHERE ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId AND OrderDetail.intSalesOrderId = @intSalesOrderId 
					  GROUP BY ShipmentItemLot.intLotId
			  				 , Lot.intParentLotId
			  				 , ShipmentItem.intItemId
			  				 , ShipmentItem.intStorageLocationId
			  				 , ShipmentItem.intSubLocationId
			  				 , OrderDetail.intItemUOMId
			  				 , ShipmentItem.intItemUOMId) AS SubQuery ON PickListDetail.intItemId = SubQuery.intItemId AND PickListDetail.intItemUOMId = SubQuery.intItemUOMId
				JOIN tblMFPickList AS PickList ON PickListDetail.intPickListId = PickList.intPickListId
				WHERE PickList.intSalesOrderId = @intSalesOrderId;
			END;

		/* Increment Loop variable */
		SELECT @intRowPointer = MIN(intRowNo) 
		FROM @tblSalesOrder 
		WHERE intRowNo > @intRowPointer
	END

