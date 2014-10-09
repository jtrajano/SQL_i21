WITH SCHEMABINDING
AS 

SELECT tblAPBill.dtmDate AS dtmDate 
, tblAPBill.intBillId 
, tblAPBill.strBillId 
, 0 AS dblAmountPaid 
, dblTotal = ISNULL(tblAPBill.dblTotal,0) 
, dblAmountDue = tblAPBill.dblAmountDue 
, dblDiscount = 0 
, dblInterest = 0 
, tblAPVendor.strVendorId 
, isnull(tblAPVendor.strVendorId,'') + ' - ' + isnull(tblEntity.strName,'') as strVendorIdName 
, tblAPBill.dtmDueDate
, tblAPBill.ysnPosted 
, tblAPBill.ysnPaid
, tblGLAccount.strAccountId
, strDescription = (Select strDescription From dbo.tblGLAccount where strAccountId = tblGLAccount.strAccountId) 
FROM dbo.tblAPBill 
INNER JOIN dbo.tblGLAccount ON tblAPBill.intAccountId = tblGLAccount.intAccountId
LEFT JOIN (dbo.tblAPVendor INNER JOIN dbo.tblEntity ON tblAPVendor.intEntityId = tblEntity.intEntityId)
	ON tblAPVendor.intEntityId = tblAPBill.intVendorId 
WHERE tblAPBill.ysnPosted = 1   
UNION ALL   
SELECT tblAPPayment.dtmDatePaid AS dtmDate,   
 tblAPPaymentDetail.intBillId,   
 tblAPBill.strBillId ,
 tblAPPaymentDetail.dblPayment AS dblAmountPaid,     
 dblTotal = 0 
, dblAmountDue = 0 
, tblAPPaymentDetail.dblDiscount 
, tblAPPaymentDetail.dblInterest 
, tblAPVendor.strVendorId 
, isnull(tblAPVendor.strVendorId,'') + ' - ' + isnull(tblEntity.strName,'') as strVendorIdName 
, tblAPBill.dtmDueDate 
, tblAPBill.ysnPosted 
, tblAPBill.ysnPaid
, tblGLAccount.strAccountId
, strDescription = (Select strDescription From dbo.tblGLAccount where strAccountId = tblGLAccount.strAccountId)
FROM dbo.tblAPPaymentDetail   
 LEFT JOIN (dbo.tblAPBill LEFT JOIN (dbo.tblAPVendor INNER JOIN dbo.tblEntity ON tblAPVendor.intEntityId = tblEntity.intEntityId) ON tblAPVendor.intVendorId = tblAPBill.intVendorId) 
 ON tblAPBill.intBillId = tblAPPaymentDetail.intBillId 
 INNER JOIN dbo.tblGLAccount ON tblAPBill.intAccountId = tblGLAccount.intAccountId  
 LEFT JOIN dbo.tblAPPayment   
 ON tblAPPayment.intPaymentId = tblAPPaymentDetail.intPaymentId   
WHERE tblAPBill.ysnPosted = 1  
	AND tblAPPayment.ysnPosted = 1