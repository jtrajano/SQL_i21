CREATE VIEW [dbo].[vyuAPPayablesForeign]
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
FROM (
	SELECT     
	 A.dtmDate     
	 , A.intBillId     
	 , A.strBillId     
	 , 0 AS dblAmountPaid     
	 , ROUND(CASE WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1     
		ELSE (B.dblTotal) * B.dblRate    
	  END , 2) AS dblTotal    
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
	 -- ,'Bill' AS [Info]    
	FROM dbo.tblAPBill A    
	LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)    
	 ON C1.[intEntityId] = A.[intEntityVendorId]    
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId     
	LEFT JOIN dbo.tblAPBillDetail B ON B.intBillId = A.intBillId    
	LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId    
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0    
	-- GROUP BY      
	--   A.dtmDate    
	--  ,A.intBillId     
	--  ,A.strBillId     
	--  ,A.intTransactionType    
	--  ,B.dblTotal    
	--  ,A.dblAmountDue    
	--  ,C1.strVendorId     
	--  ,C2.strName    
	--  , A.dtmDueDate    
	--  , A.ysnPosted     
	--  , A.ysnPaid    
	--  , A.intAccountId    
	--  , EC.strClass    
	--  , dblRate    
	--Taxes, Separate the tax and use the detail tax to match with GL calculation    
	UNION ALL    
	SELECT     
	 A.dtmDate     
	 , A.intBillId     
	 , A.strBillId     
	 , 0 AS dblAmountPaid     
	 , ROUND(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(C.dblAdjustedTax,C.dblTax) *  B.dblRate * -1     
		ELSE ISNULL(C.dblAdjustedTax,C.dblTax) * B.dblRate    
	  END ,2) AS dblTotal    
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
	 -- ,'Taxes' AS [Info]    
	FROM dbo.tblAPBill A    
	INNER JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)    
	 ON C1.[intEntityId] = A.[intEntityVendorId]    
	INNER JOIN dbo.tblAPBillDetail B ON B.intBillId = A.intBillId    
	INNER JOIN dbo.tblAPBillDetailTax C ON B.intBillDetailId = C.intBillDetailId    
	LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId    
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId     
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND ISNULL(C.dblAdjustedTax,C.dblTax) <> 0   
	--ORIGIN    
	UNION ALL    
	SELECT     
	 A.dtmDate     
	 , A.intBillId     
	 , A.strBillId     
	 , 0 AS dblAmountPaid     
	 , ROUND(CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN (A.dblTotal + A.dblTax) * -1 ELSE A.dblTotal + A.dblTax END ,2) AS dblTotal    
	 , CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue     
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
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13) AND A.ysnOrigin = 1    
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
	 , EC.strClass    
	 , A.intCurrencyId
	 -- ,'Payment' AS [Info]    
	FROM dbo.tblAPPayment  A    
	 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId    
	 INNER JOIN dbo.tblAPBill C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId    
	--  LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import    
	 LEFT JOIN dbo.tblAPBillDetail C2 ON C.intBillId = C2.intBillId    
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
	 , EC.strClass    
	 , A.intCurrencyId
	 -- ,'Payment' AS [Info]    
	FROM dbo.tblAPPayment  A    
	 INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId    
	 INNER JOIN dbo.tblAPBill C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId    
	--  LEFT JOIN dbo.fnAPGetVoucherAverageRate() avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import    
	 INNER JOIN dbo.tblAPBillDetail C2 ON C.intBillId = C2.intBillId  
	 INNER JOIN dbo.tblAPBillDetailTax C3 ON C3.intBillDetailId = C2.intBillDetailId    
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
	HAVING SUM(ROUND(payTaxes.dblAmountPaid,2)) != 0
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
	 ,A.intCurrencyId
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
	 A.dtmDate    
	 ,A.intBillId    
	 ,A.strBillId    
	 ,B.dblAmountApplied * (CASE WHEN A.intTransactionType NOT IN (1,14) THEN -1 ELSE 1 END)    
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
	 ,A.intCurrencyId
	 -- ,'DM transactions have been paid using Prepaid And Debit Tab' AS [Info]    
	FROM dbo.tblAPBill A    
	INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intTransactionId    
	INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId    
	INNER JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId) ON A.intEntityVendorId = D.[intEntityId]    
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId    
	LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId      
	WHERE C.ysnPosted = 1 AND A.intTransactionType = 3 AND B.ysnApplied = 1 AND A.ysnPosted = 1    
	UNION ALL    
	SELECT --OVERPAYMENT    
	 A.dtmDate    
	 , A.intBillId     
	 , A.strBillId     
	 , 0 AS dblAmountPaid     
	 , CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal    
	 , CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue     
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
	 ,A.intCurrencyId
	 -- ,'Overpayment' AS [Info]    
	FROM dbo.tblAPBill A    
	LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)    
	 ON C1.[intEntityId] = A.[intEntityVendorId]    
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId      
	LEFT JOIN dbo.tblGLAccount F ON  A.intAccountId = F.intAccountId    
	WHERE intTransactionType IN (8) AND A.ysnPaid != 1    
	-- UNION ALL    
	-- --APPLIED PREPAID TO VOUCHER    
	-- SELECT     --  A.dtmDate    
	--  ,A.intBillId    
	--  ,A.strBillId    
	--  ,0 AS dblAmountPaid    
	--  ,0 AS dblTotal    
	--  ,0 AS dblAmountDue    
	--  ,0 AS dblWithheld    
	--  ,0 AS dblDiscount    
	--  ,0 AS dblInterest    
	--  ,B.dblAmountApplied AS dblPrepaidAmount    
	--  ,ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName     
	--  ,D.strVendorId    
	--  ,A.dtmDueDate    
	--  ,A.ysnPosted    
	--  ,A.ysnPaid    
	--  ,A.intAccountId    
	--  ,EC.strClass    
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
	  ROUND(CASE WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment > 0    
	   THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId IS NULL)    
		   THEN B.dblPayment * -1 ELSE B.dblPayment END)    
	   WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116 OR E.intBankTransactionTypeId = 19)    
		THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE    
	   ELSE ABS(B.dblPayment) * ISNULL(A.dblExchangeRate,1) END ,2) AS dblAmountPaid, --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT    
	  dblTotal = 0     
	 , dblAmountDue = 0     
	 , dblWithheld = 0    
	 , CASE WHEN C.intTransactionType NOT IN (1,2,14) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount    
	 , CASE WHEN C.intTransactionType NOT IN (1,2,14) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest     
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
	 , ROUND(B.dblPayment * prepaidDetail.dblRate,2)      
	  * (CASE WHEN C.intTransactionType = 3 THEN -1 ELSE 1 END) AS dblAmountPaid         
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
	 AND C.intTransactionType IN (1, 3) --BILL TRANSACTION ONLY    
	 AND A.ysnPrepay = 1    
	 AND NOT EXISTS (    
	  SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = C.intBillId    
	 )
 ) payables
 CROSS APPLY tblSMCompanyPreference compPref
 WHERE compPref.intDefaultCurrencyId != payables.intCurrencyId