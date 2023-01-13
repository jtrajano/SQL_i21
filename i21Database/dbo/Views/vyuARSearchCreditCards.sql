CREATE VIEW dbo.vyuARSearchCreditCards
AS
SELECT intEntityCustomerId		= ECI.intEntityId
	 , strCreditCardNumber		= ECI.strCreditCardNumber
	 , intEntityCardInfoId		= ECI.intEntityCardInfoId
	 , strCardType				= ECI.strCardType
	 , dblConvenienceFee		= CASE WHEN UPPER(ECI.strCardType) = 'VISA' THEN CAST(ISNULL(dblVisaPercentage, 0) AS NUMERIC(18, 6))
								       WHEN UPPER(ECI.strCardType) = 'MASTERCARD' THEN CAST(ISNULL(dblMastercardPercentage, 0) AS NUMERIC(18, 6))
									   WHEN UPPER(ECI.strCardType) = 'AMERICAN EXPRESS' THEN CAST(ISNULL(dblAmericanExpressPercentage, 0) AS NUMERIC(18, 6))
									   WHEN UPPER(ECI.strCardType) = 'DISCOVER' THEN CAST(ISNULL(dblDiscoverPercentage, 0) AS NUMERIC(18, 6))
									   WHEN UPPER(ECI.strCardType) = 'DINERS CLUB' THEN CAST(ISNULL(dblDinersClubPercentage, 0) AS NUMERIC(18, 6))
									   WHEN UPPER(ECI.strCardType) = 'CHINA UNION PAY' THEN CAST(ISNULL(dblChinaUnionPayPercentage, 0) AS NUMERIC(18, 6))
								  END
	 , strConvenienceFeeType	= CP.strCreditCardConvenienceFee
	 , ysnExemptCreditCardFee	= ISNULL(C.ysnExemptCreditCardFee, 0)
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