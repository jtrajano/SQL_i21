GO
	PRINT 'START OF CREATING [uspTMRecreateDeliveryHistoryCallEntryView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeliveryHistoryCallEntryView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeliveryHistoryCallEntryView
GO


CREATE PROCEDURE uspTMRecreateDeliveryHistoryCallEntryView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveryHistoryCallEntry')
	BEGIN
		DROP VIEW [vyuTMDeliveryHistoryCallEntry]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeliveryHistoryCallEntry]
			AS
			SELECT 
				intSiteID = A.intSiteID
				,strCustomerNumber = D.vwcus_key COLLATE Latin1_General_CI_AS 
				,strCustomerName = (CASE WHEN D.vwcus_co_per_ind_cp = ''C''   
										THEN  ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')   
										ELSE    
											CASE WHEN D.vwcus_first_name IS NULL OR RTRIM(D.vwcus_first_name) = ''''  
												THEN     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''')    
												ELSE     ISNULL(RTRIM(D.vwcus_last_name),'''') + ISNULL(RTRIM(D.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(D.vwcus_first_name),'''') + ISNULL(RTRIM(D.vwcus_mid_init),'''')    
											END   
									END) COLLATE Latin1_General_CI_AS 
				,strSiteDescription = B.strDescription
				,strSiteAddress = B.strSiteAddress
				,strSiteNumber = RIGHT(''000''+ CAST(B.intSiteNumber AS NVARCHAR(4)),4)
				,strOrderNumber = A.strWillCallOrderNumber
				,strProduct = COALESCE(F.vwitm_desc ,E.vwitm_desc) COLLATE Latin1_General_CI_AS 
				,strDriverName = G.vwsls_name COLLATE Latin1_General_CI_AS 
				,strEnteredBy = H.strUserName
				,dblPercentLeft = A.dblWillCallPercentLeft
				,dblQuantity =  CASE WHEN ISNULL(A.dblWillCallDesiredQuantity,0) = 0 THEN ISNULL(A.dblWillCallCalculatedQuantity,0) ELSE A.dblWillCallDesiredQuantity END
				,dblPrice = A.dblWillCallPrice
				,dblTotal = A.dblWillCallTotal
				,dtmRequestedDate = A.dtmWillCallRequestedDate
				,strPrinted = CASE WHEN ISNULL(A.ysnWillCallPrinted,0) = 0 THEN ''No'' ELSE ''YES'' END
				,intPriority = A.intWillCallPriority
				,strComments = A.strWillCallComments
				,strOrderStatus = ''Completed''
				,dtmCallInDate = A.dtmWillCallCallInDate
				,dtmDispatchedDate = A.dtmWillCallDispatch
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = CAST(A.intWillCallDispatchId AS INT)
				,intCompanyLocationId  = J.intCompanyLocationId
				,strCompanyLocationName  = J.strLocationName
				,dblLocationLongitude = 0.0
				,dblLocationLatitude = 0.0
				,strSiteCity = B.strCity
				,strSiteZipCode = B.strZipCode
				,strSiteState = B.strState
				,strSiteCountry = B.strCountry
				,dblLongitude = B.dblLongitude
				,dblLatitude = B.dblLatitude
				,intCustomerId = B.intCustomerID
				,ysnLeakCheckRequired = A.ysnWillCallLeakCheckRequired
			FROM tblTMDeliveryHistory A
			INNER JOIN tblTMSite B
				ON A.intSiteID = B.intSiteID
			INNER JOIN tblTMCustomer C
				ON B.intCustomerID = C.intCustomerID
			INNER JOIN vwcusmst D
				ON C.intCustomerNumber = D.A4GLIdentity
			INNER JOIN vwitmmst E
				ON B.intProduct = E.A4GLIdentity
			LEFT JOIN vwitmmst F
				ON A.intWillCallSubstituteProductId = F.A4GLIdentity
			LEFT JOIN vwslsmst G
				ON A.intWillCallDriverId = G.A4GLIdentity
			LEFT JOIN tblSMUserSecurity H
				ON A.intWillCallUserId = H.intEntityId
			LEFT JOIN vwlocmst I
				ON B.intLocationId = I.A4GLIdentity
			LEFT JOIN tblSMCompanyLocation J
				ON I.vwloc_loc_no COLLATE Latin1_General_CI_AS = J.strLocationNumber
			WHERE J.intCompanyLocationId IS NOT NULL
				AND ISNULL(A.strWillCallOrderNumber,'''') <> ''''
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeliveryHistoryCallEntry]  
			AS  
			SELECT 
				intSiteID = A.intSiteID
				,strCustomerNumber = D.strEntityNo
				,strCustomerName = D.strName
				,strSiteDescription = B.strDescription
				,strSiteAddress = B.strSiteAddress
				,strSiteNumber = RIGHT(''000''+ CAST(B.intSiteNumber AS NVARCHAR(4)),4)
				,strOrderNumber = A.strWillCallOrderNumber
				,strProduct = COALESCE(F.strDescription,E.strDescription)
				,strDriverName = G.strName
				,strEnteredBy = H.strUserName
				,dblPercentLeft = A.dblWillCallPercentLeft
				,dblQuantity =  CASE WHEN ISNULL(A.dblWillCallDesiredQuantity,0) = 0 THEN ISNULL(A.dblWillCallCalculatedQuantity,0) ELSE A.dblWillCallDesiredQuantity END
				,dblPrice = A.dblWillCallPrice
				,dblTotal = A.dblWillCallTotal
				,dtmRequestedDate = A.dtmWillCallRequestedDate
				,strPrinted = CASE WHEN ISNULL(A.ysnWillCallPrinted,0) = 0 THEN ''No'' ELSE ''YES'' END
				,intPriority = A.intWillCallPriority
				,strComments = A.strWillCallComments
				,strOrderStatus = ''Completed''
				,dtmCallInDate = A.dtmWillCallCallInDate
				,dtmDispatchedDate = A.dtmWillCallDispatch
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = CAST(A.intWillCallDispatchId AS INT)
				,intCompanyLocationId  = B.intLocationId
				,strCompanyLocationName  = I.strLocationName
				,dblLocationLongitude = ISNULL(I.dblLongitude,0.0)
				,dblLocationLatitude = ISNULL(I.dblLatitude,0.0)
				,strSiteCity = B.strCity
				,strSiteZipCode = B.strZipCode
				,strSiteState = B.strState
				,strSiteCountry = B.strCountry
				,dblLongitude = B.dblLongitude
				,dblLatitude = B.dblLatitude
				,intCustomerId = B.intCustomerID
				,ysnLeakCheckRequired = A.ysnWillCallLeakCheckRequired
			FROM tblTMDeliveryHistory A
			INNER JOIN tblTMSite B
				ON A.intSiteID = B.intSiteID
			INNER JOIN tblTMCustomer C
				ON B.intCustomerID = C.intCustomerID
			INNER JOIN tblEMEntity D
				ON C.intCustomerNumber = D.intEntityId
			INNER JOIN tblICItem E
				ON B.intProduct = E.intItemId
			LEFT JOIN tblICItem F
				ON A.intWillCallSubstituteProductId = F.intItemId
			LEFT JOIN tblEMEntity G
				ON A.intWillCallDriverId = G.intEntityId
			LEFT JOIN tblSMUserSecurity H
				ON A.intWillCallUserId = H.[intEntityId]
			LEFT JOIN tblSMCompanyLocation I
				ON B.intLocationId = I.intCompanyLocationId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateDeliveryHistoryCallEntryView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateDeliveryHistoryCallEntryView] SP'
GO
	EXEC ('uspTMRecreateDeliveryHistoryCallEntryView')
GO
	PRINT 'END OF Execute [uspTMRecreateDeliveryHistoryCallEntryView] SP'
GO
