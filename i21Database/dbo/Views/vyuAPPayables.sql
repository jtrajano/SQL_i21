﻿/*
	Note: Standard amount of void payment transaction is negative. The original transaction should be positive
	Note: Origin transaction do not have multi currency implementation, also to handle issue (see 792717-000, CISCO transaction of COPP)
	Note: Handle negative quantity received
*/
CREATE VIEW vyuAPPayables
WITH SCHEMABINDING
AS 
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CASE WHEN A.intTransactionType != 1 THEN (B.dblTotal + B.dblTax) *  B.dblRate * -1 
				ELSE (B.dblTotal + B.dblTax) * B.dblRate
		END AS dblTotal
	, CASE WHEN A.intTransactionType != 1 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
	, EC.strClass
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblAPBillDetail B ON B.intBillId = A.intBillId
WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2)  AND A.ysnOrigin = 0
-- GROUP BY  
-- 	 A.dtmDate
-- 	,A.intBillId 
-- 	,A.strBillId 
-- 	,A.intTransactionType
-- 	,B.dblTotal
-- 	,A.dblAmountDue
-- 	,C1.strVendorId 
-- 	,C2.strName
-- 	, A.dtmDueDate
-- 	, A.ysnPosted 
-- 	, A.ysnPaid
-- 	, A.intAccountId
-- 	, EC.strClass
-- 	, dblRate
UNION ALL
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN (A.dblTotal + A.dblTax) * -1 ELSE A.dblTotal + A.dblTax END AS dblTotal
	, CASE WHEN A.intTransactionType != 1 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
	, EC.strClass
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2) AND A.ysnOrigin = 1
UNION ALL   
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId,   
	 C.strBillId ,
	 CASE WHEN C.intTransactionType NOT IN (1,2) AND B.dblPayment > 0
			THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId IS NULL)
						 THEN B.dblPayment * -1 ELSE B.dblPayment END)
			WHEN C.intTransactionType NOT IN (1,2) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116 OR E.intBankTransactionTypeId = 19)
				THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE
			ELSE B.dblPayment END AS dblAmountPaid,     
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
	, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, EC.strClass
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
	AND C.intTransactionType != 2
	AND A.ysnPrepay = 0 --EXCLUDE THE PREPAYMENT
UNION ALL
--APPLIED DM
SELECT
	A.dtmDate
	,A.intBillId
	,A.strBillId
	,B.dblAmountApplied
	,0 AS dblTotal
	,0 AS dblAmountDue
	,0 AS dblWithheld
	,0 AS dblDiscount
	,0 AS dblInterest
	,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	,D.strVendorId
	,A.dtmDueDate
	,A.ysnPosted
	,C.ysnPaid
	,A.intAccountId
	,EC.strClass
FROM dbo.tblAPBill A
INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
WHERE A.ysnPosted = 1
UNION ALL
SELECT --OVERPAYMENT
	A.dtmDate
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal
	, CASE WHEN A.intTransactionType != 1 AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	,A.intAccountId
	,EC.strClass
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId		
WHERE intTransactionType IN (8) AND A.ysnPaid != 1

