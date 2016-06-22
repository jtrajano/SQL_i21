CREATE PROCEDURE [dbo].[uspICUpdateStatusOnShipmentSave]
	@intShipmentId INT
	,@ysnOpenStatus	BIT = 0
AS
BEGIN
	DECLARE @OrderTypeSalesContract AS INT = 1
			,@OrderTypeSalesOrder AS INT = 2
			,@OrderTypeTransferOrder AS INT = 3
			,@OrderTypeDirect AS INT = 4

	DECLARE @SourceTypeNone AS INT = 0
			,@SourceTypeScale AS INT = 1
			,@SourceTypeInboundShipment AS INT = 2
			,@SourceTypePickLot AS INT = 3

	-- Update the Sales Order Status. 
	IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId AND intOrderType = @OrderTypeSalesOrder)
	BEGIN
		DECLARE @SOId INT

		SELECT	DISTINCT 
				intOrderId 
		INTO	#tmpSOList FROM tblICInventoryShipmentItem
		WHERE	intInventoryShipmentId = @intShipmentId
				AND intOrderId IS NOT NULL 

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpSOList)
		BEGIN
			SELECT TOP 1 @SOId = intOrderId FROM #tmpSOList

			IF (@ysnOpenStatus = 1)
				EXEC uspSOUpdateOrderShipmentStatus @SOId, 1
			ELSE
				EXEC uspSOUpdateOrderShipmentStatus @SOId, NULL 

			DELETE FROM #tmpSOList WHERE intOrderId = @SOId
		END
		
		DROP TABLE #tmpSOList
	END

	-- Update the Logistic Status
	IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId AND intOrderType = @OrderTypeSalesContract AND intSourceType = @SourceTypePickLot)
	BEGIN
		DECLARE @PickLotId INT

		SELECT	DISTINCT intSourceId 
		INTO	#tmpPickLotList 
		FROM	tblICInventoryShipmentItem
		WHERE	intInventoryShipmentId = @intShipmentId
				AND intSourceId IS NOT NULL 

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPickLotList)
		BEGIN
			SELECT TOP 1 @PickLotId = intSourceId FROM #tmpPickLotList

			EXEC uspLGReserveStockForPickLots @PickLotId
			
			DELETE FROM #tmpPickLotList WHERE intSourceId = @PickLotId
		END
		
		DROP TABLE #tmpPickLotList
	END

	-- Update the Scale Status 
	IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId AND intSourceType = @SourceTypeScale)
	BEGIN
		DECLARE @ScaleId INT

		SELECT DISTINCT 
				intSourceId 
		INTO	#tmpScaleTickets 
		FROM	tblICInventoryShipmentItem
		WHERE	intInventoryShipmentId = @intShipmentId
				AND intSourceId IS NOT NULL 

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpScaleTickets)
		BEGIN
			SELECT TOP 1 
					@ScaleId = intSourceId 
			FROM	#tmpScaleTickets

			IF (@ysnOpenStatus = 1)
				EXEC uspSCUpdateStatus @ScaleId, 1
			ELSE
				EXEC uspSCUpdateStatus @ScaleId, NULL 
			
			DELETE	 FROM #tmpScaleTickets 
			WHERE	intSourceId = @ScaleId
		END
		
		DROP TABLE #tmpScaleTickets
	END

	RETURN
END