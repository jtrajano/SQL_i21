﻿
CREATE VIEW [dbo].vyuTMMobileBillingOrder  
AS 


SELECT 
	intOrderId = A.intDispatchID
	,A.strOrderNumber
	,A.dtmRequestedDate
	,strCustomerNumber = D.strEntityNo
	,D.intEntityId
	,intSiteId = B.intSiteID
	,B.intSiteNumber
	,E.intItemId
	,E.strItemNo
	,M.intItemUOMId
	,dblQuantity = CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN A.dblQuantity ELSE A.dblMinimumQuantity END
	,F.intContractDetailId
	,G.strContractNumber
	,F.intContractSeq
	,A.dblPrice
	,intTermId = H.intTermID
	,strTermId = H.strTerm
	,A.strComments
	,intUserId = A.intUserID
	,strUser = I.strUserName
	,intDriverId = A.intDriverID
	,strDriver = J.strEntityNo
	,strOrderStatus = A.strWillCallStatus
	,intRouteId = K.intRouteId
	,K.strRouteNumber
	,intStopNumber = L.intSequence
	,B.intTaxStateID
	,B.strDescription as strSiteName
	,N.intShipToId
	,O.intFreightTermId
	,B.strLocation
	,B.intLocationId
	,E.strDescription as strItemDescription
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