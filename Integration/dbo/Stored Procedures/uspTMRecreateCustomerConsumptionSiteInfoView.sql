GO
	PRINT 'START OF CREATING [uspTMRecreateCustomerConsumptionSiteInfoView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateCustomerConsumptionSiteInfoView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateCustomerConsumptionSiteInfoView
GO


CREATE PROCEDURE uspTMRecreateCustomerConsumptionSiteInfoView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMCustomerConsumptionSiteInfo')
	BEGIN
		DROP VIEW [vyuTMCustomerConsumptionSiteInfo]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMCustomerConsumptionSiteInfo]
			AS
			SELECT 
				intSiteId = B.intSiteID
				,intCustomerId = B.intCustomerID
				,strCustomerName = (CASE WHEN D.vwcus_co_per_ind_cp = ''C''   
										THEN  ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')   
										ELSE    
											CASE WHEN D.vwcus_first_name IS NULL OR RTRIM(D.vwcus_first_name) = ''''  
												THEN     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')    
												ELSE     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''')    
											END   
									END) COLLATE Latin1_General_CI_AS 
				,strSiteAddress = B.strSiteAddress
				,strSiteCity = B.strCity
				,strSiteState = B.strState
				,strSiteZip = B.strZipCode
				,intCompanyLocationId  = B.intLocationId
				,strCompanyLocationName  = J.strLocationName
				,dblLongitude = B.dblLongitude
				,dblLatitude = B.dblLatitude
				,strSiteDescription = B.strDescription
				,dblSiteTotalCapacity = B.dblTotalCapacity
				,dtmSiteRunOutDate = B.dtmRunOutDate
				,dblSiteEstimatedPercentLeft = B.dblEstimatedPercentLeft
				,strSiteComment = B.strComment
				,strSiteInstruction = B.strInstruction
				,B.ysnActive
				,strDriverNumber = M.vwsls_slsmn_id
				,strDriverName = M.vwsls_name
				,B.intRouteId 
				,strRoute = K.strRouteId
			FROM tblTMSite B
			INNER JOIN tblTMCustomer C
				ON B.intCustomerID = C.intCustomerID
			INNER JOIN vwcusmst D
				ON C.intCustomerNumber = D.A4GLIdentity
			LEFT JOIN vwlocmst I
				ON B.intLocationId = I.A4GLIdentity
			LEFT JOIN tblSMCompanyLocation J
				ON I.vwloc_loc_no  COLLATE Latin1_General_CI_AS = J.strLocationNumber
			LEFT JOIN vwslsmst M
				ON B.intDriverID = M.A4GLIdentity
			LEFT JOIN tblTMRoute K
				ON B.intRouteId = K.intRouteId
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMCustomerConsumptionSiteInfo]  
			AS  
				SELECT 
					intSiteId = B.intSiteID
					,intCustomerId = B.intCustomerID
					,strCustomerNumber = D.strEntityNo
					,strCustomerName = D.strName
					,strSiteAddress = B.strSiteAddress
					,strSiteCity = B.strCity
					,strSiteState = B.strState
					,strSiteZip = B.strZipCode
					,intCompanyLocationId  = B.intLocationId
					,strCompanyLocationName  = I.strLocationName
					,dblLongitude = B.dblLongitude
					,dblLatitude = B.dblLatitude
					,strSiteDescription = B.strDescription
					,dblSiteTotalCapacity = B.dblTotalCapacity
					,dtmSiteRunOutDate = B.dtmRunOutDate
					,dblSiteEstimatedPercentLeft = B.dblEstimatedPercentLeft
					,strSiteComment = B.strComment
					,strSiteInstruction = B.strInstruction
					,B.ysnActive
					,strDriverNumber = J.strEntityNo
					,strDriverName = J.strName
					,B.intRouteId 
					,strRoute = K.strRouteId
				FROM tblTMSite B
				INNER JOIN tblTMCustomer C
					ON B.intCustomerID = C.intCustomerID
				INNER JOIN tblEMEntity D
					ON C.intCustomerNumber = D.intEntityId
				LEFT JOIN tblSMCompanyLocation I
					ON B.intLocationId = I.intCompanyLocationId
				LEFT JOIN tblEMEntity J
					ON B.intDriverID = J.intEntityId
				LEFT JOIN tblTMRoute K
					ON B.intRouteId = K.intRouteId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateCustomerConsumptionSiteInfoView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateCustomerConsumptionSiteInfoView] SP'
GO
	EXEC ('uspTMRecreateCustomerConsumptionSiteInfoView')
GO
	PRINT 'END OF Execute [uspTMRecreateCustomerConsumptionSiteInfoView] SP'
GO
