CREATE PROCEDURE [dbo].[uspSOProcessToItemShipment]
	@SalesOrderId			INT,
	@UserId					INT,
	@Unship					BIT = 0,
	@InventoryShipmentId	INT OUTPUT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
DECLARE	 @ShipmentId INT
		,@InvoiceId  INT = 0	    

--VALIDATE IF SO IS ALREADY CLOSED
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [strOrderStatus] = 'Closed') 
	BEGIN
		RAISERROR('Sales Order already closed.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO HAS ZERO TOTAL AMOUNT
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [dblSalesOrderTotal]  = 0 AND @Unship = 0)
	BEGIN
		RAISERROR('Cannot process Sales Order with zero(0) amount.', 16, 1)
		RETURN;
	END

--IF UNSHIP
IF @Unship = 1
	BEGIN
		--VALIDATE IF SO HAS POSTED SHIPMENT RECORDS
		DECLARE @shipmentNos NVARCHAR(MAX) = NULL

		SELECT @shipmentNos = COALESCE(@shipmentNos + ', ' ,'') + ISH.strShipmentNumber 
		FROM tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
			WHERE ISHI.intOrderId = @SalesOrderId 
			  AND ISH.ysnPosted = 1

		IF ISNULL(@shipmentNos, '') <> ''
			BEGIN
				DECLARE @errorMsg NVARCHAR(MAX) = 'Failed to unship Sales Order. Unpost this Shipment Record first: ' + @shipmentNos
				RAISERROR(@errorMsg, 16, 1)
				RETURN
			END
		ELSE
			BEGIN
				--DELETE SHIPMENT RECORD								
				DELETE FROM tblICInventoryShipment 
				WHERE intInventoryShipmentId IN (SELECT DISTINCT ISH.intInventoryShipmentId FROM tblICInventoryShipmentItem ISHI
													INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
													WHERE intOrderId = @SalesOrderId)
			
				--UPDATE ORDER STATUS
				EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId, 0, 1

				UPDATE tblSOSalesOrder SET ysnShipped = 0 WHERE intSalesOrderId = @SalesOrderId
				RETURN 1
			END
	END

--VALIDATE IF THERE ARE STOCK ITEMS TO SHIP
IF NOT EXISTS(SELECT 1 FROM tblSOSalesOrderDetail SOD WHERE intSalesOrderId = @SalesOrderId 
		AND dbo.fnIsStockTrackingItem(intItemId) = 1 
		AND (dblQtyOrdered - dblQtyShipped > 0)
		AND SOD.[intSalesOrderDetailId] NOT IN (SELECT ISNULL(tblARInvoiceDetail.[intSalesOrderDetailId],0) 
				FROM tblARInvoiceDetail INNER JOIN tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId 
				WHERE SOD.dblQtyOrdered <= tblARInvoiceDetail.dblQtyShipped))
	BEGIN
		RAISERROR('Shipping Failed. There is no shippable item on this sales order', 16, 1);
        RETURN
	END
ELSE
	BEGIN
		EXEC dbo.uspICProcessToInventoryShipment
				 @intSourceTransactionId = @SalesOrderId
				,@strSourceType = 'Sales Order'
				,@intEntityUserSecurityId = @UserId
				,@InventoryShipmentId = @ShipmentId OUTPUT
		
		SET @InventoryShipmentId = @ShipmentId

		IF @@ERROR > 0 
			RETURN 0;

		EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId

		UPDATE tblSOSalesOrder
		SET dtmProcessDate = GETDATE()
		  , ysnProcessed   = 1
		  , ysnShipped     = 1
		WHERE intSalesOrderId = @SalesOrderId
	
		RETURN 1
	END

END