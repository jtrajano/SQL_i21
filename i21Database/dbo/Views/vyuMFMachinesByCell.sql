CREATE VIEW vyuMFMachinesByCell
AS
SELECT DISTINCT Machine.intMachineId
			  , Machine.strName
			  , Machine.intSubLocationId
			  , Machine.intLocationId
			  , Machine.intIssuedUOMTypeId
			  , MachineIssuedUOM.strName AS strIssuedUOMType
			  , Cell.intManufacturingCellId
			  , CompanySubLocation.strSubLocationName
			  , CompanyLocation.strLocationName AS strCompanyLocationName
FROM tblMFMachine AS Machine
JOIN tblMFMachinePackType AS MachinePackType ON MachinePackType.intMachineId = Machine.intMachineId
JOIN tblMFManufacturingCellPackType AS CellPackType ON CellPackType.intPackTypeId = MachinePackType.intPackTypeId
JOIN tblMFManufacturingCell AS Cell ON Cell.intManufacturingCellId = CellPackType.intManufacturingCellId
LEFT JOIN tblMFMachineIssuedUOMType AS MachineIssuedUOM ON Machine.intIssuedUOMTypeId = MachineIssuedUOM.intIssuedUOMTypeId
LEFT JOIN tblSMCompanyLocationSubLocation AS CompanySubLocation ON CompanySubLocation.intCompanyLocationSubLocationId = Machine.intSubLocationId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON Machine.intLocationId = CompanyLocation.intCompanyLocationId