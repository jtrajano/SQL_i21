CREATE PROCEDURE [dbo].[uspARUpdateCustomerTotalAR]
AS

TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
	 , intEntityUserId
	 , dblCreditLimit
	 , dblTotalAR
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblTotalDue
	 , dblAmountPaid
	 , dblCredits
	 , dblPrepayments
	 , dblPrepaids
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
	 , strAgingType
)
EXEC uspARCustomerAgingAsOfDateReport

UPDATE CUSTOMER
SET dblARBalance = AGING.dblTotalAR
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
		 , dblTotalAR = ISNULL(dblTotalAR, 0)
	FROM tblARCustomerAgingStagingTable
) AGING ON CUSTOMER.intEntityId = AGING.intEntityCustomerId

TRUNCATE TABLE tblARCustomerAgingStagingTable