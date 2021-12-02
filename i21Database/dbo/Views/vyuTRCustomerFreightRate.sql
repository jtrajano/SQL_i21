CREATE VIEW [dbo].[vyuTRCustomerFreightRate]
AS
SELECT DISTINCT CF.intFreightXRefId
, C.intEntityId AS intCustomerId
, EM.strName AS strCustomerName
, CF.intEntityLocationId AS inCustomerLocationId
, EL.strLocationName AS strCustomerLocationName
, CF.strZipCode AS strZipCode
, C.intEntityTariffTypeId AS intEntityTariffTypeId
, TT.strTariffType AS strTariffType
, TA.intEntityId AS intShipViaId
, EMSV.strName AS strShipViaName
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
, SMLOB.strLineOfBusiness AS strLineOfBusiness
, TCN.strTerminalControlNumber
FROM tblARCustomerFreightXRef CF
INNER JOIN tblARCustomer C ON C.intEntityId = CF.intEntityCustomerId
INNER JOIN tblEMEntity EM ON EM.intEntityId = C.intEntityId
INNER JOIN tblEMEntityLineOfBusiness EMELOB ON EM.intEntityId = EMELOB.intEntityId
INNER JOIN tblSMLineOfBusiness SMLOB ON EMELOB.intLineOfBusinessId = SMLOB.intLineOfBusinessId
LEFT JOIN tblEMEntityTariffType TT ON TT.intEntityTariffTypeId = CF.intEntityTariffTypeId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = C.intEntityId AND EL.intEntityLocationId = CF.intEntityLocationId
LEFT JOIN tblEMEntityTariff TA ON TA.intEntityTariffTypeId = CF.intEntityTariffTypeId 
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = TA.intEntityId
LEFT JOIN tblEMEntity EMSV ON EMSV.intEntityId = SV.intEntityId
LEFT JOIN tblICCategory CC ON CC.intCategoryId = CF.intCategoryId
LEFT JOIN tblSMShipVia FSV ON FSV.intEntityId = CF.intShipViaId
LEFT JOIN tblEMEntity EMFSV ON EMFSV.intEntityId = FSV.intEntityId
LEFT JOIN (
    SELECT CN.strTerminalControlNumber, ELV.strZipCode, ELV.strLocationName FROM tblAPVendor V
    INNER JOIN tblEMEntityLocation ELV ON ELV.intEntityId = V.intEntityId
    INNER JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = ELV.intEntityLocationId AND SP.intEntityVendorId = V.intEntityId
    INNER JOIN tblTFTerminalControlNumber CN ON CN.intTerminalControlNumberId = SP.intTerminalControlNumberId
    WHERE V.ysnTransportTerminal = 1
) TCN ON TCN.strZipCode = CF.strZipCode