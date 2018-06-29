CREATE TRIGGER trgAPBill
ON dbo.tblAPBill
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @billRecord NVARCHAR(50);
	DECLARE @billId INT;
	DECLARE @error NVARCHAR(500);
	SELECT TOP 1 @billRecord = del.strBillId, @billId = del.intBillId FROM tblGLDetail glDetail
					INNER JOIN DELETED del ON glDetail.strTransactionId = del.strBillId AND glDetail.intTransactionId = del.intBillId
				WHERE glDetail.ysnIsUnposted = 0

	IF @billId > 0
	BEGIN
		SET @error = 'You cannot delete posted voucher (' + @billRecord + ')';
		RAISERROR(@error, 16, 1);
	END
	ELSE
	BEGIN
		DELETE A
		FROM tblAPBill A
		INNER JOIN DELETED B ON A.intBillId = B.intBillId
	END
END
GO