CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT 
B2.intEntityId, 
B2.strName, 
B2.strEmail, 
E.strLocationName, 
D.strPhone, 
D.strTimezone, 
D.strTitle, 
D.ysnPortalAccess
FROM dbo.tblARCustomer AS A 
INNER JOIN dbo.tblEntity AS B ON A.intEntityId = B.intEntityId 
INNER JOIN dbo.tblEntityToContact AS C ON B.intEntityId = C.intEntityId 
INNER JOIN dbo.tblEntity AS B2 ON C.intContactId = B2.intEntityId 
INNER JOIN dbo.tblEntityContact AS D ON B2.intEntityId = D.intEntityId 
LEFT OUTER JOIN dbo.tblEntityLocation AS E ON C.intLocationId = E.intEntityLocationId