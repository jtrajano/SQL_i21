CREATE VIEW [dbo].[vyuSMCompanyCreditCardMerchantInfo]
	AS SELECT intCompanyPreferenceId, strPaymentServer, strMerchantId, dbo.fnAESDecryptASym(strMerchantPassword) AS strMerchantPassword,
			strCreditCardProcessingType, ysnEnableCreditCardProcessing, strPaymentPortal, strPaymentExternalLink
	FROM	dbo.tblSMCompanyPreference
