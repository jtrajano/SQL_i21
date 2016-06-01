CREATE VIEW [dbo].[vyuARPaymentSearch]
AS
SELECT 
	 P.intPaymentId
	,P.strRecordNumber
	,P.intEntityId
	,P.intEntityCustomerId
	,P.intBankAccountId
	,LTRIM(RTRIM(BA.strBankAccountNo)) AS strBankAccountNo
	,LTRIM(RTRIM(E.strName)) AS strCustomerName
	,ISNULL(C.strCustomerNumber, E.strEntityNo) AS strCustomerNumber
	,P.dtmDatePaid
	,P.intPaymentMethodId
	,PM.strPaymentMethod AS strPaymentMethod
	,P.dblAmountPaid AS dblAmountPaid
	,P.ysnPosted
	,'Payment' AS strPaymentType
	,dbo.fnARGetInvoiceNumbersFromPayment(intPaymentId) AS strInvoices
	,P.intLocationId 
	,CL.strLocationName
	,GL.dtmDate AS dtmBatchDate
	,GL.strBatchId
	,ISNULL(GL.strName, EM.strName) strUserEntered
FROM
	tblARPayment P 
LEFT OUTER JOIN (SELECT intEntityId, strName FROM tblEMEntity ) EM ON P.intEntityId = EM.intEntityId
LEFT OUTER JOIN 
	tblSMPaymentMethod PM 
		ON P.intPaymentMethodId = PM.intPaymentMethodID
LEFT OUTER JOIN 
	(tblARCustomer C INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId) 
		ON C.intEntityCustomerId = P.intEntityCustomerId
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