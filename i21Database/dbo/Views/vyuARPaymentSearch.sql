CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT 
	 P.intPaymentId
	,P.strRecordNumber
	,P.intEntityId
	,P.intEntityCustomerId
	,P.intBankAccountId
	,strBankAccountNo		= LTRIM(RTRIM(BA.strBankAccountNo))
	,strCustomerName		= LTRIM(RTRIM(E.strName))
	,strCustomerNumber		= ISNULL(C.strCustomerNumber, E.strEntityNo)
	,P.dtmDatePaid
	,P.intPaymentMethodId
	,strPaymentMethod		= PM.strPaymentMethod
	,dblAmountPaid			= P.dblAmountPaid
	,P.ysnPosted
	,strPaymentType			= 'Payment'
	,strInvoices			= dbo.fnARGetInvoiceNumbersFromPayment(intPaymentId)
	,P.intLocationId 
	,CL.strLocationName
	,dtmBatchDate			= GL.dtmDate
	,GL.strBatchId
	,strUserEntered			= ISNULL(GL.strName, EM.strName)
	,strTicketNumbers		= dbo.fnARGetScaleTicketNumbersFromPayment(P.intPaymentId)
	,strCustomerReferences	= dbo.fnARGetCustomerReferencesFromPayment(P.intPaymentId)
FROM
	tblARPayment P 
LEFT OUTER JOIN (SELECT intEntityId, strName FROM tblEMEntity ) EM ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN 
	tblSMPaymentMethod PM 
		ON P.intPaymentMethodId = PM.intPaymentMethodID
INNER JOIN 
	tblEMEntity E 
		ON P.intEntityCustomerId = E.intEntityId
LEFT OUTER JOIN 
	tblARCustomer C 
		ON E.intEntityId = C.intEntityCustomerId
LEFT OUTER JOIN 
	tblCMBankAccount BA 
		ON P.intBankAccountId = BA.intBankAccountId
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON P.intLocationId = CL.intCompanyLocationId
LEFT OUTER JOIN
	(
	SELECT --TOP 1
		 G.intTransactionId
		,G.strTransactionId
		,G.intAccountId
		,G.strTransactionType
		,G.dtmDate
		,G.strBatchId
		,E.intEntityId
		,E.strName
	FROM
		tblGLDetail G
	LEFT OUTER JOIN
		tblEMEntity E
			ON G.intEntityId = E.intEntityId
	WHERE
			G.strTransactionType IN ('Receive Payments')
		AND G.ysnIsUnposted = 0
		AND G.strCode = 'AR'
	) GL
		ON P.intPaymentId = GL.intTransactionId
		AND P.intAccountId = GL.intAccountId
		AND P.strRecordNumber = GL.strTransactionId