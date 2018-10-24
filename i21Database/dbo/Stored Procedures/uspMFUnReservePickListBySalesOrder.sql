CREATE PROCEDURE [dbo].[uspMFUnReservePickListBySalesOrder] @intSalesOrderId INT
AS
DECLARE @tblTransaction TABLE (intTransactionId INT)
DECLARE @intTransactionId INT

--Unship SO
IF EXISTS (
		SELECT 1
		FROM tblSOSalesOrder
		WHERE intSalesOrderId = @intSalesOrderId
		)
BEGIN
	--Update tblICStockReservation Set ysnPosted=0 
	--Where intTransactionId=
	--(
	--	Select pl.intPickListId From tblMFPickList pl Where pl.intSalesOrderId=@intSalesOrderId
	--)
	--AND intInventoryTransactionType=34
	INSERT INTO @tblTransaction
	SELECT pl.intPickListId
	FROM tblMFPickList pl
	WHERE pl.intSalesOrderId = @intSalesOrderId

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
END
ELSE --Delete SO
BEGIN
	INSERT INTO @tblTransaction
	SELECT pl.intPickListId
	FROM tblMFPickList pl
	WHERE pl.intSalesOrderId = @intSalesOrderId

	SELECT @intTransactionId = MIN(intTransactionId)
	FROM @tblTransaction

	WHILE @intTransactionId IS NOT NULL
	BEGIN
		EXEC dbo.uspICPostStockReservation @intTransactionId
			,34
			,1

		SELECT @intTransactionId = MIN(intTransactionId)
		FROM @tblTransaction
		WHERE intTransactionId > @intTransactionId
	END
END
