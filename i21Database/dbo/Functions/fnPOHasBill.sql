CREATE FUNCTION [dbo].[fnPOHasBill]
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
							INNER JOIN (tblAPBill D1 INNER JOIN tblAPBillDetail D2 ON D1.intBillId = D2.intBillId)
								 ON B.intPurchaseDetailId = D2.[intPurchaseDetailId]
							INNER JOIN tblICItem C ON C.intItemId = D2.intItemId
							WHERE strType IN ('Service','Software','Non-Inventory','Other Charge')
								AND A.intPurchaseId = @poId)
					THEN 1
				WHEN @posted IS NOT NULL
					AND EXISTS(SELECT 1 FROM tblPOPurchase A 
							INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
							INNER JOIN (tblAPBill D1 INNER JOIN tblAPBillDetail D2 ON D1.intBillId = D2.intBillId)
								 ON B.intPurchaseDetailId = D2.[intPurchaseDetailId]
							INNER JOIN tblICItem C ON C.intItemId = D2.intItemId
							WHERE strType IN ('Service','Software','Non-Inventory','Other Charge')
								AND A.intPurchaseId = @poId
								AND D1.ysnPosted = @posted)
					THEN 1					
				ELSE 0 END
END
