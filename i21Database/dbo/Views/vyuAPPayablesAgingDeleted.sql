CREATE VIEW [dbo].[vyuAPPayablesAgingDeleted]
AS

SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1 
				ELSE (B.dblTotal) * B.dblRate
		END AS DECIMAL(18,2)) AS dblTotal
	, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
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
	, 1 AS intCount
	-- ,'Bill' AS [Info]
FROM dbo.tblAPBillArchive A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0
UNION ALL --Taxes, Separate the tax and use the detail tax to match with GL calculation
SELECT 
	A.dtmDate	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(B.dblTax, 0) *  B.dblRate * -1 
				ELSE ISNULL(B.dblTax, 0) * B.dblRate
		END AS DECIMAL(18,2)) AS dblTotal
	, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
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
	, 2 AS intCount
	-- ,'Taxes' AS [Info]
FROM dbo.tblAPBillArchive A
INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
INNER JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
--INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND B.dblTax != 0
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
	CAST(B.dblPayment  * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblAmountPaid, 
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, CAST(CASE 
				WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblDiscount) > 0 
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
			END * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblDiscount
	, CAST(CASE 
			WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblInterest) > 0 
			THEN B.dblInterest --* -1 
			ELSE B.dblInterest
			END * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, F.strAccountId
	, EC.strClass
	, 3 AS intCount
	-- ,'Payment' AS [Info]
FROM dbo.tblAPPayment  A
 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 INNER JOIN dbo.tblAPBillArchive C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
 LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import
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
UNION ALL --THIS WILL REMOVE THE DELETED DATA WHEN THERE IS NO DATE FILTER
SELECT 
	A.dtmDateDeleted --USE THE DATE DELETED FOR THE NEGATIVE SO REMOVE THE DELETED DATA WHEN NO DATE FILTER PROVIDED
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1 
				ELSE (B.dblTotal) * B.dblRate
		END AS DECIMAL(18,2)) * -1 AS dblTotal
	, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END * B.dblRate * -1 AS dblAmountDue 
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
	, 4 AS intCount
	-- ,'Bill' AS [Info]
FROM dbo.tblAPBillArchive A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
LEFT JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0
UNION ALL --Taxes, Separate the tax and use the detail tax to match with GL calculation
SELECT 
	A.dtmDateDeleted	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(B.dblTax, 0) *  B.dblRate * -1 
				ELSE ISNULL(B.dblTax, 0) * B.dblRate
		END AS DECIMAL(18,2)) * -1 AS dblTotal
	, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
		END * B.dblRate * -1 AS dblAmountDue 
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
	, 4 AS intCount
	-- ,'Taxes' AS [Info]
FROM dbo.tblAPBillArchive A
INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
INNER JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
--INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND B.dblTax != 0
