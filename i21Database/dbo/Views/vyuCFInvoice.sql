CREATE VIEW [dbo].[vyuCFInvoice]
AS
SELECT        INV.intEntityCustomerId, INV.intEntityId, C.strCustomerNumber, dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, 
                         INV.strShipToZipCode, INV.strShipToCountry, NULL, 0) AS strShipTo, dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, 
                         INV.strBillToZipCode, INV.strBillToCountry, E.strName, 0) AS strBillTo, CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE
                             (SELECT        TOP 1 strCompanyName
                               FROM            tblSMCompanySetup) END AS strCompanyName, CASE WHEN L.strUseLocationAddress IS NULL OR
                         L.strUseLocationAddress = 'No' OR
                         L.strUseLocationAddress = '' OR
                         L.strUseLocationAddress = 'Always' THEN
                             (SELECT        TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, 0)
                               FROM            tblSMCompanySetup) WHEN L.strUseLocationAddress = 'Yes' THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, L.strZipPostalCode, 
                         L.strCountry, NULL, NULL) WHEN L.strUseLocationAddress = 'Letterhead' THEN '' END AS strCompanyAddress, ISNULL(INV.strType, 'Standard') AS strType, E.strName AS strCustomerName, L.strLocationName, 
                         INV.intInvoiceId, INV.strInvoiceNumber, INV.intTransactionId, INV.dtmDate, INV.dtmPostDate
FROM            dbo.tblARInvoice AS INV INNER JOIN
                         dbo.tblARCustomer AS C INNER JOIN
                         dbo.tblEMEntity AS E ON C.intEntityCustomerId = E.intEntityId ON C.intEntityCustomerId = INV.intEntityCustomerId INNER JOIN
                         dbo.tblSMCompanyLocation AS L ON INV.intCompanyLocationId = L.intCompanyLocationId

