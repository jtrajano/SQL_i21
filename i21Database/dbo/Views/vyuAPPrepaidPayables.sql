/**
	Note: Consider all origin prepaid was already paid.
*/
CREATE VIEW [dbo].[vyuAPPrepaidPayables]
AS

--VENDOR PREPAYMENT
--POSITIVE PART
SELECT
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, A.dblTotal AS dblTotal
	, A.dblAmountDue AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0
	, dblPrepaidAmount = 0  
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
	, EC.strClass
	, intPrepaidRowType = 1
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId
WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
UNION ALL
--VENDOR PREPAYMENT PAYMENT TRANSACTION (this will remove the positive part and leave the negative part)
SELECT 
	  A.dtmDatePaid AS dtmDate 
	, B.intBillId  
	, C.strBillId
	, B.dblPayment  AS dblAmountPaid     
	, dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, B.dblDiscount AS dblDiscount
	, B.dblInterest AS dblInterest 
	, dblPrepaidAmount = 0  
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, EC.strClass
	, 1
FROM dbo.tblAPPayment  A
 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 INNER JOIN dbo.tblAPBill C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2, 13)
	AND A.ysnPrepay = 1
	AND NOT EXISTS (
		SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = C.intBillId
	)
UNION ALL
--VENDOR PREPAYMENT PAYMENT TRANSACTION (this will remove the positive part and leave the negative part)
--HANDLE THOSE ORIGIN PREPAYMENT THAT HAS BEEN IMPORTED UNPAID AND PAID IN i21 BUT DO NOT HAVE PAYMENT TRANSACTION (ysnPrepay = 1)
SELECT 
	  A.dtmDate AS dtmDate 
	, A.intBillId  
	, A.strBillId
	, A.dblPayment  AS dblAmountPaid     
	, dblTotal = 0 
	, dblAmountDue = 0 
	, A.dblWithheld
	, A.dblDiscount AS dblDiscount
	, A.dblInterest AS dblInterest 
	, dblPrepaidAmount = 0  
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, A.dtmDueDate 
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
	, EC.strClass
	, 1
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1
	AND A.intTransactionType IN (2, 13)
	AND NOT EXISTS (
		SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
	)
	AND NOT EXISTS (
		SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
		WHERE B.intBillId = A.intBillId AND C.ysnPrepay = 1
	)
UNION ALL
--NEGATIVE PART
SELECT
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, A.dblTotal * -1 AS dblTotal
	, A.dblAmountDue * -1 AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0
	, dblPrepaidAmount = 0   
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
	, EC.strClass
	, 2
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId
WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
UNION ALL
--OFFSET VENDOR PREPAYMENT TRANSACTION
SELECT 
	  A.dtmDatePaid AS dtmDate 
	, B.intBillId  
	, C.strBillId
	, B.dblPayment * -1 AS dblAmountPaid     
	, dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, B.dblDiscount * -1 AS dblDiscount
	, B.dblInterest * -1 AS dblInterest
	, dblPrepaidAmount = 0   
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, EC.strClass
	, 2
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2, 13)
	AND A.ysnPrepay = 0
	AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = B.intBillId
)
UNION ALL --APPLIED PREPAYMENT
SELECT
	A.dtmDate
	,B.intTransactionId
	,C.strBillId
	,B.dblAmountApplied * -1
	,0 AS dblTotal
	,0 AS dblAmountDue
	,0 AS dblWithheld
	,0 AS dblDiscount
	,0 AS dblInterest
	, dblPrepaidAmount = 0  
	,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	,D.strVendorId
	,A.dtmDueDate
	,A.ysnPosted
	,C.ysnPaid
	,A.intAccountId
	,EC.strClass
	,2
FROM dbo.tblAPBill A
INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
WHERE A.ysnPosted = 1 AND C.intTransactionType IN (2, 13)
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)

UNION ALL
--PAYMENT MADE TO AR TO OFFSET THE PREPAYMENT
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId AS intTransactionId,   
	 C.strBillId ,
	 B.dblPayment * ISNULL(A.dblExchangeRate,1) * - 1 AS dblAmountPaid, --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = 0
	, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
	, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, EC.strClass
	,2
FROM dbo.tblARPayment  A
 LEFT JOIN dbo.tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityCustomerId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strRecordNumber = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2)

