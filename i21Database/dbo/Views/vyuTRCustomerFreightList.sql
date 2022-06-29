CREATE VIEW [dbo].[vyuTRCustomerFreightList]
AS
SELECT DISTINCT CF.intFreightXRefId
, C.intEntityId AS intCustomerId
, EM.strName AS strCustomerName
, CF.intEntityLocationId AS inCustomerLocationId
, EL.strLocationName AS strCustomerLocationName
, CF.strZipCode AS strZipCode
, C.intEntityTariffTypeId AS intEntityTariffTypeId
, TT.strTariffType AS strTariffType
, CF.intCategoryId AS intCategoryId
, CC.strCategoryCode AS strCategoryCode
, CF.ysnFreightOnly AS ysnFreightOnly 
, CF.strFreightType AS strFreightType
, CF.intShipViaId AS intFixedShipViaId
, EMFSV.strName AS strFixedShipViaName
, CF.dblFreightAmount AS dblFreightAmount
, CF.dblFreightRate AS dblFreightRate
, CF.dblFreightMiles AS dblFreightMiles
, CF.ysnFreightInPrice AS ysnFreightInPrice
, CF.dblFreightRateIn AS dblFreightRateIn
, EM.strEntityNo AS strCustomerEntityNo
, CF.dblMinimumUnits AS dblMinimumUnits
, CF.dblMinimumUnitsIn AS dblMinimumUnitsIn
, CF.dblSurchargeOut AS dblSurchargeOut
FROM tblARCustomerFreightXRef CF
INNER JOIN tblARCustomer C ON C.intEntityId = CF.intEntityCustomerId
INNER JOIN tblEMEntity EM ON EM.intEntityId = C.intEntityId
LEFT JOIN tblEMEntityTariffType TT ON TT.intEntityTariffTypeId = CF.intEntityTariffTypeId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityId AND EL.intEntityLocationId = CF.intEntityLocationId
LEFT JOIN tblEMEntityTariff TA ON TA.intEntityTariffTypeId = CF.intEntityTariffTypeId 
LEFT JOIN tblICCategory CC ON CC.intCategoryId = CF.intCategoryId
LEFT JOIN tblSMShipVia FSV ON FSV.intEntityId = CF.intShipViaId
LEFT JOIN tblEMEntity EMFSV ON EMFSV.intEntityId = FSV.intEntityId