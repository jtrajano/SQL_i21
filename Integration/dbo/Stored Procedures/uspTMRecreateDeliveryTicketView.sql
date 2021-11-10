GO
	PRINT 'START OF CREATING [uspTMRecreateDeliveryTicketView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeliveryTicketView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeliveryTicketView
GO


CREATE PROCEDURE uspTMRecreateDeliveryTicketView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveryTicket')
	BEGIN
		DROP VIEW vyuTMDeliveryTicket
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeliveryTicket] 
			AS
			SELECT 
				A.strSiteAddress
				,strCustomerAddress = RTRIM(ISNULL(C.vwcus_addr,'''')) + CHAR(10) 
								+ RTRIM(ISNULL(C.vwcus_addr2,'''')) + CHAR(10) 
				,strCustomerCity = C.vwcus_city COLLATE Latin1_General_CI_AS
				,strCustomerState = C.vwcus_state COLLATE Latin1_General_CI_AS
				,strCustomerZip = C.vwcus_zip COLLATE Latin1_General_CI_AS
				,strCustomerName = (CASE WHEN C.vwcus_co_per_ind_cp = ''C'' 
															THEN RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init) + RTRIM(C.vwcus_name_suffix)   
														WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
															THEN     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix)    
														ELSE     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix) + '', '' + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init)
														END)  COLLATE Latin1_General_CI_AS
				,A.intSiteNumber
				,strInstruction = ISNULL(A.strInstruction,'''')
				,A.dblTotalCapacity
				,strDispatchComments = ISNULL(J.strComments,'''')
				,strCustomerNumber = C.vwcus_key
				,A.intNextDeliveryDegreeDay
				,K.strRouteId
				,strItemNo = ISNULL(O.vwitm_no, I.vwitm_no) COLLATE Latin1_General_CI_AS
				,strItemDescription = CASE WHEN O.vwitm_no IS NULL THEN I.vwitm_desc ELSE O.vwitm_desc END
				,J.dtmRequestedDate
				,strTerm = ISNULL(CAST(L.vwtrm_desc AS NVARCHAR(20)),'''')  COLLATE Latin1_General_CI_AS 
				,dblARBalance = C.vwcus_balance 
				,dblPrice = ISNULL(J.dblPrice,0.0)
				,dblTaxRate = ISNULL(dbo.[fnTMGetSalesTax](L.vwtrm_key_n,A.intTaxStateID),0.0)
				,intSiteId = A.intSiteID
				,M.strDeliveryTicketFormat
				,strSiteCity = ISNULL(A.strCity,'''')
				,strSiteState = ISNULL(A.strState,'''')
				,strSiteZipCode = ISNULL(A.strZipCode,'''')
				,dblRequestedQuantity = ISNULL(J.dblMinimumQuantity,0.0)
				,dblQuantity = (CASE WHEN ISNULL(J.dblMinimumQuantity,0.0) > 0 THEN J.dblMinimumQuantity ELSE J.dblQuantity END)
				,K.intRouteId
				,intDispatchId = J.intDispatchID
				,strReportType = M.strDeliveryTicketFormat
				,intConcurrencyId = J.intConcurrencyId
				,strCustomerPhone = ISNULL(vwcus_phone,'''')
				,strOrderNumber = ISNULL(J.strOrderNumber,'''')
				,dblSiteEstimatedPercentLeft = ISNULL(J.dblPercentLeft,0.0)
				,strFillMethod = ISNULL(H.strFillMethod,'''')
				,A.dtmLastDeliveryDate
				,J.dtmCallInDate
				,strUserCreated = P.strUserName
				,strSerialNumber = ISNULL(Q.strSerialNumber,'''')
				,strTaxGroup = ISNULL(R.vwlcl_tax_state, ISNULL(S.vwlcl_tax_state,''''))  COLLATE Latin1_General_CI_AS 
				,dblYTDGalsThisSeason = ISNULL(HH.dblTotalGallons,0.0)
				,ysnTaxable = ISNULL(A.ysnTaxable,0)
				,strSiteDescription = ISNULL(A.strDescription,'''')
				,strSiteRecurringPO = ISNULL(A.strRecurringPONumber,'''')
				,Driver.strEntityNo AS strDriverNumber
			FROM tblTMSite A
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN vwcusmst C
				ON B.intCustomerNumber = C.A4GLIdentity
			INNER JOIN tblTMDispatch J
				ON A.intSiteID = J.intSiteID
			LEFT JOIN vwitmmst I
				ON A.intProduct = I.A4GLIdentity
			LEFT JOIN vwitmmst O
				ON J.intSubstituteProductID = O.A4GLIdentity
			LEFT JOIN tblTMFillMethod H
				ON A.intFillMethodId = H.intFillMethodId
			LEFT JOIN tblTMRoute K
				ON A.intRouteId = K.intRouteId
			LEFT JOIN vwtrmmst L	
				ON J.intDeliveryTermID = L.A4GLIdentity
			LEFT JOIN tblTMClock M
				ON A.intClockID = M.intClockID
			LEFT JOIN tblSMUserSecurity P
				ON J.intUserID = P.intEntityId
			LEFT JOIN (
				SELECT 
					AA.intSiteID
					,BB.strSerialNumber
					,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
				FROM tblTMSiteDevice AA
				INNER JOIN tblTMDevice BB
					ON AA.intDeviceId = BB.intDeviceId
				INNER JOIN tblTMDeviceType CC
					ON CC.intDeviceTypeId = BB.intDeviceTypeId
				WHERE ISNULL(BB.ysnAppliance,0) = 0 AND CC.strDeviceType = ''Tank''
			) Q
				ON A.intSiteID = Q.intSiteID
				AND Q.intCntId = 1
			LEFT JOIN vwlclmst R
				ON A.intTaxStateID = R.A4GLIdentity
			LEFT JOIN vwlclmst S
				ON C.intTaxId = S.A4GLIdentity
			LEFT JOIN (
				SELECT 
					intSiteId
					,dblTotalGallons = SUM(dblTotalGallons) 
				FROM vyuTMSiteDeliveryHistoryTotal 
				WHERE intCurrentSeasonYear = intSeasonYear
				GROUP BY intSiteId,intCurrentSeasonYear,intSeasonYear
			)HH
				ON A.intSiteID = HH.intSiteId
			LEFT JOIN tblEMEntity Driver
				ON Driver.intEntityId = A.intDriverID
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMDeliveryTicket]  
			AS  
			SELECT 
				A.strSiteAddress
				,strCustomerAddress = Loc.strAddress
				,strCustomerCity = Loc.strCity
				,strCustomerState = Loc.strState
				,strCustomerZip = Loc.strZipCode
				,strCustomerName = Ent.strName
				,A.intSiteNumber
				,strInstruction = ISNULL(A.strInstruction,'''')
				,A.dblTotalCapacity
				,strDispatchComments = J.strComments
				,strCustomerNumber = Ent.strEntityNo
				,A.intNextDeliveryDegreeDay
				,K.strRouteId
				,strItemNo = ISNULL(O.strItemNo, I.strItemNo)
				,strItemDescription = CASE WHEN O.strItemNo IS NULL THEN I.strDescription ELSE O.strDescription END
				,J.dtmRequestedDate
				,strTerm = ISNULL(L.strTerm ,'''')  COLLATE Latin1_General_CI_AS 
				,dblARBalance = ISNULL(Cus.dblARBalance,0.0)
				,dblPrice = ISNULL(J.dblPrice,0.0)
				,dblTaxRate = ISNULL(dbo.[fnGetItemTotalTaxForCustomer](
																	ISNULL(O.intItemId, I.intItemId)
																	,Ent.intEntityId
																	,J.dtmCallInDate
																	,J.dblPrice
																	,(CASE WHEN ISNULL(J.dblMinimumQuantity,0.0) > 0 THEN J.dblMinimumQuantity ELSE J.dblQuantity END)
																	,A.intTaxStateID
																	,A.intLocationId
																	,NULL
																	,1
																	,A.ysnTaxable
																	,A.intSiteID
																	,Loc.intFreightTermId
																	,NULL
																	,NULL
																	,0
																	,0
																	,NULL
																	,1
																	,0
																	,NULL --intItemUOMId
																	,NULL
																	,NULL
																	,NULL
																),0.0)
				,intSiteId = A.intSiteID
				,M.strDeliveryTicketFormat
				,strSiteCity = ISNULL(A.strCity,'''')
				,strSiteState = ISNULL(A.strState,'''')
				,strSiteZipCode = ISNULL(A.strZipCode,'''')
				,dblRequestedQuantity = ISNULL(J.dblMinimumQuantity,0.0)
				,dblQuantity = (CASE WHEN ISNULL(J.dblMinimumQuantity,0.0) > 0 THEN J.dblMinimumQuantity ELSE J.dblQuantity END)
				--,K.intRouteId
				,intDispatchId = J.intDispatchID
				,strReportType = M.strDeliveryTicketFormat
				,intConcurrencyId = J.intConcurrencyId
				,strCustomerPhone = ISNULL(ConPhone.strPhone,'''')
				,strOrderNumber = ISNULL(J.strOrderNumber,'''')
				,dblSiteEstimatedPercentLeft = ISNULL(J.dblPercentLeft,0.0)
				,strFillMethod = ISNULL(H.strFillMethod,'''')
				,A.dtmLastDeliveryDate
				,J.dtmCallInDate
				,strUserCreated = P.strUserName
				,strSerialNumber = ISNULL(Q.strSerialNumber,'''')
				,strTaxGroup = ISNULL(R.strTaxGroup,'''')  COLLATE Latin1_General_CI_AS 
				,dblYTDGalsThisSeason = ISNULL(HH.dblTotalGallons,0.0)
				,ysnTaxable = ISNULL(A.ysnTaxable,0)
				,strSiteDescription = ISNULL(A.strDescription,'''')
				,strSiteRecurringPO = ISNULL(A.strRecurringPONumber,'''')
				,Driver.strEntityNo AS strDriverNumber
				,CL.strLocationName AS strCompanyLocationName
				,CL.strAddress AS strCompanyLocationAddress
				,CL.strCity AS strCompanyLocationCity
				,CL.strStateProvince AS strCompanyLocationState
				,CL.strZipPostalCode AS strCompanyLocationZipCode
				,A.intClockID AS intClockId
				,J.ysnCallEntryPrinted ysnPrinted
				,A.intDriverID AS intDriverId
				,A.intUserID AS intEntityUserSecurityId
				,A.intRouteId AS intRouteId
				,A.intLocationId AS intLocationId
			FROM tblTMSite A
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = A.intLocationId
			INNER JOIN tblTMCustomer B
				ON A.intCustomerID = B.intCustomerID
			INNER JOIN tblEMEntity Ent
				ON B.intCustomerNumber = Ent.intEntityId
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblEMEntityToContact CustToCon 
				ON Cus.intEntityId = CustToCon.intEntityId 
					and CustToCon.ysnDefaultContact = 1
			INNER JOIN tblEMEntity Con 
				ON CustToCon.intEntityContactId = Con.intEntityId
			INNER JOIN tblEMEntityLocation Loc 
				ON Ent.intEntityId = Loc.intEntityId 
					and Loc.ysnDefaultLocation = 1
			LEFT JOIN tblEMEntityPhoneNumber ConPhone
				ON Con.intEntityId = ConPhone.intEntityId
			INNER JOIN tblTMDispatch J
				ON A.intSiteID = J.intSiteID
			INNER JOIN tblICItem I
				ON A.intProduct = I.intItemId
			LEFT JOIN tblICItem O
				ON J.intSubstituteProductID = O.intItemId
			LEFT JOIN [vyuARCustomerInquiryReport] CI
				ON Ent.intEntityId = CI.intEntityCustomerId
			LEFT JOIN tblTMFillMethod H
				ON A.intFillMethodId = H.intFillMethodId
			LEFT JOIN tblTMRoute K
				ON A.intRouteId = K.intRouteId
			LEFT JOIN tblSMTerm L	
				ON J.intDeliveryTermID = L.intTermID
			LEFT JOIN tblTMClock M
				ON A.intClockID = M.intClockID
			LEFT JOIN tblSMUserSecurity P
				ON J.intUserID = P.intEntityId
			LEFT JOIN (
				SELECT 
					AA.intSiteID
					,BB.strSerialNumber
					,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
				FROM tblTMSiteDevice AA
				INNER JOIN tblTMDevice BB
					ON AA.intDeviceId = BB.intDeviceId
				INNER JOIN tblTMDeviceType CC
					ON CC.intDeviceTypeId = BB.intDeviceTypeId
				WHERE ISNULL(BB.ysnAppliance,0) = 0 AND CC.strDeviceType = ''Tank''
			) Q
				ON A.intSiteID = Q.intSiteID
				AND Q.intCntId = 1
			LEFT JOIN tblSMTaxGroup R
				ON A.intTaxStateID = R.intTaxGroupId
			LEFT JOIN (
				SELECT 
					intSiteId
					,dblTotalGallons = SUM(dblTotalGallons) 
				FROM vyuTMSiteDeliveryHistoryTotal 
				WHERE intCurrentSeasonYear = intSeasonYear
				GROUP BY intSiteId,intCurrentSeasonYear,intSeasonYear
			)HH
				ON A.intSiteID = HH.intSiteId
			LEFT JOIN tblEMEntity Driver
				ON Driver.intEntityId = A.intDriverID
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateDeliveryTicketView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateDeliveryTicketView] SP'
GO
	EXEC ('uspTMRecreateDeliveryTicketView')
GO
	PRINT 'END OF Execute [uspTMRecreateDeliveryTicketView] SP'
GO