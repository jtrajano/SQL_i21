CREATE VIEW [dbo].[vyuAGGetApplicationMethodDetail]
AS

SELECT 
MD.intApplicationMethodDetailId
,MD.intApplicationMethodId
,MD.intProductMixerId
,MD.strStagingLocationType
,MD.intStagingLocationId
,MD.intProductionStagingLocationId
,MD.ysnDefault
,PM.strMixerNumber
,PM.intLocationId
,strStorageStagingLocationName = STAGE_LOCATION.strName
,strStorageProductionStagingLocationName  = PRODUCTION_LOCATION.strName
,MD.intConcurrencyId

FROM tblAGApplicationMethodDetail MD
LEFT JOIN tblAGProductMixer PM ON PM.intProductMixerId = MD.intProductMixerId
LEFT JOIN tblICStorageLocation STAGE_LOCATION ON STAGE_LOCATION.intStorageLocationId = MD.intStagingLocationId
LEFT JOIN tblICStorageLocation PRODUCTION_LOCATION ON PRODUCTION_LOCATION.intStorageLocationId = MD.intProductionStagingLocationId
