﻿--RUN THIS IF THERE ARE TRANSACTIONS THAT HAS TYPE OF BILL APPROVAL
PRINT('BEGIN UPDATING BILL APPROVAL RECORDS')
IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intTransactionType = 7))
BEGIN
	UPDATE A
		SET A.intTransactionType = 1,
		A.ysnForApproval = 1
	FROM tblAPBill A
	WHERE A.intTransactionType = 7
END
PRINT('END UPDATING BILL APPROVAL RECORDS')