GO
	PRINT 'START OF CREATING [uspTMRecreateSiteOrderView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateSiteOrderView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateSiteOrderView
GO


CREATE PROCEDURE uspTMRecreateSiteOrderView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMSiteOrder')
	BEGIN
		DROP VIEW vyuTMSiteOrder
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst') AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
			AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwslsmst'))
		BEGIN
			EXEC('
			CREATE VIEW [dbo].[vyuTMSiteOrder]  
			AS
	  
			SELECT
				A.intSiteID 
				,C.vwcus_key AS strCustomerNumber
				,(	CASE WHEN C.vwcus_co_per_ind_cp = ''C''   
					THEN    RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init) + RTRIM(C.vwcus_name_suffix)   
					ELSE    
						CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
							THEN     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix)    
						ELSE     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix) + '', '' + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init)    
						END   
					END
					)COLLATE Latin1_General_CI_AS AS strCustomerName
				,RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4) AS strSiteNumber
				,(A.strSiteAddress + CHAR(10) + A.strCity + '', '' + A.strState +  '' '' +  A.strZipCode) AS strSiteAddress
				,A.strLocation
				,E.vwsls_name AS strDriverName
				,F.vwitm_no AS strItemNo
				,CAST(ISNULL(A.dblEstimatedPercentLeft,0) AS DECIMAL(18,2)) AS dblEstimatedPercentLeft
				,CAST(ISNULL(A.dblTotalCapacity,0.0) * ((ISNULL(F.vwitm_deflt_percnt,100) - ISNULL(dblEstimatedPercentLeft,0.0))/100) AS INT) AS intCalculatedQuantity
				,CAST(ISNULL(A.dblTotalCapacity,0.0) AS DECIMAL(18,2)) AS dblTotalCapacity
				,ISNULL(D.strRouteId,'''') AS strRouteId
				,A.intConcurrencyId
				,A.intFillMethodId
				,A.intRouteId
				,A.intDriverID AS intDriverId
				,ISNULL(A.intNextDeliveryDegreeDay,0) AS intNextDegreeDay
				,ISNULL(A.ysnActive,0) AS ysnActive
				,ISNULL(A.ysnOnHold,0) AS ysnOnHold
				,DATEADD(dd, DATEDIFF(dd, 0, A.dtmNextDeliveryDate), 0) AS dtmNextJulianDate
				,CAST((CASE WHEN G.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
				,intDispatchID AS intDispatchId
				,F.vwitm_class AS strItemClass
				,A.intProduct AS intProductId
				,A.intDeliveryTermID
				,ISNULL(G.ysnDispatched,0) AS ysnDispatched
				,A.intTaxStateID
				,ISNULL(G.strWillCallStatus,'''') AS strWillCallStatus
				,ISNULL(A.ysnTaxable,0) AS ysnTaxable
				,RTRIM(ISNULL(F.vwitm_desc,'''')) AS strProductDescription
				,dblPriceAdjustment = ISNULL(A.dblPriceAdjustment,0.0)
				,intCustomerNumber = B.intCustomerNumber
				,intLocationId = A.intLocationId
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN vwcusmst C
				ON B.intCustomerNumber = C.A4GLIdentity
			LEFT JOIN tblTMRoute D
				ON A.intRouteId = D.intRouteId	
			LEFT JOIN vwslsmst E
				ON A.intDriverID = E.A4GLIdentity	
			LEFT JOIN vwitmmst F
				ON A.intProduct = F.A4GLIdentity
					AND A.intLocationId = F.
			LEFT JOIN tblTMDispatch G
				ON A.intSiteID = G.intSiteID
			')	
		END	

	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMSiteOrder]  
			AS
	  
			SELECT
				A.intSiteID 
				,C.strEntityNo AS strCustomerNumber
				,C.strName AS strCustomerName
				,RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4) AS strSiteNumber
				,(A.strSiteAddress + CHAR(10) + A.strCity + '', '' + A.strState +  '' '' +  A.strZipCode) AS strSiteAddress
				,A.strLocation
				,E.vwsls_name AS strDriverName
				,D.strItemNo AS strItemNo
				,CAST(ISNULL(A.dblEstimatedPercentLeft,0) AS DECIMAL(18,2)) AS dblEstimatedPercentLeft
				,CAST(ISNULL(A.dblTotalCapacity,0.0) * (((CASE WHEN ISNULL(D.dblDefaultFull,0) = 0 THEN 100 ELSE D.dblDefaultFull END) - ISNULL(A.dblEstimatedPercentLeft,0.0))/100) AS INT) AS intCalculatedQuantity
				,CAST(ISNULL(A.dblTotalCapacity,0.0) AS DECIMAL(18,2)) AS dblTotalCapacity
				,ISNULL(F.strRouteId,'''') AS strRouteId
				,A.intConcurrencyId
				,A.intFillMethodId
				,A.intRouteId
				,A.intDriverID AS intDriverId
				,ISNULL(A.intNextDeliveryDegreeDay,0) AS intNextDegreeDay
				,ISNULL(A.ysnActive,0) AS ysnActive
				,ISNULL(A.ysnOnHold,0) AS ysnOnHold
				,DATEADD(dd, DATEDIFF(dd, 0, A.dtmNextDeliveryDate), 0) AS dtmNextJulianDate
				,CAST((CASE WHEN G.intDispatchID IS NULL THEN 0 ELSE 1 END) AS BIT) AS ysnPending
				,intDispatchID AS intDispatchId
				,H.strCategoryCode AS strItemClass
				,A.intProduct AS intProductId
				,A.intDeliveryTermID
				,ISNULL(G.ysnDispatched,0) AS ysnDispatched
				,A.intTaxStateID
				,ISNULL(G.strWillCallStatus,'''') AS strWillCallStatus
				,ISNULL(A.ysnTaxable,0) AS ysnTaxable
				,D.strDescription AS strProductDescription
				,dblPriceAdjustment = ISNULL(A.dblPriceAdjustment,0.0)
				,intCustomerNumber = B.intCustomerNumber
				,intLocationId = A.intLocationId
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN tblEntity C
				ON B.intCustomerNumber = C.intEntityId
			LEFT JOIN vwslsmst E
				ON A.intDriverID = E.A4GLIdentity
			LEFT JOIN tblICItem D
				ON A.intProduct = D.intItemId
			LEFT JOIN tblTMRoute F
				ON A.intRouteId = F.intRouteId	
			LEFT JOIN tblTMDispatch G
				ON A.intSiteID = G.intSiteID
			LEFT JOIN tblICCategory H
				ON D.intCategoryId = H.intCategoryId	
			
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateSiteOrderView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateSiteOrderView] SP'
GO
	EXEC ('uspTMRecreateSiteOrderView')
GO
	PRINT 'END OF Execute [uspTMRecreateSiteOrderView] SP'
GO