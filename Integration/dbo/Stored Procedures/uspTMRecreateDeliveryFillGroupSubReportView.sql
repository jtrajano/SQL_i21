GO
PRINT 'START OF CREATING [uspTMRecreateDeliveryFillGroupSubReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeliveryFillGroupSubReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeliveryFillGroupSubReportView
GO

CREATE PROCEDURE uspTMRecreateDeliveryFillGroupSubReportView 
AS
BEGIN
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
	PRINT 'END OF CREATING [uspTMRecreateDeliveryFillGroupSubReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateDeliveryFillGroupSubReportView'
GO 
	EXEC ('uspTMRecreateDeliveryFillGroupSubReportView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateDeliveryFillGroupSubReportView'
GO

