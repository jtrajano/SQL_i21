﻿CREATE VIEW [dbo].[vyuARCustomer]
AS
SELECT     
 Entity.intEntityId
,Cus.[intEntityCustomerId]
,Entity.strName
,strCustomerNumber= case when Cus.strCustomerNumber = '' then Entity.strEntityNo else Cus.strCustomerNumber end 
,Cus.strType
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
,dblCreditLimit = ISNULL(Cus.dblCreditLimit, 0)
,Cus.strVatNumber
,Con.strPhone as strPhone1
,Con.strPhone2 as strPhone2
,Loc.strCountry
,Loc.strLocationName
,ysnHasBudgetSetup = cast(case when (select top 1 1 from tblARCustomerBudget where intEntityCustomerId = Cus.intEntityCustomerId) = 1 then 1 else 0 end as bit)
FROM tblEMEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]
INNER JOIN [tblEMEntityToContact] as CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
--INNER JOIN tblARCustomerToContact as CusToCon ON Cus.intDefaultContactId = CusToCon.intARCustomerToContactId
--LEFT JOIN tblEntityContact as Con ON CusToCon.[intEntityContactId] = Con.[intEntityContactId]
LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]
LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.intEntityCustomerId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId