﻿PRINT N'START: UPDATING VOUCHER PAYABLE TRANSACTION TYPE'
UPDATE A
	SET A.intTransactionType = CASE WHEN A.ysnReturn = 1 THEN 3 ELSE 1 END
FROM tblAPVoucherPayable A
WHERE A.intTransactionType = 0

UPDATE A
	SET A.intTransactionType = CASE WHEN A.ysnReturn = 1 THEN 3 ELSE 1 END
FROM tblAPVoucherPayableCompleted A
WHERE A.intTransactionType = 0
PRINT N'SUCCESS: UPDATING VOUCHER PAYABLE TRANSACTION TYPE'