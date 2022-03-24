CREATE VIEW [dbo].[vyuApiIRelyUser]
AS
SELECT
	  ec.intEntityId
	, ec.strUserName
    , ec.intEntityCredentialId
	, e.strName
	, Contact.strEmail
	, Contact.strPhone
	, Contact.strMobile
	, Contact.strTimezone
	, Contact.strTitle
	, Contact.strSuffix
	, Contact.strWebsite
	, EntityLocation.strCity
	, EntityLocation.strCountry
	, EntityLocation.strAddress
	, EntityLocation.strLocationName
	, EntityLocation.dblLatitude
	, EntityLocation.dblLongitude
	, EntityLocation.strCounty
	, EntityLocation.strState
	, EntityLocation.strZipCode
	, EntityLocation.strNotes
FROM tblEMEntityCredential ec
JOIN vyuEMEntity e ON e.intEntityId = ec.intEntityId
JOIN tblEMEntityToContact EntityContact ON EntityContact.intEntityId = ec.intEntityId
JOIN tblEMEntity Contact ON EntityContact.intEntityContactId = Contact.intEntityId
JOIN tblSMUserSecurity Sec ON EntityContact.intEntityId = Sec.intEntityId
JOIN tblEMEntityCredential Cre ON Cre.intEntityId = EntityContact.intEntityId
JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = EntityContact.intEntityId
	AND EntityLocation.intEntityLocationId = EntityContact.intEntityLocationId
JOIN tblEMEntityType EntityType ON EntityType.intEntityId = EntityContact.intEntityId
	AND EntityType.strType = 'User'
WHERE EntityContact.ysnDefaultContact = 1