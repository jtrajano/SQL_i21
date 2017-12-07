CREATE VIEW vyuMFStorageUnit
AS
SELECT SL.intStorageLocationId
	,SL.strName
	,SL.strDescription
	,SL.intLocationId
	,UT.strInternalCode
	,CL.strLocationName
FROM tblICStorageLocation SL
JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
