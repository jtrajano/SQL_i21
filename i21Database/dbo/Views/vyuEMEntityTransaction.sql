CREATE VIEW [dbo].[vyuEMEntityTransaction]
	AS 
	select 	 
		intEntityId = a.intEntityCustomerId,
		strBillId = '' COLLATE Latin1_General_CI_AS,
		strTransactionNumber = a.strTransactionNumber COLLATE Latin1_General_CI_AS,
		strTransactionType = a.strTransactionType COLLATE Latin1_General_CI_AS,
		a.dblTransactionTotal,
		a.dblAmountPaid,
		a.dblAmountDue,
		ysnPaid = Cast(a.ysnPaid as bit),
		strEntityNo = a.strCustomerNumber COLLATE Latin1_General_CI_AS,
		dtmDate = a.dtmDate,
		strPaymentInfo = null,
		intPaymentId = null	,
		intTransactionId = null,
		dtmDatePaid = a.dtmPostDate,
		strPaymentMethod = d.strPaymentMethod
	from vyuARCustomerHistory a	
		left join tblARInvoice b on a.strTransactionNumber = b.strInvoiceNumber
		left join tblARPayment c on a.strTransactionNumber = c.strRecordNumber
		left join tblSMPaymentMethod d on c.intPaymentMethodId = d.intPaymentMethodID
			where (b.intInvoiceId is null or  b.strType <> 'CF Tran')			
				and (isnull(c.intPaymentMethodId, 0) <> 9)
	union all
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
		dtmDatePaid = dtmDatePaid,
		strPaymentMethod = null
		--,* 
	from vyuAPVendorHistory
	union all
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
		dtmDatePaid = null,
		strPaymentMethod = null
		--,* 
	from vyuTRGetQuoteHeader
