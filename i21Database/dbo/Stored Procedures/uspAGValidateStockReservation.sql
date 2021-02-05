CREATE PROCEDURE [dbo].[uspAGValidateStockReservation]
@AGWorkOrderId INT = NULL

AS
BEGIN
	
	SET QUOTED_IDENTIFIER OFF    
	SET ANSI_NULLS ON    
	SET NOCOUNT ON    
	SET XACT_ABORT ON    
	SET ANSI_WARNINGS OFF

	 DECLARE @ItemReservationTableType AS ItemReservationTableType


		INSERT INTO @ItemReservationTableType (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dblQty]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]
			)
			SELECT	[intItemId]				= ITEM.intItemId
					,[intItemLocationId]	= ICIL.intItemLocationId
					,[intItemUOMId]			= WOD.intItemUOMId
					,[intLotId]				= NULL
					,[intSubLocationId]		= NULL
					,[intStorageLocationId]	= NULL
					,[dblQty]				= CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0 THEN ((WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0))) ELSE 0 END
					,[intTransactionId]		= WO.intWorkOrderId
					,[strTransactionId]		= WO.strOrderNumber
					,[intTransactionTypeId] = 59
			FROM	tblAGWorkOrder WO
			INNER JOIN tblAGWorkOrderDetail WOD 
				ON WO.intWorkOrderId = WOD.intWorkOrderId
			INNER JOIN tblICItem ITEM 
				ON ITEM.intItemId = WOD.intItemId
			INNER JOIN tblICItemLocation ICIL
				ON ICIL.intItemId = ITEM.intItemId AND ICIL.intLocationId = WO.intCompanyLocationId
			WHERE WO.intWorkOrderId = @AGWorkOrderId


			
			DECLARE @strInvalidItemNo  NVARCHAR(MAX)
			DECLARE @intInvalidItemId INT  = NULL

		
			EXEC uspICValidateStockReserves @ItemReservationTableType, @strInvalidItemNo OUTPUT, @intInvalidItemId OUTPUT
			
			IF (@strInvalidItemNo <> NULL OR @intInvalidItemId <> NULL)
			BEGIN
				DECLARE @ERROR_MESSAGE NVARCHAR(MAX) = N'Cannot ship invalid item' + ISNULL(@strInvalidItemNo,'') + ' ' + ISNULL(CAST(@intInvalidItemId AS NVARCHAR(200)),'')
				RAISERROR(@ERROR_MESSAGE, 16, 1)
				RETURN;
			END
END