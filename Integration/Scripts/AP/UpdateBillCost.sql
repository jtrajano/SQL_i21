--Update dblCost value on tblAPBillDetail
--Make sure to execute this only if it has not been done yet
--Update only the transactions Bill and Debit Memo
IF EXISTS(SELECT 1 FROM tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			 WHERE A.dblCost = 0 AND B.intTransactionType IN (1, 3))
BEGIN
	
	UPDATE tblAPBillDetail
	SET dblCost = A.dblTotal
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	WHERE A.dblCost = 0 AND B.intTransactionType IN (1, 3)

END