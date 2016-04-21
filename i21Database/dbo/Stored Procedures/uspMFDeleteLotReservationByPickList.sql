CREATE PROCEDURE [dbo].[uspMFDeleteLotReservationByPickList]
	@intPickListId int
AS
DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=34
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 

	EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intPickListId
		,@intInventoryTransactionType
