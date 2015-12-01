GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveryFillReport')
	DROP VIEW vyuTMDeliveryFillReport
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
	AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
	AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1
	AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1
	
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vyuTMDeliveryFillReport]
		AS

		SELECT DISTINCT  
		A.intCustomerID
		, rtrim(ltrim(B.vwcus_last_name)) as agcus_last_name
		, rtrim(ltrim(B.vwcus_first_name)) as agcus_first_name
		, CustomerName = (CASE WHEN B.vwcus_co_per_ind_cp = ''C'' THEN    RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   ELSE    CASE WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  THEN     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    ELSE     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)END END) COLLATE Latin1_General_CI_AS
		, B.vwcus_phone as agcus_phone
		, B.vwcus_key as agcus_key
		, ISNULL(K.vwlcl_tax_state,B.vwcus_tax_state) as agcus_tax_state
		, B.vwcus_ar_per1 as agcus_ar_per1
		, B.vwcus_cred_limit as agcus_cred_limit
		, B.vwcus_last_stmt_bal as agcus_last_stmt_bal
		, B.vwcus_budget_amt_due as agcus_budget_amt_due
		, B.vwcus_ar_future as agcus_ar_future
		, B.vwcus_prc_lvl as agcus_prc_lvl
		,(Case  (Select ysnUseDeliveryTermOnCS From tblTMPreferenceCompany)  when 0 then 
				Cast(B.vwcus_terms_cd as nvarchar(5))+ '' - '' + (Select ISNULL(vwtrm_desc,'''') from vwtrmmst where vwtrm_key_n = B.vwcus_terms_cd)
			when 1 then 
			Cast(C.intDeliveryTermID as nvarchar(5))+ '' - '' + (Select ISNULL(vwtrm_desc,'''') from vwtrmmst where vwtrm_key_n = C.intDeliveryTermID)
			end) as Terms
		, (B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) as Credits
		, (B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) as TotalPast
		, (B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 +  B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga) as ARBalance
		, Cast((B.vwcus_ar_per2 + B.vwcus_ar_per3 + 
				  B.vwcus_ar_per4 + B.vwcus_ar_per5 - 
				  B.vwcus_cred_reg - B.vwcus_cred_ga)as money) AS dblPastCredit
		, C.intSiteNumber
		, ISNULL(C.dblLastDeliveredGal,0) as dblLastDeliveredGal
		, C.strSequenceID
		, ISNULL(C.intLastDeliveryDegreeDay,0) AS intLastDeliveryDegreeDay
		, REPLACE(C.strSiteAddress,Char(13),'' '') as strSiteAddress
		, C.dtmOnHoldEndDate
		, C.ysnOnHold
		,(Case When C.ysnOnHold = 0 Then
				''''
				When C.ysnOnHold = 1 Then 
				 HR.strHoldReason
				When (C.dtmOnHoldEndDate > GetDate() or C.dtmOnHoldEndDate is null)THEN
				 HR.strHoldReason
				End)as strHoldReason
		, (Case C.ysnOnHold 
			When 1 then
				''Yes''
			When 0 then
				''No''
			End) as strOnHold
		, C.intFillMethodId
		, (Case When C.strSiteAddress is not null Then
				'', '' + C.strCity
			ELSE
				C.strCity  
			END ) as strCity	
		, (Case When C.strCity IS NOT NULL and C.strSiteAddress is not null Then
				'', '' + C.strState
			ELSE
				C.strState  
			END ) as strState
		, (Case When C.strState IS NOT NULL and C.strCity IS NOT NULL and C.strSiteAddress is not null Then
				'' '' + C.strZipCode
			ELSE
				C.strZipCode  
			END ) as strZipCode
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
			''Date''
		Else
			''DD''
		End) as [SiteLabel]
		,(Case When C.dtmNextDeliveryDate is not Null Then
			CONVERT(varchar,C.dtmNextDeliveryDate,101)
		Else
			CAST(C.intNextDeliveryDegreeDay as nvarchar(20))
		End) as [SiteDeliveryDD]
		, 	(Case When H.strCurrentSeason = ''Summer'' Then 
				C.dblSummerDailyUse
				When H.strCurrentSeason = ''Winter''
				Then  C.dblWinterDailyUse
				ELSE
					Coalesce(C.dblWinterDailyUse,0) End) AS dblDailyUse
		, ISNULL( I.strFillGroupCode,'''') as strFillGroupCode
		, I.strDescription
		, (Case I.ysnActive
			When 1 then
				''Yes''
			When 0 then
				''No''
			End) as ysnActive
		, I.intFillGroupId
		, J.vwsls_name as strDriverName
		, J.vwsls_slsmn_id as strDriverId
		, F.dtmRequestedDate
		, Coalesce(F.dblQuantity,0.0) as dblQuantity
		, G.vwitm_no as strProductId
		, G.vwitm_desc as strProductDescription
		,(Select r.strRouteId FROM tblTMRoute r WHERE r.intRouteId = C.intRouteId) as strRouteId
		, (SELECT strFillMethod FROM tblTMFillMethod tt WHERE tt.intFillMethodId = C.intFillMethodId) AS strFillMethod
		, (Case When C.intFillMethodId = 1 Then
					Case When (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) > 1 Then
							''Varies''
						When (SELECT COUNT(intSiteID)FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 1 Then
							Case When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID)= 0 Then
									Cast((SELECT intRecurInterval FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) as varchar(50))
								When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 1 Then
									''Weekly''
								When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 2 Then 
									''Monthly''
								When (SELECT intRecurPattern FROM tblTMSiteJulianCalendar t WHERE t.intSiteID = C.intSiteID) = 3 Then
									''Single''
							End
						End
				Else
				Cast((CONVERT(DECIMAL (10,2),C.dblDegreeDayBetweenDelivery)) as varchar(50))
			End) as strBetweenDlvry		
		, (CASE WHEN ISNumeric(C.strLocation) = 1 THEN
			C.strLocation
			ELSE
			substring(C.strLocation, patindex(''%[^0]%'',C.strLocation), 50) END) AS strLocation
		,C.dtmForecastedDelivery
		,CAST((CASE WHEN F.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
		,G.vwitm_class
		,F.dtmCallInDate
		,dblCallEntryPrice = F.dblPrice
		,dblCallEntryMinimumQuantity = F.dblMinimumQuantity
		FROM tblTMCustomer A 
		INNER JOIN vwcusmst B 
			on A.intCustomerNumber = B.A4GLIdentity 
		INNER JOIN tblTMSite C 
			ON A.intCustomerID = C.intCustomerID
		LEFT JOIN tblTMDispatch F 
			ON C.intSiteID = F.intSiteID
		LEFT JOIN vwitmmst G 
			ON C.intProduct = G.A4GLIdentity
		LEFT JOIN tblTMClock H 
			ON H.intClockID = C.intClockID
		Left Join tblTMFillGroup I 
			On I.intFillGroupId = C.intFillGroupId
		LEFT JOIN vwslsmst J 
			ON J.A4GLIdentity = C.intDriverID
		LEFT JOIN tblTMHoldReason HR 
			ON C.intHoldReasonID = HR.intHoldReasonID
		LEFT JOIN vwlclmst K
			ON C.intTaxStateID = K.A4GLIdentity
		WHERE vwcus_active_yn = ''Y'' and C.ysnActive = 1
	')
END
GO