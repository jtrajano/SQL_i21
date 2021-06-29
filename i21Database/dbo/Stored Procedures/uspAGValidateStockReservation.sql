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
					,[intLotId]				= CASE WHEN (ISNULL(ITEM.strLotTracking,'') <> 'No') THEN LOT.intLotId ELSE NULL  END  
					,[intSubLocationId]		= ISNULL(WOD.intSubLocationId,StorageLocation.intSubLocationId)    
					,[intStorageLocationId]	= ISNULL(WOD.intStorageLocationId,StorageLocation.intStorageLocationId)   
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

			LEFT JOIN tblICStorageLocation StorageLocation
				ON StorageLocation.intStorageLocationId = WOD.intStorageLocationId 

			 LEFT JOIN tblICLot LOT   
 				ON LOT.intItemId = ITEM.intItemId  
			AND LOT.intItemLocationId = ICIL.intItemLocationId   
			AND ISNULL(LOT.intStorageLocationId,0) =  ISNULL(WOD.intStorageLocationId,0)  

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