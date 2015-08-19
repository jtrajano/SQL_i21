CREATE PROCEDURE [dbo].[uspICUpdateContractOnReceiptSave]
	@intReceiptId INT,
	@intUserId INT
AS

DECLARE @ContractId INT
DECLARE @QtyToReceive NUMERIC(18, 6)
DECLARE @ExternalId INT

BEGIN
		SELECT DISTINCT intLineNo, dblOpenReceive, intInventoryReceiptItemId INTO #tmpContractList FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intReceiptId
			AND ISNULL(intLineNo, '') <> ''

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpContractList)
		BEGIN
			SELECT TOP 1 @ContractId = intLineNo, @QtyToReceive = dblOpenReceive, @ExternalId = intInventoryReceiptItemId FROM #tmpContractList

			EXEC uspCTUpdateScheduleQuantity @ContractId, @QtyToReceive, @intUserId, @ExternalId, 'Inventory Receipt'
			
			DELETE FROM #tmpContractList WHERE intLineNo = @ContractId
		END
		
		DROP TABLE #tmpContractList
	
	RETURN
END