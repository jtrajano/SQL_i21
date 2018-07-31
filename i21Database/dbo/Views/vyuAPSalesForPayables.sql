CREATE VIEW [dbo].[vyuAPSalesForPayables]
AS 

SELECT 
	A.dtmDate	
	, A.intInvoiceId 
	, A.strInvoiceNumber 
	, 0 AS dblAmountPaid 
	, A.dblBaseInvoiceTotal AS dblTotal
	, A.dblBaseAmountDue  AS dblAmountDue 
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
	-- ,'Bill' AS [Info]
FROM dbo.tblARInvoice A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityId] = C2.intEntityId)
	ON C1.[intEntityId] = A.[intEntityCustomerId]
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C2.intEntityClassId	
WHERE A.ysnPosted = 1 AND A.strTransactionType = 'Cash Refund'
UNION ALL
SELECT  A.dtmDatePaid AS dtmDate,    
	 C.intInvoiceId,   
	 C.strInvoiceNumber ,
	 CAST(
		 	(CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId IS NULL)
						 THEN B.dblPayment * -1 ELSE B.dblPayment END) * A.dblExchangeRate AS DECIMAL(18,2)) AS dblAmountPaid,     
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, C.dblBaseDiscount AS dblDiscount
	, C.dblBaseInterest AS dblInterest 
	, dblPrepaidAmount = 0 
	, D.strVendorId 
	, ISNULL(D.strVendorId,'') + ' - ' + ISNULL(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
	, EC.strClass
	-- ,'Payment' AS [Info]
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblARInvoice C ON ISNULL(B.intInvoiceId,B.intOrigInvoiceId) = C.intInvoiceId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = D2.intEntityClassId		
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
	AND C.strTransactionType = 'Cash Refund'
	AND A.ysnPrepay = 0