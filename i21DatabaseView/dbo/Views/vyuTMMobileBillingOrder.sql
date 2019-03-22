
CREATE VIEW [dbo].vyuTMMobileBillingOrder  
AS 


SELECT 
	intOrderId = A.intDispatchID
	,A.strOrderNumber
	,strOrderStatus = A.strWillCallStatus
	,A.dtmRequestedDate
	,strCustomerNumber = D.strEntityNo
	,D.intEntityId
	,intUserId = A.intUserID
	,strUser = I.strUserName
	,intSiteId = B.intSiteID
	,B.intSiteNumber
	,B.strDescription as strSiteName
	,E.intItemId
	,E.strItemNo
	,E.strDescription as strItemDescription
	,M.intItemUOMId
	,dblQuantity = CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN A.dblQuantity ELSE A.dblMinimumQuantity END
	,A.dblPrice
	,F.intContractSeq
	,F.intContractDetailId
	,G.strContractNumber		
	,intTermId = H.intTermID
	,strTermId = H.strTerm
	,A.strComments	
	,intDriverId = A.intDriverID
	,strDriver = J.strEntityNo	
	,intRouteId = K.intRouteId
	,K.strRouteNumber
	,intStopNumber = L.intSequence
	,B.intTaxStateID	
	,N.intShipToId	
	,B.strLocation
	,B.intLocationId
	,O.intFreightTermId
	,Q.strSerialNumber
	,Q.dblTankCapacity
	,intConcurrencyId = A.intConcurrencyId

FROM tblTMDispatch A
INNER JOIN tblTMSite B
	ON A.intSiteID = B.intSiteID
INNER JOIN tblTMCustomer C
	ON B.intCustomerID = C.intCustomerID 
INNER JOIN tblEMEntity D
	ON C.intCustomerNumber = D.intEntityId
INNER JOIN tblICItem E
	ON B.intProduct = E.intItemId
LEFT JOIN vyuCTContractSequence F
	ON A.intContractId = F.intContractDetailId
LEFT JOIN tblCTContractHeader G
	ON F.intContractHeaderId = G.intContractHeaderId
LEFT JOIN tblSMTerm H
	ON A.intDeliveryTermID = H.intTermID
LEFT JOIN tblSMUserSecurity I
	ON A.intUserID = I.intEntityId
LEFt JOIN tblEMEntity J
	ON A.intDriverID = J.intEntityId
LEFT JOIN tblLGRoute K
	ON A.intRouteId = K.intRouteId
LEFT JOIN tblLGRouteOrder L
	ON K.intRouteId = L.intRouteId
		AND A.intDispatchID = L.intDispatchID
LEFT JOIN tblICItemUOM M
	ON M.intItemId = E.intItemId
		AND M.ysnStockUnit = 1
LEFT JOIN tblARCustomer N
	ON N.strCustomerNumber = D.strEntityNo
LEFT JOIN tblEMEntityLocation O
	ON O.intEntityLocationId = N.intShipToId

LEFT JOIN (
	  SELECT 
	   AA.intSiteID
	   ,AA.intDeviceId
	   ,BB.strSerialNumber
	   ,BB.dblTankCapacity
	   ,intRecNo = ROW_NUMBER() OVER ( PARTITION BY intSiteID ORDER BY intSiteDeviceID)
	  FROM tblTMSiteDevice AA
	  INNER JOIN tblTMDevice BB
	   ON AA.intDeviceId = BB.intDeviceId
	  INNER JOIN tblTMDeviceType CC
	   ON CC.intDeviceTypeId = BB.intDeviceTypeId
	  WHERE CC.strDeviceType = 'Tank'
	   AND BB.ysnAppliance = 0
	) Q
	ON A.intSiteID = Q.intSiteID
	  AND intRecNo = 1
		
GO