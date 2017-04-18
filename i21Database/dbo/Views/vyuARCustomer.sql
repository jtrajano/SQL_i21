CREATE VIEW [dbo].[vyuARCustomer]
AS
SELECT     
 Entity.intEntityId

,Entity.strName
,strCustomerNumber= case when Cus.strCustomerNumber = '' then Entity.strEntityNo else Cus.strCustomerNumber end 
,Cus.strType
,EnPhoneNo.strPhone
,Loc.strAddress
,Loc.strCity
,Loc.strState
,Loc.strZipCode 
,Cus.ysnActive
,Cus.intSalespersonId
,Cus.intCurrencyId
,Cus.intTermsId
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
,EnPhoneNo.strPhone as strPhone1
,Con.strPhone2 as strPhone2
,Loc.strCountry
,Loc.strLocationName
,ysnHasBudgetSetup = cast(case when (select top 1 1 from tblARCustomerBudget where intEntityCustomerId = Cus.[intEntityId]) = 1 then 1 else 0 end as bit)
,strDisplayName = Loc.strCheckPayeeName
FROM tblEMEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityId]
INNER JOIN [tblEMEntityToContact] as CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]
LEFT JOIN tblEMEntityPhoneNumber as EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.[intEntityId] = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId