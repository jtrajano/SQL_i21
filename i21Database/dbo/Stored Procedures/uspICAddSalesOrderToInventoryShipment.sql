CREATE PROCEDURE [dbo].[uspICAddSalesOrderToInventoryShipment]
	@SalesOrderId AS INT
	,@intEntityUserSecurityId AS INT
	,@InventoryShipmentId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryShipment AS INT = 31;
DECLARE @ShipmentNumber AS NVARCHAR(20)

DECLARE @SALES_CONTRACT AS INT = 1
		,@SALES_ORDER AS INT = 2
		,@TRANSFER_ORDER AS INT = 3

-- Get the transaction id 
BEGIN 
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT 
	IF @ShipmentNumber IS NULL RETURN; -- Exit sp if shipment number is not generated. 
END 

-- Insert the Inventory Shipment header 
BEGIN 
		INSERT INTO dbo.tblICInventoryShipment (
				strShipmentNumber
				,dtmShipDate
				,intOrderType
				,strReferenceNumber
				,dtmRequestedArrivalDate
				,intShipFromLocationId
				,intEntityCustomerId
				,intShipToLocationId
				,intFreightTermId
				,strBOLNumber
				,intShipViaId
				,strVessel
				,strProNumber
				,strDriverId
				,strSealNumber
				,strDeliveryInstruction
				,dtmAppointmentTime
				,dtmDepartureTime
				,dtmArrivalTime
				,dtmDeliveredDate
				,dtmFreeTime
				,strFreeTime
				,strReceivedBy
				,strComment
				,intCurrencyId
				,ysnPosted
				,intEntityId
				,intConcurrencyId
		)
		SELECT	strShipmentNumber			= @ShipmentNumber
				,dtmShipDate				= SO.dtmDate
				,intOrderType				= @SALES_ORDER
				,strReferenceNumber			= SO.strSalesOrderNumber
				,dtmRequestedArrivalDate	= NULL -- TODO
				,intShipFromLocationId		= SO.intCompanyLocationId
				,intEntityCustomerId		= SO.intEntityCustomerId
				,intShipToLocationId		= SO.intShipToLocationId
				,intFreightTermId			= SO.intFreightTermId
				,strBOLNumber				= SO.strBOLNumber
				,intShipViaId				= SO.intShipViaId
				,strVessel					= NULL -- TODO
				,strProNumber				= NULL 
				,strDriverId				= NULL
				,strSealNumber				= NULL 
				,strDeliveryInstruction		= NULL 
				,dtmAppointmentTime			= NULL 
				,dtmDepartureTime			= NULL 
				,dtmArrivalTime				= NULL 
				,dtmDeliveredDate			= NULL 
				,dtmFreeTime				= NULL
				,strFreeTime				= NULL 
				,strReceivedBy				= NULL 
				,strComment					= SO.strComments
				,intCurrencyId				= SO.intCurrencyId
				,ysnPosted					= 0 
				,intEntityId				= @intEntityUserSecurityId
				,intConcurrencyId			= 1
		FROM	dbo.tblSOSalesOrder SO
		WHERE	SO.intSalesOrderId = @SalesOrderId
END 

-- Get the identity value from tblICInventoryShipment
SELECT @InventoryShipmentId = SCOPE_IDENTITY()

IF @InventoryShipmentId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.
	EXEC uspICRaiseError 80029; 
	RETURN;
END

-- Insert the Inventory Shipment detail items 
BEGIN 
	INSERT INTO dbo.tblICInventoryShipmentItem (
			intInventoryShipmentId
			,intOrderId
			,intLineNo
			,intItemId
			,intSubLocationId
			,intStorageLocationId
			,dblQuantity
			,intItemUOMId
			,dblUnitPrice
			,intDockDoorId
			,strNotes
			,intSort
			,intOwnershipType 
			,intStorageScheduleTypeId
			,intConcurrencyId
	)
	SELECT			
			intInventoryShipmentId	= @InventoryShipmentId
			,intOrderId				= SODetail.intSalesOrderId
			,intLineNo				= SODetail.intSalesOrderDetailId
			,intItemId				= SODetail.intItemId
			,intSubLocationId		= NULL
			,intStorageLocationId	= SODetail.intStorageLocationId
			,dblQuantity			= SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)
			,intItemUOMId			= SODetail.intItemUOMId
			,dblUnitPrice			= SODetail.dblPrice
			,intDockDoorId			= NULL
			,strNotes				= SODetail.strComments
			,intSort				= SODetail.intSalesOrderDetailId
			,intOwnershipType		= CASE WHEN SODetail.intStorageScheduleTypeId IS NULL THEN 1 ELSE 2 END
			,intStorageScheduleTypeId	= SODetail.intStorageScheduleTypeId
			,intConcurrencyId		= 1
	FROM	dbo.tblSOSalesOrderDetail SODetail INNER JOIN dbo.tblICItemUOM ItemUOM			
				ON ItemUOM.intItemId = SODetail.intItemId
				AND ItemUOM.intItemUOMId = SODetail.intItemUOMId
			INNER JOIN dbo.tblICUnitMeasure UOM
				ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT OUTER JOIN 
				(SELECT intSalesOrderDetailId, SUM(dblQtyShipped) AS dblQtyShipped FROM tblARInvoiceDetail ID GROUP BY ID.intSalesOrderDetailId) AS InvoiceDetail
				ON InvoiceDetail.intSalesOrderDetailId = SODetail.intSalesOrderDetailId
	WHERE	SODetail.intSalesOrderId = @SalesOrderId
			AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1
			AND (SODetail.dblQtyOrdered - ISNULL(InvoiceDetail.dblQtyShipped, SODetail.dblQtyShipped)) > 0
END 

-- Increase Item Stock Reservation
BEGIN
	EXEC dbo.uspICReserveStockForInventoryShipment @intTransactionId = @InventoryShipmentId
END