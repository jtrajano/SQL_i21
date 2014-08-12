CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT 
A.intEntityId AS intCustomerEntityId,
D.intEntityId, 
B2.strName, 
B2.strEmail, 
E.strLocationName, 
D.strPhone, 
D.strTimezone, 
D.strTitle, 
C.ysnPortalAccess
FROM dbo.tblARCustomer AS A 
INNER JOIN dbo.tblARCustomerToContact AS C ON A.intCustomerId = C.intCustomerId  
INNER JOIN dbo.tblEntityContact AS D ON C.intContactId = D.intContactId 
INNER JOIN dbo.tblEntity AS B2 ON D.intEntityId = B2.intEntityId
LEFT OUTER JOIN dbo.tblEntityLocation AS E ON C.intEntityLocationId = E.intEntityLocationId