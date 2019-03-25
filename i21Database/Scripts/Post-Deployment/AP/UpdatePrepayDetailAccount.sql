--THIS WILL UPDATE OLD PREPAY DETAIL ACCOUNT
UPDATE A
SET A.intAccountId = loc.intAPAccount
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
	ON A.intBillId = B.intBillId
INNER JOIN tblSMCompanyLocation loc
	ON B.intShipToId = loc.intCompanyLocationId
WHERE A.intAccountId IS NULL AND B.intTransactionType = 2