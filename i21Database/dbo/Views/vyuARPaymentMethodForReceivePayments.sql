CREATE VIEW [dbo].[vyuARPaymentMethodForReceivePayments]
AS
SELECT 
	 intId					= CAST(ROW_NUMBER() OVER(ORDER BY intPaymentMethodID DESC) AS INT)
	,intPaymentMethodID		= PM.intPaymentMethodID
	,strPaymentMethod		= PM.strPaymentMethod
	,ysnActive				= PM.ysnActive
	,intEntityCardInfoId	= NULL
	,intEntityId			= 0 
	,strCardType			= NULL
	,dblConvenienceFee		= CAST(0 AS NUMERIC(18, 6))
	,strConvenienceFeeType	= NULL
	,ysnExemptCreditCardFee	= CAST(1 AS BIT)
	,strDescription			= PM.strDescription
FROM tblSMPaymentMethod PM
WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1

UNION ALL 

SELECT 
	 intId					= CAST(ROW_NUMBER() OVER(ORDER BY ECI.intEntityCardInfoId) + (SELECT COUNT(*) FROM tblSMPaymentMethod WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1) AS INT)
	,intPaymentMethodID		= 11
	,strCreditCardNumber	= ECI.strCreditCardNumber
	,ysnActive				= ECI.ysnActive
	,intEntityCardInfoId	= ECI.intEntityCardInfoId
	,intEntityId			= ECI.intEntityId
	,strCardType			= ECI.strCardType
	,dblConvenienceFee		= CASE WHEN UPPER(ECI.strCardType) = 'VISA' THEN CAST(ISNULL(dblVisaPercentage, 0) AS NUMERIC(18, 6))
								WHEN UPPER(ECI.strCardType) = 'MASTERCARD' THEN CAST(ISNULL(dblMastercardPercentage, 0) AS NUMERIC(18, 6))
								WHEN UPPER(ECI.strCardType) IN ('AMERICAN EXPRESS', 'AMEX') THEN CAST(ISNULL(dblAmericanExpressPercentage, 0) AS NUMERIC(18, 6))
								WHEN UPPER(ECI.strCardType) = 'DISCOVER' THEN CAST(ISNULL(dblDiscoverPercentage, 0) AS NUMERIC(18, 6))
								WHEN UPPER(ECI.strCardType) = 'DINERS CLUB' THEN CAST(ISNULL(dblDinersClubPercentage, 0) AS NUMERIC(18, 6))
								WHEN UPPER(ECI.strCardType) IN ('CHINA UNION PAY', 'UNION PAY') THEN CAST(ISNULL(dblChinaUnionPayPercentage, 0) AS NUMERIC(18, 6))
							  END
	,strConvenienceFeeType	= CP.strCreditCardConvenienceFee
	,ysnExemptCreditCardFee	= ISNULL(C.ysnExemptCreditCardFee, 0)
	,strDescription			= ''
FROM tblEMEntityCardInformation ECI
INNER JOIN tblARCustomer C ON ECI.intEntityId = C.intEntityId
OUTER APPLY (
	SELECT TOP 1 dblVisaPercentage
			   , dblMastercardPercentage
			   , dblAmericanExpressPercentage
			   , dblDiscoverPercentage
			   , dblDinersClubPercentage
			   , dblChinaUnionPayPercentage
			   , strCreditCardConvenienceFee
	FROM tblARCompanyPreference
) CP
WHERE ECI.strToken IS NOT NULL
  AND DATEADD(MONTH, 1 , CAST(REPLACE(ECI.strCardExpDate,'/','/01/') AS DATETIME)) > CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
  AND ECI.ysnActive = 1