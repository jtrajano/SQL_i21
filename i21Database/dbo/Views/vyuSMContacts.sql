CREATE VIEW [dbo].[vyuSMContacts]
AS
SELECT     dbo.vyuEMEntityContact.intEntityId, dbo.vyuEMEntityContact.[intEntityContactId], dbo.vyuEMEntityContact.strName, 
           dbo.vyuEMEntityContact.strEmail, dbo.vyuEMEntityContact.strLocationName, dbo.vyuEMEntityContact.strPhone, dbo.vyuEMEntityContact.strTimezone, 
           dbo.vyuEMEntityContact.strTitle, dbo.vyuEMEntityContact.ysnPortalAccess, dbo.vyuEMEntityContact.ysnDefaultContact, dbo.tblEntityCredential.strUserName, 
           dbo.tblEntityCredential.strPassword
FROM       dbo.vyuEMEntityContact 
INNER JOIN
           dbo.tblEntityCredential ON dbo.vyuEMEntityContact.[intEntityContactId] = dbo.tblEntityCredential.intEntityId
