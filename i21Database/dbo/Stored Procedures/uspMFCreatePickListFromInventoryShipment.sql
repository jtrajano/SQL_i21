/****************************************************************
 * Title: Create Pick Ticket/List.
 * Desription: Create Pick Ticket/List upon posting of inventory shipment from sales order.
 * JIRA: IC-11114
 * Created By: Jonathan Valenzuela
 * Date: 01/12/23
*****************************************************************/
CREATE PROCEDURE uspMFCreatePickListFromInventoryShipment
	@intInventoryShipmentId		INT
  , @intLocationId				INT
  , @intEntityUserSecurityId	INT
  , @dtmShipDate				DATETIME
AS

DECLARE @tblPickList TABLE
(
	intPickListId	INT
  , strPickListNo	NVARCHAR(50)
  , strWorkOrderNo	NVARCHAR(MAX)
  , intAssignedToId INT
  , intLocationId	INT
  , intSalesOrderId INT
  , dblBatchSize	NUMERIC(38, 20)
  , intUserId		INT
)

DECLARE @intSalesOrderId INT = 0
	  , @intPickListId	 INT = 0
	  , @strSalesOrder	 NVARCHAR(MAX)
	  , @strPickListNo	 NVARCHAR(MAX);

/* Retrieve Sales Order ID. */
SELECT @intSalesOrderId = SalesOrder.intSalesOrderId
FROM tblICInventoryShipment AS InventoryShipment
INNER JOIN tblSOSalesOrder AS SalesOrder ON InventoryShipment.strReferenceNumber = SalesOrder.strSalesOrderNumber AND InventoryShipment.intOrderType = 2
WHERE intInventoryShipmentId = @intInventoryShipmentId;

/* Retrieve Pick List ID. */
SELECT 	@intPickListId	= ISNULL(PickList.intPickListId, 0)
FROM tblSOSalesOrder AS SalesOrder
INNER JOIN tblMFPickList AS PickList ON PickList.intSalesOrderId = SalesOrder.intSalesOrderId
WHERE SalesOrder.intSalesOrderId = @intSalesOrderId;

/* Skip if there's already pick list on sales order. */
IF (@intPickListId <> 0) 
	BEGIN
		RETURN;
	END

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
							   , intConcurrencyId)
SELECT @intPickListId
	 , ShipmentItemLot.intLotId
	 , Lot.intParentLotId
	 , ShipmentItem.intItemId
	 , ShipmentItem.intStorageLocationId
	 , ShipmentItem.intSubLocationId
	 , @intLocationId
	 , OrderDetail.dblQtyOrdered
	 , OrderDetail.intItemUOMId
	 , OrderDetail.dblQtyOrdered
	 , OrderDetail.intItemUOMId
	 , ShipmentItem.dblQuantity
	 , ShipmentItem.intItemUOMId
	 , NULL
	 , @dtmShipDate
	 , @intEntityUserSecurityId
	 , @dtmShipDate
	 , @intEntityUserSecurityId
	 , 1
FROM tblICInventoryShipmentItem AS ShipmentItem
JOIN tblSOSalesOrderDetail AS OrderDetail ON ShipmentItem.intOrderId = OrderDetail.intSalesOrderId AND ShipmentItem.intLineNo = OrderDetail.intSalesOrderDetailId
LEFT JOIN tblICInventoryShipmentItemLot AS ShipmentItemLot ON ShipmentItem.intInventoryShipmentItemId = ShipmentItemLot.intInventoryShipmentItemId
LEFT JOIN tblICLot AS Lot ON ShipmentItemLot.intLotId = Lot.intLotId
WHERE ShipmentItem.intInventoryShipmentId = @intInventoryShipmentId AND OrderDetail.intSalesOrderId = @intSalesOrderId;
