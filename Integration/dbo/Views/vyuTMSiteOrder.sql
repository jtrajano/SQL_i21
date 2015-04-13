GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMSiteOrder')
	DROP VIEW vyuTMSiteOrder
GO

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
			) AS strCustomerName
		,RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4) AS strSiteNumber
		,A.strSiteAddress
		,A.strLocation
		,E.vwsls_name AS strDriverName
		,F.vwitm_no AS strItemNo
		,CAST(ISNULL(A.dblEstimatedPercentLeft,0) AS DECIMAL(18,2)) AS dblEstimatedPercentLeft
		,CAST(A.dblTotalCapacity * ((ISNULL(F.vwitm_deflt_percnt,100) - dblEstimatedPercentLeft)/100) AS INT) AS intCalculatedQuantity
		,CAST(ISNULL(A.dblTotalCapacity,0) AS DECIMAL(18,2)) AS dblTotalCapacity
		,ISNULL(D.strRouteId,'''') AS strRouteId
		,A.intConcurrencyId
		,A.intFillMethodId
		,A.intRouteId
		,A.intDriverID AS intDriverId
		,A.intNextDeliveryDegreeDay AS intNextDegreeDay
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
	LEFT JOIN tblTMDispatch G
		ON A.intSiteID = G.intSiteID
	')	
END	
GO