CREATE VIEW [dbo].[vyuTMCompanySiteDevice]
	AS 
SELECT SD.intCompanySiteDeviceId,
SD.intCompanyConsumptionSiteId, 
SD.intDeviceId,
D.strSerialNumber,
D.dblTankCapacity,
D.dblTankReserve,
D.strDescription,
SD.intConcurrencyId,
D.intDeviceTypeId,
DT.strDeviceType,
D.strManufacturerName,
D.ysnAppliance,
D.intApplianceTypeID,
AT.strApplianceType
FROM tblTMCompanySiteDevice SD
INNER JOIN tblTMCompanyConsumptionSite CS ON CS.intCompanyConsumptionSiteId = SD.intCompanyConsumptionSiteId
INNER JOIN tblTMDevice D ON D.intDeviceId = SD.intDeviceId
LEFT JOIN tblTMDeviceType DT ON DT.intDeviceTypeId = D.intDeviceTypeId
LEFT JOIN tblTMApplianceType AT ON AT.intApplianceTypeID = D.intApplianceTypeID

