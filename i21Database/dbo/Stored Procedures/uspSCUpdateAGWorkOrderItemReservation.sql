CREATE PROCEDURE [dbo].[uspSCUpdateAGWorkOrderItemReservation]
	@intWorkOrderId INT
	,@intTicketId INT
	,@intItemId INT
	,@ysnDistribute BIT
AS
BEGIN
	
	DECLARE @intTicketNetQuantity NUMERIC(38,20)
	DECLARE @ItemReservationTableType AS ItemReservationTableType
	DECLARE @intTransctionTypeId INT = 59
	DECLARE @strInvalidItemNo NVARCHAR(50)
	DECLARE @intInvalidItemId INT 

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @SummaryLogs AS RKSummaryLog
	
	
	
	BEGIN TRY
		IF @ysnDistribute = 1
		BEGIN
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
			SELECT	[intItemId]				= SC.intItemId
					,[intItemLocationId]	= ICIL.intItemLocationId
					,[intItemUOMId]			= SC.intItemUOMIdTo
					,[intLotId]				= NULL
					,[intSubLocationId]		= SC.intSubLocationId
					,[intStorageLocationId]	= SC.intStorageLocationId
					,[dblQty]				= CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0) - SC.dblNetUnits) > 0 THEN ((WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0) - SC.dblNetUnits) * -1) ELSE 0 END
					,[intTransactionId]		= @intWorkOrderId
					,[strTransactionId]		= WO.strOrderNumber
					,[intTransactionTypeId] = @intTransctionTypeId
			FROM	tblSCTicket SC
			INNER JOIN dbo.tblICItemLocation ICIL 
				ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
			INNER JOIN tblAGWorkOrder WO
				ON SC.intAGWorkOrderId = WO.intWorkOrderId
			INNER JOIN tblAGWorkOrderDetail WOD
				ON WO.intWorkOrderId = WOD.intWorkOrderId AND WOD.intItemId = SC.intItemId
			WHERE SC.intTicketId = @intTicketId

			EXEC uspICValidateStockReserves @ItemReservationTableType, @strInvalidItemNo, @intInvalidItemId 
			EXEC dbo.uspICCreateStockReservation @ItemReservationTableType,@intWorkOrderId,@intTransctionTypeId
		END
		ELSE
		BEGIN
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
			SELECT	[intItemId]				= SC.intItemId
					,[intItemLocationId]	= ICIL.intItemLocationId
					,[intItemUOMId]			= SC.intItemUOMIdTo
					,[intLotId]				= NULL
					,[intSubLocationId]		= SC.intSubLocationId
					,[intStorageLocationId]	= SC.intStorageLocationId
					,[dblQty]				= CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0 THEN (WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0)) ELSE 0 END
					,[intTransactionId]		= @intWorkOrderId
					,[strTransactionId]		= WO.strOrderNumber
					,[intTransactionTypeId] = 59
			FROM	tblSCTicket SC
			INNER JOIN dbo.tblICItemLocation ICIL 
				ON ICIL.intItemId = SC.intItemId AND ICIL.intLocationId = SC.intProcessingLocationId
			INNER JOIN tblAGWorkOrder WO
				ON SC.intAGWorkOrderId = WO.intWorkOrderId
			INNER JOIN tblAGWorkOrderDetail WOD
				ON WO.intWorkOrderId = WOD.intWorkOrderId AND WOD.intItemId = SC.intItemId
			WHERE SC.intTicketId = @intTicketId

			EXEC uspICValidateStockReserves @ItemReservationTableType, @strInvalidItemNo, @intInvalidItemId 
			EXEC dbo.uspICCreateStockReservation @ItemReservationTableType,@intWorkOrderId,59

		END
	_Exit:
	END TRY
	BEGIN CATCH
		SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH


END
GO