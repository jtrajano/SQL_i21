CREATE PROCEDURE [dbo].[uspAPValidateVoucherDetailReceiptPO]
	@voucherId INT,
	@voucherDetailReceiptPO AS [VoucherDetailReceipt] READONLY
AS

DECLARE @errorItem NVARCHAR(50);
DECLARE @error NVARCHAR(200);

--DO NOT ALLOW TO CREATE BILL FROM UNPOSTED INVENTORY RECEIPT
SELECT TOP 1 @errorItem = D.strItemNo FROM tblICInventoryReceipt A
			INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
			INNER JOIN @voucherDetailReceiptPO C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
			INNER JOIN tblICItem D ON B.intItemId = D.intItemId
		WHERE A.ysnPosted = 0

IF @errorItem IS NOT NULL
BEGIN
	SET @error = '''' + @errorItem + ''' was associated on unposted receipt. Post the receipt first.'
	RAISERROR(@error, 16, 1);
END

--DO NOT ALLOW TO BILL MORE THAN THE AVAILABLE QUANTITY IN INVENTORY RECEIPT
SELECT TOP 1 @errorItem = D.strItemNo FROM tblICInventoryReceipt A
			INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
			INNER JOIN @voucherDetailReceiptPO C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
			INNER JOIN tblICItem D ON B.intItemId = D.intItemId
		WHERE A.ysnPosted = 1 AND ISNULL(C.dblQtyReceived, 0) > (B.dblOpenReceive - B.dblBillQty)

IF @errorItem IS NOT NULL
BEGIN
	SET @error = '''' + @errorItem + ''' received quantity was more than the available quantity to bill.'
	RAISERROR(@error, 16, 1);
END

--ALLOW PARTIAL BILLING ONLY IF TAX WAS NOT ADJUSTED
SELECT TOP 1 @errorItem = D.strItemNo FROM tblICInventoryReceipt A
			INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
			INNER JOIN @voucherDetailReceiptPO C ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
			INNER JOIN tblICItem D ON B.intItemId = D.intItemId
			INNER JOIN tblICInventoryReceiptItemTax E ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		WHERE A.ysnPosted = 1 AND (ISNULL(C.dblQtyReceived, B.dblOpenReceive) != B.dblOpenReceive OR B.dblOpenReceive != B.dblBillQty)
		AND B.dblTax > 0 AND E.ysnTaxAdjusted = 1

IF @errorItem IS NOT NULL
BEGIN
	SET @error = '''' + @errorItem + ''' cannot partially billed because receipt item tax was adjusted.'
	RAISERROR(@error, 16, 1);
END