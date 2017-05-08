GO
	PRINT 'START OF CREATING [uspTMRecreateGeneratedCallEntryView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateGeneratedCallEntryView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateGeneratedCallEntryView
GO


CREATE PROCEDURE uspTMRecreateGeneratedCallEntryView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMGeneratedCallEntry')
	BEGIN
		DROP VIEW [vyuTMGeneratedCallEntry]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMGeneratedCallEntry]
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
				,strOrderNumber = A.strOrderNumber
				,strProduct = COALESCE(F.vwitm_desc ,E.vwitm_desc) COLLATE Latin1_General_CI_AS 
				,strDriverName = G.vwsls_name COLLATE Latin1_General_CI_AS 
				,strEnteredBy = H.strUserName
				,dblPercentLeft = A.dblPercentLeft
				,dblQuantity =  CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN ISNULL(A.dblQuantity,0) ELSE A.dblMinimumQuantity END
				,dblPrice = A.dblPrice
				,dblTotal = A.dblTotal
				,dtmRequestedDate = A.dtmRequestedDate
				,strPrinted = CASE WHEN ISNULL(A.ysnCallEntryPrinted,0) = 0 THEN ''No'' ELSE ''YES'' END
				,intPriority = A.intPriority
				,strComments = A.strComments
				,strOrderStatus = A.strWillCallStatus
				,dtmCallInDate = A.dtmCallInDate
				,dtmDispatchedDate = A.dtmDispatchingDate
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = A.intDispatchID
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
				,ysnLeakCheckRequired = A.ysnLeakCheckRequired
				,dblCustomerBalance = ISNULL(D.dblFutureCurrent, 0.0)
				,dblSiteEstimatedPercentLeft = B.dblEstimatedPercentLeft
				,intFillMethodId = B.intFillMethodId
				,strFillMethod = L.strFillMethod
				,ysnHold = B.ysnOnHold
			FROM tblTMDispatch A
			INNER JOIN tblTMSite B
				ON A.intSiteID = B.intSiteID
			INNER JOIN tblTMCustomer C
				ON B.intCustomerID = C.intCustomerID
			INNER JOIN vwcusmst D
				ON C.intCustomerNumber = D.A4GLIdentity
			INNER JOIN vwitmmst E
				ON B.intProduct = E.A4GLIdentity
			LEFT JOIN vwitmmst F
				ON A.intSubstituteProductID = F.A4GLIdentity
			LEFT JOIN vwslsmst G
				ON A.intDriverID = G.A4GLIdentity
			LEFT JOIN tblSMUserSecurity H
				ON A.intUserID = H.intEntityId
			LEFT JOIN vwlocmst I
				ON B.intLocationId = I.A4GLIdentity
			LEFT JOIN tblSMCompanyLocation J
				ON I.vwloc_loc_no  COLLATE Latin1_General_CI_AS = J.strLocationNumber
			LEFT JOIN tblTMFillMethod L
				ON B.intFillMethodId = L.intFillMethodId
			WHERE J.intCompanyLocationId IS NOT NULL
				AND ISNULL(A.strOrderNumber,'''') <> ''''
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMGeneratedCallEntry]  
			AS  
			SELECT 
				intSiteID = A.intSiteID
				,strCustomerNumber = D.strEntityNo
				,strCustomerName = D.strName
				,strSiteDescription = B.strDescription
				,strSiteAddress = B.strSiteAddress
				,strSiteNumber = RIGHT(''000''+ CAST(B.intSiteNumber AS NVARCHAR(4)),4)
				,strOrderNumber = A.strOrderNumber
				,strProduct = COALESCE(F.strDescription,E.strDescription)
				,strDriverName = G.strName
				,strEnteredBy = H.strUserName
				,dblPercentLeft = A.dblPercentLeft
				,dblQuantity =  CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN ISNULL(A.dblQuantity,0) ELSE A.dblMinimumQuantity END
				,dblPrice = A.dblPrice
				,dblTotal = A.dblTotal
				,dtmRequestedDate = A.dtmRequestedDate
				,strPrinted = CASE WHEN ISNULL(A.ysnCallEntryPrinted,0) = 0 THEN ''No'' ELSE ''YES'' END
				,intPriority = A.intPriority
				,strComments = A.strComments
				,strOrderStatus = A.strWillCallStatus
				,dtmCallInDate = A.dtmCallInDate
				,dtmDispatchedDate = A.dtmDispatchingDate
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = A.intDispatchID
				,intCustomerID = B.intCustomerID
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
				,ysnLeakCheckRequired = A.ysnLeakCheckRequired
				,dblCustomerBalance = ISNULL(K.dblTotalDue, 0.0)
				,dblSiteEstimatedPercentLeft = B.dblEstimatedPercentLeft
				,intFillMethodId = B.intFillMethodId
				,strFillMethod = L.strFillMethod
				,ysnHold = B.ysnOnHold
			FROM tblTMDispatch A
			INNER JOIN tblTMSite B
				ON A.intSiteID = B.intSiteID
			INNER JOIN tblTMCustomer C
				ON B.intCustomerID = C.intCustomerID
			INNER JOIN tblEMEntity D
				ON C.intCustomerNumber = D.intEntityId
			INNER JOIN tblICItem E
				ON B.intProduct = E.intItemId
			LEFT JOIN tblICItem F
				ON A.intSubstituteProductID = F.intItemId
			LEFT JOIN tblEMEntity G
				ON A.intDriverID = G.intEntityId
			LEFT JOIN tblSMUserSecurity H
				ON A.intUserID = H.intEntityId
			LEFT JOIN tblSMCompanyLocation I
				ON B.intLocationId = I.intCompanyLocationId
			LEFT JOIN vyuARCustomerInquiryReport K
				ON D.intEntityId = K.intEntityCustomerId
			LEFT JOIN tblTMFillMethod L
				ON B.intFillMethodId = L.intFillMethodId
			WHERE ISNULL(A.strOrderNumber,'''') <> ''''
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateGeneratedCallEntryView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateGeneratedCallEntryView] SP'
GO
	EXEC ('uspTMRecreateGeneratedCallEntryView')
GO
	PRINT 'END OF Execute [uspTMRecreateGeneratedCallEntryView] SP'
GO
