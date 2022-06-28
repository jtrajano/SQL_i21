print('/*******************  BEGIN Update tblARCompanyPreference *******************/')
GO

IF EXISTS(SELECT TOP 1 strCreditCardProcessingType FROM tblARCompanyPreference WHERE strCreditCardProcessingType IS NULL)
BEGIN
	UPDATE ARCP
	SET  ARCP.strCreditCardProcessingType	= SMCP.strCreditCardProcessingType
		,ARCP.ysnEnableCreditCardProcessing	= SMCP.ysnEnableCreditCardProcessing
		,ARCP.strMerchantId					= SMCP.strMerchantId
		,ARCP.strMerchantPassword			= SMCP.strMerchantPassword
		,ARCP.strPaymentServer				= SMCP.strPaymentServer
		,ARCP.strPaymentExternalLink		= SMCP.strPaymentExternalLink
		,ARCP.strPaymentPortal				= SMCP.strPaymentPortal
		,ARCP.strCreditCardConvenienceFee	= SMCP.strCreditCardConvenienceFee
		,ARCP.dblVisaPercentage				= SMCP.dblVisaPercentage
		,ARCP.dblMastercardPercentage		= SMCP.dblMastercardPercentage
		,ARCP.dblAmericanExpressPercentage	= SMCP.dblAmericanExpressPercentage
		,ARCP.dblDiscoverPercentage			= SMCP.dblDiscoverPercentage
		,ARCP.dblDinersClubPercentage		= SMCP.dblDinersClubPercentage
		,ARCP.dblChinaUnionPayPercentage	= SMCP.dblChinaUnionPayPercentage
		,ARCP.dblVisaFixedAmount			= SMCP.dblVisaFixedAmount
		,ARCP.dblMastercardFixedAmount		= SMCP.dblMastercardFixedAmount
		,ARCP.dblAmericanExpressFixedAmount	= SMCP.dblAmericanExpressFixedAmount
		,ARCP.dblDiscoverFixedAmount		= SMCP.dblDiscoverFixedAmount
		,ARCP.dblDinersClubFixedAmount		= SMCP.dblDinersClubFixedAmount
		,ARCP.dblChinaUnionPayFixedAmount	= SMCP.dblChinaUnionPayFixedAmount
		,ARCP.intFeeGeneralLedgerAccountId	= SMCP.intFeeGeneralLedgerAccountId
		,ARCP.intPaymentsLocationId			= SMCP.intPaymentsLocationId
	FROM tblARCompanyPreference ARCP
	OUTER APPLY (
		SELECT TOP 1 strCreditCardProcessingType
			,ysnEnableCreditCardProcessing
			,strMerchantId
			,strMerchantPassword
			,strPaymentServer
			,strPaymentExternalLink
			,strPaymentPortal
			,strCreditCardConvenienceFee
			,dblVisaPercentage
			,dblMastercardPercentage
			,dblAmericanExpressPercentage
			,dblDiscoverPercentage
			,dblDinersClubPercentage
			,dblChinaUnionPayPercentage
			,dblVisaFixedAmount
			,dblMastercardFixedAmount
			,dblAmericanExpressFixedAmount
			,dblDiscoverFixedAmount
			,dblDinersClubFixedAmount
			,dblChinaUnionPayFixedAmount
			,intFeeGeneralLedgerAccountId
			,intPaymentsLocationId
		FROM dbo.tblSMCompanyPreference WITH (NOLOCK)
	) SMCP
END

UPDATE tblARCompanyPreference SET strCreditCardProcessingType = 'Worldpay' WHERE strCreditCardProcessingType IS NULL
UPDATE tblARCompanyPreference SET strCreditCardConvenienceFee = 'Percentage' WHERE strCreditCardConvenienceFee IS NULL
UPDATE tblARCompanyPreference SET dtmCreditCardProcessingTime = '2008-01-01 20:00:00.000' WHERE dtmCreditCardProcessingTime IS NULL

GO
print('/*******************  BEGIN Update tblARCompanyPreference  *******************/')