CREATE FUNCTION [dbo].[fnAPGetIRPartialStatus]
(
	@strTransactionId NVARCHAR(100) = NULL
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @PartialStatus BIT = 0;

	IF EXISTS( 
					SELECT Billed.dblQty, B.dblOpenReceive FROM tblICInventoryReceipt A
					INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
					OUTER APPLY 
					(
						SELECT SUM(ISNULL(H.dblQtyReceived,0)) AS dblQty FROM tblAPBillDetail H 
						INNER JOIN tblAPBill I ON H.intBillId = I.intBillId
						WHERE H.intInventoryReceiptItemId = B.intInventoryReceiptItemId AND H.intInventoryReceiptChargeId IS NULL
						AND I.ysnPosted = 1
						GROUP BY H.intInventoryReceiptItemId
					) Billed
					WHERE strReceiptNumber= @strTransactionId AND ((Billed.dblQty != B.dblOpenReceive) AND Billed.dblQty IS NOT NULL)
			)
	BEGIN
		SET @PartialStatus = 1
	END

	RETURN @PartialStatus;

END
GO