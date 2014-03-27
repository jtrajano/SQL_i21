CREATE VIEW vyuAPPayablesAgingSummary 

AS 

SELECT tblAPBill.dtmDate AS dtmDate 
, tblAPBill.intBillId 
, tblAPBill.strBillId 
, 0 AS dblAmountPaid 
, dblTotal = ISNULL(tblAPBill.dblTotal,0) 
, dblAmountDue = tblAPBill.dblAmountDue 
, dblDiscount = 0 
, dblInterest = 0 
, tblAPBill.strVendorId 
, isnull(tblAPBill.strVendorId,'') + ' - ' + isnull(tblEntity.strName,'') as strVendorIdName 
, tblAPBill.dtmDueDate
, tblAPBill.dtmDiscountDate
, tblAPBill.ysnPosted 
, tblAPBill.ysnPaid
, tblGLAccount.strAccountId
, strDescription = (Select strDescription From tblGLAccount where strAccountId = tblGLAccount.strAccountId) 
FROM tblAPBill 
INNER JOIN tblGLAccount ON tblAPBill.intAccountId = tblGLAccount.intAccountId
LEFT JOIN tblAPVendor ON tblAPVendor.strVendorId = tblAPBill.strVendorId 
INNER JOIN tblEntity ON tblAPVendor.intEntityId = tblEntity.intEntityId
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
, tblAPBill.strVendorId 
, isnull(tblAPBill.strVendorId,'') + ' - ' + isnull(tblEntity.strName,'') as strVendorIdName 
, tblAPBill.dtmDueDate 
, tblAPBill.dtmDiscountDate
, tblAPBill.ysnPosted 
, tblAPBill.ysnPaid
, tblGLAccount.strAccountId
, strDescription = (Select strDescription From tblGLAccount where strAccountId = tblGLAccount.strAccountId)
FROM tblAPPaymentDetail   
 LEFT JOIN (tblAPBill LEFT JOIN (tblAPVendor INNER JOIN tblEntity ON tblAPVendor.intEntityId = tblEntity.intEntityId) ON tblAPVendor.strVendorId = tblAPBill.strVendorId) 
 ON tblAPBill.intBillId = tblAPPaymentDetail.intBillId 
 INNER JOIN tblGLAccount ON tblAPBill.intAccountId = tblGLAccount.intAccountId  
 LEFT JOIN tblAPPayment   
 ON tblAPPayment.intPaymentId = tblAPPaymentDetail.intPaymentId   
WHERE tblAPBill.ysnPosted = 1  
	AND tblAPPayment.ysnPosted = 1