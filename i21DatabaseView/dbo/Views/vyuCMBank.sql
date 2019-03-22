
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
,ISNULL(dbo.fnAESDecryptASym(strRTN), strRTN) COLLATE Latin1_General_CI_AS AS strRTN
,intCreatedUserId
,dtmCreated
,intLastModifiedUserId
,dtmLastModified
,ysnDelete
,dtmDateDeleted
,intConcurrencyId
FROM dbo.tblCMBank