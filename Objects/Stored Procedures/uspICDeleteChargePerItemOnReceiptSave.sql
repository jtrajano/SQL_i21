CREATE PROCEDURE [dbo].[uspICDeleteChargePerItemOnReceiptSave]
	@intReceiptNo INT
AS

-- Clear the records in tblICInventoryReceiptChargePerItem 
-- It will be re-created when the receipt is posted. 
BEGIN 
	DELETE	chargePerItem
	FROM	tblICInventoryReceiptChargePerItem chargePerItem INNER JOIN tblICInventoryReceipt r 
				ON chargePerItem.intInventoryReceiptId = r.intInventoryReceiptId
	WHERE	r.intInventoryReceiptId = @intReceiptNo
END 

