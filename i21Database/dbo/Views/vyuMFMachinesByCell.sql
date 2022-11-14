﻿CREATE VIEW vyuMFMachinesByCell
AS
SELECT DISTINCT M.intMachineId
			  , M.strName
			  , C.intManufacturingCellId
			  , M.intSubLocationId
			  , CLSL.strSubLocationName
			  , M.intLocationId
			  , CompanyLocation.strLocationName AS strCompanyLocationName
FROM tblMFMachine M
JOIN tblMFMachinePackType MP ON MP.intMachineId = M.intMachineId
JOIN tblMFManufacturingCellPackType CP ON CP.intPackTypeId = MP.intPackTypeId
JOIN tblMFManufacturingCell C ON C.intManufacturingCellId = CP.intManufacturingCellId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = M.intSubLocationId
LEFT JOIN tblSMCompanyLocation CompanyLocation ON M.intLocationId = CompanyLocation.intCompanyLocationId