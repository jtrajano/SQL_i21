IF EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail WHERE dblRate = 0 OR dblRate IS NULL)
BEGIN
	UPDATE A
		SET A.dblRate = 1
	FROM tblAPBillDetail A
	WHERE A.dblRate = 0 OR A.dblRate IS NULL
END