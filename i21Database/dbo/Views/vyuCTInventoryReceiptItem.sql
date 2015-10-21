CREATE VIEW [dbo].[vyuCTInventoryReceiptItem]

AS 

	SELECT	RI.intInventoryReceiptItemId,
			RI.intInventoryReceiptId,
			IR.strReceiptNumber,
			IR.strReceiptType,
			IR.intSourceType,
			RI.intSourceId intShipmentId
	FROM	tblICInventoryReceiptItem	RI
	JOIN	tblICInventoryReceipt		IR ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
