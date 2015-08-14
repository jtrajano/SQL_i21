CREATE PROCEDURE [dbo].[uspICUpdateContractOnShipmentSave]
	@intShipmentId INT,
	@intUserId INT
AS

DECLARE @ContractId INT
DECLARE @QtyToShip NUMERIC(18, 6)
DECLARE @ExternalId INT

BEGIN
		SELECT DISTINCT intLineNo, dblQuantity, intInventoryShipmentItemId INTO #tmpContractList FROM tblICInventoryShipmentItem
		WHERE intInventoryShipmentId = @intShipmentId
			AND ISNULL(intLineNo, '') <> ''

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpContractList)
		BEGIN
			SELECT TOP 1 @ContractId = intLineNo, @QtyToShip = dblOpenReceive, @ExternalId = intInventoryReceiptItemId FROM #tmpContractList

			EXEC uspCTUpdateScheduleQuantity @ContractId, @QtyToShip, @intUserId, @ExternalId, 'Inventory Shipment'
			
			DELETE FROM #tmpContractList WHERE intLineNo = @ContractId
		END
		
		DROP TABLE #tmpContractList
	
	RETURN
END