﻿GO
PRINT 'START OF CREATING vwDispatch VIEW'
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwDispatch')
	DROP VIEW vwDispatch
GO

IF  ((((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1) OR ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1)) and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwitmmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwslsmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwlocmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwcusmst') = 1 and
	(SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
BEGIN
	EXEC('
	CREATE VIEW [dbo].[vwDispatch]
		AS
		SELECT
		DispatchID = A.intDispatchID,
		CustomerNumber = H.vwcus_key COLLATE Latin1_General_CI_AS + '' '' + CASE H.vwcus_co_per_ind_cp COLLATE Latin1_General_CI_AS
				WHEN ''C'' THEN RTRIM(H.vwcus_last_name) COLLATE Latin1_General_CI_AS + H.vwcus_first_name COLLATE Latin1_General_CI_AS
				ELSE RTRIM(H.vwcus_last_name) COLLATE Latin1_General_CI_AS + '','' + H.vwcus_first_name COLLATE Latin1_General_CI_AS
				END,
		CustomerName = 
				CASE H.vwcus_co_per_ind_cp
				WHEN ''C'' THEN RTRIM(H.vwcus_last_name) + H.vwcus_first_name
				ELSE RTRIM(H.vwcus_last_name) + '','' + H.vwcus_first_name
				END,
		SiteNumber = RIGHT(CAST(''0000'' + CAST(B.intSiteNumber as varchar) as varchar), 4)+'' ''+LTRIM(B.strSiteAddress),--B.intSiteNumber,
		SiteAddress = B.strSiteAddress,
		CustomerID = B.intCustomerID,
		SiteDescription = B.strDescription,
		SiteLocation = B.strLocation,
		SiteID = B.intSiteID,
		RunOutDate = B.dtmRunOutDate,
		ProductNo = F.vwitm_no,
		ProductDesc = RTRIM(F.vwitm_desc),
		ProductID = F.A4GLIdentity,
		ClockNo = D.strClockNumber,
		DispatchRequestedDate = A.dtmRequestedDate,
		DispatchDate = A.dtmDispatchingDate,
		MinimumQuantity = A.dblMinimumQuantity,
		Price = A.dblPrice,
		Total = A.dblTotal,
		DriverName = RTRIM(G.vwsls_name),
		DriverID = G.vwsls_slsmn_id,
		NextDeliveryDegreeDay = B.intNextDeliveryDegreeDay,
		isDispatched = A.ysnDispatched,
		RouteName = E.strRouteId,
		RouteID = E.intRouteId,
		intConcurrencyId = 0
		FROM tblTMDispatch A
		INNER JOIN tblTMSite B ON A.intSiteID = B.intSiteID
		INNER JOIN tblTMCustomer C ON B.intCustomerID = C.intCustomerID
		INNER JOIN tblTMClock D ON D.intClockID = B.intClockID
		INNER JOIN tblTMRoute E ON B.intRouteId = E.intRouteId
		INNER JOIN vwitmmst F ON CAST(F.A4GLIdentity AS INT) = B.intProduct 
		INNER JOIN vwslsmst G ON CAST(G.A4GLIdentity AS INT) = A.intDriverID
		INNER JOIN vwcusmst H ON H.A4GLIdentity = C.intCustomerNumber
		WHERE B.ysnActive  = 1
			AND H.vwcus_active_yn = ''Y''
		
')
	
END
ELSE
BEGIN
	IF(((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwitmmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwslsmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwlocmst') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'vwcusmst') = 1))
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vwDispatch]
				AS
				SELECT
				DispatchID = A.intDispatchID,
				CustomerNumber = H.vwcus_key COLLATE Latin1_General_CI_AS + '' '' + CASE H.vwcus_co_per_ind_cp COLLATE Latin1_General_CI_AS
						WHEN ''C'' THEN RTRIM(H.vwcus_last_name) COLLATE Latin1_General_CI_AS + H.vwcus_first_name COLLATE Latin1_General_CI_AS
						ELSE RTRIM(H.vwcus_last_name) COLLATE Latin1_General_CI_AS + '','' + H.vwcus_first_name COLLATE Latin1_General_CI_AS
						END,
				CustomerName = 
						CASE H.vwcus_co_per_ind_cp
						WHEN ''C'' THEN RTRIM(H.vwcus_last_name) + H.vwcus_first_name
						ELSE RTRIM(H.vwcus_last_name) + '','' + H.vwcus_first_name
						END,
				SiteNumber = RIGHT(CAST(''0000'' + CAST(B.intSiteNumber as varchar) as varchar), 4)+'' ''+LTRIM(B.strSiteAddress),--B.intSiteNumber,
				SiteAddress = B.strSiteAddress,
				CustomerID = B.intCustomerID,
				SiteDescription = B.strDescription,
				SiteLocation = B.strLocation,
				SiteID = B.intSiteID,
				RunOutDate = B.dtmRunOutDate,
				ProductNo = F.vwitm_no,
				ProductDesc = RTRIM(F.vwitm_desc),
				ProductID = F.A4GLIdentity,
				ClockNo = D.strClockNumber,
				DispatchRequestedDate = A.dtmRequestedDate,
				DispatchDate = A.dtmDispatchingDate,
				MinimumQuantity = A.dblMinimumQuantity,
				Price = A.dblPrice,
				Total = A.dblTotal,
				DriverName = RTRIM(G.vwsls_name),
				DriverID = G.vwsls_slsmn_id,
				NextDeliveryDegreeDay = B.intNextDeliveryDegreeDay,
				isDispatched = A.ysnDispatched,
				RouteName = E.strRouteId,
				RouteID = E.intRouteId,
				intConcurrencyId = 0
				FROM tblTMDispatch A
				INNER JOIN tblTMSite B ON A.intSiteID = B.intSiteID
				INNER JOIN tblTMCustomer C ON B.intCustomerID = C.intCustomerID
				INNER JOIN tblTMClock D ON D.intClockID = B.intClockID
				INNER JOIN tblTMRoute E ON B.intRouteId = E.intRouteId
				INNER JOIN vwlocmst K ON B.intLocationId = K.A4GLIdentity
				INNER JOIN vwitmmst F ON CAST(F.A4GLIdentity AS INT) = B.intProduct 
					AND K.vwloc_loc_no COLLATE Latin1_General_CI_AS = F.vwitm_loc_no COLLATE Latin1_General_CI_AS
				INNER JOIN vwslsmst G ON CAST(G.A4GLIdentity AS INT) = A.intDriverID
				INNER JOIN vwcusmst H ON H.A4GLIdentity = C.intCustomerNumber
				WHERE B.ysnActive  = 1
					AND H.vwcus_active_yn = ''Y''
		
		')
	END
END

GO
PRINT 'END OF CREATING vwDispatch VIEW'
GO
