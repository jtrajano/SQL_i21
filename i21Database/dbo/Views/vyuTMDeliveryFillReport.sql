CREATE VIEW [dbo].[vyuTMDeliveryFillReport]
AS

SELECT DISTINCT  
A.intCustomerID
, agcus_last_name = ISNULL((CASE WHEN Cus.strType = 'Company' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( ', ', Ent.strName) != 0 THEN CHARINDEX( ', ', Ent.strName)  -1 ELSE 25 END)) END),'')
, agcus_first_name = ISNULL((CASE WHEN Cus.strType = 'Company' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( ', ', Ent.strName) != 0 THEN CHARINDEX( ', ', Ent.strName)  + 2 ELSE 50 END),50) END),'')
, CustomerName = Ent.strName
, agcus_phone = (CASE WHEN CHARINDEX('x', Con.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Con.strPhone,1,15), 0, CHARINDEX('x',Con.strPhone)) ELSE SUBSTRING(Con.strPhone,1,15)END)
, agcus_key = ISNULL(Ent.strEntityNo,'')
, agcus_tax_state =  ISNULL(K.strTaxGroup,'')
, agcus_ar_per1 = ISNULL(CI.dbl10Days,0.0) 
, agcus_cred_limit = Cus.dblCreditLimit
, agcus_last_stmt_bal = ISNULL(CI.dblLastStatement,0.0)
, agcus_budget_amt_due = ISNULL(CI.dblTotalDue,0.0)
, agcus_ar_future = CAST(ISNULL(CI.dblFuture,0.0) AS NUMERIC(18,6))
, agcus_prc_lvl = CAST(0 AS INT)
, Terms = (CASE  WHEN (SELECT ysnUseDeliveryTermOnCS From tblTMPreferenceCompany) <> 1 
			THEN 
				(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = Loc.intTermsId)
			ELSE  
				(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = C.intDeliveryTermID)
			END) 
, Credits = ISNULL(CI.dblUnappliedCredits,0.0) + CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
, TotalPast = ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)
, ARBalance =  ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)- CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
, dblPastCredit = (ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)) 
, C.intSiteNumber
, dblLastDeliveredGal = ISNULL(C.dblLastDeliveredGal,0)
, C.strSequenceID
, intLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay,0)
, strSiteAddress = REPLACE(C.strSiteAddress,Char(13),' ') 
, C.dtmOnHoldEndDate
, C.ysnOnHold
,strHoldReason = (Case When C.ysnOnHold = 0 Then
		''
		When C.ysnOnHold = 1 Then 
		 HR.strHoldReason
		When (C.dtmOnHoldEndDate > GetDate() or C.dtmOnHoldEndDate is null)THEN
		 HR.strHoldReason
		End)
, strOnHold = (Case C.ysnOnHold 
	When 1 then
		'Yes'
	When 0 then
		'No'
	End)
, C.intFillMethodId
,  strCity= (Case When C.strSiteAddress is not null Then
		', ' + C.strCity
	ELSE
		C.strCity  
	END ) 
, strState = (Case When C.strCity IS NOT NULL and C.strSiteAddress is not null Then
		', ' + C.strState
	ELSE
		C.strState  
	END ) 
, strZipCode = (Case When C.strState IS NOT NULL and C.strCity IS NOT NULL and C.strSiteAddress is not null Then
		' ' + C.strZipCode
	ELSE
		C.strZipCode  
	END )
, C.strComment
, C.strInstruction
, C.dblDegreeDayBetweenDelivery
, C.dblTotalCapacity
, C.dblTotalReserve
, C.strDescription AS strSiteDescription
, ISNULL(C.dblLastGalsInTank,0) AS dblLastGalsInTank
, C.dtmLastDeliveryDate
, C.intSiteID
, ISNULL(C.dblEstimatedPercentLeft,0) as dblEstimatedPercentLeft
, C.dtmNextDeliveryDate
, ISNULL(C.intNextDeliveryDegreeDay,0) AS intNextDeliveryDegreeDay
,(Case When C.dtmNextDeliveryDate is not Null Then
	'Date'
Else
	'DD'
End) as [SiteLabel]
,(Case When C.dtmNextDeliveryDate is not Null Then
	CONVERT(varchar,C.dtmNextDeliveryDate,101)
Else
	CAST(C.intNextDeliveryDegreeDay as nvarchar(20))
End) as [SiteDeliveryDD]
, 	(Case When H.strCurrentSeason = 'Summer' Then 
		C.dblSummerDailyUse
		When H.strCurrentSeason = 'Winter'
		Then  C.dblWinterDailyUse
		ELSE
			Coalesce(C.dblWinterDailyUse,0) End) AS dblDailyUse
, ISNULL( I.strFillGroupCode,'') as strFillGroupCode
, I.strDescription
, (Case I.ysnActive
	When 1 then
		'Yes'
	When 0 then
		'No'
	End) as ysnActive
, I.intFillGroupId
, strDriverName = J.strName  
, strDriverId = J.strEntityNo
, F.dtmRequestedDate
, Coalesce(F.dblQuantity,0.0) as dblQuantity
, strProductId = G.strItemNo
, strProductDescription = G.strDescription
,(Select r.strRouteId FROM tblTMRoute r WHERE r.intRouteId = C.intRouteId) as strRouteId
, (SELECT strFillMethod FROM tblTMFillMethod tt WHERE tt.intFillMethodId = C.intFillMethodId) AS strFillMethod
, (Case When C.intFillMethodId = 1 Then
			Case When (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) > 1 Then
					'Varies'
				When (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 1 Then
					Case When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID)= 0 Then
							Cast((SELECT intRecurInterval FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) as varchar(50))
						When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 1 Then
							'Weekly'
						When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 2 Then 
							'Monthly'
						When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 3 Then
							'Single'
					End
				End
		Else
		Cast((CONVERT(DECIMAL (10,2),C.dblDegreeDayBetweenDelivery)) as varchar(50))
	End) as strBetweenDlvry		
, (CASE WHEN ISNumeric(C.strLocation) = 1 THEN
	C.strLocation
	ELSE
	substring(C.strLocation, patindex('%[^0]%',C.strLocation), 50) END) AS strLocation
,C.dtmForecastedDelivery
,CAST((CASE WHEN F.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
,vwitm_class = G.strCategoryCode
,F.dtmCallInDate
,dblCallEntryPrice = F.dblPrice
,dblCallEntryMinimumQuantity = F.dblMinimumQuantity
FROM tblTMCustomer A 
INNER JOIN tblEntity Ent
	ON A.intCustomerNumber = Ent.intEntityId
INNER JOIN tblARCustomer Cus 
	ON Ent.intEntityId = Cus.intEntityCustomerId
INNER JOIN tblEntityToContact CustToCon 
	ON Cus.intEntityCustomerId = CustToCon.intEntityId 
		and CustToCon.ysnDefaultContact = 1
INNER JOIN tblEntity Con 
	ON CustToCon.intEntityContactId = Con.intEntityId
INNER JOIN tblEntityLocation Loc 
	ON Ent.intEntityId = Loc.intEntityId 
		and Loc.ysnDefaultLocation = 1
LEFT JOIN [vyuARCustomerInquiryReport] CI
	ON Ent.intEntityId = CI.intEntityCustomerId 
INNER JOIN tblTMSite C 
	ON A.intCustomerID = C.intCustomerID
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
Left Join tblTMFillGroup I 
	On I.intFillGroupId = C.intFillGroupId
LEFT JOIN (
	SELECT  
		 AA.strEntityNo
		 ,AA.strName
		 ,AA.intEntityId
		 ,intConcurrencyId = 0
	FROM tblEntity AA
	LEFT JOIN tblEntityLocation BB
		ON AA.intEntityId = BB.intEntityId
			AND BB.ysnDefaultLocation = 1
	INNER JOIN tblEntityType CC
		ON AA.intEntityId = CC.intEntityId
	WHERE strType = 'Salesperson'
) J 
	ON J.intEntityId = C.intDriverID
LEFT JOIN tblTMHoldReason HR 
	ON C.intHoldReasonID = HR.intHoldReasonID
LEFT JOIN tblSMTaxGroup K
	ON C.intTaxStateID = K.intTaxGroupId
WHERE Cus.ysnActive = 1 and C.ysnActive = 1




