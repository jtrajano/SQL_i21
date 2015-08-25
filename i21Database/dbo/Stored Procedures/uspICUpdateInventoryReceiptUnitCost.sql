CREATE PROCEDURE [dbo].[uspICUpdateInventoryReceiptUnitCost]
	@intContractDetailId AS INT,
	@newUnitCost AS NUMERIC(18,6)
AS
BEGIN

	SELECT Receipt.intInventoryReceiptId, ReceiptItem.intInventoryReceiptItemId, dblUnitCost = @newUnitCost, dblUnitRetail = @newUnitCost, dblLineTotal = (@newUnitCost * dblOpenReceive) + dblTax
	INTO #tmpContractCost
	FROM tblICInventoryReceiptItem ReceiptItem
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	WHERE ReceiptItem.intLineNo = @intContractDetailId
		AND Receipt.ysnPosted = 0
		AND Receipt.strReceiptType = 'Purchase Contract'

	UPDATE tblICInventoryReceiptItem
	SET tblICInventoryReceiptItem.dblUnitCost = ContractCost.dblUnitCost,
		tblICInventoryReceiptItem.dblUnitRetail = ContractCost.dblUnitRetail,
		tblICInventoryReceiptItem.dblLineTotal = ContractCost.dblLineTotal
	FROM #tmpContractCost ContractCost 
	WHERE tblICInventoryReceiptItem.intInventoryReceiptItemId = ContractCost.intInventoryReceiptItemId

	SELECT DISTINCT intInventoryReceiptId
	INTO #ChangedReceipts
	FROM #tmpContractCost

	DECLARE @intInventoryReceiptId INT
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #ChangedReceipts)
	BEGIN
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM #ChangedReceipts

		EXEC uspICCalculateOtherCharges @intInventoryReceiptId

		DELETE FROM #ChangedReceipts WHERE intInventoryReceiptId = @intInventoryReceiptId
	END
	DROP TABLE #ChangedReceipts
	DROP TABLE #tmpContractCost
END