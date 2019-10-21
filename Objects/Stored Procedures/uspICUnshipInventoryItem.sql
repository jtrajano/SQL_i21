CREATE PROCEDURE [dbo].[uspICUnshipInventoryItem]
	@ShipmentId INT,
	@UserId INT
AS

EXEC uspICLogTransactionDetail @TransactionType = 2, @TransactionId= @ShipmentId

EXEC uspICUpdateStatusOnShipmentSave @intShipmentId = @ShipmentId, @ysnOpenStatus=1

DELETE FROM tblICInventoryShipment WHERE intInventoryShipmentId = @ShipmentId

EXEC uspICInventoryShipmentAfterSave @ShipmentId = @ShipmentId, @ForDelete = 1, @UserId = @UserId