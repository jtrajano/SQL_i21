GO
	PRINT 'START OF CREATING [uspTMDeliveryFillGroupSubReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMDeliveryFillGroupSubReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMDeliveryFillGroupSubReportView
GO

CREATE PROCEDURE uspTMDeliveryFillGroupSubReportView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveryFillGroupSubReport') 
	BEGIN
		DROP VIEW vyuTMDeliveryFillGroupSubReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcntmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].vyuTMDeliveryFillGroupSubReport  
				AS 

				SELECT 
					strCustomerNumber = A.vwcus_key 
					,strCustomerName = A.strFullCustomerName
					,C.intSiteNumber
					,strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
					,strSiteDescription = C.strDescription 
					,strFillGroupCode = ISNULL(D.strFillGroupCode, '''')  
					,C.intFillGroupId 
					,strFillGroupDescription = D.strDescription
					,ysnFillGroupActive = D.ysnActive
					,intSiteId = intSiteID
				FROM vwcusmst A 
				INNER JOIN tblTMCustomer B 
					ON A.A4GLIdentity = B.intCustomerNumber 
				INNER JOIN tblTMSite C 
					ON B.intCustomerID = C.intCustomerID 
				INNER JOIN tblTMFillGroup D 
					ON D.intFillGroupId = C.intFillGroupId
				WHERE C.ysnActive= 1 
					AND  A.vwcus_active_yn = ''Y'' 
					AND (C.ysnOnHold = 0 OR C.dtmOnHoldEndDate < DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))   
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
			CREATE VIEW [dbo].vyuTMDeliveryFillGroupSubReport  
			AS 

			SELECT 
				strCustomerNumber = A.vwcus_key 
				,strCustomerName = A.strFullCustomerName
				,C.intSiteNumber
				,strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), '' ''),CHAR(10), '' '') 
				,strSiteDescription = C.strDescription 
				,strFillGroupCode = ISNULL(D.strFillGroupCode, '''')  
				,C.intFillGroupId 
				,strFillGroupDescription = D.strDescription
				,ysnFillGroupActive = D.ysnActive
				,intSiteId = intSiteID
			FROM vyuTMCustomerEntityView A 
			INNER JOIN tblTMCustomer B 
				ON A.A4GLIdentity = B.intCustomerNumber 
			INNER JOIN tblTMSite C 
				ON B.intCustomerID = C.intCustomerID 
			INNER JOIN tblTMFillGroup D 
				ON D.intFillGroupId = C.intFillGroupId
			WHERE C.ysnActive= 1 
				AND  A.vwcus_active_yn = ''Y'' 
				AND (C.ysnOnHold = 0 OR C.dtmOnHoldEndDate < DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))    
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMDeliveryFillGroupSubReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMDeliveryFillGroupSubReportView'
GO 
	EXEC ('uspTMDeliveryFillGroupSubReportView')
GO 
	PRINT 'END OF EXECUTE uspTMDeliveryFillGroupSubReportView'
GO

