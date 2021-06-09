CREATE VIEW [dbo].[vyuARPaymentMethodForReceivePayments]
AS
SELECT intId					= ROW_NUMBER() OVER(ORDER BY intPaymentMethodID DESC)
	 , intPaymentMethodID		= PM.intPaymentMethodID
	 , strPaymentMethod			= PM.strPaymentMethod
	 , ysnActive				= PM.ysnActive
	 , intEntityCardInfoId		= NULL
	 , intEntityId				= 0 
	 , strCardType				= NULL
	 , dblConvenienceFee		= CAST(0 AS NUMERIC(18, 6))
	 , strConvenienceFeeType	= NULL
	 , ysnExemptCreditCardFee	= CAST(1 AS BIT)
FROM tblSMPaymentMethod PM
WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1

UNION ALL 

SELECT intId					= ROW_NUMBER() OVER(ORDER BY ECI.intEntityCardInfoId) + (SELECT COUNT(*) FROM tblSMPaymentMethod WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1)
	 , intPaymentMethodID		= 11
	 , strCreditCardNumber		= ECI.strCreditCardNumber
	 , ysnActive				= ECI.ysnActive
	 , intEntityCardInfoId		= ECI.intEntityCardInfoId
	 , intEntityId				= ECI.intEntityId
	 , strCardType				= ECI.strCardType
	 , dblConvenienceFee		= CAST(2.5 AS NUMERIC(18, 6))
	 , strConvenienceFeeType	= 'Percentage'
	 , ysnExemptCreditCardFee	= ISNULL(C.ysnExemptCreditCardFee, 0)
FROM tblEMEntityCardInformation ECI
INNER JOIN tblARCustomer C ON ECI.intEntityId = C.intEntityId
WHERE ECI.strToken IS NOT NULL
  AND DATEADD(MONTH, 1 , CAST(REPLACE(ECI.strCardExpDate,'/','/01/') AS DATETIME)) > CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)