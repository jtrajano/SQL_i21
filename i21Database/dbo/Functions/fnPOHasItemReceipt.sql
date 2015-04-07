CREATE FUNCTION [dbo].[fnPOHasItemReceipt]
(
	@poId INT,
	@posted BIT = 0
)
RETURNS BIT
AS
BEGIN
	RETURN CASE WHEN 
				EXISTS(SELECT 1 FROM tblPOPurchase A 
							INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
							INNER JOIN (tblICInventoryReceipt C1 INNER JOIN tblICInventoryReceiptItem C2 ON C1.intInventoryReceiptId = C2.intInventoryReceiptId)
								 ON B.intPurchaseDetailId = C2.intLineNo
						WHERE A.intPurchaseId = B.intPurchaseId
							AND C1.ysnPosted = @posted)
				THEN 1
				ELSE 0 END
END
