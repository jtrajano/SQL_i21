GO
	PRINT 'START OF CREATING [uspTMRecreateForPrintDeliveryTicketView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateForPrintDeliveryTicketView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateForPrintDeliveryTicketView
GO


CREATE PROCEDURE uspTMRecreateForPrintDeliveryTicketView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMForPrintDeliveryTicket')
	BEGIN
		DROP VIEW vyuTMForPrintDeliveryTicket
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwslsmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMForPrintDeliveryTicket]  
			AS  
			SELECT 
				strLocation = G.vwloc_loc_no
				,strItemNo = CASE WHEN M.vwitm_no IS NULL THEN F.vwitm_no ELSE M.vwitm_no END
				,strRoute = J.strRouteId
				,strDriverId = L.vwsls_slsmn_id
				,dtmRequestedDate = E.dtmRequestedDate
				,ysnCallEntryPrinted = E.ysnCallEntryPrinted
				,strDeliveryTicketFormat = K.strDeliveryTicketFormat
				,strDeliveryTicketPrinter = K.strDeliveryTicketPrinter
				,intDispatchId = E.intDispatchID
				,intCustomerEntityId = C.A4GLIdentity
				,intSiteId = A.intSiteID
				,intLocationId = A.intLocationId
				,intItemId = CASE WHEN M.A4GLIdentity IS NULL THEN F.A4GLIdentity ELSE M.A4GLIdentity END
				,intRouteId = A.intRouteId
				,intDriverID = E.intDriverID
				,intConcurrencyId = E.intConcurrencyId
				,intClockId = K.intClockID
				,intEntityUserSecurityId = E.intUserID
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN vwcusmst C
				ON B.intCustomerNumber = C.A4GLIdentity
			INNER JOIN tblTMDispatch E
				ON A.intSiteID = E.intSiteID
			INNER JOIN vwitmmst F
				ON E.intProductID = F.A4GLIdentity
			INNER JOIN vwlocmst G
				ON A.intLocationId = G.A4GLIdentity
			LEFT JOIN vwitmmst H
				ON E.intProductID = H.A4GLIdentity
			LEFT JOIN tblTMFillMethod I
				ON A.intFillMethodId = I.intFillMethodId
			LEFT JOIN tblTMRoute J
				ON A.intRouteId = J.intRouteId
			LEFT JOIN tblTMClock K
				ON A.intClockID = K.intClockID
			LEFT JOIN vwslsmst L
				ON E.intDriverID = L.A4GLIdentity
			LEFT JOIN vwitmmst M
				ON E.intSubstituteProductID = M.A4GLIdentity
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMForPrintDeliveryTicket]  
			AS  
			SELECT 
				strLocation = G.strLocationName
				,strItemNo = CASE WHEN M.intItemId IS NULL THEN F.strItemNo ELSE M.strItemNo END
				,strRoute = J.strRouteId
				,strDriverId = L.strEntityNo
				,dtmRequestedDate = E.dtmRequestedDate
				,ysnCallEntryPrinted = E.ysnCallEntryPrinted
				,strDeliveryTicketFormat = K.strDeliveryTicketFormat
				,strDeliveryTicketPrinter = K.strDeliveryTicketPrinter
				,intDispatchId = E.intDispatchID
				,intCustomerEntityId = C.intEntityId
				,intSiteId = A.intSiteID
				,intLocationId = A.intLocationId
				,intItemId = CASE WHEN M.intItemId IS NULL THEN F.intItemId ELSE M.intItemId END
				,intRouteId = A.intRouteId
				,intDriverId = E.intDriverID
				,intConcurrencyId = E.intConcurrencyId
				,intClockId = K.intClockID
				,intEntityUserSecurityId = E.intUserID
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN tblEMEntity C
				ON B.intCustomerNumber = C.intEntityId
			INNER JOIN tblARCustomer D 
				ON C.intEntityId = D.intEntityId
			INNER JOIN tblTMDispatch E
				ON A.intSiteID = E.intSiteID
			INNER JOIN tblICItem F
				ON E.intProductID = F.intItemId
			INNER JOIN tblSMCompanyLocation G
				ON A.intLocationId = G.intCompanyLocationId
			LEFT JOIN tblICItem H
				ON E.intProductID = H.intItemId
			LEFT JOIN tblTMFillMethod I
				ON A.intFillMethodId = I.intFillMethodId
			LEFT JOIN tblTMRoute J
				ON A.intRouteId = J.intRouteId
			LEFT JOIN tblTMClock K
				ON A.intClockID = K.intClockID
			LEFT JOIN tblEMEntity L
				ON E.intDriverID = L.intEntityId
			LEFT JOIN tblICItem M
				ON E.intSubstituteProductID = M.intItemId
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateForPrintDeliveryTicketView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateForPrintDeliveryTicketView] SP'
GO
	EXEC ('uspTMRecreateForPrintDeliveryTicketView')
GO
	PRINT 'END OF Execute [uspTMRecreateForPrintDeliveryTicketView] SP'
GO