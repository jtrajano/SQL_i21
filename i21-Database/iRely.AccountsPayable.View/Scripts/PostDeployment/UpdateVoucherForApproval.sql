/*
	UPDATE THOSE OLD FOR APPROVAL TRANSACTIONS
	UPDATE THOSE THAT DOESN'T HAVE DATA IN tblAPVoucherApprover AND FOR APPROVAL STATUS
*/
IF EXISTS(SELECT 1 FROM tblAPBill A WHERE A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
			AND NOT EXISTS(SELECT 1 FROM tblAPVoucherApprover B WHERE A.intBillId = B.intVoucherId))
BEGIN
	BEGIN TRY
		SELECT 
		*
		INTO #tmpVoucherApprover
		FROM tblAPBill A1
		WHERE EXISTS(
			SELECT 1 FROM tblAPBill A WHERE A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
				AND NOT EXISTS(SELECT 1 FROM tblAPVoucherApprover B WHERE A.intBillId = B.intVoucherId)
				AND A1.intBillId = A.intBillId
		)

		UPDATE A1
			SET A1.ysnForApprovalSubmitted = 1
		FROM tblAPBill A1
		INNER JOIN #tmpVoucherApprover A2 ON A1.intBillId = A2.intBillId

		--CREATE VOUCHER APPROVER
		DECLARE @billId AS INT;
		DECLARE @BillCursor AS CURSOR;

		SET @BillCursor = CURSOR FORWARD_ONLY FOR
		SELECT intBillId FROM #tmpVoucherApprover
 
		OPEN @BillCursor;
		FETCH NEXT FROM @BillCursor INTO @billId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			 EXEC uspAPCreateVoucherApprover @billId
			 FETCH NEXT FROM @BillCursor INTO @billId
		END
		CLOSE @BillCursor;
		DEALLOCATE @BillCursor;
	END TRY
	BEGIN CATCH
		PRINT 'Unable to find approver setup.'
	END CATCH
END