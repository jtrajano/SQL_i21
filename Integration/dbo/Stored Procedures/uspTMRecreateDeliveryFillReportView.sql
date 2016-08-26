﻿GO
	PRINT 'START OF CREATING [uspTMRecreateDeliveryFillReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeliveryFillReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeliveryFillReportView
GO

CREATE PROCEDURE uspTMRecreateDeliveryFillReportView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveryFillReport') 
	BEGIN
		DROP VIEW vyuTMDeliveryFillReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMDeliveryFillReport]
				AS

				SELECT 
					intCustomerId = A.intCustomerID
					--, rtrim(ltrim(B.vwcus_last_name)) as agcus_last_name
					--, rtrim(ltrim(B.vwcus_first_name)) as agcus_first_name
					, strCustomerName = (CASE WHEN B.vwcus_co_per_ind_cp = ''C'' 
												THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   
											WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  
												THEN     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    
											ELSE     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)
											END)  COLLATE Latin1_General_CI_AS
					, strCustomerPhone = B.vwcus_phone COLLATE Latin1_General_CI_AS
					, strCustomerNumber = B.vwcus_key COLLATE Latin1_General_CI_AS
					, strCustomerTax = ISNULL(K.vwlcl_tax_state,B.vwcus_tax_state) COLLATE Latin1_General_CI_AS 
					, dblCustomerPer1 = B.vwcus_ar_per1 
					, dblCustomerCreditLimit = B.vwcus_cred_limit 
					, dblCustomerLastStatement = B.vwcus_last_stmt_bal
					, dblCustomerTotalDue = B.vwcus_budget_amt_due 
					, dblCustomerFuture = B.vwcus_ar_future
					, dblCustomerPriceLevel = B.vwcus_prc_lvl
					, strTerms = (CASE  WHEN Q.ysnUseDeliveryTermOnCS <> 1 THEN 
									CAST(B.vwcus_terms_cd AS NVARCHAR(5))+ '' - '' + ISNULL(R.vwtrm_desc,'''') 
									ELSE CAST(C.intDeliveryTermID as nvarchar(5))+ '' - '' + ISNULL(S.vwtrm_desc,'''') 
									END) COLLATE Latin1_General_CI_AS
					, dblCredits = (B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) 
					, dblTotalPast = (B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) 
					, dblARBalance = (B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 +  B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga) 
					, dblPastCredit = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga)as NUMERIC(18,6)) 
					, C.intSiteNumber
					, dblSiteLastDeliveredGal = ISNULL(C.dblLastDeliveredGal,0) 
					, strSiteSequenceId = C.strSequenceID
					, intSiteLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay,0) 
					, strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
					, C.dtmOnHoldEndDate
					, C.ysnOnHold
					, strHoldReason = (CASE WHEN C.ysnOnHold = 0 
									THEN ''''
									WHEN C.ysnOnHold = 1 
									THEN HR.strHoldReason
									WHEN (C.dtmOnHoldEndDate > DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) OR C.dtmOnHoldEndDate IS NULL)
									THEN HR.strHoldReason
									End)
					, C.intFillMethodId
					,  strCity= (CASE WHEN C.strSiteAddress IS NOT NULL THEN
									'', '' + C.strCity
								ELSE
									C.strCity  
								END ) 
					, strState = (CASE WHEN C.strCity IS NOT NULL and C.strSiteAddress IS NOT NULL Then
									'', '' + C.strState
								ELSE
									C.strState  
								END ) 
					, strZipCode = (CASE WHEN C.strState IS NOT NULL and C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL Then
									'' '' + C.strZipCode
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
										''Date''
									ELSE
										''DD''
									END)
					,strSiteDeliveryDD= (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN
											CONVERT(VARCHAR,C.dtmNextDeliveryDate,101)
										ELSE
											CAST(C.intNextDeliveryDegreeDay AS NVARCHAR(20))
										END) 
					,dblDailyUse = (CASE WHEN H.strCurrentSeason = ''Summer'' THEN C.dblSummerDailyUse
									WHEN H.strCurrentSeason = ''Winter'' THEN  C.dblWinterDailyUse
									ELSE COALESCE(C.dblWinterDailyUse,0) End) 
					, strFillGroupCode = ISNULL( I.strFillGroupCode,'''') 
					, strFillGroupDescription = I.strDescription
					, ysnFillGroupActive = I.ysnActive
					, intFillGroupId = CAST(ISNULL(C.intFillGroupId,0) AS INT)
					, strDriverName = J.vwsls_name COLLATE Latin1_General_CI_AS
					, strDriverId = J.vwsls_slsmn_id COLLATE Latin1_General_CI_AS
					, F.dtmRequestedDate
					, dblQuantity = (CASE WHEN COALESCE(F.dblMinimumQuantity,0.0) <> 0 THEN F.dblMinimumQuantity
										ELSE COALESCE(F.dblQuantity,0.0) END) 
					, strProductId = G.vwitm_no COLLATE Latin1_General_CI_AS
					, strProductDescription = G.vwitm_desc COLLATE Latin1_General_CI_AS
					, O.strRouteId
					, P.strFillMethod
					, strBetweenDlvry = (CASE WHEN C.intFillMethodId = U.intFillMethodId THEN CONVERT(VARCHAR,C.dtmNextDeliveryDate,101)
											ELSE Cast((CONVERT(INT,C.dblDegreeDayBetweenDelivery)) AS NVARCHAR(10))
										END)  		
					, strLocation =  (CASE WHEN ISNUMERIC(C.strLocation) = 1 THEN C.strLocation
										ELSE SUBSTRING(C.strLocation, PATINDEX(''%[^0]%'',C.strLocation), 50) 
										END)  
					,C.dtmForecastedDelivery
					,ysnPending = CAST((CASE WHEN F.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT)
					,strItemClass = G.vwitm_class COLLATE Latin1_General_CI_AS
					,F.dtmCallInDate
					,dblCallEntryPrice = F.dblPrice
					,dblCallEntryMinimumQuantity = F.dblMinimumQuantity
					,Z.strCompanyName
					,C.intLocationId
					,intDriverId = C.intDriverID
					,C.intRouteId
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
				LEFT JOIN tblTMRoute O
					ON C.intRouteId = O.intRouteId
				LEFT JOIN tblTMFillMethod P
					ON C.intFillMethodId = P.intFillMethodId
				LEFT JOIN vwtrmmst R
					ON B.vwcus_terms_cd = R.vwtrm_key_n
				LEFT JOIN vwtrmmst S
					ON  C.intDeliveryTermID = S.A4GLIdentity
				,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany)Q
				,(SELECT TOP 1 intFillMethodId FROM tblTMFillMethod WHERE strFillMethod = ''Julian Calendar'') U
				,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
				WHERE vwcus_active_yn = ''Y'' and C.ysnActive = 1
				')
		END
		ELSE
		BEGIN
			GOTO TMNoOrigin
		END
	END
	ELSE
	BEGIN
		TMNoOrigin:
		EXEC ('
			CREATE VIEW [dbo].[vyuTMDeliveryFillReport]
			AS  
			SELECT  
				intCustomerId = A.intCustomerID
				--, strCustomerLastName = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),'''')
				--, strCustomerFirstName = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),'''')
				, strCustomerName = Ent.strName
				, strCustomerPhone = (CASE WHEN CHARINDEX(''x'', Con.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Con.strPhone,1,15), 0, CHARINDEX(''x'',Con.strPhone)) ELSE SUBSTRING(Con.strPhone,1,15)END)
				, strCustomerNumber = ISNULL(Ent.strEntityNo,'''')
				, strCustomerTax =  ISNULL(K.strTaxGroup,'''')
				, dblCustomerPer1 = ISNULL(CI.dbl10Days,0.0) 
				, dblCustomerCreditLimit = Cus.dblCreditLimit
				, dblCustomerLastStatement = ISNULL(CI.dblLastStatement,0.0)
				, dblCustomerTotalDue = ISNULL(CI.dblTotalDue,0.0)
				, dblCustomerFuture = CAST(ISNULL(CI.dblFuture,0.0) AS NUMERIC(18,6))
				, dblCustomerPriceLevel = CAST(0 AS INT)
				, strTerms = (CASE  WHEN Q.ysnUseDeliveryTermOnCS <> 1 
							THEN 
								(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = Loc.intTermsId)
							ELSE  
								(SELECT TOP 1 strTerm FROM tblSMTerm WHERE intTermID = C.intDeliveryTermID)
							END) 
				, dblCredits = ISNULL(CI.dblUnappliedCredits,0.0) + CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
				, dblTotalPast = ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)
				, dblARBalance =  ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)- CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
				, dblPastCredit = (ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0) - ISNULL(CI.dblUnappliedCredits,0.0)) 
				, C.intSiteNumber
				, dblSiteLastDeliveredGal = ISNULL(C.dblLastDeliveredGal,0)
				, strSiteSequenceId =  C.strSequenceID
				, intSiteLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay,0)
				, strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
				, C.dtmOnHoldEndDate
				, C.ysnOnHold
				, strHoldReason = (CASE WHEN C.ysnOnHold = 0 
									THEN ''''
									WHEN C.ysnOnHold = 1 
									THEN HR.strHoldReason
									WHEN (C.dtmOnHoldEndDate > DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) OR C.dtmOnHoldEndDate IS NULL)
									THEN HR.strHoldReason
									End)
				, C.intFillMethodId
				,  strCity= (CASE WHEN C.strSiteAddress IS NOT NULL THEN
									'', '' + C.strCity
								ELSE
									C.strCity  
								END ) 
				, strState = (CASE WHEN C.strCity IS NOT NULL and C.strSiteAddress IS NOT NULL Then
									'', '' + C.strState
								ELSE
									C.strState  
								END ) 
				, strZipCode = (CASE WHEN C.strState IS NOT NULL and C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL Then
									'' '' + C.strZipCode
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
										''Date''
									ELSE
										''DD''
									END)
				,strSiteDeliveryDD= (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN
										CONVERT(VARCHAR,C.dtmNextDeliveryDate,101)
									ELSE
										CAST(C.intNextDeliveryDegreeDay AS NVARCHAR(20))
									END) 
				,dblDailyUse = (CASE WHEN H.strCurrentSeason = ''Summer'' THEN C.dblSummerDailyUse
								WHEN H.strCurrentSeason = ''Winter'' THEN  C.dblWinterDailyUse
								ELSE Coalesce(C.dblWinterDailyUse,0) End) 
				, strFillGroupCode = ISNULL( I.strFillGroupCode,'''')
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
				, strBetweenDlvry = (CASE WHEN C.intFillMethodId = U.intFillMethodId THEN CONVERT(VARCHAR,C.dtmNextDeliveryDate,101)
										ELSE CAST((CONVERT(INT,C.dblDegreeDayBetweenDelivery)) AS NVARCHAR(10))
									END)  
				, strLocation = (CASE WHEN ISNUMERIC(C.strLocation) = 1 THEN C.strLocation
								 ELSE SUBSTRING(C.strLocation, PATINDEX(''%[^0]%'',C.strLocation), 50) 
								 END)  
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
			FROM tblTMCustomer A 
			INNER JOIN tblEMEntity Ent
				ON A.intCustomerNumber = Ent.intEntityId
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityCustomerId
			INNER JOIN [tblEMEntityToContact] CustToCon 
				ON Cus.intEntityCustomerId = CustToCon.intEntityId 
					and CustToCon.ysnDefaultContact = 1
			INNER JOIN tblEMEntity Con 
				ON CustToCon.intEntityContactId = Con.intEntityId
			INNER JOIN [tblEMEntityLocation] Loc 
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
					,strCategoryCode = ISNULL(CCC.strCategoryCode,'''')
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
				WHERE strType = ''Salesperson''
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
			,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany) Q
			,(SELECT TOP 1 intFillMethodId FROM tblTMFillMethod WHERE strFillMethod = ''Julian Calendar'') U
			,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
			WHERE Cus.ysnActive = 1 and C.ysnActive = 1
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateDeliveryFillReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateDeliveryFillReportView'
GO 
	EXEC ('uspTMRecreateDeliveryFillReportView')
GO
	sp_refreshview vyuTMDeliveryFillWithItemPriceReport
GO 
	PRINT 'END OF EXECUTE uspTMRecreateDeliveryFillReportView'
GO

