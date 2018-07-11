CREATE VIEW [dbo].[vyuARPaymentReport]
AS
SELECT PAYMENTS.intPaymentId
     , PAYMENTS.strRecordNumber
	 , PAYMENTS.dtmDatePaid
	 , strLocationName      = SMCL.strLocationName
	 , strCurrency	        = CURRENCY.strCurrency
	 , PAYMENTS.strPaymentInfo
	 , PAYMENTS.strNotes
	 , PAYMENTS.dblAmountPaid
	 , PAYMENTS.dblUnappliedAmount
	 , strBatchNumber       = GLB.strBatchId
	 , PAYMENTS.intEntityCustomerId
	 , strCustomerNumber    = CUSTOMER.strCustomerNumber
     , strCustomerName      = CUSTOMER.strName
     , strCustomerAddress   = dbo.fnARFormatCustomerAddress(NULL, NULL, CUSTOMER.strBillToLocationName, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, CUSTOMER.strName, CUSTOMER.ysnIncludeEntityName)
	 , dblCustomerARBalance = ISNULL(CUSTOMER.dblARBalance, 0.00) + ISNULL(PENDINGINVOICE.dblInvoiceTotal, 0.00) - ISNULL(PENDINGPAYMENT.dblPayment, 0.00)     
     , dblPendingInvoice    = ISNULL(PENDINGINVOICE.dblInvoiceTotal, 0.00)
	 , dblPendingPayment    = ISNULL(PENDINGPAYMENT.dblPayment, 0.00)	 
     , PAYMENTS.intInvoiceId
	 , PAYMENTS.strInvoiceNumber
	 , PAYMENTS.strInvoiceType
	 , PAYMENTS.ysnIsCredit
	 , PAYMENTS.dblInvoiceTotal
	 , PAYMENTS.dtmDueDate
	 , PAYMENTS.dblInterest
	 , PAYMENTS.dblDiscount
	 , PAYMENTS.dblPayment
	 , strCompanyName       = CASE WHEN SMCL.strUseLocationAddress = 'Letterhead' THEN '' ELSE COMPANY.strCompanyName END
     , strCompanyAddress	= CASE WHEN SMCL.strUseLocationAddress IS NULL OR SMCL.strUseLocationAddress IN ('','No','Always')
										THEN COMPANY.strCompanyAddress
								   WHEN SMCL.strUseLocationAddress = 'Yes'
										THEN dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, SMCL.strAddress, SMCL.strCity, SMCL.strStateProvince, SMCL.strZipPostalCode, SMCL.strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
								   WHEN SMCL.strUseLocationAddress = 'Letterhead'
										THEN ''
							  END

FROM (
	SELECT intPaymentId			= ARP.intPaymentId
		 , intEntityCustomerId  = ARP.intEntityCustomerId
		 , intCurrencyId		= ARP.intCurrencyId
		 , intCompanyLocationId	= ARP.intLocationId
		 , intAccountId			= ARP.intAccountId
		 , strRecordNumber      = ARP.strRecordNumber
		 , strPaymentInfo       = ARP.strPaymentInfo
		 , strNotes				= ARP.strNotes
		 , dblAmountPaid        = ARP.dblAmountPaid
		 , dblUnappliedAmount   = ARP.dblUnappliedAmount
		 , dtmDatePaid			= ARP.dtmDatePaid	 
		 , intInvoiceId         = ARPD.intInvoiceId
		 , strInvoiceNumber     = ARPD.strInvoiceNumber
		 , strInvoiceType       = ARPD.strTransactionType
		 , ysnIsCredit          = CASE WHEN ARPD.strTransactionType IN ('Credit Memo', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN 1 ELSE 0 END
		 , dblInvoiceTotal      = ISNULL(ARPD.dblInvoiceTotal, 0.00)
		 , dtmDueDate           = ARPD.dtmDueDate
		 , dblInterest          = ISNULL(ARPD.dblInterest, 0.00)
		 , dblDiscount          = ISNULL(ARPD.dblDiscount, 0.00)
		 , dblPayment           = ISNULL(ARPD.dblPayment, 0.00)     
	FROM tblARPayment ARP
	LEFT OUTER JOIN (
		SELECT PD.intPaymentId
			 , PD.dblDiscount
			 , PD.dblInterest
			 , PD.dblPayment
			 , ARI.*
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
		INNER JOIN (SELECT intInvoiceId
						 , strInvoiceNumber
						 , strTransactionType
						 , dtmDueDate
						 , dblInvoiceTotal = dbo.fnARGetInvoiceAmountMultiplier(strTransactionType) * dblInvoiceTotal
					FROM dbo.tblARInvoice 
		) ARI ON PD.intInvoiceId = ARI.intInvoiceId
		WHERE PD.dblPayment <> 0
	) ARPD ON ARP.intPaymentId = ARPD.intPaymentId

	UNION ALL

	SELECT intPaymentId			= ARP.intPaymentId
		 , intEntityCustomerId  = ARP.intEntityCustomerId
		 , intCurrencyId		= ARP.intCurrencyId
		 , intCompanyLocationId	= ARP.intLocationId
		 , intAccountId			= ARP.intAccountId
		 , strRecordNumber      = ARP.strRecordNumber
		 , strPaymentInfo       = ARP.strPaymentInfo
		 , strNotes				= ARP.strNotes
		 , dblAmountPaid        = ARP.dblAmountPaid
		 , dblUnappliedAmount   = ARP.dblUnappliedAmount
		 , dtmDatePaid			= ARP.dtmDatePaid	 
		 , intInvoiceId         = I.intInvoiceId
		 , strInvoiceNumber     = I.strInvoiceNumber
		 , strInvoiceType       = I.strTransactionType
		 , ysnIsCredit          = CASE WHEN I.strTransactionType IN ('Credit Memo', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN 1 ELSE 0 END
		 , dblInvoiceTotal      = I.dblInvoiceTotal
		 , dtmDueDate           = I.dtmDueDate
		 , dblInterest          = I.dblInterest
		 , dblDiscount          = I.dblDiscount
		 , dblPayment           = I.dblInvoiceTotal
	FROM tblARPayment ARP
	INNER JOIN (
		SELECT intInvoiceId
			 , intPaymentId
			 , strInvoiceNumber
			 , strTransactionType
			 , dtmDueDate
			 , dblInvoiceTotal
			 , dblInterest
			 , dblDiscount
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
	) I ON ARP.intPaymentId = I.intPaymentId
	WHERE 
		ARP.ysnInvoicePrepayment = 0
) PAYMENTS
INNER JOIN (
	SELECT intEntityId
		 , strBillToLocationName
		 , strBillToAddress
		 , strBillToCity
		 , strBillToState
		 , strBillToZipCode
		 , strBillToCountry		 
	     , strName
		 , strCustomerNumber
		 , dblARBalance
	     , ysnIncludeEntityName 
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON PAYMENTS.intEntityCustomerId = CUSTOMER.intEntityId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
		 , strUseLocationAddress
		 , strAddress
		 , strCity
		 , strStateProvince
		 , strZipPostalCode
		 , strCountry
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) SMCL ON PAYMENTS.intCompanyLocationId = SMCL.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON PAYMENTS.intCurrencyId = CURRENCY.intCurrencyID
LEFT OUTER JOIN (
    SELECT GLD.intTransactionId
         , GLD.strTransactionId
         , GLD.intAccountId
         , GLD.strBatchId
    FROM dbo.tblGLDetail GLD WITH (NOLOCK)
    WHERE GLD.strTransactionType IN ('Receive Payments')
        AND GLD.ysnIsUnposted = 0
        AND GLD.strCode = 'AR'
) GLB ON PAYMENTS.intPaymentId = GLB.intTransactionId
     AND PAYMENTS.intAccountId = GLB.intAccountId
     AND PAYMENTS.strRecordNumber = GLB.strTransactionId
OUTER APPLY (
	SELECT TOP 1 strCompanyName 
			   , strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, CUSTOMER.ysnIncludeEntityName)
			   , ysnIncludeEntityName
	FROM dbo.tblSMCompanySetup WITH (NOLOCK)
) COMPANY
OUTER APPLY (
	SELECT dblPayment = SUM(ISNULL(dblAmountPaid, 0.00)) 
	FROM dbo.tblARPayment WITH (NOLOCK) 
	WHERE intEntityCustomerId = PAYMENTS.intEntityCustomerId 
	  AND ysnPosted = 0
) PENDINGPAYMENT
OUTER APPLY (
	SELECT dblInvoiceTotal = SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END) 
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE intEntityCustomerId = PAYMENTS.intEntityCustomerId 
	  AND ysnPosted = 0 
	  AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0)))
) PENDINGINVOICE