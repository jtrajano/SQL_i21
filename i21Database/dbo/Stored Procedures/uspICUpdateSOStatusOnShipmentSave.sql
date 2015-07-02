﻿CREATE PROCEDURE [dbo].[uspICUpdateSOStatusOnShipmentSave]
	@intShipmentId INT
AS

DECLARE @SOId INT

BEGIN

	IF EXISTS(SELECT * FROM tblICInventoryShipment WHERE intOrderType = 2)
	BEGIN
		SELECT DISTINCT intOrderId INTO #tmpSOList FROM tblICInventoryShipmentItem
		WHERE intInventoryShipmentId = @intShipmentId
			AND ISNULL(intOrderId, '') <> ''

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpSOList)
		BEGIN
			SELECT TOP 1 @SOId = intOrderId FROM #tmpSOList
			
			EXEC uspSOUpdateOrderShipmentStatus @SOId

			DELETE FROM #tmpSOList WHERE intOrderId = @SOId
		END
		
		DROP TABLE #tmpSOList
	END

	RETURN
END