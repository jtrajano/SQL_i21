CREATE VIEW [dbo].[vyuEMEntityTransaction]
	AS 
	select 	 
		intEntityId = intEntityCustomerId,
		strBillId = '' COLLATE Latin1_General_CI_AS,
		strTransactionNumber = strTransactionNumber COLLATE Latin1_General_CI_AS,
		strTransactionType = strTransactionType COLLATE Latin1_General_CI_AS,
		dblTransactionTotal,
		dblAmountPaid,
		dblAmountDue,
		ysnPaid = Cast(ysnPaid as bit),
		strEntityNo = strCustomerNumber COLLATE Latin1_General_CI_AS,
		dtmDate = dtmDate,
		strPaymentInfo = null,
		intPaymentId = null	,
		intTransactionId = null,
		dtmDatePaid = null

	from vyuARCustomerHistory
	union
	select 
		intEntityId = intEntityVendorId,
		strBillId = strBillId COLLATE Latin1_General_CI_AS,
		strTransactionNumber = strInvoiceNumber COLLATE Latin1_General_CI_AS,
		strTransactionType = strTransactionType COLLATE Latin1_General_CI_AS,
		dblTransactionTotal = dblTotal,
		dblAmountPaid ,
		dblAmountDue,
		ysnPaid = Cast(ysnPaid as bit),
		strEntityNo = strVendorId COLLATE Latin1_General_CI_AS,
		dtmDate = dtmDate,
		strPaymentInfo = strPaymentInfo,
		intPaymentId = intPaymentId,
		intTransactionId = intTransactionId,
		dtmDatePaid = dtmDatePaid
		--,* 
	from vyuAPVendorHistory
	union
	select 
		intEntityId = intEntityCustomerId,
		strBillId = '' COLLATE Latin1_General_CI_AS,
		strTransactionNumber = strQuoteNumber COLLATE Latin1_General_CI_AS,
		strTransactionType = 'Transport Quote' COLLATE Latin1_General_CI_AS,
		dblTransactionTotal = 0,
		dblAmountPaid = 0,
		dblAmountDue = 0,
		ysnPaid = Cast(0 as bit),
		strEntityNo = '' COLLATE Latin1_General_CI_AS,
		dtmDate = dtmQuoteDate,
		strPaymentInfo = '',
		intPaymentId = 0,
		intTransactionId = intQuoteHeaderId,
		dtmDatePaid = null
		--,* 
	from vyuTRGetQuoteHeader
