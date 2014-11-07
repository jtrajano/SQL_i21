--Update Bill records for the new fields in 14.3

IF EXISTS(SELECT 1 FROM tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE A.dblQtyOrdered = 0 AND A.dblTotal <> 0 AND B.ysnOrigin = 1)
BEGIN

	PRINT 'BEGIN Updating value of new fields in tblAPBill'
	--Update Bill Cost, Landed Cost, Quantity Order and Received, Discount
	UPDATE tblAPBillDetail
	SET dblCost = A.dblTotal
	,dblQtyOrdered = 1
	,dblQtyReceived = 1
	FROM tblAPBillDetail A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	WHERE A.dblCost = 0 AND A.dblTotal <> 0

	PRINT 'END Updating value of new fields in tblAPBill'
	
END
