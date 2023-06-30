CREATE VIEW [dbo].[vyuARBatchPosting]
AS 

SELECT 
     strTransactionType     = CASE strTransactionType WHEN 'Debit Memo' THEN 'Debit Memo (Sales)' ELSE strTransactionType END
    ,intTransactionId       = intInvoiceId
    ,strTransactionId       = strInvoiceNumber
    ,dblAmount              = dblInvoiceTotal
    ,strVendorInvoiceNumber = strPONumber
    ,intEntityCustomerId    = intEntityCustomerId
    ,intEntityId            = I.intEntityId
    ,dtmDate                = dtmDate
    ,strDescription         = I.strComments
    ,intCompanyLocationId   = intCompanyLocationId
FROM
	tblARInvoice I
INNER JOIN tblARCustomer C
ON I.intEntityCustomerId = C.intEntityId
WHERE 
	strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash') 
	AND ysnPosted = 0  
	AND (ISNULL(intDistributionHeaderId, 0) = 0 AND ISNULL(intLoadDistributionHeaderId, 0) = 0) 
	AND (ISNULL(intTransactionId, 0) = 0 AND I.strType <> 'CF Tran') 
	AND ISNULL(ysnRecurring,0) = 0 
	AND ((I.strType = 'Service Charge' AND ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND ysnForgiven = 0)))
    AND ISNULL(strCreditCode,'') <> 'Reject Orders'
    AND C.ysnActive = 1
UNION ALL

SELECT 
     strTransactionType     = 'Payment'
    ,intTransactionId       = intPaymentId
    ,strTransactionId       = strRecordNumber
    ,dblAmount              = dblAmountPaid
    ,strVendorInvoiceNumber = strPaymentInfo
    ,intEntityCustomerId    = intEntityCustomerId
    ,intEntityId            = intEntityId
    ,dtmDate                = dtmDatePaid
    ,strDescription         = strNotes
    ,intCompanyLocationId   = intLocationId 
FROM
	tblARPayment
WHERE
	ysnPosted = 0
