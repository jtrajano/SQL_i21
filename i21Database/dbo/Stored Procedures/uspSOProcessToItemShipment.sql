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
		,@InvoiceId  INT
		,@IsSoftwareType BIT = 0
		,@HasInventoryItem BIT = 0

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
		RAISERROR('There is no sellable item on this sales order.', 16, 1);
        RETURN;
	END
ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId 
				WHERE SOD.intSalesOrderId = @SalesOrderId AND I.strType = 'Software')
			BEGIN
				SET @IsSoftwareType = 1
				IF EXISTS(SELECT 1 FROM tblSOSalesOrderDetail A INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
					WHERE intSalesOrderId = @SalesOrderId AND strType NOT IN ('Non-Inventory', 'Other Charge', 'Service', 'Software'))
					BEGIN
						SET @HasInventoryItem = 1
					END

				EXEC dbo.uspARInsertToInvoice @SalesOrderId, @UserId, @HasInventoryItem, @InvoiceId OUTPUT

				IF (@HasInventoryItem = 0) 
					BEGIN
						SET @InventoryShipmentId = @InvoiceId; 
						RETURN; 
					END
			END
	END

DECLARE @icUserId INT = (SELECT TOP 1 intUserSecurityID FROM tblSMUserSecurity WHERE intEntityId = @UserId);

EXEC dbo.uspICProcessToInventoryShipment
		 @intSourceTransactionId = @SalesOrderId
		,@strSourceType = 'Sales Order'
		,@intUserId = @icUserId
		,@InventoryShipmentId = @ShipmentId OUTPUT

IF (@IsSoftwareType = 1 AND @HasInventoryItem = 1)
	BEGIN
		DECLARE @strTransactionId NVARCHAR(40) = NULL
		SELECT @strTransactionId = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId
		EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @icUserId, @UserId
	END

IF @@ERROR > 0 
	RETURN 0;

EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId

UPDATE
	tblSOSalesOrder
SET
	dtmProcessDate = GETDATE()
  , ysnProcessed = 1
WHERE
	intSalesOrderId = @SalesOrderId		

SET @InventoryShipmentId = @ShipmentId;

RETURN 1;

END
