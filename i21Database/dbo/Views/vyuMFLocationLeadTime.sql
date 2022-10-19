CREATE VIEW [dbo].[vyuMFLocationLeadTime]  

AS  

SELECT 

intLocationLeadTimeId,
[intOriginId],
[strOrigin],
[intBuyingCenterId],
[strBuyingCenter] = LOC.strLocationName,
[intReceivingStorageLocation],
[strReceivingStorageLocation] = SLOC.strName,
[intChannelId],
[strChannel] = SBOOK.strSubBook,
[intReceivingPlantId] = SLOC.intLocationId,
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
INNER JOIN tblICStorageLocation SLOC ON SLOC.intStorageLocationId=LLT.intReceivingStorageLocation
INNER JOIN tblCTSubBook SBOOK ON SBOOK.intSubBookId=LLT.intChannelId
LEFT JOIN tblSMCompanyLocation RLOC ON SLOC.intLocationId = RLOC.intCompanyLocationId
