/*
	@poId = The intPurchaseId of tblPOPurchase table
	@posted = a. DEFAULT if wanted to know if PO has item receipt wether posted or not
			  b. Pass 1 to check if PO has item receipt that was posted else 0

*/
CREATE FUNCTION [dbo].[fnPOHasItemReceipt]
(
	@poId INT,
	@posted BIT = NULL
)
RETURNS BIT
AS
BEGIN
	RETURN CASE WHEN @posted IS NULL
					AND EXISTS(SELECT 1 FROM tblPOPurchase A 
							INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
							INNER JOIN (tblICInventoryReceipt C1 INNER JOIN tblICInventoryReceiptItem C2 ON C1.intInventoryReceiptId = C2.intInventoryReceiptId)
								 ON B.intPurchaseDetailId = C2.intLineNo
						WHERE A.intPurchaseId = @poId)
					THEN 1
				WHEN @posted IS NOT NULL AND
						EXISTS(SELECT 1 FROM tblPOPurchase A 
							INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
							INNER JOIN (tblICInventoryReceipt C1 INNER JOIN tblICInventoryReceiptItem C2 ON C1.intInventoryReceiptId = C2.intInventoryReceiptId)
								 ON B.intPurchaseDetailId = C2.intLineNo
						WHERE A.intPurchaseId = @poId
							AND C1.ysnPosted = @posted)
					THEN 1
				ELSE 
					0
				END
END
