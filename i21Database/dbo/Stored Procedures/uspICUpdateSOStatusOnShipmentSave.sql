CREATE PROCEDURE [dbo].[uspICUpdateSOStatusOnShipmentSave]
	@intShipmentId INT
	,@ysnOpenStatus	BIT = 0
AS

BEGIN

	IF EXISTS(SELECT * FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId AND intOrderType = 2)
	BEGIN
		DECLARE @SOId INT

		SELECT DISTINCT intOrderId INTO #tmpSOList FROM tblICInventoryShipmentItem
		WHERE intInventoryShipmentId = @intShipmentId
			AND ISNULL(intOrderId, '') <> ''

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

	IF EXISTS(SELECT * FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intShipmentId AND intOrderType = 1 AND intSourceType = 3)
	BEGIN
		DECLARE @PickLotId INT

		SELECT DISTINCT intSourceId INTO #tmpPickLotList FROM tblICInventoryShipmentItem
		WHERE intInventoryShipmentId = @intShipmentId
			AND ISNULL(intSourceId, '') <> ''

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPickLotList)
		BEGIN
			SELECT TOP 1 @PickLotId = intSourceId FROM #tmpPickLotList

			EXEC uspLGReserveStockForPickLots @PickLotId
			
			DELETE FROM #tmpPickLotList WHERE intSourceId = @PickLotId
		END
		
		DROP TABLE #tmpPickLotList
	END

	RETURN
END