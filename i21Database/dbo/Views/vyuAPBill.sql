CREATE VIEW vyuAPBill
AS
SELECT
	A.intBillId,
	A.strBillId,
	A.dblTotal,
	A.ysnPosted,
	A.strVendorOrderNumber,
	B1.strName,
	C.strAccountId
FROM
	tblAPBill A
	INNER JOIN 
		(tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityId = B1.intEntityId)
	ON A.intVendorId = B.intEntityId
	INNER JOIN tblGLAccount C
		ON A.intAccountId = C.intAccountId