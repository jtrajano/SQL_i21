CREATE VIEW [dbo].[vyuSMLocationCreditCardMerchantInfo]
AS 
SELECT intCompanyLocationId
,strMerchantId
,dbo.fnAESDecryptASym(strMerchantPassword) AS strMerchantPassword
FROM
tblSMCompanyLocation
