CREATE VIEW [dbo].[vyuARCustomer]
AS
SELECT     
 Entity.intEntityId
,Cus.intCustomerId
,Entity.strName
,Cus.strCustomerNumber
,Con.strPhone
,Loc.strAddress
,Loc.strCity
,Loc.strState
,Loc.strZipCode 
,Cus.ysnActive
,Cus.intSalespersonId
,Cus.intCurrencyId
,Loc.intTermsId
,Loc.intShipViaId
,ShipToLoc.strAddress as strShipToAddress
,ShipToLoc.strCity as strShipToCity
,ShipToLoc.strState as strShipToState
,ShipToLoc.strZipCode as strShipToZipCode
,ShipToLoc.strCountry as strShipToCountry
,BillToLoc.strAddress as strBillToAddress
,BillToLoc.strCity as strBillToCity
,BillToLoc.strState as strBillToState
,BillToLoc.strZipCode as strBillToZipCode
,BillToLoc.strCountry as strBillToCountry
FROM tblEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.intEntityId
INNER JOIN tblARCustomerToContact as CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
LEFT JOIN tblEntityContact as Con ON CusToCon.intContactId = Con.intContactId
LEFT JOIN tblEntityLocation as Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId
LEFT JOIN tblEntityLocation as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN tblEntityLocation as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId

