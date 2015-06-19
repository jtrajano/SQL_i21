CREATE VIEW [dbo].[vyuARUnappliedCreditsRegister]
AS
SELECT DISTINCT 
       C.strCustomerNumber
     , RTRIM(C.strCustomerNumber) + ' - ' + C.strName AS strName
	 , P.strPaymentInfo AS strFarmCheck
	 , P.strRecordNumber
	 , L.strLocationName
	 , P.dtmDatePaid
	 , P.dblAmountPaid
	 , strTransactionType
	 , P.dblUnappliedAmount AS dblUsed
	 , P.dblAmountPaid - P.dblUnappliedAmount AS dblRemaining
	 , P.strNotes
	 , strContact = [dbo].fnARFormatCustomerAddress(E.strPhone, E.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry)
FROM tblARPayment P
	INNER JOIN (vyuARCustomer C INNER JOIN tblEntity E ON C.intEntityCustomerId = E.intEntityId) ON P.intEntityCustomerId = C.intEntityCustomerId
	INNER JOIN (tblARInvoice I INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId) ON P.intEntityCustomerId = I.intEntityCustomerId
WHERE I.ysnPosted = 1 
  AND P.ysnPosted = 1
  AND I.ysnPaid = 0
  AND I.strTransactionType <> 'Invoice'
  AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
						INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
						WHERE AG.strAccountGroup = 'Receivables')