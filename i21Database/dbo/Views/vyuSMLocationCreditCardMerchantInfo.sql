CREATE VIEW [dbo].[vyuSMLocationCreditCardMerchantInfo]
	AS SELECT        intCompanyLocationId, strPaymentServer, strMerchantId, dbo.fnAESDecryptASym(strMerchantPassword) AS strMerchantPassword,
	strCreditCardProcessingType, ysnEnableCreditCardProcessing, strPaymentPortal, strPaymentExternalLink
	FROM	dbo.tblSMCompanyLocation
