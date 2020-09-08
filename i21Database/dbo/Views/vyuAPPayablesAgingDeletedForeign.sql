CREATE VIEW [dbo].[vyuAPPayablesAgingDeletedForeign]

AS

SELECT 
	payables.dtmDate
	,payables.intBillId
	,payables.strBillId
	,payables.dblAmountPaid
	,payables.dblTotal
	,payables.dblAmountDue
	,payables.dblWithheld
	,payables.dblDiscount
	,payables.dblInterest
	,payables.dblPrepaidAmount
	,payables.strVendorId
	,payables.strVendorIdName
	,payables.dtmDueDate
	,payables.ysnPosted
	,payables.ysnPaid
	,payables.intAccountId
	,payables.strAccountId
	,payables.strClass
	,payables.intCurrencyId
	,payables.intCount
FROM (
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
	, A.intCurrencyId
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
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(C.dblAdjustedTax,C.dblTax) *  B.dblRate * -1 
				ELSE ISNULL(C.dblAdjustedTax,C.dblTax) * B.dblRate
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
	, A.intCurrencyId
	, 2 AS intCount
	-- ,'Taxes' AS [Info]
FROM dbo.tblAPBillArchive A
INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
INNER JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND B.dblTax != 0
UNION ALL   
SELECT
	payData.dtmDate
	,payData.intBillId
	,payData.strBillId
	,SUM(ROUND(payData.dblAmountPaid,2))
	,payData.dblTotal
	,payData.dblAmountDue
	,payData.dblWithheld
	,payData.dblDiscount
	,payData.dblInterest
	,payData.dblPrepaidAmount
	,payData.strVendorId
	,payData.strVendorIdName
	,payData.dtmDueDate
	,payData.ysnPosted
	,payData.ysnPaid
	,payData.intAccountId
	,payData.strAccountId
	,payData.strClass
	,payData.intCurrencyId
	,payData.intCount
FROM (
SELECT  A.dtmDatePaid AS dtmDate,        
	C.intBillId,    
	C2.intBillDetailId,   
	C.strBillId ,    
	--  CAST(    
	--    (CASE WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment > 0    
	--    THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId <> 122 OR E.intBankTransactionTypeId IS NULL)    
	--       THEN B.dblPayment * -1 ELSE B.dblPayment END)    
	--    WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116  OR E.intBankTransactionTypeId = 19  OR E.intBankTransactionTypeId = 122)    
	--     THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE    
	--    ELSE B.dblPayment END) * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblAmountPaid,         
	(    
	(CASE     
		WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment > 0    
	THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId <> 122 OR E.intBankTransactionTypeId IS NULL)    
		THEN -1 ELSE 1 END    
		)    
	WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116  OR E.intBankTransactionTypeId = 19  OR E.intBankTransactionTypeId = 122)    
		THEN -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE    
	ELSE 1 END)     
	*    
	(    
		--TO CORRECTLY CALCULATE THE EXCHANGE RATE ON PARTIAL PAYMENT IF EACH VOUCHER DETAIL HAVE DIFFERENT RATE    
		--USE THE PERCENTAGE OF DETAIL TO TOTAL OF VOUCHER THEN MULTIPLE TO PAYMENT    
		(((C2.dblTotal) / C.dblTotal) * B.dblPayment) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblAmountPaid,     
	dblTotal = 0     
	, dblAmountDue = 0     
	, dblWithheld = B.dblWithheld    
	, (    
	(CASE     
	WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblDiscount) > 0     
	THEN -1     
	ELSE     
	(    
	--Honor only the discount if full payment, consider only for voucher    
	CASE     
		WHEN B.dblAmountDue = 0 AND ISNULL(E.ysnCheckVoid,0) = 0    
		THEN 1     
	ELSE 0    
	END    
	)    
	END)     
	*    
	(    
	(((C2.dblTotal) / C.dblTotal) * B.dblDiscount) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblDiscount    
	, (    
	(CASE     
	WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblInterest) > 0     
	THEN -1     
	ELSE 1    
	END)    
	*    
	(    
	(((C2.dblTotal) / C.dblTotal) * B.dblInterest) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblInterest     
	, dblPrepaidAmount = 0     
	, D.strVendorId     
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName     
	, C.dtmDueDate     
	, C.ysnPosted     
	, C.ysnPaid    
	, B.intAccountId    
	, F.strAccountId 
	, A.intCurrencyId   
	, EC.strClass    
	, 3 AS intCount
	-- ,'Payment' AS [Info]    
FROM dbo.tblAPPayment  A    
	INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId    
	INNER JOIN dbo.tblAPBillArchive C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId    
--  LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import    
	LEFT JOIN dbo.tblAPBillDetailArchive C2 ON C.intBillId = C2.intBillId    
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
	--AND C.intBillId = 10013 
	) payData
	GROUP BY
	payData.dtmDate
	,payData.intBillId
	,payData.intBillDetailId
	,payData.strBillId
	--,payData.dblAmountPaid
	,payData.dblTotal
	,payData.dblAmountDue
	,payData.dblWithheld
	,payData.dblDiscount
	,payData.dblInterest
	,payData.dblPrepaidAmount
	,payData.strVendorId
	,payData.strVendorIdName
	,payData.dtmDueDate
	,payData.ysnPosted
	,payData.ysnPaid
	,payData.intAccountId
	,payData.strAccountId
	,payData.strClass
	,payData.intCurrencyId
	,payData.intCount
HAVING SUM(ROUND(payData.dblAmountPaid,2)) != 0
	UNION ALL  --TAXES     
	SELECT
	payTaxes.dtmDate
	,payTaxes.intBillId
	,payTaxes.strBillId
	,SUM(ROUND(payTaxes.dblAmountPaid,2))
	,payTaxes.dblTotal
	,payTaxes.dblAmountDue
	,payTaxes.dblWithheld
	,payTaxes.dblDiscount
	,payTaxes.dblInterest
	,payTaxes.dblPrepaidAmount
	,payTaxes.strVendorId
	,payTaxes.strVendorIdName
	,payTaxes.dtmDueDate
	,payTaxes.ysnPosted
	,payTaxes.ysnPaid
	,payTaxes.intAccountId
	,payTaxes.strAccountId
	,payTaxes.strClass
	,payTaxes.intCurrencyId
	,payTaxes.intCount
	FROM (
SELECT  A.dtmDatePaid AS dtmDate,        
	C.intBillId,       
	C3.intBillDetailTaxId,
	C.strBillId ,    
	--  CAST(    
	--    (CASE WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment > 0    
	--    THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId <> 122 OR E.intBankTransactionTypeId IS NULL)    
	--       THEN B.dblPayment * -1 ELSE B.dblPayment END)    
	--    WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116  OR E.intBankTransactionTypeId = 19  OR E.intBankTransactionTypeId = 122)    
	--     THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE    
	--    ELSE B.dblPayment END) * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblAmountPaid,         
	(    
	(CASE     
		WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment > 0    
	THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId <> 122 OR E.intBankTransactionTypeId IS NULL)    
		THEN -1 ELSE 1 END    
		)    
	WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116  OR E.intBankTransactionTypeId = 19  OR E.intBankTransactionTypeId = 122)    
		THEN -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE    
	ELSE 1 END)     
	*    
	(    
		--TO CORRECTLY CALCULATE THE EXCHANGE RATE ON PARTIAL PAYMENT IF EACH VOUCHER DETAIL HAVE DIFFERENT RATE    
		--USE THE PERCENTAGE OF DETAIL TO TOTAL OF VOUCHER THEN MULTIPLE TO PAYMENT    
		(((ISNULL(C3.dblAdjustedTax,C3.dblTax)) / C.dblTotal) * B.dblPayment) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblAmountPaid,     
	dblTotal = 0     
	, dblAmountDue = 0     
	, dblWithheld = B.dblWithheld    
	, (    
	(CASE     
	WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblDiscount) > 0     
	THEN -1     
	ELSE     
	(    
	--Honor only the discount if full payment, consider only for voucher    
	CASE     
		WHEN B.dblAmountDue = 0 AND ISNULL(E.ysnCheckVoid,0) = 0    
		THEN 1     
	ELSE 0    
	END    
	)    
	END)     
	*    
	(    
	(((ISNULL(C3.dblAdjustedTax,C3.dblTax)) / C.dblTotal) * B.dblDiscount) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblDiscount    
	, (    
	(CASE     
	WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblInterest) > 0     
	THEN -1     
	ELSE 1    
	END)    
	*    
	(    
	((ISNULL(C3.dblAdjustedTax,C3.dblTax) / C.dblTotal) * B.dblInterest) * ISNULL(NULLIF(C2.dblRate,0),1)    
	)    
	) AS dblInterest     
	, dblPrepaidAmount = 0     
	, D.strVendorId     
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName     
	, C.dtmDueDate     
	, C.ysnPosted     
	, C.ysnPaid    
	, B.intAccountId    
	, F.strAccountId 
	, A.intCurrencyId   
	, EC.strClass    
	, 3 AS intCount
	-- ,'Payment' AS [Info]    
FROM dbo.tblAPPayment  A    
	INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId    
	INNER JOIN dbo.tblAPBillArchive C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId    
--  LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import    
	INNER JOIN dbo.tblAPBillDetailArchive C2 ON C.intBillId = C2.intBillId  
	INNER JOIN dbo.tblAPBillDetailTaxArchive C3 ON C3.intBillDetailId = C2.intBillDetailId    
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
	) payTaxes
	GROUP BY
	payTaxes.dtmDate
,payTaxes.intBillId
,payTaxes.intBillDetailTaxId
,payTaxes.strBillId
--,payTaxes.dblAmountPaid
,payTaxes.dblTotal
,payTaxes.dblAmountDue
,payTaxes.dblWithheld
,payTaxes.dblDiscount
,payTaxes.dblInterest
,payTaxes.dblPrepaidAmount
,payTaxes.strVendorId
,payTaxes.strVendorIdName
,payTaxes.dtmDueDate
,payTaxes.ysnPosted
,payTaxes.ysnPaid
,payTaxes.intAccountId
,payTaxes.strAccountId
,payTaxes.strClass 
,payTaxes.intCurrencyId
,payTaxes.intCount
HAVING SUM(ROUND(payTaxes.dblAmountPaid,2)) != 0
UNION ALL --THIS WILL REMOVE THE DELETED DATA WHEN THERE IS NO DATE FILTER
SELECT 
	A.dtmDateCreated --USE THE DATE CREATED FOR THE NEGATIVE SO REMOVE THE DELETED DATA WHEN NO DATE FILTER PROVIDED
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
	, A.intCurrencyId
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
	A.dtmDateCreated	
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(C.dblAdjustedTax,C.dblTax) *  B.dblRate * -1 
				ELSE ISNULL(C.dblAdjustedTax,C.dblTax) * B.dblRate
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
	, A.intCurrencyId
	, 5 AS intCount
	-- ,'Taxes' AS [Info]
FROM dbo.tblAPBillArchive A
INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityVendorId]
INNER JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId
INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 0 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND B.dblTax != 0
) payables
 CROSS APPLY tblSMCompanyPreference compPref
 WHERE compPref.intDefaultCurrencyId != payables.intCurrencyId
