CREATE VIEW vyuAPPayablesAgingSummary
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
, ISNULL(C1.strVendorId,'') + ' - ' + ISNULL(C2.strName,'') as strVendorIdName 
, A.dtmDueDate
, A.ysnPosted 
, A.ysnPaid
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPPayment B1 INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId)
	ON A.intBillId = B.intBillId
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEntity C2 ON C1.intEntityId = C2.intEntityId)
	ON C1.intVendorId = A.intVendorId
WHERE A.ysnPosted = 1  AND B1.ysnPosted = 1
UNION ALL   
SELECT 
A.dtmDatePaid AS dtmDate
, B.intBillId
, C.strBillId
, B.dblPayment AS dblAmountPaid
, dblTotal = 0 
, dblAmountDue = 0 
, B.dblDiscount 
, B.dblInterest 
, D.strVendorId 
, ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
, C.dtmDueDate 
, C.ysnPosted 
, C.ysnPaid
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEntity D2 ON D.intEntityId = D2.intEntityId)
	ON A.intVendorId = D.intVendorId
 WHERE C.ysnPosted = 1  
	AND C.ysnPosted = 1
