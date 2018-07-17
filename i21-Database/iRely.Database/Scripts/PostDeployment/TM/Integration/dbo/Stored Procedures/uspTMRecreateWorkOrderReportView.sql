GO
	PRINT 'START OF CREATING [uspTMRecreateWorkOrderReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateWorkOrderReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateWorkOrderReportView
GO

CREATE PROCEDURE uspTMRecreateWorkOrderReportView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMWorkOrderReport') 
	BEGIN
		DROP VIEW vyuTMWorkOrderReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMWorkOrderReport]
				AS

				SELECT 
					strCustomerNumber = CUS.vwcus_key COLLATE Latin1_General_CI_AS
					,intWorkOrderId = WRK.intWorkOrderID
					,intSiteId = STE.intSiteID
					,strCustomerName = (CASE WHEN CUS.vwcus_co_per_ind_cp = ''C'' 
																THEN RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init) + RTRIM(CUS.vwcus_name_suffix)   
															WHEN CUS.vwcus_first_name IS NULL OR RTRIM(CUS.vwcus_first_name) = ''''  
																THEN     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix)    
															ELSE     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix) + '', '' + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init)
															END)  COLLATE Latin1_General_CI_AS
					,strCustomerAddress = (CASE WHEN  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' +  RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city)  + '' '' + RTRIM(CUS.vwcus_zip)
		
											WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city)  + '', '' + RTRIM(CUS.vwcus_state)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
											RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) 
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '' '' + RTRIM(CUS.vwcus_zip)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_state)
		
											When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
											RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city)

											END) COLLATE Latin1_General_CI_AS
					,dblCustomerPer1 = CUS.vwcus_ar_per1
					,dblCustomerPer2 = CUS.vwcus_ar_per2 
					,dblCustomerPer3 = CUS.vwcus_ar_per3 
					,dblCustomerPer4 = CUS.vwcus_ar_per4
					,strCustomerPhone = CUS.vwcus_phone COLLATE Latin1_General_CI_AS
					,strCustomerPhone2 =  CUS.vwcus_phone2 COLLATE Latin1_General_CI_AS
					,strCustomerTermDescription = (CASE 
													WHEN A.ysnUseDeliveryTermOnCS = 1 THEN 
														CAST(STE.intDeliveryTermID AS NVARCHAR(5))+ '' - '' + ISNULL(B.vwtrm_desc,'''') 
													WHEN A.ysnUseDeliveryTermOnCS = 0 THEN 
														CAST(CUS.vwcus_terms_cd AS NVARCHAR(5))+ '' - '' + (SELECT ISNULL(vwtrm_desc,'''') FROM vwtrmmst WHERE vwtrm_key_n = CUS.vwcus_terms_cd)
													END) COLLATE Latin1_General_CI_AS
	
					,strSiteAddress = REPLACE(STE.strSiteAddress,CHAR(13),'' '') + '', '' + RTRIM(strCity) + '', '' + RTRIM(strState) + '', '' + RTRIM(strZipCode) 
					,strSiteInstruction = STE.strInstruction
					,dtmDateCreated = DATEADD(DAY, DATEDIFF(DAY, 0, WRK.dtmDateCreated), 0)
					,dtmDateScheduled = WRK.dtmDateScheduled
					,strAdditonalInfo = WRK.strAdditionalInfo
					,strPerformer = PRF.vwsls_name
					,strPerformerId = PRF.vwsls_slsmn_id
					,C.strWorkStatus
					,Z.strCompanyName
					,strLocationName = loc.vwloc_loc_no
					,CAT.strWorkOrderCategory
				FROM tblTMCustomer CST 
				INNER JOIN vwcusmst CUS 
					ON CST.intCustomerNumber = CUS.A4GLIdentity 
				INNER JOIN tblTMSite STE 
					ON CST.intCustomerID = STE.intCustomerID
				INNER JOIN tblTMWorkOrder WRK 
					ON STE.intSiteID = WRK.intSiteID
				LEFT JOIN tblTMWorkStatusType C
					ON WRK.intWorkStatusTypeID = C.intWorkStatusID
				LEFT JOIN vwslsmst PRF 
					ON WRK.intPerformerID = PRF.A4GLIdentity
				LEFT JOIN vwtrmmst B
					ON STE.intDeliveryTermID = B.A4GLIdentity
				LEFT JOIN vwlocmst loc
					ON STE.intLocationId = loc.A4GLIdentity
				LEFT JOIN tblTMWorkOrderCategory CAT
					ON WRK.intWorkOrderCategoryId = CAT.intWorkOrderCategoryId
				,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
				,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany) A 
				WHERE STE.ysnActive = 1  AND CUS.vwcus_active_yn = ''Y'' 
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
			CREATE VIEW [dbo].[vyuTMWorkOrderReport]
			AS

			SELECT 
				strCustomerNumber = CUS.vwcus_key COLLATE Latin1_General_CI_AS
				,intWorkOrderId = WRK.intWorkOrderID
				,intSiteId = STE.intSiteID
				,strCustomerName = (CASE WHEN CUS.vwcus_co_per_ind_cp = ''C'' 
															THEN RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init) + RTRIM(CUS.vwcus_name_suffix)   
														WHEN CUS.vwcus_first_name IS NULL OR RTRIM(CUS.vwcus_first_name) = ''''  
															THEN     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix)    
														ELSE     RTRIM(CUS.vwcus_last_name) + RTRIM(CUS.vwcus_name_suffix) + '', '' + RTRIM(CUS.vwcus_first_name) + RTRIM(CUS.vwcus_mid_init)
														END)  COLLATE Latin1_General_CI_AS
				,strCustomerAddress = (CASE WHEN  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' +  RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city)  + '' '' + RTRIM(CUS.vwcus_zip)
		
										WHEN ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2)  + '', '' + RTRIM(CUS.vwcus_city)  + '', '' + RTRIM(CUS.vwcus_state)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
										RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state) 
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_state) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_city) + '', '' + RTRIM(CUS.vwcus_state)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') != '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '' '' + RTRIM(CUS.vwcus_zip)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_state)
		
										When  ISNULL(RTRIM(CUS.vwcus_addr2),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_addr),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_city),'''') != '''' AND ISNULL(RTRIM(CUS.vwcus_state),'''') = '''' AND ISNULL(RTRIM(CUS.vwcus_zip),'''') = '''' THEN
										RTRIM(CUS.vwcus_addr) + '', '' + RTRIM(CUS.vwcus_addr2) + '', '' + RTRIM(CUS.vwcus_city)

										END) COLLATE Latin1_General_CI_AS
				,dblCustomerPer1 = CUS.vwcus_ar_per1
				,dblCustomerPer2 = CUS.vwcus_ar_per2 
				,dblCustomerPer3 = CUS.vwcus_ar_per3 
				,dblCustomerPer4 = CUS.vwcus_ar_per4
				,strCustomerPhone = CUS.vwcus_phone COLLATE Latin1_General_CI_AS
				,strCustomerPhone2 =  CUS.vwcus_phone2 COLLATE Latin1_General_CI_AS
				,strCustomerTermDescription = (CASE 
												WHEN A.ysnUseDeliveryTermOnCS = 1 THEN 
													ISNULL(B.strTerm,'''') 
												WHEN A.ysnUseDeliveryTermOnCS = 0 THEN 
													CUS.vwcus_termdescription
												END) COLLATE Latin1_General_CI_AS
	
				,strSiteAddress = REPLACE(STE.strSiteAddress,CHAR(13),'' '') + '', '' + RTRIM(STE.strCity) + '', '' + RTRIM(STE.strState) + '', '' + RTRIM(STE.strZipCode) 
				,strSiteInstruction = STE.strInstruction
				,dtmDateCreated = DATEADD(DAY, DATEDIFF(DAY, 0, WRK.dtmDateCreated), 0)
				,dtmDateScheduled = WRK.dtmDateScheduled
				,strAdditonalInfo = WRK.strAdditionalInfo
				,strPerformer = PRF.strName
				,strPerformerId = PRF.strEntityNo
				,C.strWorkStatus
				,Z.strCompanyName
				,loc.strLocationName
				,CAT.strWorkOrderCategory
			FROM tblTMCustomer CST 
			INNER JOIN vyuTMCustomerEntityView CUS 
				ON CST.intCustomerNumber = CUS.A4GLIdentity 
			INNER JOIN tblTMSite STE 
				ON CST.intCustomerID = STE.intCustomerID
			INNER JOIN tblTMWorkOrder WRK 
				ON STE.intSiteID = WRK.intSiteID
			LEFT JOIN tblTMWorkStatusType C
				ON WRK.intWorkStatusTypeID = C.intWorkStatusID
			LEFT JOIN tblEMEntity PRF 
				ON WRK.intPerformerID = PRF.intEntityId
			LEFT JOIN tblSMTerm B
				ON STE.intDeliveryTermID = B.intTermID
			LEFT JOIN tblSMCompanyLocation loc
				ON STE.intLocationId = loc.intCompanyLocationId
			LEFT JOIN tblTMWorkOrderCategory CAT
				ON WRK.intWorkOrderCategoryId = CAT.intWorkOrderCategoryId
			,(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)Z
			,(SELECT TOP 1 ysnUseDeliveryTermOnCS FROM tblTMPreferenceCompany) A 
			WHERE STE.ysnActive = 1  AND CUS.vwcus_active_yn = ''Y'' 

	')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateWorkOrderReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateWorkOrderReportView'
GO 
	EXEC ('uspTMRecreateWorkOrderReportView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateWorkOrderReportView'
GO

