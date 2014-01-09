CREATE TRIGGER trgBillRecordNumber
ON tblAPBill
AFTER INSERT
AS
	DECLARE @BillId NVARCHAR(50)
	SELECT @BillId = strPrefix + CONVERT(NVARCHAR,intNumber + 1) 
		FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Bill' AND ysnEnable = 1
	
	IF(@BillId IS NOT NULL)
	BEGIN
	UPDATE tblAPBill
		SET tblAPBill.strBillId = @BillId
	FROM tblAPBill A
		INNER JOIN INSERTED B ON A.intBillId = B.intBillId
	END

	UPDATE tblSMStartingNumber
		SET intNumber = intNumber + 1
	WHERE strTransactionType = 'Bill' AND ysnEnable = 1