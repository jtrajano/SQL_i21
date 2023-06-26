﻿/*
	Note: Standard amount of void payment transaction is negative. The original transaction should be positive
	Note: Origin transaction do not have multi currency implementation, also to handle issue (see 792717-000, CISCO transaction of COPP)
	Note: Handle negative quantity received
*/
CREATE VIEW [dbo].[vyuAPPayables]
--WITH SCHEMABINDING
AS 
SELECT payables.*
FROM (
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType IN (16) THEN (B.dblTotal * (B.dblProvisionalPercentage / 100)) * B.dblRate
						WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1 
				ELSE (B.dblTotal) * B.dblRate
		END AS DECIMAL(18,2)) AS dblTotal
	,	CASE WHEN A.intTransactionType IN (16) THEN A.dblProvisionalAmountDue
				WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END * B.dblRate AS dblAmountDue 
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
	, A.intCurrencyId
	-- ,'Bill' AS [Info]
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblAPBillDetail B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13, 15)  AND A.ysnOrigin = 0
UNION ALL --VOID VOUCHER DELETED
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType IN (16) THEN (B.dblTotal * (ISNULL(BL.dblProvisionalPercentage, 100) / 100)) * B.dblRate 
				WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1 
				ELSE (B.dblTotal) * B.dblRate
		END AS DECIMAL(18,2)) AS dblTotal
	, CASE WHEN A.intTransactionType IN (16) THEN BL.dblProvisionalAmountDue
	WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END * B.dblRate AS dblAmountDue 
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
	, A.intCurrencyId
	-- ,'Bill' AS [Info]
FROM dbo.tblAPBillArchive A
INNER JOIN tblAPBill BL ON A.intBillId = BL.intBillId
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 1 AND A.intTransactionType NOT IN (7, 2, 12, 13, 15)  AND A.ysnOrigin = 0
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
--Taxes, Separate the tax and use the detail tax to match with GL calculation
UNION ALL
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType IN (16) THEN  (ISNULL(B.dblTax, 0) * (A.dblProvisionalPercentage / 100)) * B.dblRate
				WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(B.dblTax, 0) *  B.dblRate * -1 
				ELSE ISNULL(B.dblTax, 0) * B.dblRate
		END AS DECIMAL(18,2)) AS dblTotal
	, CASE WHEN A.intTransactionType IN (16) THEN A.dblProvisionalAmountDue
		WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END * B.dblRate AS dblAmountDue 
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
	, A.intCurrencyId
	-- ,'Taxes' AS [Info]
FROM dbo.tblAPBill A
INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
INNER JOIN dbo.tblAPBillDetail B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
--INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13, 15)  AND A.ysnOrigin = 0 AND B.dblTax != 0
--ORIGIN
UNION ALL
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType IN (16) AND A.dblProvisionalTotal > 0 THEN (A.dblProvisionalTotal + (A.dblTax * (A.dblProvisionalPercentage / 100)))
							WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN (A.dblTotal + A.dblTax) * -1 ELSE A.dblTotal + A.dblTax END AS DECIMAL(18,2)) AS dblTotal
	, CASE WHEN A.intTransactionType IN (16) THEN A.dblProvisionalAmountDue
	WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
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
	, A.intCurrencyId
	-- ,'Origin' AS [Info]
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13, 15) AND A.ysnOrigin = 1
UNION ALL   
SELECT  A.dtmDatePaid AS dtmDate,    
	 C.intBillId,   
	 C.strBillId ,
	--  CAST(
	-- 	 	(CASE WHEN C.intTransactionType NOT IN (1, 2, 14) AND B.dblPayment != 0
	-- 			THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId <> 122 OR E.intBankTransactionTypeId IS NULL)
	-- 					 THEN B.dblPayment * -1 ELSE B.dblPayment END)
	-- 			WHEN C.intTransactionType NOT IN (1, 2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116  OR E.intBankTransactionTypeId = 19  OR E.intBankTransactionTypeId = 122)
	-- 				THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE
	-- 			ELSE B.dblPayment END) * A.dblExchangeRate AS DECIMAL(18,2)) AS dblAmountPaid,    
	CAST(B.dblPayment  * ISNULL(C.dblAverageExchangeRate,1) AS DECIMAL(18,2)) AS dblAmountPaid, 
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, CAST(CASE 
				WHEN C.intTransactionType NOT IN (1,2,14,16) AND ABS(B.dblDiscount) > 0 
				THEN B.dblDiscount --* -1 note: we expect that the discount in 20.1 is already negative  
			ELSE 
			(
				--Honor only the discount if full payment, consider only for voucher
				CASE 
					WHEN B.dblAmountDue = 0 AND ISNULL(E.ysnCheckVoid,0) = 0
					THEN B.dblDiscount 
				ELSE 0
				END
			)
			END * ISNULL(C.dblAverageExchangeRate,1) AS DECIMAL(18,2)) AS dblDiscount
	, CAST(CASE 
			WHEN C.intTransactionType NOT IN (1,2,14,16) AND ABS(B.dblInterest) > 0 
			THEN B.dblInterest --* -1 
			ELSE B.dblInterest
			END * ISNULL(C.dblAverageExchangeRate,1) AS DECIMAL(18,2)) AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, F.strAccountId
	, EC.strClass
	, A.intCurrencyId
	-- ,'Payment' AS [Info]
FROM dbo.tblAPPayment  A
 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 INNER JOIN dbo.tblAPBill C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
 --LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblGLAccount F ON  B.intAccountId = F.intAccountId		
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType NOT IN (2, 12, 13)
	AND A.ysnPrepay = 0 --EXCLUDE THE PREPAYMENT
UNION ALL
--APPLIED VOUCHER, (Payment have been made using prepaid and debit memos tab)
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
	,0 AS dblPrepaidAmount 
	,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	,D.strVendorId
	,A.dtmDueDate
	,A.ysnPosted
	,C.ysnPaid
	,A.intAccountId
	,F.strAccountId
	,EC.strClass
	, A.intCurrencyId
	-- ,'Paid through Prepaid And Debit Memo' AS [Info]
FROM dbo.tblAPBill A
INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
OUTER APPLY (
	SELECT TOP 1
		voucherDetail.dblRate
	FROM tblAPBillDetail voucherDetail
	WHERE voucherDetail.intBillDetailId = B.intBillDetailApplied
) voucherDetailApplied
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 1 AND B.ysnApplied = 1
UNION ALL
--APPLIED DM, (DM HAVE BEEN USED AS OFFSET IN PREPAID AND DEBIT MEMO TABS)
SELECT
	C.dtmDate --THIS SHOUD BE THE DATE OF THE VOUCHER THAT APPLIED THE DM
	,A.intBillId
	,A.strBillId
	,B.dblAmountApplied * (CASE WHEN A.intTransactionType NOT IN (1,14,16) THEN -1 ELSE 1 END)
	,0 AS dblTotal
	,0 AS dblAmountDue
	,0 AS dblWithheld
	,0 AS dblDiscount
	,0 AS dblInterest
	,0 AS dblPrepaidAmount 
	,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	,D.strVendorId
	,A.dtmDueDate
	,A.ysnPosted
	,C.ysnPaid
	,A.intAccountId
	,F.strAccountId
	,EC.strClass
	, A.intCurrencyId
	-- ,'DM transactions have been paid using Prepaid And Debit Tab' AS [Info]
FROM dbo.tblAPBill A
INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intTransactionId
INNER JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId		
WHERE C.ysnPosted = 1 AND A.intTransactionType IN (3, 11) AND B.ysnApplied = 1 AND A.ysnPosted = 1
UNION ALL
SELECT --OVERPAYMENT
	A.dtmDate
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CASE WHEN A.intTransactionType IN (16) AND A.dblProvisionalTotal > 0 THEN A.dblProvisionalTotal
		WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal
	, CASE WHEN A.intTransactionType IN (16) AND A.dblProvisionalAmountDue > 0 THEN A.dblProvisionalAmountDue
		WHEN A.intTransactionType NOT IN (1,14) AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
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
	,EC.strClass
	, A.intCurrencyId
	-- ,'Overpayment' AS [Info]
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId		
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE intTransactionType IN (8) AND A.ysnPaid != 1
-- UNION ALL
-- --APPLIED PREPAID TO VOUCHER
-- SELECT 
-- 	A.dtmDate
-- 	,A.intBillId
-- 	,A.strBillId
-- 	,0 AS dblAmountPaid
-- 	,0 AS dblTotal
-- 	,0 AS dblAmountDue
-- 	,0 AS dblWithheld
-- 	,0 AS dblDiscount
-- 	,0 AS dblInterest
-- 	,B.dblAmountApplied AS dblPrepaidAmount
-- 	,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
-- 	,D.strVendorId
-- 	,A.dtmDueDate
-- 	,A.ysnPosted
-- 	,A.ysnPaid
-- 	,A.intAccountId
-- 	,EC.strClass
-- FROM dbo.tblAPBill A
-- INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
-- INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
-- INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]
-- LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
-- WHERE A.ysnPosted = 1
UNION ALL
--PAYMENT MADE TO AR
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId,   
	 C.strBillId ,
	 CAST(CASE WHEN C.intTransactionType NOT IN (1,2, 14,16) AND B.dblPayment != 0
			THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId IS NULL)
						 THEN B.dblPayment * -1 ELSE B.dblPayment END)
			WHEN C.intTransactionType NOT IN (1,2, 14,16) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116 OR E.intBankTransactionTypeId = 19)
				THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE
			ELSE ABS(B.dblPayment) * ISNULL(A.dblExchangeRate,1) END AS DECIMAL(18,2)) AS dblAmountPaid, --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = 0
	, CASE WHEN C.intTransactionType NOT IN (1,2,14,16) AND B.dblDiscount > 0 THEN B.dblDiscount * -1 ELSE ABS(B.dblDiscount) END AS dblDiscount
	, CASE WHEN C.intTransactionType NOT IN (1,2,14,16) AND B.dblInterest > 0 THEN B.dblInterest * -1 ELSE ABS(B.dblInterest) END AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, F.strAccountId
	, EC.strClass
	, A.intCurrencyId
	-- ,'AR Payment' AS [Info]
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
	AND C.intTransactionType NOT IN (2)
UNION ALL
--BILL PAYMENT TRANSACTION (PAYMENT TRANSACTION FOR DELETE PAY SCENARIO)
SELECT 
	  A.dtmDatePaid AS dtmDate 
	, ISNULL(B.intBillId ,B.intOrigBillId) AS intBillId  
	, C.strBillId
	, CAST(B.dblPayment * prepaidDetail.dblRate AS DECIMAL(18,2))  AS dblAmountPaid   
		--* (CASE WHEN C.intTransactionType = 3 THEN -1 ELSE 1 END) AS dblAmountPaid     
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
	, A.intCurrencyId
	--, 1
FROM dbo.tblAPPayment  A
 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 INNER JOIN dbo.tblAPBill C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId
LEFT JOIN dbo.tblGLAccount F ON  B.intAccountId = F.intAccountId
OUTER APPLY (
	SELECT TOP 1
		bd.dblRate
	FROM tblAPBillDetail bd
	WHERE bd.intBillId = C.intBillId
) prepaidDetail		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.intTransactionType IN (1, 3,16) --BILL TRANSACTION ONLY
	AND A.ysnPrepay = 1
	AND NOT EXISTS (
		SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = C.intBillId
	)	
) payables
CROSS APPLY tblSMCompanyPreference compPref
WHERE payables.intCurrencyId = compPref.intDefaultCurrencyId
GO
