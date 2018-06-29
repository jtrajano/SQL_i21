CREATE VIEW [dbo].[vyuTMDeliveryFillReport]
AS

SELECT  
	intCustomerId = A.intCustomerID
	, strCustomerName = B.strFullCustomerName
	, strCustomerPhone = B.vwcus_phone
	, strCustomerNumber = B.vwcus_key
	, strCustomerTax =  ISNULL(K.strTaxGroup,'')
	, dblCustomerPer1 = ISNULL(B.vwcus_ar_per1,0.0) 
	, dblCustomerCreditLimit = B.vwcus_cred_limit
	, dblCustomerLastStatement = ISNULL(B.vwcus_last_stmt_bal,0.0)
	, dblCustomerTotalDue = B.vwcus_budget_amt_due
	, dblCustomerFuture = B.vwcus_ar_future
	, dblCustomerPriceLevel = CAST(0 AS INT)
	, strTerms = (CASE  WHEN Q.ysnUseDeliveryTermOnCS <> 1 
				THEN 
					(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = B.intCustomerDeliveryTermId)
				ELSE  
					(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = C.intDeliveryTermID)
				END) 
	, dblCredits = (B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) 
	, dblTotalPast = vwcus_high_past_due
	, dblARBalance =  ISNULL(B.vwcus_balance,0.0)
	, dblPastCredit = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga)as NUMERIC(18,6)) 
	, C.intSiteNumber
	, dblSiteLastDeliveredGal = ISNULL(C.dblLastDeliveredGal,0)
	, strSiteSequenceId =  C.strSequenceID
	, intSiteLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay,0)
	, strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), ' '),CHAR(10), ' ') 
	, C.dtmOnHoldEndDate
	, C.ysnOnHold
	, strHoldReason = (CASE WHEN C.ysnOnHold = 0 
						THEN ''
						WHEN C.ysnOnHold = 1 
						THEN HR.strHoldReason
						WHEN (C.dtmOnHoldEndDate > DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) OR C.dtmOnHoldEndDate IS NULL)
						THEN HR.strHoldReason
						End)
	, C.intFillMethodId
	,  strCity= (CASE WHEN C.strSiteAddress IS NOT NULL THEN
						', ' + C.strCity
					ELSE
						C.strCity  
					END ) 
	, strState = (CASE WHEN C.strCity IS NOT NULL and C.strSiteAddress IS NOT NULL Then
						', ' + C.strState
					ELSE
						C.strState  
					END ) 
	, strZipCode = (CASE WHEN C.strState IS NOT NULL and C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL Then
						' ' + C.strZipCode
					ELSE
						C.strZipCode  
					END )
	, C.strComment
	, C.strInstruction
	, C.dblDegreeDayBetweenDelivery
	, C.dblTotalCapacity
	, C.dblTotalReserve
	, strSiteDescription = C.strDescription
	, dblLastGalsInTank = ISNULL(C.dblLastGalsInTank,0)
	, C.dtmLastDeliveryDate
	, intSiteId = C.intSiteID
	, dblEstimatedPercentLeft = ISNULL(C.dblEstimatedPercentLeft,0)
	, C.dtmNextDeliveryDate
	, intNextDeliveryDegreeDay = ISNULL(C.intNextDeliveryDegreeDay,0)
	, strSiteLabel =(	CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN
							'Date'
						ELSE
							'DD'
						END)
	,strSiteDeliveryDD= (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN
							CONVERT(VARCHAR,C.dtmNextDeliveryDate,101)
						ELSE
							CAST(C.intNextDeliveryDegreeDay AS NVARCHAR(20))
						END) 
	,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= H.intBeginSummerMonth AND  MONTH(GETDATE()) < H.intBeginWinterMonth
						THEN ISNULL(C.dblSummerDailyUse,0.0) 
						ELSE ISNULL(C.dblWinterDailyUse,0.0)
					END)
	, strFillGroupCode = ISNULL( I.strFillGroupCode,'')
	, strFillGroupDescription = I.strDescription
	, ysnFillGroupActive = I.ysnActive
	, intFillGroupId = CAST(ISNULL(C.intFillGroupId,0) AS INT)
	, strDriverName = J.strName  
	, strDriverId = J.strEntityNo
	, F.dtmRequestedDate
	, dblQuantity = (CASE WHEN COALESCE(F.dblMinimumQuantity,0.0) <> 0 THEN F.dblMinimumQuantity
						ELSE COALESCE(F.dblQuantity,0.0) END) 
	, strProductId = G.strItemNo
	, strProductDescription = G.strDescription
	, O.strRouteId
	, P.strFillMethod
	, strBetweenDlvry = (CASE WHEN C.intFillMethodId = U.intFillMethodId THEN R.strDescription
							ELSE CAST((CONVERT(NUMERIC(18,2),C.dblDegreeDayBetweenDelivery)) AS NVARCHAR(10))
						END)  
	, strLocation = CL.strLocationName
	,C.dtmForecastedDelivery
	,ysnPending = CAST((CASE WHEN F.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT)
	,strItemClass = G.strCategoryCode
	,F.dtmCallInDate
	,dblCallEntryPrice = F.dblPrice
	,dblCallEntryMinimumQuantity = F.dblMinimumQuantity
	,Z.strCompanyName
	,C.intLocationId
	,intDriverId = C.intDriverID
	,C.intRouteId
	,dblNextDeliveryGallons = ISNULL(C.dblLastGalsInTank,0.0) - ISNULL(C.dblEstimatedGallonsLeft,0.0)
	,intGroupSiteCount = CASE WHEN ISNULL(C.intFillGroupId,0) = 0 THEN 0 ELSE (SELECT COUNT(intSiteId) 
																							FROM vyuTMDeliveryFillGroupSubReport 
																							WHERE intFillGroupId = C.intFillGroupId
																								AND intSiteId <> C.intSiteID) END
FROM tblTMCustomer A 
INNER JOIN vyuTMCustomerEntityView B
	ON A.intCustomerNumber = B.A4GLIdentity
INNER JOIN tblTMSite C 
	ON A.intCustomerID = C.intCustomerID
LEFT JOIN tblSMCompanyLocation CL
	ON C.intLocationId = CL.intCompanyLocationId 
LEFT JOIN tblTMDispatch F 
	ON C.intSiteID = F.intSiteID
LEFT JOIN (
	SELECT
		AAA.strItemNo
		,AAA.strDescription
		,strCategoryCode = ISNULL(CCC.strCategoryCode,'')
		,AAA.intItemId
		,BBB.intLocationId
	FROM tblICItem AAA
	INNER JOIN tblICItemLocation BBB
		ON AAA.intItemId = BBB.intItemId
	LEFT JOIN tblICCategory CCC
		ON AAA.intCategoryId = CCC.intCategoryId
) G 
	ON C.intProduct = G.intItemId
	AND C.intLocationId = G.intLocationId
LEFT JOIN tblTMClock H 
	ON H.intClockID = C.intClockID
LEFT JOIN tblTMFillGroup I 
	On I.intFillGroupId = C.intFillGroupId
LEFT JOIN (
	SELECT  
		 AA.strEntityNo
		 ,AA.strName
		 ,AA.intEntityId
		 ,intConcurrencyId = 0
	FROM tblEMEntity AA
	LEFT JOIN [tblEMEntityLocation] BB
		ON AA.intEntityId = BB.intEntityId
			AND BB.ysnDefaultLocation = 1
	INNER JOIN [tblEMEntityType] CC
		ON AA.intEntityId = CC.intEntityId
	WHERE strType = 'Salesperson'
) J 
	ON J.intEntityId = C.intDriverID
LEFT JOIN tblTMHoldReason HR 
	ON C.intHoldReasonID = HR.intHoldReasonID
LEFT JOIN tblSMTaxGroup K
	ON C.intTaxStateID = K.intTaxGroupId
LEFT JOIN tblTMRoute O
	ON C.intRouteId = O.intRouteId
LEFT JOIN tblTMFillMethod P
	ON C.intFillMethodId = P.intFillMethodId
LEFT JOIN tblTMGlobalJulianCalendar R
	ON C.intGlobalJulianCalendarId = R.intGlobalJulianCalendarId
,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany) Q
,(SELECT TOP 1 intFillMethodId FROM tblTMFillMethod WHERE strFillMethod = 'Julian Calendar') U
,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
WHERE B.vwcus_active_yn = 'Y' and C.ysnActive = 1

GO



