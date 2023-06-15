CREATE VIEW [dbo].[vyuTMGetSite]
AS

WITH callentry (intSiteId, intCount)
AS (SELECT intSiteID, intCount = COUNT(1) FROM tblTMDispatch GROUP BY intSiteID),

callentryDispatched (intSiteId, intCount)
AS (SELECT intSiteID, intCount = COUNT(1) FROM tblTMDispatch WHERE ISNULL(ysnDispatched, 0) = 1 GROUP BY intSiteID),

openWorkOrder (intSiteId, intCount)
AS (SELECT wo.intSiteID, intCount = COUNT(1)
	FROM tblTMWorkOrder wo
	JOIN tblTMWorkStatusType wst ON wst.intWorkStatusID = wo.intWorkStatusTypeID AND wst.strWorkStatus = 'Open'
	GROUP BY intSiteID),

device (intSiteId, strSerialNumber)
AS (SELECT intSiteID, strSerialNumber
	FROM (
		SELECT intSiteID, dv.strSerialNumber, intRow = ROW_NUMBER() OVER (PARTITION BY intSiteID ORDER BY sd.intSiteDeviceID)
		FROM tblTMSiteDevice sd
		JOIN tblTMDevice dv ON dv.intDeviceId = sd.intDeviceId
		JOIN tblTMDeviceType dt ON dt.intDeviceTypeId = dv.intDeviceTypeId AND dt.strDeviceType = 'Tank'		
	) tbl WHERE intRow = 1
),

lastLeakCheckEvent (intSiteId, dtmDate)
AS (SELECT intSiteID, dtmDate = MAX(dtmDate)
	FROM tblTMEvent ev
	JOIN tblTMEventType evtype ON evtype.intEventTypeID = ev.intEventTypeID
		AND evtype.strDefaultEventType = 'Event-004'
	GROUP BY intSiteID) 
	

SELECT dblBurnRate = site.dblBurnRate
	, dblConfidenceFactor = site.dblConfidenceFactor
	, dblDegreeDayBetweenDelivery = site.dblDegreeDayBetweenDelivery
	, dblEstimatedGallonsLeft = site.dblEstimatedGallonsLeft
	, dblEstimatedPercentLeft = site.dblEstimatedPercentLeft
	, dblLastDeliveredGal = site.dblLastDeliveredGal
	, dblLastGalsInTank = site.dblLastGalsInTank
	, dblLastMeterReading = site.dblLastMeterReading
	, dblLatitude = site.dblLatitude
	, dblLongitude = site.dblLongitude
	, dblPreviousBurnRate = site.dblPreviousBurnRate
	, dblPriceAdjustment = site.dblPriceAdjustment
	, dblSummerDailyUse = site.dblSummerDailyUse
	, dblTotalCapacity = site.dblTotalCapacity
	, dblTotalReserve = site.dblTotalReserve
	, dblWinterDailyUse = site.dblWinterDailyUse
	, dtmForecastedDelivery = site.dtmForecastedDelivery
	, dtmLastDeliveryDate = site.dtmLastDeliveryDate
	, dtmLastReadingUpdate = site.dtmLastReadingUpdate
	, dtmLastUpdated = site.dtmLastUpdated
	, dtmNextDeliveryDate = site.dtmNextDeliveryDate
	, dtmOnHoldEndDate = site.dtmOnHoldEndDate
	, dtmOnHoldStartDate = site.dtmOnHoldStartDate
	, dtmRunOutDate = site.dtmRunOutDate
	, intClockID = site.intClockID
	, intCompanyLocationPricingLevelId = site.intCompanyLocationPricingLevelId
	, intConcurrencyId = site.intConcurrencyId
	, intCustomerID = site.intCustomerID
	, intDeliveryTermID = site.intDeliveryTermID
	, intDeliveryTicketNumber = site.intDeliveryTicketNumber
	, intDriverID = site.intDriverID
	, intFillGroupId = site.intFillGroupId
	, intFillMethodId = site.intFillMethodId
	, intGlobalJulianCalendarId = site.intGlobalJulianCalendarId
	, intHoldReasonID = site.intHoldReasonID
	, intLastDeliveryDegreeDay = site.intLastDeliveryDegreeDay
	, intLocationId = site.intLocationId
	, intNextDeliveryDegreeDay = site.intNextDeliveryDegreeDay
	, intParentSiteID = site.intParentSiteID
	, intProduct = site.intProduct
	, intRoute = site.intRoute
	, intRouteId = site.intRouteId
	, intSiteID = site.intSiteID
	, intSiteNumber = site.intSiteNumber
	, intTankTownshipId = site.intTankTownshipId
	, intTaxLocale1 = site.intTaxLocale1
	, intTaxLocale2 = site.intTaxLocale2
	, intTaxStateID = site.intTaxStateID
	, intUserID = site.intUserID
	, strAcctStatus = site.strAcctStatus
	, strBillingBy = site.strBillingBy
	, strCity = site.strCity
	, strClassFillOption = site.strClassFillOption
	, strComment = site.strComment
	, strCountry = site.strCountry
	, strDescription = site.strDescription
	, strFillGroup = site.strFillGroup
	, strInstruction = site.strInstruction

	, strRecurringPONumber = site.strRecurringPONumber
	, strReleasePONumber = site.strReleasePONumber
	, strSequenceID = site.strSequenceID
	, strSiteAddress = site.strSiteAddress
					
	, strZipCode = site.strZipCode
	, ysnActive = site.ysnActive
	, ysnAdjustBurnRate = site.ysnAdjustBurnRate
	, ysnAllowPriceChange = site.ysnAllowPriceChange
	, ysnDeliveryTicketPrinted = site.ysnDeliveryTicketPrinted
	, ysnHoldDDCalculations = site.ysnHoldDDCalculations
	, ysnOnHold = site.ysnOnHold
	, ysnPrintARBalance = site.ysnPrintARBalance
	, ysnPrintDeliveryTicket = site.ysnPrintDeliveryTicket
	, ysnPromptForPercentFull = site.ysnPromptForPercentFull
	, ysnTaxable = site.ysnTaxable
	, strState = site.strState
	, ysnRoutingAlert = site.ysnRoutingAlert
	, intLostCustomerReasonId = site.intLostCustomerReasonId
	, ysnLostCustomer = site.ysnLostCustomer
	, dtmLostCustomerDate = site.dtmLostCustomerDate
	, strFacilityNumber = site.strFacilityNumber
	,ysnRequireClock = site.ysnRequireClock
	,ysnRequirePump = site.ysnRequirePump
	,ysnCompanySite = site.ysnCompanySite
					
	, strSiteCustomerLocation = EL.strCheckPayeeName
	, intSiteCustomerLocationId = LCS.intEntityLocationId
	, ysnSiteTakenOffHoldByCallEntry = CONVERT(BIT, 0)
	, strDriverName = driver.strName
	, strRouteId = route.strRouteId
	, strLocation = location.strLocationName
	, strClockNumber = clock.strClockNumber
	, strDeliveryTerm = deliverTerm.strTerm
	, strPricingLevelName = pricingLevel.strPricingLevelName
	, strTaxStateLocale = taxLocale.strTaxGroup
	, strProductDescription = item.strDescription
	, strFillMethod = fillMethod.strFillMethod
	, strFillGroupCode = fillGroup.strFillGroupCode
	, strGlobalJulianCalendar = cal.strDescription
	, strHoldReason = holdReason.strHoldReason
	, strTankTownship = tankTownship.strTankTownship
	, dtmLastLeakCheckDate = lastLeakCheckEvent.dtmDate
	, strProductClass = cat.strCategoryCode
	, strItemNo = item.strItemNo
	, ysnHasCallEntry = CONVERT(BIT, CASE WHEN ISNULL(callentry.intCount, 0) > 0 THEN 1 ELSE 0 END)
	, ysnCallEntryDispatched = CONVERT(BIT, CASE WHEN ISNULL(callentryDispatched.intCount, 0) > 0 THEN 1 ELSE 0 END)
	, intOpenWorkOrder = ISNULL(openWorkOrder.intCount, 0)
	, strLostCustomerReason = lostCustomerReason.strLostCustomerReason
	, strFirstTankSerialNumber = device.strSerialNumber
	, strLocationAddress = location.strAddress
	, strLocationPhone = location.strPhone
	, site.intCompanyLocationSubLocationId
	, sublocation.strSubLocationName
	, strLocationNumber = location.strLocationNumber
	, strLocationType = location.strLocationType
	, strLocationEmail = location.strEmail
	, ysnLocationActive = ISNULL(location.ysnLocationActive,0)
	, strLocationInternalNotes = location.strInternalNotes
	, dtmLastInvDeliveryDate = invDeliveries.dtmDate
	, dblLastInvDeliveredGal = ISNULL(invDeliveries.dblQuantity,0.0)
	, dblLastInvGalsInTank = ISNULL(invValuation.dblRunningQuantity,0.0)
FROM tblTMSite site
LEFT JOIN (tblEMEntityLocationConsumptionSite LCS JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LCS.intEntityLocationId) ON LCS.intSiteID = site.intSiteID	
LEFT JOIN (tblEMEntity driver JOIN tblEMEntityType et ON et.intEntityId = driver.intEntityId AND strType = 'Salesperson') ON driver.intEntityId = site.intDriverID
LEFT JOIN tblTMRoute route ON route.intRouteId = site.intRouteId
JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = site.intLocationId
JOIN (tblICItem item JOIN tblICCategory cat ON cat.intCategoryId = item.intCategoryId) ON item.intItemId = site.intProduct
LEFT JOIN tblTMClock clock ON clock.intClockID = site.intClockID
LEFT JOIN tblSMTerm deliverTerm ON deliverTerm.intTermID = site.intDeliveryTermID
LEFT JOIN tblSMCompanyLocationPricingLevel pricingLevel ON pricingLevel.intCompanyLocationPricingLevelId = site.intCompanyLocationPricingLevelId
LEFT JOIN tblSMTaxGroup taxLocale ON taxLocale.intTaxGroupId = site.intTaxStateID				
LEFT JOIN tblTMFillMethod fillMethod ON fillMethod.intFillMethodId = site.intFillMethodId
LEFT JOIN tblTMFillGroup fillGroup ON fillGroup.intFillGroupId = site.intFillGroupId
LEFT JOIN tblTMGlobalJulianCalendar cal ON cal.intGlobalJulianCalendarId = site.intGlobalJulianCalendarId
LEFT JOIN tblTMHoldReason holdReason ON holdReason.intHoldReasonID = site.intHoldReasonID
LEFT JOIN tblTMTankTownship tankTownship ON tankTownship.intTankTownshipId = site.intTankTownshipId
LEFT JOIN callentry ON callentry.intSiteId = site.intSiteID
LEFT JOIN callentryDispatched ON callentryDispatched.intSiteId = site.intSiteID
LEFT JOIN openWorkOrder ON openWorkOrder.intSiteId = site.intSiteID
LEFT JOIN tblTMLostCustomerReason lostCustomerReason ON lostCustomerReason.intLostCustomerReasonId = site.intLostCustomerReasonId
LEFT JOIN device ON device.intSiteId = site.intSiteID
LEFT JOIN lastLeakCheckEvent ON lastLeakCheckEvent.intSiteId = site.intSiteID
LEFT JOIN tblSMCompanyLocationSubLocation sublocation ON site.intCompanyLocationSubLocationId = sublocation.intCompanyLocationSubLocationId
OUTER APPLY (
	SELECT TOP 1
		dtmDate
		,dblQuantity
	FROM vyuICGetInventoryValuation
	WHERE strTransactionType = 'Inventory Receipt' 
			OR strTransactionType = 'Inventory Transfer'
			OR strTransactionType = 'Inventory Transfer with Shipment'
			OR strTransactionType = 'Inventory Adjustment - Quantity'
			OR strTransactionType = 'Inventory Adjustment - Item'
		AND site.ysnCompanySite = 1
		AND intLocationId = site.intLocationId AND site.intLocationId IS NOT NULL
		AND intSubLocationId = site.intCompanyLocationSubLocationId AND site.intCompanyLocationSubLocationId IS NOT NULL
		AND intItemId = site.intProduct AND site.intProduct IS NOT NULL
	ORDER BY dtmDate DESC
)invDeliveries
OUTER APPLY (
	SELECT dblRunningQuantity = SUM(dblQuantity)
	FROM vyuICGetInventoryValuation
	WHERE site.ysnCompanySite = 1
		AND intLocationId = site.intLocationId
		AND intLocationId = site.intLocationId AND site.intLocationId IS NOT NULL
		AND intSubLocationId = site.intCompanyLocationSubLocationId AND site.intCompanyLocationSubLocationId IS NOT NULL
		AND intItemId = site.intProduct AND site.intProduct IS NOT NULL
)invValuation

