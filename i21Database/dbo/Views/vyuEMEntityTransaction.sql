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
		intTransactionId = null
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
		intTransactionId = intTransactionId
		--,* 
	from vyuAPVendorHistory