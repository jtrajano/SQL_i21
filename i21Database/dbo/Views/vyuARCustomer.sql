CREATE VIEW [dbo].[vyuARCustomer]
AS
SELECT     
 Entity.intEntityId
,Entity.strName
,Cus.strCustomerNumber
,Con.strPhone
,Loc.strAddress
,Loc.strCity
,Loc.strState
,Loc.strZipCode 
FROM tblEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.intEntityId
INNER JOIN tblARCustomerToContact as CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
LEFT JOIN tblEntityContact as Con ON CusToCon.intContactId = Con.intContactId
LEFT JOIN tblEntityLocation as Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
