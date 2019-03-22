CREATE VIEW [dbo].[vyuTMSiteEventHistory]
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
		,strDeviceType = F.strDeviceType
		,strDeviceDescription = E.strDescription
		,strDeviceOwnership = E.strOwnership
		,strDeviceBulkPlant = E.strBulkPlant
		,strDeviceInventoryStatus = G.strInventoryStatusType
		,strDeviceComment = E.strComment
		,strDeviceParent = H.strSerialNumber
		,strDeviceRegulatorType = I.strRegulatorType
		,strDeviceLease = J.strLeaseNumber
		,strDeviceSerialNumber = E.strSerialNumber
		,strDeviceManufacturerID = E.strManufacturerID
		,strDeviceManufacturerName = E.strManufacturerName
		,dtmDeviceManufacturedDate = E.dtmManufacturedDate
		,strDeviceModelNumber = E.strModelNumber
		,strDeviceAssetNumber = E.strAssetNumber
		,dblDevicePurchasePrice = E.dblPurchasePrice
		,dtmDevicePurchaseDate = E.dtmPurchaseDate
		,dblDeviceTankCapacity = E.dblTankCapacity
		,dblDeviceTankReserve = E.dblTankReserve
		,strDeviceTankType = K.strTankType
		,dblDeviceEstimatedGalTank = E.dblEstimatedGalTank
		,ysnDeviceUnderground = E.ysnUnderground
		,strDeviceMeterType = X.strMeterType
		,intDeviceMeterCycle = E.intMeterCycle
		,strDeviceMeterStatus = E.strMeterStatus
		,dblDeviceMeterReading = E.dblMeterReading
		,ysnDeviceAppliance = E.ysnAppliance
		,dtmEventDate = D.dtmDate
		,dtmEventLastUpdated = D.dtmLastUpdated
		,dtmEventTankMonitorReading = D.dtmTankMonitorReading
		,strEventType = Y.strEventType
		,strEventPerformerName = Z.strName
		,strEventUser = AB.strUserName
		,strEventDescription = D.strDescription
		,strEventLevel = D.strLevel
		,strEventDeviceOwnership = D.strDeviceOwnership
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B	
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	LEFT JOIN tblTMEvent D
		ON A.intSiteID = D.intSiteID
	LEFT JOIN tblTMDevice E
		ON D.intDeviceId = E.intDeviceId
	LEFT JOIN tblTMLeaseDevice EE
		ON E.intDeviceId = EE.intDeviceId
	LEFT JOIN tblTMDeviceType F
		ON E.intDeviceTypeId = F.intDeviceTypeId
	LEFT JOIN tblTMInventoryStatusType G
		ON E.intInventoryStatusTypeId = G.intInventoryStatusTypeId
	LEFT JOIN tblTMDevice H
		ON E.intParentDeviceID = H.intDeviceId
	LEFT JOIN tblTMRegulatorType I
		ON E.intRegulatorTypeId = I.intRegulatorTypeId
	LEFT JOIN tblTMLease J
		ON EE.intLeaseId = J.intLeaseId
	LEFT JOIN tblTMTankType K
		ON E.intTankTypeId = K.intTankTypeId
	----Start Getting Site Driver	
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
	LEFT JOIN tblTMMeterType X
		ON E.intMeterTypeId = X.intMeterTypeId
	LEFT JOIN tblTMEventType Y
		ON D.intEventTypeID = Y.intEventTypeID
	----Start Getting Event Performer	
	LEFT JOIN tblEMEntity Z
		ON D.intPerformerID = Z.intEntityId	
	----End Getting Event Performer
	LEFT JOIN tblSMUserSecurity AB
		ON D.intUserID = AB.[intEntityId]
		
GO