CREATE VIEW [dbo].[vyuSMCompanyCreditCardMerchantInfo]
AS 
SELECT 
	 intCompanyPreferenceId
	,strPaymentServer
	,strMerchantId
	,dbo.fnAESDecryptASym(strMerchantPassword) COLLATE Latin1_General_CI_AS AS strMerchantPassword
	,strCreditCardProcessingType
	,ysnEnableCreditCardProcessing
	,strPaymentPortal
	,strPaymentExternalLink
	,[strExpressAccountID]
	,strExpressAccountToken
	,[strExpressAcceptorID]
	,[strExpressApplicationID]
FROM tblARCompanyPreference
