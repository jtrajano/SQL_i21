
CREATE VIEW [dbo].vyuCMBank
AS 

SELECT        
intBankId
,strBankName
,strContact
,strAddress
,strZipCode
,strCity
,strState
,strCountry
,strPhone
,strFax
,strWebsite
,strEmail
,ISNULL(dbo.fnAESDecryptASym(strRTN), strRTN) AS strRTN
,intCreatedUserId
,dtmCreated
,intLastModifiedUserId
,dtmLastModified
,ysnDelete
,dtmDateDeleted
,intConcurrencyId
FROM dbo.tblCMBank