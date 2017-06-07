GO
	PRINT 'START OF CREATING [uspTMRecreateLeakGasCheckSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateLeakGasCheckSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateLeakGasCheckSearchView
GO

CREATE PROCEDURE uspTMRecreateLeakGasCheckSearchView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMLeakGasCheckSearch') 
	BEGIN
		DROP VIEW vyuTMLeakGasCheckSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMLeakGasCheckSearch]
				AS
					SELECT 
						strLocation = D.vwloc_loc_no
						,strCustomerNumber = B.vwcus_key COLLATE Latin1_General_CI_AS 
						,strCustomerName = (CASE WHEN B.vwcus_co_per_ind_cp = ''C''   
												THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   
											ELSE  
												CASE WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  
													THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    
												ELSE
													RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)    
												END   
											END) COLLATE Latin1_General_CI_AS 
						,strSiteNumber = RIGHT(''0000''+ CAST(A.intSiteNumber AS VARCHAR(4)),4)
						,strSerialNumber = I.strSerialNumber
						,dblTankCapacity = I.dblTankCapacity
						,strTankType = J.strTankType
						,dtmLastLeakCheck = G.dtmLastLeakCheck
						,dtmLastGasCheck = G.dtmLastGasCheck
						,intSiteID = A.intSiteID
						,intCustomerID = A.intCustomerID
						,intLocationId = A.intLocationId
						,intConcurrencyId = 0
						,intDeviceId = I.intDeviceId
					FROM tblTMSite A
					INNER JOIN vwlocmst D
						ON A.intLocationId = D.A4GLIdentity
					INNER JOIN tblTMCustomer E 
						ON A.intCustomerID = E.intCustomerID
					INNER JOIN vwcusmst B 
						ON E.intCustomerNumber = B.A4GLIdentity
					INNER JOIN tblTMSiteDevice H
						ON A.intSiteID = H.intSiteID
					INNER JOIN tblTMDevice I
						ON H.intDeviceId = I.intDeviceId
					LEFT JOIN tblTMTankType J
						ON I.intTankTypeId = J.intTankTypeId
					LEFT JOIN tblTMDeviceType K
						ON I.intDeviceTypeId = K.intDeviceTypeId
					LEFT JOIN vyuTMLastLeakGasCheckTable G
						ON A.intSiteID = G.intSiteID
					WHERE ISNULL(I.ysnAppliance,0) = 0
						AND K.strDeviceType = ''Tank''
						AND A.ysnActive = 1
						AND B.vwcus_active_yn = ''Y''

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
			CREATE VIEW [dbo].[vyuTMLeakGasCheckSearch]
			AS  
				SELECT 
					strLocation = D.strLocationName
					,strCustomerNumber = B.strEntityNo
					,strCustomerName = B.strName
					,strSiteNumber = RIGHT(''0000''+ CAST(A.intSiteNumber AS VARCHAR(4)),4)
					,strSerialNumber = I.strSerialNumber
					,dblTankCapacity = I.dblTankCapacity
					,strTankType = J.strTankType
					,dtmLastLeakCheck = G.dtmLastLeakCheck
					,dtmLastGasCheck = G.dtmLastGasCheck
					,intSiteID = A.intSiteID
					,intCustomerID = A.intCustomerID
					,intLocationId = A.intLocationId
					,intConcurrencyId = 0
					,intDeviceId = I.intDeviceId
				FROM tblTMSite A
				INNER JOIN tblSMCompanyLocation D
					ON A.intLocationId = D.intCompanyLocationId
				INNER JOIN tblTMCustomer E 
					ON A.intCustomerID = E.intCustomerID
				INNER JOIN tblEMEntity B 
					ON E.intCustomerNumber = B.intEntityId
				INNER JOIN tblTMSiteDevice H
					ON A.intSiteID = H.intSiteID
				INNER JOIN tblTMDevice I
					ON H.intDeviceId = I.intDeviceId
				INNER JOIN tblARCustomer L
					ON B.intEntityId = L.intEntityId
				LEFT JOIN tblTMTankType J
					ON I.intTankTypeId = J.intTankTypeId
				LEFT JOIN tblTMDeviceType K
					ON I.intDeviceTypeId = K.intDeviceTypeId
				LEFT JOIN vyuTMLastLeakGasCheckTable G
					ON A.intSiteID = G.intSiteID
				WHERE ISNULL(I.ysnAppliance,0) = 0
					AND K.strDeviceType = ''Tank''
					AND A.ysnActive = 1
					AND L.ysnActive = 1
			
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateLeakGasCheckSearchView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateLeakGasCheckSearchView'
GO 
	EXEC ('uspTMRecreateLeakGasCheckSearchView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateLeakGasCheckSearchView'
GO

