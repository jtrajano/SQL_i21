CREATE VIEW dbo.vyuCFCustomerEntity
AS
SELECT     Entity.intEntityId, Cus.intEntityCustomerId, Entity.strName, 
                      CASE WHEN Cus.strCustomerNumber = '' THEN Entity.strEntityNo ELSE Cus.strCustomerNumber END AS strCustomerNumber, Cus.strType, Con.strPhone, 
                      Loc.strAddress, Loc.strCity, Loc.strState, Loc.strZipCode, Cus.ysnActive, Cus.intSalespersonId, Cus.intCurrencyId, Loc.intTermsId, Loc.intShipViaId, 
                      ShipToLoc.strLocationName AS strShipToLocationName, ShipToLoc.strAddress AS strShipToAddress, ShipToLoc.strCity AS strShipToCity, 
                      ShipToLoc.strState AS strShipToState, ShipToLoc.strZipCode AS strShipToZipCode, ShipToLoc.strCountry AS strShipToCountry, 
                      BillToLoc.strLocationName AS strBillToLocationName, BillToLoc.strAddress AS strBillToAddress, BillToLoc.strCity AS strBillToCity, 
                      BillToLoc.strState AS strBillToState, BillToLoc.strZipCode AS strBillToZipCode, BillToLoc.strCountry AS strBillToCountry
FROM         dbo.tblEntity AS Entity INNER JOIN
                      dbo.tblARCustomer AS Cus ON Entity.intEntityId = Cus.intEntityCustomerId INNER JOIN
                      dbo.tblEntityToContact AS CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId AND CusToCon.ysnDefaultContact = 1 LEFT OUTER JOIN
                      dbo.tblEntity AS Con ON CusToCon.intEntityContactId = Con.intEntityId LEFT OUTER JOIN
                      dbo.tblEntityLocation AS Loc ON Cus.intDefaultLocationId = Loc.intEntityLocationId LEFT OUTER JOIN
                      dbo.tblEntityLocation AS ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId LEFT OUTER JOIN
                      dbo.tblEntityLocation AS BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
