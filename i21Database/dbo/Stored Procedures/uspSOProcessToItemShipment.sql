CREATE PROCEDURE [dbo].[uspSOProcessToItemShipment]
	@SalesOrderId			INT,
	@UserId					INT,
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
		,@HasSoftwareItems BIT = 0
		,@HasNonSoftwareItems BIT = 0
	    ,@icUserId INT = (SELECT TOP 1 intUserSecurityID FROM tblSMUserSecurity WHERE intEntityId = @UserId)

IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [strOrderStatus] = 'Closed') 
	BEGIN
		RAISERROR('Sales Order already closed.', 16, 1)
		RETURN;
	END

IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [dblSalesOrderTotal]  = 0)
	BEGIN
		RAISERROR('Cannot process Sales Order with zero(0) amount.', 16, 1)
		RETURN;
	END

IF NOT EXISTS(SELECT 1 FROM tblSOSalesOrderDetail A INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
                WHERE intSalesOrderId = @SalesOrderId AND strType NOT IN ('Non-Inventory', 'Other Charge', 'Service'))
	BEGIN
		RAISERROR('Process Failed. There is no shippable item on this sales order', 16, 1);
        RETURN;
	END
ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId 
				WHERE SOD.intSalesOrderId = @SalesOrderId AND I.strType = 'Software')
			BEGIN
				SET @HasSoftwareItems = 1
				IF EXISTS(SELECT 1 FROM tblSOSalesOrderDetail A LEFT JOIN tblICItem B ON A.intItemId = B.intItemId 
					WHERE intSalesOrderId = @SalesOrderId AND strType <> 'Software')
					BEGIN
						SET @HasNonSoftwareItems = 1
					END

				GOTO PROCESS_SHIPMENT;				
			END
	END

PROCESS_SHIPMENT:
IF EXISTS(SELECT 1 FROM tblSOSalesOrderDetail A INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
                WHERE intSalesOrderId = @SalesOrderId AND strType = 'Inventory' AND intItemUOMId IS NOT NULL)
	BEGIN		
        EXEC dbo.uspICProcessToInventoryShipment
		 @intSourceTransactionId = @SalesOrderId
		,@strSourceType = 'Sales Order'
		,@intUserId = @icUserId
		,@InventoryShipmentId = @ShipmentId OUTPUT

		IF (@HasSoftwareItems = 1)
			BEGIN
				DECLARE @strTransactionId NVARCHAR(40) = NULL
				SELECT @strTransactionId = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId
				EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @icUserId, @UserId
			END

		SET @InventoryShipmentId = @ShipmentId;
	END

IF @@ERROR > 0 
	RETURN 0;

IF @HasSoftwareItems = 1
	BEGIN
		EXEC dbo.uspARInsertToInvoice @SalesOrderId, @UserId, @HasNonSoftwareItems, @ShipmentId, @InvoiceId OUTPUT
		IF @InvoiceId > 0
			BEGIN
				DECLARE @param NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX), @InvoiceId)

				EXEC dbo.uspARPostInvoice NULL, 1, 0, @param, @UserId				
			END
		SET @InventoryShipmentId = @InvoiceId
	END

EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId

UPDATE
	tblSOSalesOrder
SET
	dtmProcessDate = GETDATE()
  , ysnProcessed = 1
WHERE
	intSalesOrderId = @SalesOrderId		
	
RETURN 1;

END
