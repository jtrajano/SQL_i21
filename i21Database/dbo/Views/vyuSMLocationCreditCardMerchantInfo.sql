CREATE VIEW [dbo].[vyuSMLocationCreditCardMerchantInfo]
AS 
SELECT intCompanyLocationId
,ysnEnableCreditCardProcessing
,strMerchantId
,dbo.fnAESDecryptASym(strMerchantPassword) AS strMerchantPassword
FROM
tblSMCompanyLocation
