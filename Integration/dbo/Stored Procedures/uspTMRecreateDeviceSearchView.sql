GO
	PRINT 'START OF CREATING [uspTMRecreateDeviceSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeviceSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeviceSearchView
GO


CREATE PROCEDURE uspTMRecreateDeviceSearchView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeviceSearch')
	BEGIN
		DROP VIEW vyuTMDeviceSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeviceSearch]
			AS  
				SELECT 
					strSerialNumber = A.strSerialNumber
					,strDeviceType = D.strDeviceType
					,strManufacturerID = A.strManufacturerID
					,strManufacturerName = A.strManufacturerName
					,strInventoryStatusType = E.strInventoryStatusType
					,strSiteNumber = RIGHT(''000''+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
					,strSiteAddress = C.strSiteAddress
					,strCustomerID = G.vwcus_key COLLATE Latin1_General_CI_AS 
					,strCustomerName = (CASE WHEN G.vwcus_co_per_ind_cp = ''C''   
													THEN  ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_first_name),'''') + ISNULL(RTRIM(G.vwcus_mid_init),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''')   
													ELSE    
														CASE WHEN G.vwcus_first_name IS NULL OR RTRIM(G.vwcus_first_name) = ''''  
															THEN     ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''')    
															ELSE     ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(G.vwcus_first_name),'''') + ISNULL(RTRIM(G.vwcus_mid_init),'''')    
														END   
												END) COLLATE Latin1_General_CI_AS 
					,strOwnership = A.strOwnership
					,intDeviceId = A.intDeviceId
					,strLocationName = H.vwloc_name
					,dblTankCapacity = A.dblTankCapacity
					,intLocationId = A.intLocationId
					,strSiteCity = C.strCity
					,strSiteState = C.strState
					,strSiteZip = C.strZipCode
					,dtmPurchaseDate = A.dtmPurchaseDate
					,dblPurchasePrice = A.dblPurchasePrice
					,dtmManufacturedDate = A.dtmManufacturedDate 
					,strTankType = I.strTankType
					,dblEstimatedGalsInTank = A.dblEstimatedGalTank
					,strLeaseNumber = K.strLeaseNumber
					,intLeaseId  = K.intLeaseId
					,intConcurrencyId = 0
				FROM tblTMDevice A
				LEFT JOIN tblTMSiteDevice B
					ON A.intDeviceId = B.intDeviceId
				LEFT JOIN tblTMSite C
					ON B.intSiteID = C.intSiteID
				LEFT JOIN tblTMDeviceType D
					ON A.intDeviceTypeId = D.intDeviceTypeId
				LEFT JOIN tblTMInventoryStatusType E
					ON A.intInventoryStatusTypeId = E.intInventoryStatusTypeId
				LEFT JOIN tblTMCustomer F
					ON C.intCustomerID = F.intCustomerID
				LEFT JOIN vwcusmst G
					ON F.intCustomerNumber = G.A4GLIdentity
				LEFT JOIN vwlocmst H
					ON A.intLocationId = H.A4GLIdentity
				LEFT JOIN tblTMTankType I
					ON A.intTankTypeId = I.intTankTypeId
				LEFT JOIN tblTMLeaseDevice J
					ON A.intDeviceId = J.intDeviceId
				LEFT JOIN tblTMLease K
					ON J.intLeaseId = K.intLeaseId
				WHERE A.ysnAppliance <> 1
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeviceSearch]
			AS  
				SELECT 
					strSerialNumber = A.strSerialNumber
					,strDeviceType = D.strDeviceType
					,strManufacturerID = A.strManufacturerID
					,strManufacturerName = A.strManufacturerName
					,strInventoryStatusType = E.strInventoryStatusType
					,strSiteNumber = RIGHT(''000''+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
					,strSiteAddress = C.strSiteAddress
					,strCustomerID = G.strEntityNo
					,strCustomerName = G.strName
					,strOwnership = A.strOwnership
					,intDeviceId = A.intDeviceId
					,strLocationName = H.strLocationName
					,dblTankCapacity = A.dblTankCapacity
					,intLocationId = A.intLocationId
					,strSiteCity = C.strCity
					,strSiteState = C.strState
					,strSiteZip = C.strZipCode
					,dtmPurchaseDate = A.dtmPurchaseDate
					,dblPurchasePrice = A.dblPurchasePrice
					,dtmManufacturedDate = A.dtmManufacturedDate 
					,strTankType = I.strTankType
					,dblEstimatedGalsInTank = A.dblEstimatedGalTank
					,strLeaseNumber = K.strLeaseNumber
					,intLeaseId  = K.intLeaseId
					,intConcurrencyId = 0
				FROM tblTMDevice A
				LEFT JOIN tblTMSiteDevice B
					ON A.intDeviceId = B.intDeviceId
				LEFT JOIN tblTMSite C
					ON B.intSiteID = C.intSiteID
				LEFT JOIN tblTMDeviceType D
					ON A.intDeviceTypeId = D.intDeviceTypeId
				LEFT JOIN tblTMInventoryStatusType E
					ON A.intInventoryStatusTypeId = E.intInventoryStatusTypeId
				LEFT JOIN tblTMCustomer F
					ON C.intCustomerID = F.intCustomerID
				LEFT JOIN tblEMEntity G
					ON F.intCustomerNumber = G.intEntityId
				LEFT JOIN tblSMCompanyLocation H
					ON A.intLocationId = H.intCompanyLocationId
				LEFT JOIN tblTMTankType I
					ON A.intTankTypeId = I.intTankTypeId
				LEFT JOIN tblTMLeaseDevice J
					ON A.intDeviceId = J.intDeviceId
				LEFT JOIN tblTMLease K
					ON J.intLeaseId = K.intLeaseId
				WHERE A.ysnAppliance <> 1
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateDeviceSearchView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateDeviceSearchView] SP'
GO
	EXEC ('uspTMRecreateDeviceSearchView')
GO
	PRINT 'END OF Execute [uspTMRecreateDeviceSearchView] SP'
GO