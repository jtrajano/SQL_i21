CREATE VIEW [dbo].[vyuTMETExportTankManagementSite]  
AS 

SELECT 
	C.strEntityNo CustomerNumber
	,REPLICATE('0',4-LEN(CAST(A.intSiteNumber  AS NVARCHAR(20)))) + CAST(A.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber
	,ISNULL(A.strBillingBy,'') BillingBy
	,ISNULL(A.strDescription,'') [SiteDescription]
	,ISNULL(A.strSiteAddress,'') [Address]
	,ISNULL(A.strZipCode,'') ZipCode
	,ISNULL(A.strCity,'') City
	,ISNULL(A.strState,'') [State]
	,ISNULL(A.strCountry,'') Country
	,ISNULL(A.dblLatitude,0) Latitude
	,ISNULL(A.dblLongitude,0) Longitude
	,ISNULL(D.strEntityNo,'') DriverNumber
	,ISNULL(K.strRouteId,'') [Route] 
	,ISNULL(A.strSequenceID,'') Sequence
	,ISNULL(A.strLocation,'') Location
	,ISNULL(E.strClockNumber,'') ClockNumber
	,ISNULL(A.strAcctStatus,'') AccountStatus
	,ISNULL(A.dblTotalCapacity,0) TotalCapacity
	,ROUND(ISNULL(A.dblTotalReserve,0),2) TotalReserve
	,ISNULL(RTRIM(LTRIM(F.strItemNo)),'') Product
	,CASE ISNULL(A.ysnTaxable,0) WHEN 1 THEN 'Yes' ELSE 'No' END SalesTax
	,ISNULL(G.strTaxGroup,'') TaxStateID
	,'' TaxLocale1
	,'' TaxLocale2
	,CASE A.intDeliveryTermID WHEN NULL THEN
			ISNULL(C.strTermCode,'')
		WHEN 0 THEN
			ISNULL(C.strTermCode,'')
		ELSE 
			(SELECT strTermCode FROM tblSMTerm WHERE intTermID = A.intDeliveryTermID)
		END	DeliveryTermsCode
	,CASE intDeliveryTermID WHEN NULL THEN
			ISNULL(C.strTerm,'')
		WHEN 0 THEN
			ISNULL(C.strTerm,'')
		ELSE 
			(SELECT strTerm FROM tblSMTerm WHERE intTermID = A.intDeliveryTermID)
		END DeliveryTermsCodeDescription
	,ISNULL(A.dblPriceAdjustment,0) PriceReduction
	,ISNULL(A.strClassFillOption,'') ClassFill
	,ISNULL(CAST(A.strRecurringPONumber AS NVARCHAR(50)),' ') RecurringPONumber
	,CASE ISNULL(A.ysnPrintARBalance,0) WHEN 1 THEN 'Yes' ELSE 'No' END PrintARBalance
	,ISNULL(H.strFillMethod,'') FillMethod
	,ISNULL(A.strFillGroup,'') FillGroup
	,ISNULL(A.dblDegreeDayBetweenDelivery,0) DegreeDaysBetweenDelivery
	,ISNULL(CONVERT(VARCHAR(10), A.dtmNextDeliveryDate , 101),'') NextJulianDeliveryDate
	,ISNULL(A.dblSummerDailyUse,0) SummerDailyUse
	,ISNULL(A.dblWinterDailyUse,0) WinterDailyUse
	,ROUND(ISNULL(A.dblBurnRate,0),2) BurnRate
	,ROUND(ISNULL(A.dblPreviousBurnRate,0),2) PreviousBurnRate
	,CASE ISNULL(A.ysnPromptForPercentFull,0) WHEN 1 THEN 'Yes' ELSE 'No' END PromptForPercentFull
	,CASE ISNULL(A.ysnAdjustBurnRate,0) WHEN 1 THEN 'Yes' ELSE 'No' END AdjustBurnRate
	,CASE ISNULL(A.ysnOnHold,0) WHEN 1 THEN 'Yes' ELSE 'No' END OnHold
	,ISNULL(I.strHoldReason,'') OnHoldReason
	,ISNULL(CONVERT(VARCHAR(10),A.dtmOnHoldStartDate, 101),'') OnHoldStart
	,ISNULL(CONVERT(VARCHAR(10),A.dtmOnHoldEndDate, 101),'') OnHoldEnd
	,CASE ISNULL(A.ysnHoldDDCalculations,0) WHEN 1 THEN 'Yes' ELSE 'No' END HoldDDCalculation
	,ISNULL(CONVERT(VARCHAR(10),A.dtmLastDeliveryDate , 101),'') LastDeliveryDate
	,ISNULL(A.intLastDeliveryDegreeDay,0) LastDeliveryDegreeDay
	,ISNULL(A.dblLastDeliveredGal,0) LastDeliveredGallons
	,ISNULL(A.intNextDeliveryDegreeDay,0) NextDeliveryDegreeDay
	,ISNULL(A.dblEstimatedGallonsLeft,0) EstimatedGallonsLeft
	,ISNULL(A.dblEstimatedPercentLeft,0) EstimatedPercentLeft
	,ISNULL(HH.dblTotalGallons,0) dblYTDGalsThisSeason
	,ISNULL(II.dblTotalGallons,0) YTDGallonsLastSeason
	,ISNULL(JJ.dblTotalGallons,0) YTDGallons2SeasonsAgo
	,ISNULL(HH.dblTotalSales,0) YTDSalesThisSeason
	,ISNULL(II.dblTotalSales,0) YTDSalesLastSeason
	,ISNULL(JJ.dblTotalSales,0) YTDSales2SeasonsAgo
	,ISNULL(CONVERT(VARCHAR(10),A.dtmRunOutDate , 101),'') RunOutDate
	,ISNULL(CONVERT(VARCHAR(10),A.dtmForecastedDelivery , 101),'') ForecastedDeliveryDate
	,ISNULL(J.strTankTownship,'') TankTownShip
	,CASE ISNULL(A.ysnPrintDeliveryTicket,0) WHEN 1 THEN 'Yes' ELSE 'No' END PrintDeliveryTicket
	,ISNULL(A.strInstruction,'') Instructions
	,ISNULL(A.strComment,'') Comments
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID = B.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
				,Loc.intTermsId
				,Trm.strTermCode
				,Trm.strTerm
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]
			INNER JOIN [tblEMEntityLocation] Loc 
				ON Ent.intEntityId = Loc.intEntityId 
					and Loc.ysnDefaultLocation = 1
			LEFT JOIN tblSMTerm Trm
				ON Trm.intTermID =  Loc.intTermsId) C
	ON B.intCustomerNumber = C.intEntityId
INNER JOIN (
	SELECT 
		 A.strEntityNo
		 ,A.intEntityId
	FROM tblEMEntity A
	LEFT JOIN [tblEMEntityLocation] B
		ON A.intEntityId = B.intEntityId
			AND B.ysnDefaultLocation = 1
	LEFT JOIN [tblEMEntityToContact] D
		ON A.intEntityId = D.intEntityId
			AND D.ysnDefaultContact = 1
	LEFT JOIN tblEMEntity E
		ON D.intEntityContactId = E.intEntityId
	INNER JOIN [tblEMEntityType] C
		ON A.intEntityId = C.intEntityId
	WHERE strType = 'Salesperson'
	) D
	ON A.intDriverID = D.intEntityId
INNER JOIN tblTMClock E
	ON A.intClockID =E.intClockID
LEFT JOIN  (
	SELECT 
		A.intItemId
		,A.strItemNo 
		,C.intCompanyLocationId
	FROM tblICItem A
	INNER JOIN tblICItemLocation B
		ON A.intItemId = B.intItemId
	INNER JOIN tblSMCompanyLocation C
		ON B.intLocationId = C.intCompanyLocationId
	LEFT JOIN tblICCategory D
		ON A.intCategoryId = D.intCategoryId
	LEFT JOIN tblICItemPricing E
		ON A.intItemId = E.intItemId 
		AND B.intLocationId = E.intItemLocationId
	) F
	ON 	F.intItemId = A.intProduct
		AND A.intLocationId = F.intCompanyLocationId
LEFT JOIN tblSMTaxGroup G
	ON A.intTaxStateID = G.intTaxGroupId
LEFT JOIN tblTMFillMethod H
	ON A.intFillMethodId = H.intFillMethodId
LEFT JOIN tblTMHoldReason I
	ON I.intHoldReasonID = A.intHoldReasonID
LEFT JOIN tblTMTankTownship J
	ON J.intTankTownshipId = A.intTankTownshipId
LEFT JOIN tblTMRoute K
	ON A.intRouteId = K.intRouteId
OUTER APPLY (
	SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons), dblTotalSales = SUM(dblTotalSales) FROM vyuTMSiteDeliveryHistoryTotal 
	WHERE intSiteId = A.intSiteID
		AND intCurrentSeasonYear = intSeasonYear
)HH
OUTER APPLY (
	SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons), dblTotalSales = SUM(dblTotalSales) FROM vyuTMSiteDeliveryHistoryTotal 
	WHERE intSiteId = A.intSiteID
		AND (intCurrentSeasonYear - 1) = intSeasonYear
)II
OUTER APPLY (
	SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons), dblTotalSales = SUM(dblTotalSales) FROM vyuTMSiteDeliveryHistoryTotal 
	WHERE intSiteId = A.intSiteID
		AND (intCurrentSeasonYear - 2) = intSeasonYear
)JJ
WHERE C.ysnActive = 1 AND A.ysnActive =1