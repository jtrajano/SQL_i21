CREATE PROCEDURE [dbo].[uspMFDeleteLotReservation]
	@intWorkOrderId int
AS
DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=8
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 

	EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intWorkOrderId
		,@intInventoryTransactionType
