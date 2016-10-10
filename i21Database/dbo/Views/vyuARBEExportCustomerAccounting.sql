CREATE VIEW [dbo].[vyuARBEExportCustomerAccounting]
AS 
SELECT
	 account			= ISNULL(ARCI.[strCustomerNumber], '')
	,priceID			= ''
	,balance			= CAST(ROUND(ISNULL(ARC.[dblARBalance], 0.00), 2) AS NUMERIC(18, 2))
	,pastDue30			= CAST(ROUND(ISNULL(ARCI.[dbl60Days], 0.00) + ISNULL(ARCI.[dbl90Days], 0.00) + ISNULL(ARCI.[dbl91Days], 0.00), 2) AS NUMERIC(18, 2))
	,creditRating        = ISNULL(ARCI.strTerm, '')
FROM
	vyuARCustomerInquiry ARCI
INNER JOIN
	tblARCustomer ARC
		ON ARCI.[intEntityCustomerId] = ARC.[intEntityCustomerId]
WHERE ARC.ysnActive = 1
