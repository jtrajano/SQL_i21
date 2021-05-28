
CREATE VIEW [dbo].[vyuAGGetStorageLocation]
AS
SELECT intStorageLocationId,
strName + ' - ' + CSL.strSubLocationName as strSubLocationName 
,SL.intLocationId AS intLocationId
,UT.strInternalCode
FROM dbo.tblICStorageLocation SL 
JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId 
JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId 



