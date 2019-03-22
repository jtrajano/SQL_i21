CREATE PROCEDURE [dbo].[uspMFUnReservePickListByShipment] @intInventoryShipmentId INT
AS
DECLARE @tblTransaction TABLE (intTransactionId INT)
DECLARE @intTransactionId INT

INSERT INTO @tblTransaction
SELECT pl.intPickListId
FROM tblMFPickList pl
JOIN tblSOSalesOrder so ON pl.intSalesOrderId = so.intSalesOrderId
JOIN tblICInventoryShipmentItem si ON si.intOrderId = so.intSalesOrderId
JOIN tblICInventoryShipment sh ON si.intInventoryShipmentId = sh.intInventoryShipmentId
WHERE si.intInventoryShipmentId = @intInventoryShipmentId
	AND sh.intOrderType = 2

SELECT @intTransactionId = MIN(intTransactionId)
FROM @tblTransaction

WHILE @intTransactionId IS NOT NULL
BEGIN
	EXEC dbo.uspICPostStockReservation @intTransactionId
		,34
		,0

	SELECT @intTransactionId = MIN(intTransactionId)
	FROM @tblTransaction
	WHERE intTransactionId > @intTransactionId
END
