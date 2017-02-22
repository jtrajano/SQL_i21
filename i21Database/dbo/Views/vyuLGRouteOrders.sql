CREATE VIEW vyuLGRouteOrders
AS
SELECT 
 Rte.intRouteOrderId
 ,Rte.intRouteId
 ,R.strRouteNumber
 ,R.strDriver
 ,R.dtmDispatchedDate
 ,R.dblTruckCapacity
 ,R.strComments
 ,R.strFromLocation
 ,R.strFromSubLocation
 ,Rte.intDispatchID
 ,Rte.intLoadDetailId
 ,Rte.intCustomerID
 ,Rte.intSiteID
 ,Rte.intEntityLocationId
 ,Rte.intEntityTypeId
 ,Rte.intSequence
 ,Rte.dblToLatitude
 ,Rte.dblToLongitude
 ,Rte.strToAddress
 ,Rte.strToCity
 ,Rte.strToState
 ,Rte.strToZipCode
 ,Rte.strToCountry
 ,Rte.dblBalance
 ,Rte.strOrderNumber
 ,Rte.dtmScheduledDate 
 ,Rte.strEntityName 
 ,Rte.strOrderStatus
 ,Rte.strItemNo
 ,Rte.dblQuantity
 ,Rte.strCustomerReference
 ,Rte.strOrderComments
 ,Rte.strLocationType
 ,strDestination = Rte.strToAddress + ', ' + Rte.strToCity + ', ' + Rte.strToState + ' ' + Rte.strToZipCode 
 ,Rte.strLocationName
 ,Rte.strSubLocation
 ,Rte.intLoadId
 ,Rte.strEntityType
 ,Rte.ysnLeakCheckRequired
 ,Rte.dblPercentLeft
 ,Rte.dblARBalance

FROM tblLGRouteOrder Rte
JOIN vyuLGRoute R ON R.intRouteId = Rte.intRouteId
