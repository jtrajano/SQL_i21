CREATE VIEW [dbo].[vyuARUnappliedCreditsRegister]
AS
SELECT DISTINCT 
      C.strCustomerNumber
	, RTRIM(C.strCustomerNumber) + ' - ' + C.strName AS strName
	, I.intEntityCustomerId
	, strInvoiceNumber
	, strTransactionType	
	, CC.strLocationName
	, dtmDate
	, dblAmount = ISNULL(dblInvoiceTotal, 0) * -1
	, dblUsed = ISNULL(dblPayment, 0) * -1
	, dblRemaining = ISNULL(dblAmountDue, 0) * -1
	, strContact = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry)
FROM tblARInvoice I
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
WHERE I.ysnPosted = 1
AND I.ysnPaid = 0
AND I.strTransactionType <> 'Invoice'
AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')