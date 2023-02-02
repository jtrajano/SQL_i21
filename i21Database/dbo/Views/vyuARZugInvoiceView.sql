CREATE VIEW [dbo].[vyuARZugInvoiceView]
AS
SELECT 'Invoice Number'			= I.strInvoiceNumber
	 , 'Customer Name'			= E.strName
	 , 'Customer Number'		= C.strCustomerNumber
	 , 'Contact Name'			= EC.strName
	 , 'Source'					= I.strType
	 , 'Type'					= I.strTransactionType
	 , 'Term'					= T.strTerm
	 , 'BOL No.'				= I.strBOLNumber
	 , 'PO Number'				= I.strPONumber
	 , 'Book'					= B.strBook
	 , 'SubBook'				= SB.strSubBook
	 , 'Scale Ticket Nos.'		= I.strTicketNumbers
	 , 'Customer References'	= I.strCustomerReferences
	 , 'SO Number'				= SO.strSalesOrderNumber
	 , 'Base Date'				= I.dtmDate
	 , 'Days Old'				= DATEDIFF(DAYOFYEAR, I.dtmDate, CAST(GETUTCDATE() AS DATE))
	 , 'Due Date'				= I.dtmDueDate
	 , 'Accounting Period'		= FYP.strPeriod
	 , 'Discount Taken'			= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblDiscount, 0) ELSE ISNULL(I.dblDiscount, 0) * -1 END
	 , 'Discount Available'		= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblDiscountAvailable, 0) ELSE ISNULL(I.dblDiscountAvailable, 0) * -1 END
	 , 'Interest'				= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblInterest, 0) ELSE ISNULL(I.dblInterest, 0) * -1 END
	 , 'Invoice Total'			= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblInvoiceTotal, 0)
                                       WHEN I.strTransactionType = 'Customer Prepayment' THEN CASE WHEN I.ysnRefundProcessed = 1 THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE 0 END
                                       ELSE ISNULL(I.dblInvoiceTotal, 0) * -1 
                                  END
	 , 'Payment'				= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblPayment, 0)
                                       WHEN I.strTransactionType = 'Customer Prepayment' THEN CASE WHEN I.ysnRefundProcessed = 1 THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
                                       ELSE ISNULL(I.dblPayment, 0) * -1
                                  END
	 , 'Amount Due'				= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblAmountDue, 0)  ELSE  ISNULL(I.dblAmountDue, 0) * -1 END
	 , 'Tax'					= CASE WHEN I.strTransactionType IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(I.dblTax, 0) ELSE ISNULL(I.dblTax, 0) * -1 END
	 , 'WithHeld'				= CASE WHEN ysnPaid = 1 
                                       THEN I.dblPayment - (I.dblPayment - (I.dblPayment * (dblWithholdPercent / 100))) * CASE WHEN I.strTransactionType IN ('Credit Memo','Customer Prepayment', 'Overpayment') THEN -1 ELSE 1 END
									   ELSE I.dblAmountDue - (I.dblAmountDue - (I.dblAmountDue * (dblWithholdPercent / 100))) * CASE WHEN I.strTransactionType IN ('Credit Memo','Customer Prepayment', 'Overpayment') THEN -1 ELSE 1 END
								  END	 
	 , 'Currency'				= CUR.strCurrency
	 , 'Posted'					= I.ysnPosted
	 , 'Invoice Date'			= I.dtmDate
	 , 'Paid'					= CASE WHEN I.strTransactionType = 'Customer Prepayment' AND I.ysnPaid = 0 THEN I.ysnPaidCPP ELSE I.ysnPaid END
	 , 'Days to Pay'			= CASE WHEN I.ysnPaid = 0 OR I.strTransactionType IN ('Cash') THEN 0 ELSE DATEDIFF(DAYOFYEAR, I.dtmDate, CAST(FULLPAY.dtmDatePaid AS DATE)) END
	 , 'Processed'				= I.ysnProcessed
	 , 'Comments'				= I.strComments
	 , 'Batch Id'				= I.strBatchId
	 , 'Location'				= CL.strLocationName
	 , 'Entered By'				= EE.strName
	 , 'Posted By'				= PE.strName
	 , 'Invoice Id'				= I.intInvoiceId
	 , 'Customer Id'			= I.intEntityCustomerId
	 , 'Currency Id'			= I.intCurrencyId
	 , 'Currency Description'	= CUR.strCurrency
	 , 'Payments'				= PAYMENTS.strRecordNumbers
	 , 'Mail Sent'				= ISNULL(EMAILSTATUS.ysnMailSent, 0)
FROM tblARInvoice I
INNER JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN tblSMTerm T ON I.intTermId = T.intTermID
INNER JOIN tblSMCurrency CUR ON I.intCurrencyId = CUR.intCurrencyID
INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
LEFT JOIN tblEMEntity EC ON I.intEntityContactId = EC.intEntityId
LEFT JOIN tblCTBook B ON I.intBookId = B.intBookId
LEFT JOIN tblCTSubBook SB ON I.intSubBookId = SB.intSubBookId
LEFT JOIN tblEMEntity EE ON I.intEntityId = EE.intEntityId
LEFT JOIN tblEMEntity PE ON I.intPostedById = PE.intEntityId
LEFT JOIN tblSOSalesOrder SO ON I.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN tblGLFiscalYearPeriod FYP ON I.intPeriodId = FYP.intGLFiscalYearPeriodId
LEFT JOIN (
	SELECT intRecordId	= SMT.intRecordId 
	     , ysnMailSent	= CASE WHEN COUNT(SMA.intTransactionId) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)  END 
	FROM tblSMTransaction SMT WITH (NOLOCK)
	INNER JOIN tblSMScreen SC WITH (NOLOCK) ON SMT.intScreenId = SC.intScreenId
	INNER JOIN tblSMActivity SMA WITH (NOLOCK) ON SMA.intTransactionId = SMT.intTransactionId 
	WHERE SC.strScreenName = 'Invoice'
	  AND SMA.strType = 'Email' 
	  AND SMA.strStatus = 'Sent'
	GROUP by SMT.intRecordId
) EMAILSTATUS ON I.intInvoiceId = EMAILSTATUS.intRecordId
LEFT JOIN (
	SELECT dtmDatePaid		= MAX(P.dtmDatePaid)
		 , intInvoiceId		= PD.intInvoiceId
	FROM tblARPaymentDetail PD
	INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
	WHERE P.ysnPosted = 1
	  AND P.ysnInvoicePrepayment = 0
	GROUP BY PD.intInvoiceId
) FULLPAY ON I.intInvoiceId = FULLPAY.intInvoiceId AND I.ysnPaid = 1
OUTER APPLY (
	SELECT strRecordNumbers = LEFT(strRecordNumber, LEN(strRecordNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(P.strRecordNumber AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD 
		INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
		WHERE P.ysnPosted = 1
		  AND PD.intInvoiceId IS NOT NULL
		  AND PD.intInvoiceId = I.intInvoiceId
		FOR XML PATH ('')
	) INV (strRecordNumber)
) PAYMENTS