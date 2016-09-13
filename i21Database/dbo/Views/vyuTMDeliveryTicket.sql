CREATE VIEW [dbo].[vyuTMDeliveryTicket]  
AS  
SELECT 
	A.strSiteAddress
	,strCustomerAddress = Loc.strAddress
	,strCustomerCity = Loc.strCity
	,strCustomerState = Loc.strState
	,strCustomerZip = Loc.strZipCode
	,strCustomerName = Ent.strName
	,A.intSiteNumber
	,A.strInstruction
	,A.dblTotalCapacity
	,strDispatchComments = J.strComments
	,strCustomerNumber = Ent.strEntityNo
	,A.intNextDeliveryDegreeDay
	,K.strRouteId
	,strItemNo = ISNULL(O.strItemNo, I.strItemNo)
	,J.dtmRequestedDate
	,strTerm = L.strTerm 
	,dblARBalance = ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0) 
	,J.dblPrice
	,dblTaxRate = dbo.[fnGetItemTotalTaxForCustomer](
                                                        ISNULL(O.intItemId, I.intItemId)
                                                        ,Ent.intEntityId
                                                        ,J.dtmCallInDate
                                                        ,J.dblPrice
                                                        ,(CASE WHEN ISNULL(J.dblMinimumQuantity,0.0) > 0 THEN J.dblMinimumQuantity ELSE J.dblQuantity END)
                                                        ,A.intTaxStateID
                                                        ,A.intLocationId
                                                        ,NULL
                                                        ,1
                                                        ,A.ysnTaxable
                                                        ,A.intSiteID
														,Loc.intFreightTermId
														,NULL
														,NULL
                                                    )
	,intSiteId = A.intSiteID
	,M.strDeliveryTicketFormat
	,strSiteCity = A.strCity
	,strSiteState = A.strState
	,strSiteZipCode = A.strZipCode
	,dblRequestedQuantity = ISNULL(J.dblMinimumQuantity,0.0)
	,dblQuantity = (CASE WHEN ISNULL(J.dblMinimumQuantity,0.0) > 0 THEN J.dblMinimumQuantity ELSE J.dblQuantity END)
	,intDispatchId = J.intDispatchID
	,strReportType = M.strDeliveryTicketFormat
	,intConcurrencyId = J.intConcurrencyId
	,strCustomerPhone = ISNULL(ConPhone.strPhone,'')
	,strOrderNumber = ISNULL(J.strOrderNumber,'')
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID = B.intCustomerID
INNER JOIN tblEMEntity Ent
	ON B.intCustomerNumber = Ent.intEntityId
INNER JOIN tblARCustomer Cus 
	ON Ent.intEntityId = Cus.intEntityCustomerId
INNER JOIN tblEMEntityToContact CustToCon 
	ON Cus.intEntityCustomerId = CustToCon.intEntityId 
		and CustToCon.ysnDefaultContact = 1
INNER JOIN tblEMEntity Con 
	ON CustToCon.intEntityContactId = Con.intEntityId
INNER JOIN tblEMEntityLocation Loc 
	ON Ent.intEntityId = Loc.intEntityId 
		and Loc.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityPhoneNumber ConPhone
	ON Con.intEntityId = ConPhone.intEntityId
INNER JOIN tblTMDispatch J
	ON A.intSiteID = J.intSiteID
INNER JOIN tblICItem I
	ON J.intProductID = I.intItemId
LEFT JOIN tblICItem O
	ON J.intProductID = O.intItemId
LEFT JOIN [vyuARCustomerInquiryReport] CI
	ON Ent.intEntityId = CI.intEntityCustomerId
LEFT JOIN tblTMFillMethod H
	ON A.intFillMethodId = H.intFillMethodId
LEFT JOIN tblTMRoute K
	ON A.intRouteId = K.intRouteId
LEFT JOIN tblSMTerm L	
	ON J.intDeliveryTermID = L.intTermID
LEFT JOIN tblTMClock M
	ON A.intClockID = M.intClockID
GO