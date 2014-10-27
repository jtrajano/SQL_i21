CREATE VIEW vyuAPBill
WITH SCHEMABINDING
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.dblTotal,
	A.ysnPosted,
	A.ysnPaid,
	A.strVendorOrderNumber,
	A.intTransactionType,
	A.dtmDate,
	B1.strName,
	C.strAccountId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEntity B1 ON B.intEntityId = B1.intEntityId)
	ON A.intVendorId = B.intVendorId
	INNER JOIN dbo.tblGLAccount C
		ON A.intAccountId = C.intAccountId