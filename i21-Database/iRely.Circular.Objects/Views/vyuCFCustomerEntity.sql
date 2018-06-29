CREATE VIEW dbo.vyuCFCustomerEntity
AS
SELECT        Entity.intEntityId, Entity.strName, CASE WHEN Cus.strCustomerNumber = '' THEN Entity.strEntityNo ELSE Cus.strCustomerNumber END AS strCustomerNumber, Cus.strType, 
                         Con.strPhone, Entity.strAddress, Entity.strCity, Entity.strState, Entity.strZipCode, Cus.ysnActive, Cus.intSalespersonId, Cus.intCurrencyId, Loc.intTermsId, Loc.intShipViaId, 
                         ShipToLoc.strLocationName AS strShipToLocationName, ShipToLoc.strAddress AS strShipToAddress, ShipToLoc.strCity AS strShipToCity, ShipToLoc.strState AS strShipToState, 
                         ShipToLoc.strZipCode AS strShipToZipCode, ShipToLoc.strCountry AS strShipToCountry, BillToLoc.strLocationName AS strBillToLocationName, BillToLoc.strAddress AS strBillToAddress, 
                         BillToLoc.strCity AS strBillToCity, BillToLoc.strState AS strBillToState, BillToLoc.strZipCode AS strBillToZipCode, BillToLoc.strCountry AS strBillToCountry
FROM            dbo.vyuEMSearch AS Entity INNER JOIN
                         dbo.tblARCustomer AS Cus ON Entity.intEntityId = Cus.[intEntityId] INNER JOIN
                         dbo.[tblEMEntityToContact] AS CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId AND CusToCon.ysnDefaultContact = 1 LEFT OUTER JOIN
                         dbo.tblEMEntity AS Con ON CusToCon.intEntityContactId = Con.intEntityId LEFT OUTER JOIN
                         dbo.[tblEMEntityLocation] AS Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId LEFT OUTER JOIN
                         dbo.[tblEMEntityLocation] AS ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId LEFT OUTER JOIN
                         dbo.[tblEMEntityLocation] AS BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId