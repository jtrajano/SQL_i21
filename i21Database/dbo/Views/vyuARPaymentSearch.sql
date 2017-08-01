CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT 
	 P.intPaymentId
	,P.strRecordNumber
	,P.intEntityId
	,P.intEntityCustomerId
	,P.intBankAccountId
	,strBankAccountNo		= LTRIM(RTRIM(BA.strBankAccountNo))
	,strCustomerName		= LTRIM(RTRIM(C.strName))
	,strCustomerNumber		= C.strCustomerNumber
	,P.dtmDatePaid
	,P.intPaymentMethodId
	,strPaymentMethod		= PM.strPaymentMethod
	,dblAmountPaid			= P.dblAmountPaid
	,dblDiscount		    = ISNULL(PD.dblDiscount, 0)
	,P.ysnPosted
	,strPaymentType			= 'Payment'
	,strInvoices			= dbo.fnARGetInvoiceNumbersFromPayment(P.intPaymentId)
	,P.intLocationId 
	,CL.strLocationName
	,dtmBatchDate			= P.dtmBatchDate
	,strBatchId				= P.strBatchId
	,strUserEntered			= USERENTERED.strName
	,strTicketNumbers		= dbo.fnARGetScaleTicketNumbersFromPayment(P.intPaymentId)
	,strCustomerReferences	= dbo.fnARGetCustomerReferencesFromPayment(P.intPaymentId)
	,intCurrencyId			= P.intCurrencyId
	,strCurrency			= SMC.strCurrency
    ,strCurrencyDescription	= SMC.strDescription	 
FROM (
	SELECT intPaymentId
		 , strRecordNumber
		 , intEntityId
		 , intEntityCustomerId
		 , intBankAccountId
		 , dtmDatePaid
		 , intPaymentMethodId
		 , dblAmountPaid
		 , ysnPosted
		 , intLocationId
		 , intAccountId
		 , intCurrencyId
		 , dtmBatchDate
		 , intPostedById
		 , strBatchId
	FROM dbo.tblARPayment WITH (NOLOCK)
) P
LEFT JOIN (
	SELECT intPaymentId
	     , dblDiscount = SUM(ISNULL(dblDiscount, 0))
	FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	WHERE ISNULL(dblDiscount, 0) <> 0
	GROUP BY intPaymentId
) PD ON P.intPaymentId = PD.intPaymentId
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) EM ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN (
	SELECT intPaymentMethodID
		 , strPaymentMethod
	FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
INNER JOIN (
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK)
) C ON P.intEntityCustomerId = C.intEntityId
LEFT OUTER JOIN (
	SELECT intBankAccountId
		 , strBankAccountNo 
	FROM dbo.tblCMBankAccount WITH (NOLOCK)
) BA ON P.intBankAccountId = BA.intBankAccountId
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON P.intLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , strCurrency 
		 , strDescription 
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON P.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strName 
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERENTERED ON USERENTERED.intEntityId = P.intPostedById