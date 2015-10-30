CREATE VIEW [dbo].[vyuCTInventoryReceiptItem]

AS 
	SELECT	CAST(ROW_NUMBER() OVER(ORDER BY strReceiptNumber ASC) AS INT) intInventoryReceiptItemId,
			*
	FROM	(
				SELECT	DISTINCT
						RI.intInventoryReceiptId,
						IR.strReceiptNumber,
						IR.strReceiptType,
						IR.intSourceType,
						CQ.intShipmentId,
						CQ.intContractDetailId
				FROM	tblICInventoryReceiptItem	RI
				JOIN	tblICInventoryReceipt		IR ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
				JOIN	tblLGShipmentContractQty CQ ON CQ.intShipmentContractQtyId = RI.intSourceId
				WHERE	IR.strReceiptType = 'Purchase Contract' AND IR.intSourceType = 2
			)t