CREATE VIEW dbo.vyuARPaymentMethodForPortal
AS
SELECT intPaymentMethodId		= P.intPaymentMethodID
	 , intEntityCustomerId		= CASE WHEN strPaymentMethod = 'ACH' THEN ACH.intEntityId ELSE NULL END
	 , intBankId				= CASE WHEN strPaymentMethod = 'ACH' THEN ACH.intBankId ELSE NULL END
	 , intBankAccountId			= CASE WHEN strPaymentMethod = 'ACH' THEN ACH.intBankAccountId ELSE NULL END
	 , strBankName				= CASE WHEN strPaymentMethod = 'ACH' THEN ACH.strBankName ELSE NULL END
	 , strPaymentMethod			= P.strPaymentMethod
	 , strCreditCardNumber		= NULL
	 , intEntityCardInfoId		= NULL
	 , strCardType				= NULL
	 , dblConvenienceFee		= CAST(0 AS NUMERIC(18, 6))
	 , strConvenienceFeeType	= NULL
	 , ysnExemptCreditCardFee	= CAST(1 AS BIT)
FROM tblSMPaymentMethod P
OUTER APPLY (
	SELECT intEntityId
		 , intBankId
		 , intBankAccountId
		 , strBankName
	FROM tblEMEntityEFTInformation EFT
	CROSS APPLY (
		SELECT TOP 1 intBankAccountId
		FROM tblCMBankAccount BA 
		WHERE EFT.intBankId = BA.intBankId 
	) BA
	WHERE strPaymentMethod = 'ACH'
) ACH
WHERE strPaymentMethod IN ('ACH')
  AND ysnActive = 1

UNION ALL

SELECT intPaymentMethodId		= 11
	 , intEntityCustomerId		= ECI.intEntityId
	 , intBankId				= NULL
	 , intBankAccountId			= NULL
	 , strBankName				= NULL
	 , strPaymentMethod			= 'Credit Card'
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
FROM tblARCustomer C
CROSS APPLY (
	SELECT TOP 1 ECI.*
	FROM tblEMEntityCardInformation ECI
	WHERE ECI.intEntityId = C.intEntityId
	ORDER BY dtmDateCreated desc
) ECI
OUTER APPLY (
	SELECT TOP 1 dblVisaPercentage
			   , dblMastercardPercentage
			   , dblAmericanExpressPercentage
			   , dblDiscoverPercentage
			   , dblDinersClubPercentage
			   , dblChinaUnionPayPercentage
			   , strCreditCardConvenienceFee
	FROM tblSMCompanyPreference
) CP
WHERE ECI.strToken IS NOT NULL
  AND DATEADD(MONTH, 1 , CAST(REPLACE(ECI.strCardExpDate,'/','/01/') AS DATETIME)) > CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
  AND ECI.ysnActive = 1