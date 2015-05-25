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
		,@ShipmentNumber NVARCHAR(100);


IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [strOrderStatus] = 'Complete') 
	BEGIN
		RAISERROR('Sales Order already completed.', 16, 1)
		RETURN;
	END

IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [dblSalesOrderTotal]  = 0)
	BEGIN
		RAISERROR('Cannot process Sales Order with zero(0) amount.', 16, 1)
		RETURN;
	END

IF NOT EXISTS(	SELECT 1 
				FROM tblSOSalesOrderDetail A
					INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
				WHERE
					[intSalesOrderId] = @SalesOrderId AND
					strType NOT IN ('Non-Inventory', 'Other Charge', 'Service')
				)
	BEGIN
		RAISERROR('There is no sellable item on this sales order.', 16, 1);
		RETURN;
	END


DECLARE @icUserId INT = (SELECT TOP 1 intUserSecurityID FROM tblSMUserSecurity WHERE intEntityId = @UserId);

EXEC dbo.uspICProcessToInventoryShipment
		 @intSourceTransactionId = @SalesOrderId
		,@strSourceType = 'Sales Order'
		,@intUserId = @icUserId
		,@InventoryShipmentId = @ShipmentId OUTPUT

IF @@ERROR > 0 
	RETURN 0;


UPDATE
	tblSOSalesOrder
SET
	strOrderStatus = 'In Process'
WHERE
	[intSalesOrderId] = @SalesOrderId
	

SET @InventoryShipmentId = @ShipmentId;
SELECT @ShipmentNumber = strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId

RETURN 1;

END
