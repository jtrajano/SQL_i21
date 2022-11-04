CREATE VIEW [dbo].[vyuMFLocationLeadTime]  

AS  

SELECT 

[intLocationLeadTimeId],
[intOriginId],
[strOrigin],
[intBuyingCenterId],
[strBuyingCenter] = LOC.strLocationName,
[intReceivingStorageLocation],
[strReceivingStorageLocation] = SLOC.strSubLocationDescription,
[intChannelId],
[strChannel] = MZ.strMarketZoneCode,
[intReceivingPlantId] = SLOC.intCompanyLocationId,
[strReceivingPlant] = RLOC.strLocationName,
[intPortOfDispatchId],
[strPortOfDispatch],
[intPortOfArrivalId],
[strPortOfArrival],
[dblPurchaseToShipment],
[dblPortToPort],
[dblPortToMixingUnit],
[dblMUToAvailableForBlending],
[intEntityId]

FROM 
tblMFLocationLeadTime LLT

INNER JOIN tblSMCompanyLocation LOC ON LLT.intBuyingCenterId = LOC.intCompanyLocationId
INNER JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=LLT.intReceivingStorageLocation
INNER JOIN tblARMarketZone MZ ON MZ.intMarketZoneId=LLT.intChannelId
LEFT JOIN tblSMCompanyLocation RLOC ON SLOC.intCompanyLocationId = RLOC.intCompanyLocationId
