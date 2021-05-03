CREATE VIEW [dbo].[vyuRestApiEntityUsers]
AS
SELECT
    Contact.intEntityId,
	NULLIF(Contact.strEmail, '') strEmail,
    Contact.strName,
	Security.strUserName, 
	EntityContact.ysnPortalAccess, 
	EntityContact.ysnPortalAdmin, 
	Security.ysnAdmin, 
	Contact.ysnActive,
	EntityContact.intEntityLocationId
FROM tblEMEntityToContact EntityContact
JOIN tblEMEntity Contact ON EntityContact.intEntityContactId = Contact.intEntityId
JOIN tblSMUserSecurity Security ON EntityContact.intEntityId = Security.intEntityId
JOIN tblEMEntityCredential Credential ON Credential.intEntityId = EntityContact.intEntityId
JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = EntityContact.intEntityId
	AND EntityLocation.intEntityLocationId = EntityContact.intEntityLocationId
JOIN tblEMEntityType EntityType ON EntityType.intEntityId = EntityContact.intEntityId
	AND EntityType.strType = 'User'
WHERE EntityContact.ysnDefaultContact = 1