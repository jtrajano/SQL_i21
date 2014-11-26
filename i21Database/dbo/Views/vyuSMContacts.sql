CREATE VIEW [dbo].[vyuSMContacts]
AS
SELECT     dbo.vyuARCustomerContacts.intCustomerId, dbo.vyuARCustomerContacts.intEntityId, dbo.vyuARCustomerContacts.intContactId, dbo.vyuARCustomerContacts.strName, 
           dbo.vyuARCustomerContacts.strEmail, dbo.vyuARCustomerContacts.strLocationName, dbo.vyuARCustomerContacts.strPhone, dbo.vyuARCustomerContacts.strTimezone, 
           dbo.vyuARCustomerContacts.strTitle, dbo.vyuARCustomerContacts.ysnPortalAccess, dbo.vyuARCustomerContacts.ysnDefaultContact, dbo.tblEntityCredential.strUserName, 
           dbo.tblEntityCredential.strPassword
FROM       dbo.vyuARCustomerContacts INNER JOIN
           dbo.tblEntityCredential ON dbo.vyuARCustomerContacts.intEntityId = dbo.tblEntityCredential.intEntityId
