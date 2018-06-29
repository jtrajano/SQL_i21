--THIS WILL UPDATE tblAPBill.int1099Code
IF(EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblAPBillDetail'))
BEGIN
	IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'int1099Code' and object_id = OBJECT_ID(N'tblAPBillDetail')))
	BEGIN
	EXEC('
		UPDATE A
			SET A.int1099Code = ISNULL(A.int1099Code, 0)
		FROM tblAPBillDetail A
		WHERE A.int1099Code IS NULL
		')

	END

	IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'int1099Category' and object_id = OBJECT_ID(N'tblAPBillDetail')))
	BEGIN
	EXEC('
		UPDATE A
			SET A.int1099Category = ISNULL(A.int1099Category, 0)
		FROM tblAPBillDetail A
		WHERE A.int1099Category IS NULL
		')
	END
END