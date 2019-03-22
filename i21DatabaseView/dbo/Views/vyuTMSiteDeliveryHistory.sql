CREATE VIEW [dbo].[vyuTMSiteDeliveryHistory]
AS  
	SELECT 
		strCustomerNumber = C.strEntityNo
		,strCustomerName = C.strName
		,intSiteNumber = A.intSiteNumber
		,strSiteBillingBy = A.strBillingBy
		,ysnSiteActive = A.ysnActive
		,strSiteDescription = A.strDescription
		,strSiteAddress = A.strSiteAddress
		,strSiteZipCode = A.strZipCode
		,strSiteCity = A.strCity
		,strSiteState = A.strState
		,strSiteCountry = A.strCountry
		,dblSiteLatitude = A.dblLatitude
		,dblSiteLongitude = A.dblLongitude
		,strSiteDriverName = L.strName
		,strSiteRouteId = N.strRouteId
		,strSiteSequenceID = A.strSequenceID
		,ysnSiteOnHold = A.ysnOnHold
		,ysnSiteHoldDDCalculations = A.ysnHoldDDCalculations
		,strSiteHoldReason = O.strHoldReason	
		,dtmSiteOnHoldStartDate = A.dtmOnHoldStartDate
		,dtmSiteOnHoldEndDate = A.dtmOnHoldEndDate
		,strSiteLocation = P.strLocationName
		,dblSiteTotalCapacity = A.dblTotalCapacity
		,strSiteClockNumber = Q.strClockNumber
		,dblSiteTotalReserve = A.dblTotalReserve
		,strSiteAcctStatus = A.strAcctStatus
		,strSiteDeliveryTermID = R.strTerm
		,ysnSiteTaxable = A.ysnTaxable
		,dblSitePriceAdjustment = A.dblPriceAdjustment
		,strSiteTax = S.strTaxGroup
		,strSiteRecurringPONumber = A.strRecurringPONumber
		,strSiteClassFillOption = A.strClassFillOption
		,ysnSitePrintARBalance = A.ysnPrintARBalance
		,strSiteItemNumber = T.strItemNo
		,strSiteItemDescription = T.strDescription
		,strSiteFillMethod = U.strFillMethod
		,strSiteFillGroupCode = V.strFillGroupCode
		,dblSiteDegreeDayBetweenDelivery = A.dblDegreeDayBetweenDelivery
		,dtmSiteNextDeliveryDate = A.dtmNextDeliveryDate
		,dblSiteSummerDailyUse = A.dblSummerDailyUse
		,dblSiteWinterDailyUse = A.dblWinterDailyUse
		,dblSiteBurnRate = A.dblBurnRate
		,dblSitePreviousBurnRate = A.dblPreviousBurnRate
		,ysnSitePromptForPercentFull = A.ysnPromptForPercentFull 
		,ysnSiteAdjustBurnRate = A.ysnAdjustBurnRate
		,dtmSiteLastDeliveryDate = A.dtmLastDeliveryDate
		,intSiteLastDeliveryDegreeDay = A.intLastDeliveryDegreeDay
		,dblSiteLastDeliveredGal = A.dblLastDeliveredGal
		,intSiteNextDeliveryDegreeDay = A.intNextDeliveryDegreeDay
		,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
		,dblSiteEstimatedPercentLeft = A.dblEstimatedPercentLeft
		,dblSiteLastGalsInTank = A.dblLastGalsInTank
		--,dblSiteYTDGalsThisSeason = A.dblYTDGalsThisSeason  
		--,dblSiteYTDGalsLastSeason = A.dblYTDGalsLastSeason
		--,dblSiteYTDGals2SeasonsAgo = A.dblYTDGals2SeasonsAgo 
		--,dblSiteYTDSales = A.dblYTDSales
		--,dblSiteYTDSalesLastSeason = A.dblYTDSalesLastSeason
		--,dblSiteYTDSales2SeasonsAgo = A.dblYTDSales2SeasonsAgo
		,dtmSiteRunOutDate = A.dtmRunOutDate
		,dtmSiteForecastedDelivery = A.dtmForecastedDelivery
		,strSiteTankTownship = W.strTankTownship
		,ysnSitePrintDeliveryTicket = A.ysnPrintDeliveryTicket
		,strSiteInstruction = A.strInstruction
		,strSiteComment = A.strComment
		,strDHInvoiceNumber = D.strInvoiceNumber
		,strDHBulkPlantNumber = D.strBulkPlantNumber
		,dtmDHInvoiceDate = D.dtmInvoiceDate
		,strDHProductDelivered = D.strProductDelivered
		,dblDHQuantityDelivered = D.dblQuantityDelivered
		,intDHDegreeDayOnDeliveryDate = D.intDegreeDayOnDeliveryDate
		,intDHDegreeDayOnLastDeliveryDate = D.intDegreeDayOnLastDeliveryDate
		,dblDHBurnRateAfterDelivery = D.dblBurnRateAfterDelivery
		,dblDHCalculatedBurnRate = D.dblCalculatedBurnRate
		,ysnDHAdjustBurnRate = D.ysnAdjustBurnRate
		,intDHElapsedDegreeDaysBetweenDeliveries = D.intElapsedDegreeDaysBetweenDeliveries
		,intDHElapsedDaysBetweenDeliveries = D.intElapsedDaysBetweenDeliveries
		,strDHSeason = D.strSeason
		,dblDHWinterDailyUsageBetweenDeliveries = D.dblWinterDailyUsageBetweenDeliveries
		,dblDHSummerDailyUsageBetweenDeliveries = D.dblSummerDailyUsageBetweenDeliveries
		,dblDHGallonsInTankbeforeDelivery = D.dblGallonsInTankbeforeDelivery 
		,dblDHGallonsInTankAfterDelivery = D.dblGallonsInTankAfterDelivery
		,dblDHEstimatedPercentBeforeDelivery = D.dblEstimatedPercentBeforeDelivery
		,dblDHActualPercentAfterDelivery = D.dblActualPercentAfterDelivery
		,strDHSalesPersonID = D.strSalesPersonID 
		,dtmDHLastUpdated = D.dtmLastUpdated
		,dblDHWillCallPercentLeft = D.dblWillCallPercentLeft
		,dblDHWillCallCalculatedQuantity = D.dblWillCallCalculatedQuantity
		,dblDHWillCallDesiredQuantity = D.dblWillCallDesiredQuantity
		,strDHWillCallDriverName = E.strName
		,strDHWillCallItemNo =  G.strItemNo
		,strDHWillCallSubstituteItemNo =  H.strItemNo
		,dblDHWillCallDeliveryPrice = D.dblWillCallDeliveryPrice
		,strDHWillCallTerm = I.strTerm
		,dtmDHWillCallRequestedDate = D.dtmWillCallRequestedDate
		,intDHWillCallPriority = D.intWillCallPriority
		,dblDHWillCallDeliveryTotal = D.dblWillCallDeliveryTotal 
		,ysnDHWillCallPrinted = D.ysnWillCallPrinted
		,strDHWillCallComments = D.strWillCallComments
		,strDHWillCallEnteredBy = J.strUserName
		,dtmDHWillCallCallInDate = D.dtmWillCallCallInDate
		,dtmDHWillCallDispatch = D.dtmWillCallDispatch
		,strDHWillCallOrderNumber = D.strWillCallOrderNumber
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B	
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblTMDeliveryHistory D
		ON A.intSiteID = D.intSiteID
	----Start Getting Will call Driver	
	LEFT JOIN tblEMEntity E
		ON D.intWillCallDriverId = E.intEntityId	
	----End Getting Driver
	LEFT JOIN tblICItem G
		ON D.intWillCallProductId = G.intItemId
	LEFT JOIN tblICItem H
		ON D.intWillCallSubstituteProductId = H.intItemId
	LEFT JOIN tblSMTerm I
		ON D.intWillCallDeliveryTermId = I.intTermID
	LEFT JOIN tblSMUserSecurity J
		ON D.intUserID = J.[intEntityId]
	----Start Getting will call Driver	
	LEFT JOIN tblEMEntity L
		ON A.intDriverID = L.intEntityId	
	----End Getting Driver
	LEFT JOIN tblTMRoute N
		ON A.intRouteId = N.intRouteId
	LEFT JOIN tblTMHoldReason O
		ON A.intHoldReasonID = O.intHoldReasonID
	---Start Getting Site Location	
	LEFT JOIN tblSMCompanyLocation P
		ON A.intLocationId = P.intCompanyLocationId
	---END Getting Site Location
	LEFT JOIN tblTMClock Q
		ON A.intClockID = Q.intClockID	
	LEFT JOIN tblSMTerm R
		ON A.intDeliveryTermID = R.intTermID
	LEFT JOIN tblSMTaxGroup S
		ON A.intTaxStateID = S.intTaxGroupId
	LEFT JOIN tblICItem T
		ON A.intProduct = T.intItemId 
	LEFT JOIN tblTMFillMethod U
		ON A.intFillMethodId = U.intFillMethodId
	LEFT JOIN tblTMFillGroup V
		ON A.intFillGroupId = V.intFillGroupId
	LEFT JOIN tblTMTankTownship W
		ON A.intTankTownshipId = W.intTankTownshipId
GO