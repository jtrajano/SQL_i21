CREATE VIEW [dbo].[vyuMFLocationLeadTime]  

AS  

SELECT 

[intLocationLeadTimeId],
[intOriginId],
[strOrigin],
[intBuyingCenterId],
[strBuyingCenter] = LOC.strLocationName,
[intReceivingPlantId], 
[strReceivingPlant],
[intReceivingStorageLocation],
[strReceivingStorageLocation] = SLOC.strSubLocationName,
[intChannelId],
[strChannel] = MZ.strMarketZoneCode,
[intPortOfDispatchId],
[strPortOfDispatch],
[intPortOfArrivalId],
[strPortOfArrival],
[dblPurchaseToShipment],
[dblPortToPort],
[dblPortToMixingUnit],
[dblMUToAvailableForBlending],
[intEntityId] = LLT.intEntityId

FROM 
tblMFLocationLeadTime LLT

INNER JOIN tblSMCompanyLocation LOC ON LLT.intBuyingCenterId = LOC.intCompanyLocationId
INNER JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=LLT.intReceivingStorageLocation
INNER JOIN tblARMarketZone MZ ON MZ.intMarketZoneId=LLT.intChannelId
LEFT JOIN tblSMCompanyLocation RLOC ON SLOC.intCompanyLocationId = RLOC.intCompanyLocationId
