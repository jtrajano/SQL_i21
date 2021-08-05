CREATE VIEW [dbo].[vyuTRShipViaTariff]
AS 
SELECT TA.intEntityTariffId
, TA.intEntityId
, SV.strShipVia
, TA.strDescription strTariffDescription
, TA.dtmEffectiveDate dtmTariffEffectiveDate
, TA.intEntityTariffTypeId
, TT.strTariffType strTariffType
, TC.intEntityTariffCategoryId
, TC.intCategoryId
, CC.strCategoryCode strCategoryCode
, FS.intEntityTariffFuelSurchargeId
, FS.dblFuelSurcharge
, FS.dtmEffectiveDate
FROM tblEMEntityTariff TA 
INNER JOIN tblSMShipVia SV ON SV.intEntityId = TA.intEntityId
LEFT JOIN tblEMEntityTariffType TT ON TT.intEntityTariffTypeId = TA.intEntityTariffTypeId
LEFT JOIN tblEMEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId
LEFT JOIN tblICCategory CC ON CC.intCategoryId = TC.intCategoryId
LEFT JOIN tblEMEntityTariffFuelSurcharge FS ON FS.intEntityTariffId = TC.intEntityTariffId