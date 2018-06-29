--THIS WILL FIXED THOSE BILLS THAT ARE ALREADY PAID BUT HAS NEGATIVE AMOUNT DUE
BEGIN TRY
BEGIN TRANSACTION #updateUnpaidStatus
SAVE TRANSACTION #updateUnpaidStatus
IF(EXISTS(SELECT 1 FROM vyuAPBillStatus WHERE strStatus = 'Invalid Paid Status. Bill was already fully paid.'))
BEGIN
	
	UPDATE A
		SET A.ysnPaid = 1
	FROM tblAPBill A
	WHERE EXISTS(
		SELECT 1 FROM vyuAPBillStatus B WHERE strStatus = 'Invalid Paid Status. Bill was already fully paid.'
		AND A.intBillId = B.intBillId
	)

END
IF @@TRANCOUNT > 0
BEGIN
COMMIT TRANSACTION #updateUnpaidStatus
END
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION #updateUnpaidStatus
END CATCH