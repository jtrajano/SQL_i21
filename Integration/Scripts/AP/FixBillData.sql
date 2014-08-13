--Update Bill records for the new fields in 14.3

IF EXISTS(SELECT 1 FROM tblAPBillDetail A WHERE A.dblQtyOrdered = 0 AND A.dblTotal <> 0)
BEGIN

	PRINT 'Updating value of new fields in tblAPBill'
	--Update Bill Cost, Landed Cost, Quantity Order and Received, Discount
	UPDATE tblAPBillDetail
	SET dblCost = A.dblTotal
	,dblQtyOrdered = 1
	,dblQtyReceived = 1
	FROM tblAPBillDetail A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	
END
