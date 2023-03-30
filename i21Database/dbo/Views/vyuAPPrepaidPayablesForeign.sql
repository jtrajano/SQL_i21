﻿/**
	Note: Consider all origin prepaid was already paid.
*/
CREATE VIEW [dbo].[vyuAPPrepaidPayablesForeign]
AS

--VENDOR PREPAYMENT
--POSITIVE PART
SELECT
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(A.dblTotal AS DECIMAL(18,2)) AS dblTotal
	, CAST(A.dblAmountDue AS DECIMAL(18,2)) AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0
	, dblPrepaidAmount = 0  
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, prepaidDetail.intAccountId
	, prepaidDetail.strAccountId
	, EC.strClass
	, intPrepaidRowType = 1
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId
OUTER APPLY (
	SELECT TOP 1
		bd.intAccountId,
		accnt.strAccountId
	FROM tblAPBillDetail bd
	LEFT JOIN tblGLAccount accnt ON bd.intAccountId = accnt.intAccountId
	WHERE bd.intBillId = A.intBillId
) prepaidDetail

WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1
AND A.intTransactionReversed IS NULL --Remove if already reversed, negative part will be offset by the reversal transaction
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
UNION ALL
--VENDOR PREPAYMENT PAYMENT TRANSACTION (this will remove the positive part and leave the negative part)
SELECT 
	  A.dtmDatePaid AS dtmDate 
	, ISNULL(B.intBillId ,B.intOrigBillId) AS intBillId  
	, C.strBillId
	, CAST(B.dblPayment AS DECIMAL(18,2))  AS dblAmountPaid     
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
	, F.strAccountId
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
LEFT JOIN dbo.tblGLAccount F ON  B.intAccountId = F.intAccountId	
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2, 13)
	AND B.ysnOffset = 0
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
	, CAST(A.dblTotal AS DECIMAL(18,2))  AS dblAmountPaid     
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
	, prepaidDetail.intAccountId
	, F.strAccountId
	, EC.strClass
	, 1
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId	
OUTER APPLY (
	SELECT TOP 1
		bd.intAccountId
	FROM tblAPBillDetail bd
	WHERE bd.intBillId = A.intBillId
) prepaidDetail		
LEFT JOIN dbo.tblGLAccount F ON  prepaidDetail.intAccountId = F.intAccountId
 WHERE A.ysnPosted = 1
	AND A.intTransactionType IN (2, 13)
	AND NOT EXISTS (
		SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
	)
	AND NOT EXISTS (
		SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
		WHERE B.intBillId = A.intBillId AND C.ysnPrepay = 1
	)
	AND A.ysnOrigin = 1
	AND A.intTransactionReversed IS NULL --REMOVE ALREADY REVERSED
UNION ALL
--NEGATIVE PART
SELECT
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(A.dblTotal AS DECIMAL(18,2)) * -1 AS dblTotal
	, CAST(A.dblAmountDue AS DECIMAL(18,2)) * -1 AS dblAmountDue
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
	, F.strAccountId
	, EC.strClass
	, 2
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
UNION ALL --PREPAYMENT REVERSAL
SELECT
	A.dtmDate	
	, A.intBillId --Use the original prepaid primary key but display the bill id of reversal (-R)
	, B.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(B.dblTotal AS DECIMAL(18,2)) AS dblTotal
	, CAST(B.dblAmountDue AS DECIMAL(18,2)) AS dblAmountDue
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0
	, dblPrepaidAmount = 0   
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, B.dtmDueDate
	, B.ysnPosted 
	, B.ysnPaid
	, B.intAccountId
	, F.strAccountId
	, EC.strClass
	, 2
FROM dbo.tblAPBill A
INNER JOIN tblAPBill B ON A.intTransactionReversed = B.intBillId
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE B.intTransactionType IN (12) AND A.ysnPosted = 1 AND B.ysnPosted = 1
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
UNION ALL
--OFFSET VENDOR PREPAYMENT TRANSACTION
SELECT 
	  A.dtmDatePaid AS dtmDate 
	, B.intBillId  
	, C.strBillId
	, CAST(B.dblPayment AS DECIMAL(18,2)) AS dblAmountPaid     
	, dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, CAST(B.dblDiscount AS DECIMAL(18,2)) AS dblDiscount
	, CAST(B.dblInterest AS DECIMAL(18,2)) AS dblInterest
	, dblPrepaidAmount = 0   
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, F.strAccountId
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
LEFT JOIN dbo.tblGLAccount F ON B.intAccountId = F.intAccountId	
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2, 13)
	AND B.ysnOffset = 1
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
	,C.intAccountId
	,F.strAccountId
	,EC.strClass
	,2
FROM dbo.tblAPBill A
INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId
LEFT JOIN dbo.tblGLAccount F ON  C.intAccountId = F.intAccountId	
WHERE A.ysnPosted = 1 AND C.intTransactionType IN (2, 13)
AND NOT EXISTS (
	SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId
)
AND B.ysnApplied = 1 AND A.ysnPosted = 1

UNION ALL
--PAYMENT MADE TO AR TO OFFSET THE PREPAYMENT
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId AS intTransactionId,   
	 C.strBillId ,
	 B.dblPayment * - 1 AS dblAmountPaid, --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT
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
	, F.strAccountId
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
LEFT JOIN dbo.tblGLAccount F ON  B.intAccountId = F.intAccountId
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (2)
UNION ALL --CLAIM TRANSACTION IN AR
SELECT A.dtmDatePaid AS dtmDate,   
	 F.intBillId AS intTransactionId,   
	 F.strBillId ,
	 (B.dblPayment + prepaid.dblFranchiseAmount) * - 1 AS dblAmountPaid,
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = 0
	, CASE WHEN F.intTransactionType NOT IN (1,2) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
	, CASE WHEN F.intTransactionType NOT IN (1,2) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, accnt.strAccountId
	, EC.strClass
	, 2
FROM dbo.tblARPayment  A
 LEFT JOIN dbo.tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
  LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityCustomerId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strRecordNumber = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId	
LEFT JOIN tblGLAccount accnt ON B.intAccountId = accnt.intAccountId
OUTER APPLY (
	--claim transaction
	SELECT TOP 1
		C2.intPrepayTransactionId
		,C2.dblFranchiseAmount
	FROM tblAPBillDetail C2
	WHERE C2.intBillId = C.intBillId
) prepaid
LEFT JOIN tblAPBill F ON F.intBillId = prepaid.intPrepayTransactionId
 WHERE A.ysnPosted = 1  
	AND C.intTransactionType IN (11)
