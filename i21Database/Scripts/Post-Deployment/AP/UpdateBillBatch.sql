--This will default the new field of bill batch to the first date of first associated bill
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'dtmBatchDate' AND [object_id] = OBJECT_ID(N'tblAPBillBatch'))
	AND EXISTS(SELECT 1 FROM tblAPBillBatch WHERE dtmBatchDate IS NULL)
BEGIN

	UPDATE A
		SET A.dtmBatchDate = ISNULL((SELECT TOP 1 dtmDate FROM tblAPBill WHERE intBillBatchId = A.intBillBatchId), GETDATE())
	FROM tblAPBillBatch A
	WHERE dtmBatchDate IS NULL

END