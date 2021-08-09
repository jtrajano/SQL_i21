CREATE PROCEDURE [dbo].[uspAGUpdateICStockReservation]

@AGWorkOrderId INT = NULL,
@toShip BIT = 0,
@intUserId INT = NULL


AS
BEGIN
	SET QUOTED_IDENTIFIER OFF    
	SET ANSI_NULLS ON    
	SET NOCOUNT ON    
	SET XACT_ABORT ON    
	SET ANSI_WARNINGS OFF

    DECLARE @intWorkOrderId INT = @AGWorkOrderId

	--VALIDATE QTY MUST NOT BE ZERO


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
					,[dblQty]				= 
                                            CASE WHEN @toShip = 1 THEN
                                            (CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0 
                                                    THEN ((WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0))) 
                                                    ELSE 0 END)
                                            ELSE 
                                                CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0
                                                        THEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) * - 1
                                                    ELSE 0 END

						                    END
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
				AND ISNULL(LOT.intStorageLocationId,0) = ISNULL(WOD.intStorageLocationId,0)   
				  
			WHERE WO.intWorkOrderId = @AGWorkOrderId


			
			DECLARE @strInvalidItemNo  NVARCHAR(MAX)
			DECLARE @intInvalidItemId INT  = NULL

		
			EXEC uspICValidateStockReserves @ItemReservationTableType, @strInvalidItemNo OUTPUT, @intInvalidItemId OUTPUT
			
			IF (@strInvalidItemNo <> NULL OR @intInvalidItemId <> NULL)
			BEGIN
				RAISERROR('Cannot ship invalid item', 16, 1)  
			END

			EXEC dbo.uspICCreateStockReservation @ItemReservationTableType,@intWorkOrderId,59, @intUserId

			
            --UPDATE THE STATUS
			IF (@toShip = 1)
			BEGIN
				-- UPDATE tblAGWorkOrderDetail
				-- 		SET dblQtyShipped = CASE WHEN (ISNULL(dblQtyShipped,0)) < ISNULL(dblQtyOrdered,0) THEN (ISNULL(dblQtyShipped,0) + ISNULL(dblQtyOrdered,0)) 
				-- 							ELSE ISNULL(dblQtyShipped,0) END
				-- 		WHERE intWorkOrderId = @intWorkOrderId

				UPDATE tblAGWorkOrder SET
						 ysnShipped = 1,
						 ysnFinalized = 0,
						 strStatus = 'In Progress'
					WHERE intWorkOrderId = @AGWorkOrderId
			END
			ELSE
				BEGIN
					-- UPDATE tblAGWorkOrderDetail
					-- 		SET dblQtyShipped = CASE WHEN (ISNULL(dblQtyShipped,0) > 0 ) THEN ISNULL(dblQtyOrdered,0) - (dblQtyShipped)
					-- 							ELSE 0 END
					--UPDATE THE STATUS
					UPDATE tblAGWorkOrder SET
						 ysnShipped = 0,
						 ysnFinalized = 0,
						 strStatus = 'Open'
						WHERE intWorkOrderId = @AGWorkOrderId
				END

		
END
