CREATE VIEW [dbo].[vyuTMForPrintDeliveryTicket]  
AS  
SELECT 
	strLocation = G.strLocationName
	,strItemNo = CASE WHEN M.intItemId IS NULL THEN F.strItemNo ELSE M.strItemNo END
	,strRoute = J.strRouteId
	,strDriverId = L.strEntityNo
	,dtmRequestedDate = E.dtmRequestedDate
	,ysnCallEntryPrinted = E.ysnCallEntryPrinted
	,strDeliveryTicketFormat = K.strDeliveryTicketFormat
	,strDeliveryTicketPrinter = K.strDeliveryTicketPrinter
	,intDispatchId = E.intDispatchID
	,intCustomerEntityId = C.intEntityId
	,intSiteId = A.intSiteID
	,intLocationId = A.intLocationId
	,intItemId = CASE WHEN M.intItemId IS NULL THEN F.intItemId ELSE M.intItemId END
	,intRouteId = A.intRouteId
	,intDriverId = E.intDriverID
	,intConcurrencyId = E.intConcurrencyId
	,intClockId = K.intClockID
	,intEntityUserSecurityId = E.intUserID
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID = B.intCustomerID
INNER JOIN tblEMEntity C
	ON B.intCustomerNumber = C.intEntityId
INNER JOIN tblARCustomer D 
	ON C.intEntityId = D.[intEntityId]
INNER JOIN tblTMDispatch E
	ON A.intSiteID = E.intSiteID
INNER JOIN tblICItem F
	ON E.intProductID = F.intItemId
INNER JOIN tblSMCompanyLocation G
	ON A.intLocationId = G.intCompanyLocationId
LEFT JOIN tblICItem H
	ON E.intProductID = H.intItemId
LEFT JOIN tblTMFillMethod I
	ON A.intFillMethodId = I.intFillMethodId
LEFT JOIN tblTMRoute J
	ON A.intRouteId = J.intRouteId
LEFT JOIN tblTMClock K
	ON A.intClockID = K.intClockID
LEFT JOIN tblEMEntity L
	ON E.intDriverID = L.intEntityId
LEFT JOIN tblICItem M
	ON E.intSubstituteProductID = M.intItemId

GO