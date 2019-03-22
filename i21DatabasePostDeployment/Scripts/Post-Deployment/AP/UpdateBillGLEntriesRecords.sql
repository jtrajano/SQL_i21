--THIS WILL FIXED THOSE BILLS GL ENTRIES THAT ARE HAS VOUCHER NAME
PRINT('BEGIN UPDATING BILL GL ENTRIES RECORDS')
BEGIN
	IF EXISTS(SELECT 1 FROM tblGLDetail WHERE strJournalLineDescription LIKE '%Posted Voucher%')
	BEGIN
		UPDATE A
			SET A.strJournalLineDescription = 'Posted Bill',
				A.strTransactionType = 'Bill',
				A.strTransactionForm = 'Bill'
		FROM dbo.tblGLDetail A
		WHERE A.strModuleName = 'Accounts Payable' AND A.strTransactionType LIKE '%Voucher%' AND A.strTransactionForm LIKE '%Voucher%'
	END
END
PRINT('END UPDATING BILL GL ENTRIES RECORDS')
