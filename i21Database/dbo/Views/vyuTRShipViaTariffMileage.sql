CREATE VIEW [dbo].[vyuTRShipViaTariffMileage]
AS 
SELECT TA.intEntityTariffId
, TA.intEntityId
, SV.strShipVia
, TA.strDescription strTariffDescription
, TA.dtmEffectiveDate dtmTariffEffectiveDate
, TA.intEntityTariffTypeId
, TT.strTariffType strTariffType
, FM.intEntityTarifffMileageId
, FM.intFromMiles
, FM.intToMiles
, FM.dblCostRatePerUnit
, FM.dblInvoiceRatePerUnit
, FC.intEntityTariffCategoryId
, CC.strCategoryCode
FROM tblEMEntityTariff TA 
INNER JOIN tblSMShipVia SV ON SV.intEntityId = TA.intEntityId
LEFT JOIN tblEMEntityTariffType TT ON TT.intEntityTariffTypeId = TA.intEntityTariffTypeId
LEFT JOIN tblEMEntityTariffMileage FM ON FM.intEntityTariffId = TA.intEntityTariffId
LEFT JOIN tblEMEntityTariffCategory FC ON FC.intEntityTariffId = TA.intEntityTariffId
LEFT JOIN tblICCategory CC ON FC.intCategoryId = CC.intCategoryId