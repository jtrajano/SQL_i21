/****************************************************************
 * Title: Create Pick Ticket/List.
 * Desription: Create Pick Ticket/List upon posting of inventory shipment from sales order.
 * JIRA: IC-11114
 * Created By: Jonathan Valenzuela
 * Date: 01/12/2023
*****************************************************************/
CREATE PROCEDURE [dbo].[uspMFCreateUpdatePickListFromInventoryShipment]
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
	  , @strSalesOrder	 NVARCHAR(MAX)
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
			 , @strSalesOrder	= strSalesOrder
		FROM @tblSalesOrder
		WHERE intRowNo = @intRowPointer;

		/* Retrieve Pick List ID. */
		SELECT @intPickListId = ISNULL(PickList.intPickListId, 0)
		FROM tblSOSalesOrder AS SalesOrder
		INNER JOIN tblMFPickList AS PickList ON PickList.intSalesOrderId = SalesOrder.intSalesOrderId
		WHERE SalesOrder.intSalesOrderId = @intSalesOrderId;

		/* Update shipped qty if there's already pick list on sales order. */
		IF (@intPickListId <> 0) 
			BEGIN
				UPDATE PickListDetail
				SET PickListDetail.dblShippedQty = ISNULL(PickListDetail.dblShippedQty, 0) + SubQuery.dblShippedQuantity
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

				/*Create Pick List Detail for Remaining Lot. */
				INSERT INTO tblMFPickListDetail (intPickListId
											   , intLotId
											   , intParentLotId
											   , intItemId
											   , intStorageLocationId
											   , intSubLocationId
											   , intLocationId
											   , dblQuantity
											   , intItemUOMId
											   , dblIssuedQuantity
											   , intItemIssuedUOMId
											   , dblPickQuantity
											   , intPickUOMId
											   , intStageLotId
											   , dtmCreated
											   , intCreatedUserId
											   , dtmLastModified
											   , intLastModifiedUserId
											   , intConcurrencyId
											   , dblShippedQty)
				SELECT @intPickListId
					 , ShipmentItemLot.intLotId
					 , Lot.intParentLotId
					 , SalesOrderDetail.intItemId
					 , ShipmentItem.intStorageLocationId 
					 , ShipmentItem.intSubLocationId
					 , Shipment.intShipFromLocationId
					 , SUM(SalesOrderDetail.dblQtyOrdered)
					 , SalesOrderDetail.intItemUOMId
					 , SUM(SalesOrderDetail.dblQtyOrdered)
					 , SalesOrderDetail.intItemUOMId
					 , SUM(SalesOrderDetail.dblQtyOrdered)
					 , SalesOrderDetail.intItemUOMId
					 , NULL
					 , Shipment.dtmShipDate
					 , @intEntityUserSecurityId
					 , Shipment.dtmShipDate
					 , @intEntityUserSecurityId
					 , 1
					 , SUM(dblShippedQty)
				FROM tblSOSalesOrderDetail AS SalesOrderDetail
				JOIN tblICItem AS Item ON SalesOrderDetail.intItemId = Item.intItemId 
				JOIN tblMFPickList AS PickList ON SalesOrderDetail.intSalesOrderId = PickList.intSalesOrderId   
				LEFT JOIN tblICInventoryShipmentItem AS ShipmentItem ON ShipmentItem.intOrderId = SalesOrderDetail.intSalesOrderId AND ShipmentItem.intLineNo = SalesOrderDetail.intSalesOrderDetailId
				LEFT JOIN tblICInventoryShipment AS Shipment ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
				LEFT JOIN tblICInventoryShipmentItemLot AS ShipmentItemLot ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemLot.intInventoryShipmentItemId
								LEFT JOIN tblICLot AS Lot ON ShipmentItemLot.intLotId = Lot.intLotId
				LEFT JOIN tblMFPickListDetail AS PickListDetail ON PickList.intPickListId = PickListDetail.intPickListId 
															   AND SalesOrderDetail.intItemUOMId = PickListDetail.intItemUOMId
															   AND SalesOrderDetail.intItemId = PickListDetail.intItemId
				WHERE SalesOrderDetail.intSalesOrderId = @intSalesOrderId AND Item.strType NOT IN ('Comment', 'Other Charge') AND PickListDetail.intItemId IS NULL 
				GROUP BY ShipmentItemLot.intLotId
					   , Lot.intParentLotId
					   , SalesOrderDetail.intItemId
					   , ShipmentItem.intStorageLocationId
					   , ShipmentItem.intSubLocationId
					   , SalesOrderDetail.intItemUOMId
					   , ShipmentItem.intItemUOMId
					   , Shipment.intShipFromLocationId
					   , Shipment.dtmShipDate


			END
		ELSE	
			/* Create pick list. */
			BEGIN
				DECLARE @strPickListNo	 NVARCHAR(MAX)
					  , @intLocationId	 INT
					  , @dtmShipDate	 DATETIME
				
				SELECT @intLocationId	= Shipment.intShipFromLocationId
					 , @dtmShipDate		= Shipment.dtmShipDate
				FROM tblICInventoryShipmentItem AS ShipmentItem
				JOIN tblICInventoryShipment AS Shipment ON ShipmentItem.intInventoryShipmentId = Shipment.intInventoryShipmentId
				LEFT JOIN tblSOSalesOrder AS SalesOrder ON ShipmentItem.intOrderId = SalesOrder.intSalesOrderId AND Shipment.intOrderType = 2
				WHERE ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId;

				/* Generate Pick List No. */
				EXEC dbo.uspMFGeneratePatternId @intCategoryId			= NULL
											  , @intItemId				= NULL
											  , @intManufacturingId		= NULL
											  , @intSubLocationId		= NULL
											  , @intLocationId			= @intLocationId
											  , @intOrderTypeId			= NULL
											  , @intBlendRequirementId	= NULL
											  , @intPatternCode			= 68
											  , @ysnProposed			= 0
											  , @strPatternString		= @strPickListNo OUTPUT


				/* Create/Insert Pick List start here. */
				INSERT INTO tblMFPickList(strPickListNo
										, strWorkOrderNo
										, intKitStatusId
										, intAssignedToId
										, intLocationId
										, intSalesOrderId
										, dblBatchSize
										, dtmCreated
										, intCreatedUserId
										, dtmLastModified
										, intLastModifiedUserId
										, intConcurrencyId)
				VALUES( @strPickListNo
					  , @strSalesOrder
					  , 7
					  , @intEntityUserSecurityId
					  , @intLocationId
					  , @intSalesOrderId
					  , 1
					  , @dtmShipDate
					  , @intEntityUserSecurityId
					  , @dtmShipDate
					  , @intEntityUserSecurityId
					  , 1); 

				SET @intPickListId = SCOPE_IDENTITY();

				/* Create Audit Log. */
				EXEC uspSMAuditLog @keyValue			=  @intPickListId
								 , @screenName			= 'Manufacturing.view.SalesOrderPickList'
								 , @entityId			= 2
								 , @actionType			= 'Created'
								 , @changeDescription	= 'Inventory Shipment to Sales Order Pick List'

				/* Create Pick List Detail. */
				INSERT INTO tblMFPickListDetail (intPickListId
											   , intLotId
											   , intParentLotId
											   , intItemId
											   , intStorageLocationId
											   , intSubLocationId
											   , intLocationId
											   , dblQuantity
											   , intItemUOMId
											   , dblIssuedQuantity
											   , intItemIssuedUOMId
											   , dblPickQuantity
											   , intPickUOMId
											   , intStageLotId
											   , dtmCreated
											   , intCreatedUserId
											   , dtmLastModified
											   , intLastModifiedUserId
											   , intConcurrencyId
											   , dblShippedQty)
				SELECT @intPickListId
					 , ShipmentItemLot.intLotId
					 , Lot.intParentLotId
					 , ShipmentItem.intItemId
					 , ShipmentItem.intStorageLocationId
					 , ShipmentItem.intSubLocationId
					 , @intLocationId
					 , SUM(OrderDetail.dblQtyOrdered)
					 , OrderDetail.intItemUOMId
					 , SUM(OrderDetail.dblQtyOrdered)
					 , OrderDetail.intItemUOMId
					 , SUM(ShipmentItem.dblQuantity)
					 , ShipmentItem.intItemUOMId
					 , NULL
					 , @dtmShipDate
					 , @intEntityUserSecurityId
					 , @dtmShipDate
					 , @intEntityUserSecurityId
					 , 1
					 , SUM(ShipmentItem.dblQuantity)
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
					   , ShipmentItem.intItemUOMId
			/* End of Create pick list. */
			END;		
	
		/* Increment Loop variable */
		SELECT @intRowPointer = MIN(intRowNo) 
		FROM @tblSalesOrder 
		WHERE intRowNo > @intRowPointer
	END;



