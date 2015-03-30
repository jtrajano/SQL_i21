CREATE PROCEDURE [dbo].[uspPOUpdateStatus]
    @poId INT,
    @status INT = NULL
AS
BEGIN

	IF @status IS NULL
	BEGIN
		--try to change status based on records
		SELECT	@status =	CASE	WHEN 
										(SELECT SUM(dblQtyOrdered) - SUM(dblQtyReceived) FROM tblPOPurchaseDetail WHERE intPurchaseId = A.intPurchaseId) = 0 
									THEN 3 --Closed
									WHEN NOT EXISTS(SELECT 1 FROM tblAPBillDetail WHERE intItemReceiptId = B.intPurchaseDetailId)
											AND NOT EXISTS(SELECT 1 FROM tblICInventoryReceiptItem WHERE intLineNo = B.intPurchaseDetailId)
									THEN 1 --Open
									WHEN 
										EXISTS(SELECT 1 FROM tblAPBillDetail WHERE intItemReceiptId = B.intPurchaseDetailId) OR 
													EXISTS(SELECT 1 FROM tblICInventoryReceiptItem WHERE intLineNo = B.intPurchaseDetailId)
									THEN 7 --Pending
									WHEN 
										EXISTS(SELECT 1 FROM tblAPBill A INNER JOIN tblAPBillDetail ON A.intBillId = tblAPBillDetail.intBillId
															WHERE intItemReceiptId = B.intPurchaseDetailId AND A.ysnPosted = 1) OR 
													EXISTS(SELECT 1 FROM tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem ON A.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
														WHERE intLineNo = B.intPurchaseDetailId AND A.ysnPosted = 1)
									THEN 2 --Partial
									ELSE NULL 
							END
		FROM	tblPOPurchase A INNER JOIN tblPOPurchaseDetail B 
					ON A.intPurchaseId = B.intPurchaseId
		WHERE A.intPurchaseId = @poId
	END

	IF @status IS NULL
	BEGIN
		RAISERROR('Invalid status provided.', 16, 1);
	END

	EXEC uspPOValidateStatus @poId, @status

	UPDATE A
		SET A.intOrderStatusId = @status
	FROM tblPOPurchase A
	WHERE intPurchaseId = @poId


END
