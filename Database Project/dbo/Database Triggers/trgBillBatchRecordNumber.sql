CREATE TRIGGER trgBillBatchRecordNumber
ON tblAPBillBatch
AFTER INSERT
AS
	DECLARE @BillBatchId NVARCHAR(50)
	SELECT @BillBatchId = strPrefix + CONVERT(NVARCHAR,intNumber + 1) 
		FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Bill Batch' AND ysnEnable = 1
	
	IF(@BillBatchId IS NOT NULL)
	BEGIN
	UPDATE tblAPBillBatch
		SET tblAPBillBatch.strBillBatchNumber = @BillBatchId
	FROM tblAPBillBatch A
		INNER JOIN INSERTED B ON A.intBillBatchId = B.intBillBatchId
	END
