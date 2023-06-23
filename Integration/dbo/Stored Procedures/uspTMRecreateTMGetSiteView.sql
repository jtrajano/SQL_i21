GO
	PRINT 'START OF CREATING [uspTMRecreateTMGetSiteView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateTMGetSiteView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateTMGetSiteView
GO


CREATE PROCEDURE uspTMRecreateTMGetSiteView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMGetSite')
	BEGIN
		DROP VIEW vyuTMGetSite
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1 
		
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMGetSite] 
			AS
			WITH callentry (intSiteId, intCount)
			AS (SELECT intSiteID, intCount = COUNT(1) FROM tblTMDispatch GROUP BY intSiteID),

			callentryDispatched (intSiteId, intCount)
			AS (SELECT intSiteID, intCount = COUNT(1) FROM tblTMDispatch WHERE ISNULL(ysnDispatched, 0) = 1 GROUP BY intSiteID),

			openWorkOrder (intSiteId, intCount)
			AS (SELECT wo.intSiteID, intCount = COUNT(1)
				FROM tblTMWorkOrder wo
				JOIN tblTMWorkStatusType wst ON wst.intWorkStatusID = wo.intWorkStatusTypeID AND wst.strWorkStatus = ''Open''
				GROUP BY intSiteID),

			device (intSiteId, strSerialNumber)
			AS (SELECT intSiteID, strSerialNumber
				FROM (
					SELECT intSiteID, dv.strSerialNumber, intRow = ROW_NUMBER() OVER (PARTITION BY intSiteID ORDER BY sd.intSiteDeviceID)
					FROM tblTMSiteDevice sd
					JOIN tblTMDevice dv ON dv.intDeviceId = sd.intDeviceId
					JOIN tblTMDeviceType dt ON dt.intDeviceTypeId = dv.intDeviceTypeId AND dt.strDeviceType = ''Tank''	
				) tbl WHERE intRow = 1
			),

			lastLeakCheckEvent (intSiteId, dtmDate)
			AS (SELECT intSiteID, dtmDate = MAX(dtmDate)
				FROM tblTMEvent ev
				JOIN tblTMEventType evtype ON evtype.intEventTypeID = ev.intEventTypeID
					AND evtype.strDefaultEventType = ''Event-004''
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
				, strSiteNumber = RIGHT(''000'' + CAST(site.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS
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
					
				, strSiteCustomerLocation = EL.strLocationName
				, intSiteCustomerLocationId = LCS.intEntityLocationId
				, ysnSiteTakenOffHoldByCallEntry = CONVERT(BIT, 0)
				, strDriverName = driver.strName
				, strRouteId = route.strRouteId
				, strLocation = location.strLocationName
				, strClockNumber = clock.strClockNumber
				, strDeliveryTerm = deliverTerm.strTerm
				, strPricingLevelName = pricingLevel.strPricingLevelName
				, strTaxStateLocale = taxLocale.strTaxGroup
				, strProductDescription = item.vwitm_desc
				, strFillMethod = fillMethod.strFillMethod
				, strFillGroupCode = fillGroup.strFillGroupCode
				, strGlobalJulianCalendar = cal.strDescription
				, strHoldReason = holdReason.strHoldReason
				, strTankTownship = tankTownship.strTankTownship
				, dtmLastLeakCheckDate = lastLeakCheckEvent.dtmDate
				, strProductClass = ''
				, strItemNo = item.vwitm_no
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
			LEFT JOIN (tblEMEntity driver JOIN tblEMEntityType et ON et.intEntityId = driver.intEntityId AND strType = ''Salesperson'') ON driver.intEntityId = site.intDriverID
			LEFT JOIN tblTMRoute route ON route.intRouteId = site.intRouteId
			JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = site.intLocationId
			--JOIN (tblICItem item JOIN tblICCategory cat ON cat.intCategoryId = item.intCategoryId) ON item.intItemId = site.intProduct
			LEFT JOIN vwitmmst item ON site.intProduct = item.A4GLIdentity
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
				FROM vyuTMGetInventoryDelivery
				WHERE (intTransactionTypeId IN (4,10,12,13,15,33,47,58))
					AND site.ysnCompanySite = 1
					AND intLocationId = site.intLocationId AND site.intLocationId IS NOT NULL
					AND intSubLocationId = site.intCompanyLocationSubLocationId AND site.intCompanyLocationSubLocationId IS NOT NULL
					AND intItemId = site.intProduct AND site.intProduct IS NOT NULL
					AND dblQuantity > 0
				ORDER BY dtmDate DESC
			)invDeliveries
			OUTER APPLY (
				SELECT dblRunningQuantity = SUM(dblQuantity)
				FROM vyuTMGetInventoryDelivery
				WHERE site.ysnCompanySite = 1
					AND intLocationId = site.intLocationId AND site.intLocationId IS NOT NULL
					AND intSubLocationId = site.intCompanyLocationSubLocationId AND site.intCompanyLocationSubLocationId IS NOT NULL
					AND intItemId = site.intProduct AND site.intProduct IS NOT NULL
			)invValuation
				
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch]
			AS  
				SELECT 
				strKey = C.strEntityNo
				,strCustomerName = C.strName
				,strPhone = EP.strPhone
				,intCustomerID = B.intCustomerID 
				,strDescription = A.strDescription
				,strLocation = E.strLocationName
				,strAddress = A.strSiteAddress
				,intSiteID = A.intSiteID
				,intSiteNumber = A.intSiteNumber
				,intConcurrencyId = A.intConcurrencyId
				,strCity = A.strCity
				,strBillingBy = A.strBillingBy
				,strSerialNumber = J.strSerialNumber
				,A.intLocationId
				,ysnSiteActive = ISNULL(A.ysnActive,0)
				,intCntId = CAST((ROW_NUMBER()OVER (ORDER BY A.intSiteID)) AS INT)
				,strFillMethod = H.strFillMethod
				,A.intProduct
				,strItemNo = ISNULL(I.strItemNo,'''')
				,dtmLastDeliveryDate = A.dtmLastDeliveryDate
				,dtmNextDeliveryDate = A.dtmNextDeliveryDate
				,dblEstimatedPercentLeft = ISNULL(A.dblEstimatedPercentLeft,0.0)
				,strContactEmailAddress = G.strEmail COLLATE Latin1_General_CI_AS      
				,strFillGroup = K.strFillGroupCode
				,strFillDescription = K.strDescription
				,ysnOnHold = CAST(ISNULL(A.ysnOnHold,0) AS BIT)
				,L.strHoldReason
				,A.dtmOnHoldStartDate
				,A.dtmOnHoldEndDate
				,A.intDeliveryTermID
				,D.dblCreditLimit
				,strTerm = M.strTerm COLLATE Latin1_General_CI_AS      
				,A.strInstruction
				,A.intDriverID
				,strDriverId = O.strEntityNo COLLATE Latin1_General_CI_AS      
				,P.strRouteId
				,A.dblTotalCapacity
				,A.ysnTaxable
				,strTaxGroup = Q.strTaxGroup COLLATE Latin1_General_CI_AS      
				,strDeviceOwnership = J.strOwnership
				,A.strZipCode
				,strGlobalJulianCalendar = R.strDescription
				,intCustomerEntityId = B.intCustomerNumber
				,strSiteAccountStatus = A.strAcctStatus
				,AA.strLostCustomerReason
				,A.ysnLostCustomer
				,A.dtmLostCustomerDate
				,A.intNextDeliveryDegreeDay
				,A.intLastDeliveryDegreeDay
				,A.dblDegreeDayBetweenDelivery
				,A.dblBurnRate
				,A.dblPreviousBurnRate
				,A.dblSummerDailyUse
				,A.dblWinterDailyUse
				,A.ysnAdjustBurnRate
				,strPricingLevelName = S.strPricingLevelName COLLATE Latin1_General_CI_AS      
				,A.dblPriceAdjustment
				,T.strClockNumber
				,A.strClassFillOption
				,A.dblTotalReserve
				,A.dtmRunOutDate
				,A.dtmForecastedDelivery
				,ysnCustomerActive = ISNULL(D.ysnActive,0)
				,strAccountStatusCode = A.strAcctStatus	
				,A.ysnHoldDDCalculations
				,A.strState
				FROM tblTMSite A WITH(NOLOCK)
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN tblEMEntity C
					ON B.intCustomerNumber = C.intEntityId
				INNER JOIN tblARCustomer D
					ON C.intEntityId = D.intEntityId
				LEFT JOIN tblSMCompanyLocation E
					ON A.intLocationId = E.intCompanyLocationId
				INNER JOIN [tblEMEntityToContact] F
					ON D.intEntityId = F.intEntityId 
						and F.ysnDefaultContact = 1
				INNER JOIN tblEMEntity G 
					ON F.intEntityContactId = G.intEntityId
				INNER JOIN tblTMClock	T
					ON A.intClockID = T.intClockID
				LEFT JOIN tblICItem I
					ON A.intProduct = I.intItemId
				LEFT JOIN tblTMFillMethod H
					ON A.intFillMethodId = H.intFillMethodId
				LEFT JOIN tblTMFillGroup K
					ON A.intFillGroupId = K.intFillGroupId
				LEFT JOIN tblTMHoldReason L
					ON A.intHoldReasonID = L.intHoldReasonID
				LEFT JOIN tblSMTerm M
					ON A.intDeliveryTermID = M.intTermID
				LEFT JOIN (
								SELECT Y.strSerialNumber 
									,Z.intSiteID
									,Y.strOwnership
								FROM tblTMSiteDevice Z
								INNER JOIN tblTMDevice Y
									ON Z.intDeviceId = Y.intDeviceId
								INNER JOIN tblTMDeviceType X
									ON Y.intDeviceTypeId = X.intDeviceTypeId
								WHERE X.strDeviceType = ''Tank''
							) J
								ON A.intSiteID = J.intSiteID
				LEFT JOIN tblEMEntity O
					ON A.intDriverID = O.intEntityId
				LEFT JOIN tblTMRoute P
					ON A.intRouteId = P.intRouteId
				LEFT JOIN tblSMTaxGroup Q
					ON A.intTaxStateID = Q.intTaxGroupId
				LEFT JOIN tblEMEntityPhoneNumber EP
					ON G.intEntityId = EP.intEntityId  
				LEFT JOIN tblTMGlobalJulianCalendar R
					ON A.intGlobalJulianCalendarId = R.intGlobalJulianCalendarId
				LEFT JOIN tblTMLostCustomerReason AA
					ON A.intLostCustomerReasonId = AA.intLostCustomerReasonId
				LEFT JOIN tblSMCompanyLocationPricingLevel S
					ON A.intCompanyLocationPricingLevelId = S.intCompanyLocationPricingLevelId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateConsumptionSiteSearchView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateConsumptionSiteSearchView] SP'
GO
	EXEC ('uspTMRecreateConsumptionSiteSearchView')
GO
	PRINT 'END OF Execute [uspTMRecreateConsumptionSiteSearchView] SP'
GO