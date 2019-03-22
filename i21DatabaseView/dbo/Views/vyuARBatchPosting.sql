CREATE VIEW [dbo].[vyuARBatchPosting]
AS 

SELECT 
     strTransactionType     = CASE strTransactionType WHEN 'Debit Memo' THEN 'Debit Memo (Sales)' ELSE strTransactionType END
    ,intTransactionId       = intInvoiceId
    ,strTransactionId       = strInvoiceNumber
    ,dblAmount              = dblInvoiceTotal
    ,strVendorInvoiceNumber = strPONumber
    ,intEntityCustomerId    = intEntityCustomerId
    ,intEntityId            = intEntityId
    ,dtmDate                = dtmDate
    ,strDescription         = strComments
    ,intCompanyLocationId   = intCompanyLocationId
FROM
	tblARInvoice
WHERE 
	strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash') 
	AND ysnPosted = 0  
	AND (ISNULL(intDistributionHeaderId, 0) = 0 AND ISNULL(intLoadDistributionHeaderId, 0) = 0) 
	AND (ISNULL(intTransactionId, 0) = 0 AND strType <> 'CF Tran') 
	AND ISNULL(ysnRecurring,0) = 0 
	AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
	AND intInvoiceId NOT IN (SELECT intTransactionId FROM vyuARForApprovalTransction WHERE strScreenName = 'Invoice')

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
