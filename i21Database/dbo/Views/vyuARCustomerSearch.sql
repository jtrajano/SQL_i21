	CREATE VIEW [dbo].[vyuARCustomerSearch]
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
,Loc.intFreightTermId
,strSalespersonId =  case when ISNULL(S.strSalespersonId,'') = '' then T.strEntityNo else S.strSalespersonId end
,ysnPORequired
,intTaxGroupId = Loc.intTaxGroupId 
,strTaxGroup = Tax.strTaxGroup
,Cus.strVatNumber
,Cus.strFLOId
,Cus.dtmMembershipDate
,Cus.dtmBirthDate
,strSalesPersonName = T.strName
,Cus.dblCreditLimit
,Cus.dblARBalance
,Cus.dtmLastActivityDate
,Cus.strStockStatus
,ysnHasBudgetSetup = cast(case when (select top 1 1 from tblARCustomerBudget where intEntityCustomerId = Cus.intEntityCustomerId) = 1 then 1 else 0 end as bit)
,CusToCon.intEntityContactId
,Cus.ysnIncludeEntityName
FROM tblEMEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]
LEFT JOIN [tblEMEntityToContact] as CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
--LEFT JOIN tblEMEntityContact as Con ON CusToCon.[intEntityContactId] = Con.[intEntityContactId]
LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]
LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.intEntityCustomerId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
LEFT JOIN tblARSalesperson S ON Cus.intSalespersonId = S.intEntitySalespersonId
LEFT JOIN tblEMEntity T on S.intEntitySalespersonId = T.intEntityId
LEFT JOIN tblSMTaxGroup Tax ON Loc.intTaxGroupId = Tax.intTaxGroupId
