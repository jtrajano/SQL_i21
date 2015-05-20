﻿CREATE VIEW [dbo].[vyuARCustomerSearch]
AS
SELECT     
 Entity.intEntityId
,Cus.[intEntityCustomerId]
,Entity.strName
,strCustomerNumber= case when Cus.strCustomerNumber = '' then Entity.strEntityNo else Cus.strCustomerNumber end 
,Con.strPhone
,Loc.strAddress
,Loc.strCity
,Loc.strState
,Loc.strZipCode
,Cus.ysnTaxExempt 
,Cus.ysnActive
,Cus.intSalespersonId
,Cus.intCurrencyId
,Loc.intTermsId
,Loc.intShipViaId
,ShipToLoc.strLocationName as strShipToLocationName
,ShipToLoc.strAddress as strShipToAddress
,ShipToLoc.strCity as strShipToCity
,ShipToLoc.strState as strShipToState
,ShipToLoc.strZipCode as strShipToZipCode
,ShipToLoc.strCountry as strShipToCountry
,BillToLoc.strLocationName as strBillToLocationName
,BillToLoc.strAddress as strBillToAddress
,BillToLoc.strCity as strBillToCity
,BillToLoc.strState as strBillToState
,BillToLoc.strZipCode as strBillToZipCode
,BillToLoc.strCountry as strBillToCountry
,Cus.intShipToId
,Cus.intBillToId 
FROM tblEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]
LEFT JOIN tblEntityToContact as CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
--LEFT JOIN tblEntityContact as Con ON CusToCon.[intEntityContactId] = Con.[intEntityContactId]
LEFT JOIN tblEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]
LEFT JOIN tblEntityLocation as Loc ON Cus.intEntityCustomerId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
LEFT JOIN tblEntityLocation as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN tblEntityLocation as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
