GO
	PRINT 'START OF CREATING [uspTMRecreateOpenCallEntryView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateOpenCallEntryView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateOpenCallEntryView
GO


CREATE PROCEDURE uspTMRecreateOpenCallEntryView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOpenCallEntry')
	BEGIN
		DROP VIEW [vyuTMOpenCallEntry]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOpenCallEntry]
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
				,dtmCallInDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmCallInDate),0)
				,dtmDispatchedDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDispatchingDate),0)
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = A.intDispatchID
				,intCustomerID = B.intCustomerID
				,intLocationId = B.intLocationId
				,ysnLeakCheckRequired = A.ysnLeakCheckRequired
				,ysnCallEntryPrinted = ISNULL(A.ysnCallEntryPrinted,0)
				,intOpenWorkOrder = ISNULL(M.intOpenCount,0)
				,strFillMethod = N.strFillMethod
			,strLocation = B.strLocation
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
			LEFT JOIN (
					SELECT intSiteId = intSiteID
						,intOpenCount = COUNT(intSiteID)
					FROM tblTMWorkOrder 
					WHERE intWorkStatusTypeID = (SELECT TOP 1 intWorkStatusID 
													FROM tblTMWorkStatusType 
													WHERE strWorkStatus = ''Open'' 
													AND ysnDefault = 1)
					GROUP BY intSiteID
				) M
					ON A.intSiteID = M.intSiteId
			LEFT JOIN tblTMFillMethod N
				ON B.intFillMethodId = N.intFillMethodId
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOpenCallEntry]  
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
				,dtmCallInDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmCallInDate),0)
				,dtmDispatchedDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDispatchingDate),0)
				,intConcurrencyId = A.intConcurrencyId
				,intDispatchId = A.intDispatchID
				,intCustomerID = B.intCustomerID
				,intLocationId = B.intLocationId
				,strLocation = B.strLocation
				,ysnLeakCheckRequired = A.ysnLeakCheckRequired
				,ysnCallEntryPrinted = ISNULL(A.ysnCallEntryPrinted,0)
				,intOpenWorkOrder = ISNULL(M.intOpenCount,0)
				,strFillMethod = N.strFillMethod
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
			LEFT JOIN (
					SELECT intSiteId = intSiteID
						,intOpenCount = COUNT(intSiteID)
					FROM tblTMWorkOrder 
					WHERE intWorkStatusTypeID = (SELECT TOP 1 intWorkStatusID 
													FROM tblTMWorkStatusType 
													WHERE strWorkStatus = ''Open'' 
													AND ysnDefault = 1)
					GROUP BY intSiteID
				) M
					ON A.intSiteID = M.intSiteId
			LEFT JOIN tblTMFillMethod N
				ON B.intFillMethodId = N.intFillMethodId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateOpenCallEntryView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateOpenCallEntryView] SP'
GO
	EXEC ('uspTMRecreateOpenCallEntryView')
GO
	PRINT 'END OF Execute [uspTMRecreateOpenCallEntryView] SP'
GO