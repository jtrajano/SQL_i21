--THIS WILL FIXED BILL ASSOCIATION TO INVENTORY RECEIPT
BEGIN TRAN InvalidBillAssociations
SAVE TRAN InvalidBillAssociations
IF (EXISTS(SELECT 1 FROM tblAPBillDetail A
WHERE A.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem)))
BEGIN

	DECLARE @totalAffected INT
	SET @totalAffected = (SELECT COUNT(*) FROM tblAPBillDetail A
							WHERE A.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem))

	UPDATE A
		SET A.intInventoryReceiptItemId = IR.intInventoryReceiptItemId
		,A.intPurchaseDetailId = IR.intLineNo
	FROM tblAPBillDetail A
	CROSS APPLY (
		SELECT B.* FROM tblICInventoryReceiptItem B
			INNER JOIN tblICInventoryReceipt B2 ON B.intInventoryReceiptId = B2.intInventoryReceiptId
		WHERE B.intLineNo IN (
			SELECT A2.intInventoryReceiptItemId FROM tblAPBillDetail A2
			WHERE A2.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem)
			AND A2.intBillDetailId = A.intBillDetailId
		)
		AND B2.strReceiptType = 'Purchase Order'
	) IR

	IF(@@ROWCOUNT != @totalAffected)
	BEGIN
		RAISERROR('Unexpected number of rows affected.', 16, 1);
	END

	IF (EXISTS(SELECT 1 FROM tblAPBillDetail A
		WHERE A.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem)))
	BEGIN
		RAISERROR('Updating bill assocation to inventory receipt has failed.', 16, 1);
	END

	IF  (@@ERROR != 0)
	BEGIN
		ROLLBACK TRAN InvalidBillAssociations
	END
	ELSE
	BEGIN
		COMMIT TRAN InvalidBillAssociations
	END

END 
