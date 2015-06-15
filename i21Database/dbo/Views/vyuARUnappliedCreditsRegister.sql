CREATE VIEW [dbo].[vyuARUnappliedCreditsRegister]
AS
SELECT DISTINCT 
       C.strCustomerNumber
     , RTRIM(C.strCustomerNumber) + ' - ' + C.strName AS strName
	 , P.strRecordNumber
	 , L.strLocationName
	 , P.dtmDatePaid
	 , P.dblAmountPaid
	 , strTransactionType
	 , P.dblUnappliedAmount AS dblUsed
	 , P.dblAmountPaid - P.dblUnappliedAmount AS dblRemaining
	 , strContact = ISNULL(RTRIM(E.strPhone) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(E.strEmail) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToLocationName) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToAddress) + CHAR(13) + char(10), '')
				  + ISNULL(RTRIM(C.strBillToCity), '')
				  + ISNULL(', ' + RTRIM(C.strBillToState), '')
				  + ISNULL(', ' + RTRIM(C.strZipCode), '')
				  + ISNULL(', ' + RTRIM(C.strBillToCountry), '')
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