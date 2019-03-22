CREATE VIEW [dbo].[vyuSMLocationCreditCardMerchantInfo]
AS 
SELECT intCompanyLocationId
,ysnEnableCreditCardProcessing
,strMerchantId
,dbo.fnAESDecryptASym(strMerchantPassword) COLLATE Latin1_General_CI_AS AS strMerchantPassword
FROM
tblSMCompanyLocation
