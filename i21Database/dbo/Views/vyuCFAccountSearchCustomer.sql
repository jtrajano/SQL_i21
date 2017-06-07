CREATE VIEW dbo.vyuCFAccountSearchCustomer
AS
SELECT     [intEntityId], strName, strCustomerNumber, strType, strPhone, strAddress, strCity, strState, strZipCode, ysnActive, intSalespersonId, intCurrencyId, 
                      intTermsId, intShipViaId, strShipToLocationName, strShipToAddress, strShipToCity, strShipToState, strShipToZipCode, strShipToCountry, strBillToLocationName, 
                      strBillToAddress, strBillToCity, strBillToState, strBillToZipCode, strBillToCountry
FROM         dbo.vyuCFCustomerEntity
WHERE     ([intEntityId] NOT IN
                          (SELECT     intCustomerId
                            FROM          dbo.tblCFAccount))
