CREATE VIEW [dbo].[vyuApiEntitySearch]
AS
SELECT
      intEntityId
    , strEntityNo
    , strName
    , strPhone
    , strAddress
    , strCity
    , strState
    , strCountry
    , strTerm
    , strLocationName
    , strPhone1
    , strPhone2
    , strZipCode
    , intWarehouseId
    , CAST(CASE Customer WHEN 1 THEN 1 ELSE 0 END AS BIT) IsCustomer
    , CAST(CASE Vendor WHEN 1 THEN 1 ELSE 0 END AS BIT) IsVendor
    , CAST(CASE Employee WHEN 1 THEN 1 ELSE 0 END AS BIT) IsEmployee
    , CAST(CASE Salesperson WHEN 1 THEN 1 ELSE 0 END AS BIT) IsSalesperson
    , CAST(CASE User WHEN 1 THEN 1 ELSE 0 END AS BIT) IsUser
    , CAST(CASE FuturesBroker WHEN 1 THEN 1 ELSE 0 END AS BIT) IsFuturesBroker
    , CAST(CASE ForwardingAgent WHEN 1 THEN 1 ELSE 0 END AS BIT) IsForwardingAgent
    , CAST(CASE Terminal WHEN 1 THEN 1 ELSE 0 END AS BIT) IsTerminal
    , CAST(CASE ShippingLine WHEN 1 THEN 1 ELSE 0 END AS BIT) IsShippingLine
    , CAST(CASE Trucker WHEN 1 THEN 1 ELSE 0 END AS BIT) IsTrucker
    , CAST(CASE Insurer WHEN 1 THEN 1 ELSE 0 END AS BIT) IsInsurer
    , CAST(CASE ShipVia WHEN 1 THEN 1 ELSE 0 END AS BIT) IsShipVia
    , CAST(CASE Applicator WHEN 1 THEN 1 ELSE 0 END AS BIT) IsApplicator
    , CAST(CASE VendorOrCustomer WHEN 1 THEN 1 ELSE 0 END AS BIT) IsVendorOrCustomer
    , strFederalTaxId
    , strDefaultEntityType
FROM vyuEMSearch