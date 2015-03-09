CREATE VIEW vyuAPPayables
WITH SCHEMABINDING
AS 
SELECT 
	A.dtmDate
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, dblTotal = ISNULL(A.dblTotal,0) 
	, dblAmountDue = A.dblAmountDue 
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEntity C2 ON C1.intEntityVendorId = C2.intEntityId)
	ON C1.intEntityVendorId = A.intVendorId
WHERE A.ysnPosted = 1
UNION ALL   
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId,   
	 C.strBillId ,
	 B.dblPayment AS dblAmountPaid,     
	 dblTotal = 0 
	, dblAmountDue = 0 
	, B.dblDiscount 
	, B.dblInterest 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEntity D2 ON D.intEntityVendorId = D2.intEntityId)
	ON A.intVendorId = D.intEntityVendorId
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
