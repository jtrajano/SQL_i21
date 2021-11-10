CREATE VIEW vyuLGRouteOrders
AS
SELECT 
 Rte.intRouteOrderId
 ,Rte.intRouteId
 ,R.strRouteNumber
 ,R.intSourceType
 ,strSourceType = CASE R.intSourceType 
					WHEN 1 THEN 'LG Loads - Inbound'
					WHEN 2 THEN 'TM Orders'
					WHEN 3 THEN 'LG Loads - Outbound'
					WHEN 4 THEN 'TM Sites'
					WHEN 5 THEN 'Entities'
					WHEN 6 THEN 'Sales/Transfer Orders'
				END COLLATE Latin1_General_CI_AS
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
 ,Rte.strRoute
 ,Rte.dblBalance
 ,Rte.strOrderNumber
 ,Rte.dtmScheduledDate 
 ,Rte.dtmHoursFrom
 ,Rte.dtmHoursTo
 ,Rte.strEntityName 
 ,Rte.strOrderStatus
 ,Rte.strItemNo
 ,Rte.dblQuantity
 ,Rte.strCustomerReference
 ,Rte.strOrderComments
 ,Rte.strOneTimeComments
 ,Rte.strDeliveryComments
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
