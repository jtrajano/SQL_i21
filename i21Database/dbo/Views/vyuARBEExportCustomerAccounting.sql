CREATE VIEW [dbo].[vyuARBEExportCustomerAccounting]
AS 
SELECT
	 account			= ISNULL(ARCI.[strCustomerNumber], '')
	,priceID			= ''
	,balance			= ISNULL(ARC.[dblARBalance], 0.000000) 
	,pastDue30			= ISNULL(ARCI.[dbl60Days], 0.000000) + ISNULL(ARCI.[dbl90Days], 0.000000) + ISNULL(ARCI.[dbl91Days], 0.000000)
	,creditRating		= ISNULL(ARC.strCreditCode, '')
FROM
	vyuARCustomerInquiry ARCI
INNER JOIN
	tblARCustomer ARC
		ON ARCI.[intEntityCustomerId] = ARC.[intEntityCustomerId]
