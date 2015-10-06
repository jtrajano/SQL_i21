﻿GO
	PRINT 'START OF CREATING [uspTMRecreateOpenWorkOrderView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateOpenWorkOrderView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateOpenWorkOrderView
GO


CREATE PROCEDURE uspTMRecreateOpenWorkOrderView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMWorkOrder')
	BEGIN
		DROP VIEW vyuTMWorkOrder
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMWorkOrder]
			AS
			SELECT 
				strCustomerNumber = G.vwcus_key COLLATE Latin1_General_CI_AS 
				,strCustomerName = (CASE WHEN G.vwcus_co_per_ind_cp = ''C''   
										THEN  ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_first_name),'''') + ISNULL(RTRIM(G.vwcus_mid_init),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''')   
										ELSE    
											CASE WHEN G.vwcus_first_name IS NULL OR RTRIM(G.vwcus_first_name) = ''''  
												THEN     ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''')    
												ELSE     ISNULL(RTRIM(G.vwcus_last_name),'''') + ISNULL(RTRIM(G.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(G.vwcus_first_name),'''') + ISNULL(RTRIM(G.vwcus_mid_init),'''')    
											END   
									END) COLLATE Latin1_General_CI_AS 
				,strWorkStatus = C.strWorkStatus
				,strSiteNumber = RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4)
				,strLocation = A.strLocation
				,strWorkOrderCategory = D.strWorkOrderCategory
				,dtmDateCreated = B.dtmDateCreated
				,dtmDateScheduled = B.dtmDateScheduled
				,dtmDateClosed = B.dtmDateClosed
				,strAddress = REPLACE(RTRIM(ISNULL(A.strSiteAddress,'''')) ,CHAR(13),'' '') + '', '' + RTRIM(ISNULL(A.strCity,'''')) + '', '' + RTRIM(ISNULL(A.strState,'''')) + '', '' + RTRIM(ISNULL(A.strZipCode,'''')) 
				,strCloseReason = H.strCloseReason
				,strPerformerName = I.vwsls_name COLLATE Latin1_General_CI_AS 
				,A.strDescription
				,intWorkOrderID = B.intWorkOrderID
				,intSiteID = A.intSiteID
				,A.intCustomerID
				,A.intConcurrencyId
			FROM tblTMSite A
			INNER JOIN tblTMWorkOrder B
				ON A.intSiteID = B.intSiteID
			LEFT JOIN tblTMWorkStatusType C
				ON B.intWorkStatusTypeID = C.intWorkStatusID
			LEFT JOIN tblTMWorkOrderCategory D
				ON B.intWorkOrderCategoryId = D.intWorkOrderCategoryId
			INNER JOIN tblTMCustomer F
				ON A.intCustomerID = F.intCustomerID
			INNER JOIN vwcusmst G
				ON F.intCustomerNumber = G.A4GLIdentity
			LEFT JOIN tblTMWorkCloseReason H
				ON B.intCloseReasonID = H.intCloseReasonID
			LEFT JOIN vwslsmst I
				ON B.intPerformerID = I.A4GLIdentity
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMWorkOrder]  
			AS  
				SELECT 
					strCustomerNumber = G.strEntityNo
					,strCustomerName = G.strName
					,strWorkStatus = C.strWorkStatus
					,strSiteNumber = RIGHT(''000''+ CAST(A.intSiteNumber AS NVARCHAR(4)),4)
					,strLocation = E.strLocationName
					,strWorkOrderCategory = D.strWorkOrderCategory
					,dtmDateCreated = B.dtmDateCreated
					,dtmDateScheduled = B.dtmDateScheduled
					,dtmDateClosed = B.dtmDateClosed
					,strAddress = REPLACE(RTRIM(ISNULL(A.strSiteAddress,'''')) ,CHAR(13),'' '') + '', '' + RTRIM(ISNULL(A.strCity,'''')) + '', '' + RTRIM(ISNULL(A.strState,'''')) + '', '' + RTRIM(ISNULL(A.strZipCode,'''')) 
					,strCloseReason = H.strCloseReason
					,strPerformerName = I.strName
					,A.strDescription
					,intWorkOrderID = B.intWorkOrderID
					,intSiteID = A.intSiteID
					,A.intCustomerID
					,A.intConcurrencyId
				FROM tblTMSite A
				INNER JOIN tblTMWorkOrder B
					ON A.intSiteID = B.intSiteID
				LEFT JOIN tblTMWorkStatusType C
					ON B.intWorkStatusTypeID = C.intWorkStatusID
				LEFT JOIN tblTMWorkOrderCategory D
					ON B.intWorkOrderCategoryId = D.intWorkOrderCategoryId
				INNER JOIN tblSMCompanyLocation E
					ON A.intLocationId = E.intCompanyLocationId
				INNER JOIN tblTMCustomer F
					ON A.intCustomerID = F.intCustomerID
				INNER JOIN tblEntity G
					ON F.intCustomerNumber = G.intEntityId
				LEFT JOIN tblTMWorkCloseReason H
					ON B.intCloseReasonID = H.intCloseReasonID
				LEFT JOIN tblEntity I
					ON B.intPerformerID = I.intEntityId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateOpenWorkOrderView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateOpenWorkOrderView] SP'
GO
	EXEC ('uspTMRecreateOpenWorkOrderView')
GO
	PRINT 'END OF Execute [uspTMRecreateOpenWorkOrderView] SP'
GO