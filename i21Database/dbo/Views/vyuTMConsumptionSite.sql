CREATE VIEW [dbo].[vyuTMConsumptionSite]
AS  
	SELECT 
		strCustomerNumber = C.strEntityNo
		,strCustomerName = C.strName
		,strCustomerPhone = G.strPhone
		,strCustomerAddress = H.strAddress
		,strCustomerCity = H.strCity
		,strCustomerState = H.strState
		,strCustomerZipCode = H.strZipCode
		,strCustomerContact = G.strName
		,strCustomerComments = G.strInternalNotes
		,strCustomerSalesPerson = I.strSalespersonId
		,intCustomerTerms = H.intTermsId
		,strCustomerStatementFormat = D.strStatementFormat
		,dblCustomerYTDSales = ISNULL(CI.dblYTDSales,0.0)
		,dblCustomerBudgetAmountForBudgetBilling = D.dblBudgetAmountForBudgetBilling
		,strCustomerBudgetBillingBeginMonth = D.strBudgetBillingBeginMonth
		,strCustomerBudgetBillingEndMonth = D.strBudgetBillingEndMonth
		,ysnCustomerActive = D.ysnActive
		,dblCustomerFuture = CI.dblFuture
		,dblCustomer10Days = CI.dbl10Days
		,dblCustomer30Days = CI.dbl30Days
		,dblCustomer60Days = CI.dbl60Days
		,dblCustomer90Days = CI.dbl90Days
		,dblCustomer91Days = CI.dbl91Days
		,dblCustomerInvoiceTotal = CI.dblInvoiceTotal
		,dblCustomerUnappliedCredits = CI.dblUnappliedCredits
		,dblCustomerPendingPayment = CI.dblPendingPayment
		,strCustomerType = D.strType
		,dblCustomerCreditLimit = D.dblCreditLimit
		,dblCustomerLastStatement = CI.dblLastStatement
		,dblCustomerTotalDue = CI.dblTotalDue
		,dblCustomerPrepaids = CI.dblPrepaids
		,dblCustomerLastPayment = CI.dblLastPayment
		,dtmCustomerLastPaymentDate = CI.dtmLastPaymentDate
		,dtmCustomerLastStatementDate = CI.dtmLastStatementDate
		,strCustomerCountry = H.strCountry
		,strCustomerTermCode = J.strTermCode
		,ysnCustomerApplyPrepaidTax = D.ysnApplyPrepaidTax
		,intCustomerEntityId = D.[intEntityId]
		,dblCustomerBalance = ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0) 
		,dblCustomerLastYearSales = CI.dblLastYearSales
		,strCustomerAccountStatusCode = K.strAccountStatusCode
		,strCustomerLocationName = H.strLocationName
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
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblARCustomer D
		ON C.intEntityId = D.[intEntityId]
	INNER JOIN [tblEMEntityToContact] F
		ON D.[intEntityId] = F.intEntityId 
			AND F.ysnDefaultContact = 1
	INNER JOIN tblEMEntity G 
		ON F.intEntityContactId = G.intEntityId
	INNER JOIN [tblEMEntityLocation] H 
		ON C.intEntityId = H.intEntityId 
			AND H.ysnDefaultLocation = 1
	LEFT JOIN tblARSalesperson I
		ON D.intSalespersonId = I.intEntitySalespersonId
	LEFT JOIN [vyuARCustomerInquiryReport] CI
		ON C.intEntityId = CI.intEntityCustomerId
	LEFT JOIN tblSMTerm J
		ON H.intTermsId = J.intTermID
	LEFT JOIN tblARAccountStatus K
		ON D.intAccountStatusId = K.intAccountStatusId
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
GO