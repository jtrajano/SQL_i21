CREATE VIEW [dbo].[vyuARBEExportCustomerAccounting]
AS 
SELECT
	 account			= ISNULL(ENT.[strEntityNo], '')
	,priceID			= ''
	,balance			= CAST(ROUND(ISNULL(ARC.[dblARBalance], 0.00), 2) AS NUMERIC(18, 2))
	,pastDue30			= CAST(ROUND(ISNULL(ARCI.[dbl60Days], 0.00) + ISNULL(ARCI.[dbl90Days], 0.00) + ISNULL(ARCI.[dbl91Days], 0.00), 2) AS NUMERIC(18, 2))
	,creditRating		= ISNULL(ARC.strCreditCode, '')
FROM
	vyuARCustomerInquiry ARCI
INNER JOIN tblARCustomer ARC
	ON ARCI.[intEntityId] = ARC.[intEntityId]
INNER JOIN tblEMEntity ENT
	ON ARC.[intEntityId] = ENT.[intEntityId]
WHERE ARC.ysnActive = 1	

