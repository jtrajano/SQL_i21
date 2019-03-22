IF EXISTS(SELECT 1 FROM tblAPBillDetail A WHERE A.dblTotal != 0 AND A.dbl1099 = 0)
BEGIN
	UPDATE A
		SET A.dbl1099 = A.dblTotal
	FROM tblAPBillDetail A
	WHERE A.dblTotal != 0 AND A.dbl1099 = 0
END