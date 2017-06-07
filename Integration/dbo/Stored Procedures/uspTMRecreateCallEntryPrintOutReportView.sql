GO
	PRINT 'START OF CREATING [uspTMRecreateCallEntryPrintOutReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateCallEntryPrintOutReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateCallEntryPrintOutReportView
GO

CREATE PROCEDURE uspTMRecreateCallEntryPrintOutReportView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMCallEntryPrintOutReport') 
	BEGIN
		DROP VIEW vyuTMCallEntryPrintOutReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcntmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMCallEntryPrintOutReport]  
				AS 

				SELECT 
					intCustomerId = A.intCustomerID 
					,dblProductCost =	ISNULL(F.dblPrice, 0.0)
					,dblQuantity = COALESCE (F.dblQuantity, 0.0) 
					,strCustomerLastName = RTRIM (LTRIM(B.vwcus_last_name)) 
					,strCustomerFirstName = RTRIM(LTRIM(B.vwcus_first_name)) 
					,strCustomerName = (CASE WHEN B.vwcus_co_per_ind_cp = ''C'' 
											THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   
										WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  
											THEN     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    
										ELSE     RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)
									 END)  COLLATE Latin1_General_CI_AS
					,strPhoneNumber = B.vwcus_phone 
					,strCustomerNumber = B.vwcus_key 
					,strCustomerZipCode = B.vwcus_zip 
					,strTaxState = ISNULL(K.vwlcl_tax_state, B.vwcus_tax_state)
					,dblCreditLimit =  CAST(B.vwcus_cred_limit AS NUMERIC(18,6))
					,dblCustomerPer1 = CAST(B.vwcus_ar_per1 AS NUMERIC(18,6))
					,dblLastStatementBalance = CAST(B.vwcus_last_stmt_bal AS NUMERIC(18,6))
					,dblBudgetAmountDue = CAST(B.vwcus_budget_amt_due AS NUMERIC(18,6))
					,dblCustomerFuture =  CAST(B.vwcus_ar_future AS NUMERIC(18,6))
					,intCustomerPriceLevel = CAST(B.vwcus_prc_lvl AS INT)
					,dblCredits = CAST((B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblTotalPast = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblARBalance = CAST((B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblPastCredit = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,C.intSiteNumber
					,dblLastDeliveredGal = ISNULL(C.dblLastDeliveredGal, 0)
					,C.intRouteId
					,C.strSequenceID
					,intLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay, 0)
					,strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
					,strCity = (CASE WHEN C.strSiteAddress IS NOT NULL 
										THEN '', '' + C.strCity
										ELSE C.strCity 
								END) 
					,strState = (CASE WHEN C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL 
										THEN '', '' + C.strState
										ELSE C.strState 
									END)
					,strZipCode = (CASE WHEN C.strState IS NOT NULL AND C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL
										THEN '' '' + C.strZipCode 
										ELSE C.strZipCode 
								END) 
					,strSiteComment = C.strComment
					,C.strInstruction
					,C.dblDegreeDayBetweenDelivery
					,C.dblTotalCapacity
					,C.dblTotalReserve
					,strSiteDescription = C.strDescription
					,dblLastGalsInTank = ISNULL(C.dblLastGalsInTank, 0)
					,C.dtmLastDeliveryDate
					,intSiteId = C.intSiteID
					,C.intDriverID
					,dblEstimatedPercentLeft = (C.dblEstimatedPercentLeft / 100)
					,C.dtmNextDeliveryDate
					,intNextDeliveryDegreeDay = ISNULL(C.intNextDeliveryDegreeDay, 0)
					,SiteLabel = (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN ''Date'' ELSE ''DD'' END)
					,SiteDeliveryDD = (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL 
											THEN CONVERT (VARCHAR,C.dtmNextDeliveryDate, 101) 
											ELSE CAST(C.intNextDeliveryDegreeDay AS NVARCHAR(20)) 
										END)
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= H.intBeginSummerMonth AND  MONTH(GETDATE()) < H.intBeginWinterMonth
										THEN ISNULL(C.dblSummerDailyUse,0.0) 
										ELSE ISNULL(C.dblWinterDailyUse,0.0)
									END)
					,F.dblPercentLeft
					,F.dblMinimumQuantity
					,F.dtmRequestedDate
					,strDispatchComment = F.strComments
					,C.intFillMethodId
					,strDriverName = J.vwsls_name 
					,strDriverID = J.vwsls_slsmn_id
					,strFillMethod = O.strFillMethod
					,strProductID = ISNULL (M.vwitm_no, G.vwitm_no)
					,strProductDescription = ISNULL(M.vwitm_desc, G.vwitm_desc)
					,strRouteId =P.strRouteId
					,strLocation = (CASE WHEN ISNUMERIC (C.strLocation) = 1 
										THEN C.strLocation 
										ELSE SUBSTRING (C.strLocation, PATINDEX (''%[^0]%'', C.strLocation), 50) 
									END)
					,F.dtmCallInDate
					,strEnteredBy = N.strUserName 
					,F.intUserID
					,strTermDescription = I.vwtrm_desc
					,strTermId = I.vwtrm_key_n 
					,Z.strCompanyName
					,strPriceLevelName = CAST(B.vwcus_prc_lvl AS NVARCHAR(50))
					,strBetweenDlvry = (CASE WHEN O.strFillMethod = ''Julian Calendar'' THEN R.strDescription
							ELSE CAST((CONVERT(NUMERIC(18,2),C.dblDegreeDayBetweenDelivery)) AS NVARCHAR(10))
						END)  
					,dblNextDeliveryGallons = ISNULL(C.dblLastGalsInTank,0.0) - ISNULL(C.dblEstimatedGallonsLeft,0.0)
				FROM tblTMCustomer A 
				INNER JOIN vwcusmst B 
					ON A.intCustomerNumber = B.A4GLIdentity 
				INNER JOIN tblTMSite C 
					ON A.intCustomerID = C.intCustomerID 
				LEFT JOIN vwlocmst L 
					ON C.intLocationId = L.A4GLIdentity 
				LEFT JOIN tblTMDispatch F 
					ON C.intSiteID = F.intSiteID 
				LEFT JOIN vwitmmst G 
					ON C.intProduct = G.A4GLIdentity 
					AND G.vwitm_loc_no COLLATE Latin1_General_CI_AS = L.vwloc_loc_no COLLATE Latin1_General_CI_AS 
				LEFT JOIN vwtrmmst I 
					ON F.intDeliveryTermID = I.vwtrm_key_n 
				LEFT JOIN vwitmmst M 
					ON F.intSubstituteProductID = M.A4GLIdentity 
					AND M.vwitm_loc_no COLLATE Latin1_General_CI_AS = L.vwloc_loc_no COLLATE Latin1_General_CI_AS 
				LEFT JOIN tblTMClock H 
					ON H.intClockID = C.intClockID 
				LEFT JOIN vwslsmst J 
					ON J.A4GLIdentity = F.intDriverID 
				LEFT JOIN vwlclmst K 
					ON C.intTaxStateID = K.A4GLIdentity 
				LEFT JOIN tblSMUserSecurity N
					ON F.intUserID = N.intEntityId
				LEFT JOIN tblTMFillMethod O
					ON C.intFillMethodId = O.intFillMethodId
				LEFT JOIN tblTMRoute P
					ON C.intRouteId = P.intRouteId
				LEFT JOIN tblTMGlobalJulianCalendar R
					ON C.intGlobalJulianCalendarId = R.intGlobalJulianCalendarId
				,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
				WHERE vwcus_active_yn = ''Y'' 
					AND C.ysnActive = 1
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
			CREATE VIEW [dbo].[vyuTMCallEntryPrintOutReport]
			AS  
				
				SELECT 
					intCustomerId = A.intCustomerID 
					,dblProductCost =	ISNULL(F.dblPrice, 0.0)
					,dblQuantity = COALESCE (F.dblQuantity, 0.0) 
					,strCustomerLastName = RTRIM (LTRIM(B.vwcus_last_name)) 
					,strCustomerFirstName = RTRIM(LTRIM(B.vwcus_first_name)) 
					,strCustomerName = B.strFullCustomerName
					,strPhoneNumber = B.vwcus_phone 
					,strCustomerNumber = B.vwcus_key 
					,strCustomerZipCode = B.vwcus_zip 
					,strTaxState = ISNULL(K.strTaxGroup, B.vwcus_tax_state)
					,dblCreditLimit =  CAST(B.vwcus_cred_limit AS NUMERIC(18,6))
					,dblCustomerPer1 = CAST(B.vwcus_ar_per1 AS NUMERIC(18,6))
					,dblLastStatementBalance = CAST(B.vwcus_last_stmt_bal AS NUMERIC(18,6))
					,dblBudgetAmountDue = CAST(B.vwcus_budget_amt_due AS NUMERIC(18,6))
					,dblCustomerFuture =  CAST(B.vwcus_ar_future AS NUMERIC(18,6))
					,intCustomerPriceLevel = CAST(B.vwcus_prc_lvl AS INT)
					,dblCredits = CAST((B.vwcus_cred_reg + B.vwcus_cred_ppd + B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblTotalPast = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblARBalance = CAST((B.vwcus_ar_future + B.vwcus_ar_per1 + B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ppd - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,dblPastCredit = CAST((B.vwcus_ar_per2 + B.vwcus_ar_per3 + B.vwcus_ar_per4 + B.vwcus_ar_per5 - B.vwcus_cred_reg - B.vwcus_cred_ga) AS NUMERIC(18,6))
					,C.intSiteNumber
					,dblLastDeliveredGal = ISNULL(C.dblLastDeliveredGal, 0)
					,C.intRouteId
					,C.strSequenceID
					,intLastDeliveryDegreeDay = ISNULL(C.intLastDeliveryDegreeDay, 0)
					,strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
					,strCity = (CASE WHEN C.strSiteAddress IS NOT NULL 
										THEN '', '' + C.strCity
										ELSE C.strCity 
								END) 
					,strState = (CASE WHEN C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL 
										THEN '', '' + C.strState
										ELSE C.strState 
									END)
					,strZipCode = (CASE WHEN C.strState IS NOT NULL AND C.strCity IS NOT NULL AND C.strSiteAddress IS NOT NULL
										THEN '' '' + C.strZipCode 
										ELSE C.strZipCode 
								END) 
					,strSiteComment = C.strComment
					,C.strInstruction
					,C.dblDegreeDayBetweenDelivery
					,C.dblTotalCapacity
					,C.dblTotalReserve
					,strSiteDescription = C.strDescription
					,dblLastGalsInTank = ISNULL(C.dblLastGalsInTank, 0)
					,C.dtmLastDeliveryDate
					,intSiteId = C.intSiteID
					,C.intDriverID
					,dblEstimatedPercentLeft = (C.dblEstimatedPercentLeft / 100)
					,C.dtmNextDeliveryDate
					,intNextDeliveryDegreeDay = ISNULL(C.intNextDeliveryDegreeDay, 0)
					,SiteLabel = (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL THEN ''Date'' ELSE ''DD'' END)
					,SiteDeliveryDD = (CASE WHEN C.dtmNextDeliveryDate IS NOT NULL 
											THEN CONVERT (VARCHAR,C.dtmNextDeliveryDate, 101) 
											ELSE CAST(C.intNextDeliveryDegreeDay AS NVARCHAR(20)) 
										END)
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= H.intBeginSummerMonth AND  MONTH(GETDATE()) < H.intBeginWinterMonth
										THEN ISNULL(C.dblSummerDailyUse,0.0) 
										ELSE ISNULL(C.dblWinterDailyUse,0.0)
									END)
					,F.dblPercentLeft
					,F.dblMinimumQuantity
					,F.dtmRequestedDate
					,strDispatchComment = F.strComments
					,C.intFillMethodId
					,strDriverName = J.strName 
					,strDriverID = J.strEntityNo
					,strFillMethod = O.strFillMethod
					,strProductID = ISNULL (M.strItemNo, G.strItemNo)
					,strProductDescription = ISNULL(M.strDescription, G.strDescription)
					,strRouteId =P.strRouteId
					,strLocation = (CASE WHEN ISNUMERIC (C.strLocation) = 1 
										THEN C.strLocation 
										ELSE SUBSTRING (C.strLocation, PATINDEX (''%[^0]%'', C.strLocation), 50) 
									END)
					,F.dtmCallInDate
					,strEnteredBy = N.strUserName 
					,F.intUserID
					,strTermDescription = I.strTerm
					,strTermId = CAST(I.intTermID AS NVARCHAR(8)) 
					,Z.strCompanyName
					,strPriceLevelName = Q.strPricingLevelName
					,strBetweenDlvry = (CASE WHEN O.strFillMethod = ''Julian Calendar'' THEN R.strDescription
							ELSE CAST((CONVERT(NUMERIC(18,2),C.dblDegreeDayBetweenDelivery)) AS NVARCHAR(10))
						END) 
					,dblNextDeliveryGallons = ISNULL(C.dblLastGalsInTank,0.0) - ISNULL(C.dblEstimatedGallonsLeft,0.0) 
				FROM tblTMCustomer A 
				INNER JOIN vyuTMCustomerEntityView B 
					ON A.intCustomerNumber = B.A4GLIdentity 
				INNER JOIN tblTMSite C 
					ON A.intCustomerID = C.intCustomerID 
				LEFT JOIN tblSMCompanyLocation L 
					ON C.intLocationId = L.intCompanyLocationId 
				LEFT JOIN tblTMDispatch F 
					ON C.intSiteID = F.intSiteID 
				LEFT JOIN  tblICItem G
					ON C.intProduct = G.intItemId
				LEFT JOIN tblSMTerm I 
					ON F.intDeliveryTermID = I.intTermID 
				LEFT JOIN tblICItem M 
					ON F.intSubstituteProductID = M.intItemId 
				LEFT JOIN tblTMClock H 
					ON H.intClockID = C.intClockID 
				LEFT JOIN tblEMEntity J 
					ON J.intEntityId = F.intDriverID 
				LEFT JOIN tblSMTaxGroup K 
					ON C.intTaxStateID = K.intTaxGroupId 
				LEFT JOIN tblSMUserSecurity N
					ON F.intUserID = N.intEntityId
				LEFT JOIN tblTMFillMethod O
					ON C.intFillMethodId = O.intFillMethodId
				LEFT JOIN tblTMRoute P
					ON C.intRouteId = P.intRouteId
				LEFT JOIN tblSMCompanyLocationPricingLevel Q
					ON C.intCompanyLocationPricingLevelId = Q.intCompanyLocationPricingLevelId
				LEFT JOIN tblTMGlobalJulianCalendar R
					ON C.intGlobalJulianCalendarId = R.intGlobalJulianCalendarId
				,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
				WHERE vwcus_active_yn = ''Y'' 
					AND C.ysnActive = 1
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateCallEntryPrintOutReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateCallEntryPrintOutReportView'
GO 
	EXEC ('uspTMRecreateCallEntryPrintOutReportView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateCallEntryPrintOutReportView'
GO

