CREATE VIEW [dbo].[vyuSMContacts]
AS
SELECT     dbo.vyuEMEntityContact.intEntityId, dbo.vyuEMEntityContact.[intEntityContactId], dbo.vyuEMEntityContact.strName, 
           dbo.vyuEMEntityContact.strEmail, dbo.vyuEMEntityContact.strLocationName, dbo.vyuEMEntityContact.strPhone, dbo.vyuEMEntityContact.strTimezone, 
           dbo.vyuEMEntityContact.strTitle, dbo.vyuEMEntityContact.ysnPortalAccess, dbo.vyuEMEntityContact.ysnDefaultContact, dbo.[tblEMEntityCredential].strUserName, 
           dbo.[tblEMEntityCredential].strPassword
FROM       dbo.vyuEMEntityContact 
INNER JOIN
           dbo.[tblEMEntityCredential] ON dbo.vyuEMEntityContact.[intEntityContactId] = dbo.[tblEMEntityCredential].intEntityId
