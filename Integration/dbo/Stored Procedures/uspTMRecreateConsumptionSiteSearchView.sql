GO
	PRINT 'START OF CREATING [uspTMRecreateConsumptionSiteSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateConsumptionSiteSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateConsumptionSiteSearchView
GO


CREATE PROCEDURE uspTMRecreateConsumptionSiteSearchView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMConsumptionSiteSearch')
	BEGIN
		DROP VIEW vyuTMConsumptionSiteSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwtrmmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlclmst') = 1 
		
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch] 
			AS
			SELECT 
				strKey = C.vwcus_key COLLATE Latin1_General_CI_AS 
				,strCustomerName = (CASE WHEN C.vwcus_co_per_ind_cp = ''C''   
										THEN  ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_first_name),'''') + ISNULL(RTRIM(C.vwcus_mid_init),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''')   
										ELSE    
											CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
												THEN     ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''')    
												ELSE     ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(C.vwcus_first_name),'''') + ISNULL(RTRIM(C.vwcus_mid_init),'''')    
											END   
									END) COLLATE Latin1_General_CI_AS 
				,strPhone = C.vwcus_phone COLLATE Latin1_General_CI_AS 
				,intCustomerID = B.intCustomerID 
				,strDescription = A.strDescription
				,strLocation = A.strLocation
				,strAddress = A.strSiteAddress
				,intSiteID = A.intSiteID
				,intSiteNumber = A.intSiteNumber
				,intConcurrencyId = A.intConcurrencyId
				,strCity = A.strCity
				,strBillingBy = A.strBillingBy
				,strSerialNumber = J.strSerialNumber
				,A.intLocationId
				,ysnSiteActive = ISNULL(A.ysnActive,0)
				,strFillMethod = H.strFillMethod
				,strItemNo = ISNULL(I.vwitm_no,'''')
				,dtmLastDeliveryDate = A.dtmLastDeliveryDate
				,dtmNextDeliveryDate = A.dtmNextDeliveryDate
				,dblEstimatedPercentLeft = ISNULL(A.dblEstimatedPercentLeft,0.0)
				,intCntId = CAST((ROW_NUMBER()OVER (ORDER BY A.intSiteID)) AS INT)
				,strContactEmailAddress = ''''
				,strFillGroup = K.strFillGroupCode
				,strFillDescription = K.strDescription
				,ysnOnHold = CAST(ISNULL(A.ysnOnHold,0) AS BIT)
				,L.strHoldReason
				,A.dtmOnHoldStartDate
				,A.dtmOnHoldEndDate
				,dblCreditLimit = C.vwcus_cred_limit
				,strTerm = M.vwtrm_desc
				,A.strInstruction
				,strDriverId = O.vwsls_slsmn_id
				,P.strRouteId
				,A.dblTotalCapacity
				,A.ysnTaxable
				,strTaxGroup = Q.vwlcl_tax_state
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN vwcusmst C
					ON B.intCustomerNumber = C.A4GLIdentity
				LEFT JOIN vwitmmst I
					ON A.intProduct = I.A4GLIdentity
				LEFT JOIN tblTMFillMethod H
					ON A.intFillMethodId = H.intFillMethodId
				LEFT JOIN tblTMFillGroup K
					ON A.intFillGroupId = K.intFillGroupId
				LEFT JOIN tblTMHoldReason L
					ON A.intHoldReasonID = L.intHoldReasonID
				LEFT JOIN vwtrmmst M
					ON A.intDeliveryTermID = M.A4GLIdentity
				LEFT JOIN (
								SELECT Y.strSerialNumber 
									,Z.intSiteID
								FROM tblTMSiteDevice Z
								INNER JOIN tblTMDevice Y
									ON Z.intDeviceId = Y.intDeviceId
								INNER JOIN tblTMDeviceType X
									ON Y.intDeviceTypeId = X.intDeviceTypeId
								WHERE X.strDeviceType = ''Tank''
							) J
								ON A.intSiteID = J.intSiteID
				LEFT JOIN vwslsmst O
					ON A.intDriverID = O.A4GLIdentity
				LEFT JOIN tblTMRoute P
					ON A.intRouteId = P.intRouteId
				LEFT JOIN vwlclmst Q
					ON A.intTaxStateID = Q.A4GLIdentity
				
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch]
			AS  
				SELECT 
				strKey = C.strEntityNo
				,strCustomerName = C.strName
				,strPhone = EP.strPhone
				,intCustomerID = B.intCustomerID 
				,strDescription = A.strDescription
				,strLocation = E.strLocationName
				,strAddress = A.strSiteAddress
				,intSiteID = A.intSiteID
				,intSiteNumber = A.intSiteNumber
				,intConcurrencyId = A.intConcurrencyId
				,strCity = A.strCity
				,strBillingBy = A.strBillingBy
				,strSerialNumber = J.strSerialNumber
				,A.intLocationId
				,ysnSiteActive = ISNULL(A.ysnActive,0)
				,intCntId = CAST((ROW_NUMBER()OVER (ORDER BY A.intSiteID)) AS INT)
				,strFillMethod = H.strFillMethod
				,strItemNo = ISNULL(I.strItemNo,'''')
				,dtmLastDeliveryDate = A.dtmLastDeliveryDate
				,dtmNextDeliveryDate = A.dtmNextDeliveryDate
				,dblEstimatedPercentLeft = ISNULL(A.dblEstimatedPercentLeft,0.0)
				,strContactEmailAddress = G.strEmail
				,strFillGroup = K.strFillGroupCode
				,strFillDescription = K.strDescription
				,ysnOnHold = CAST(ISNULL(A.ysnOnHold,0) AS BIT)
				,L.strHoldReason
				,A.dtmOnHoldStartDate
				,A.dtmOnHoldEndDate
				,D.dblCreditLimit
				,strTerm = M.strTerm
				,A.strInstruction
				,strDriverId = O.strEntityNo
				,P.strRouteId
				,A.dblTotalCapacity
				,A.ysnTaxable
				,Q.strTaxGroup
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN tblEMEntity C
					ON B.intCustomerNumber = C.intEntityId
				INNER JOIN tblARCustomer D
					ON C.intEntityId = D.intEntityId
				LEFT JOIN tblSMCompanyLocation E
					ON A.intLocationId = E.intCompanyLocationId
				INNER JOIN [tblEMEntityToContact] F
					ON D.intEntityId = F.intEntityId 
						and F.ysnDefaultContact = 1
				INNER JOIN tblEMEntity G 
					ON F.intEntityContactId = G.intEntityId
				LEFT JOIN tblICItem I
					ON A.intProduct = I.intItemId
				LEFT JOIN tblTMFillMethod H
					ON A.intFillMethodId = H.intFillMethodId
				LEFT JOIN tblTMFillGroup K
					ON A.intFillGroupId = K.intFillGroupId
				LEFT JOIN tblTMHoldReason L
					ON A.intHoldReasonID = L.intHoldReasonID
				LEFT JOIN tblSMTerm M
					ON A.intDeliveryTermID = M.intTermID
				LEFT JOIN (
								SELECT Y.strSerialNumber 
									,Z.intSiteID
								FROM tblTMSiteDevice Z
								INNER JOIN tblTMDevice Y
									ON Z.intDeviceId = Y.intDeviceId
								INNER JOIN tblTMDeviceType X
									ON Y.intDeviceTypeId = X.intDeviceTypeId
								WHERE X.strDeviceType = ''Tank''
							) J
								ON A.intSiteID = J.intSiteID
				LEFT JOIN tblEMEntity O
					ON A.intDriverID = O.intEntityId
				LEFT JOIN tblTMRoute P
					ON A.intRouteId = P.intRouteId
				LEFT JOIN tblSMTaxGroup Q
					ON A.intTaxStateID = Q.intTaxGroupId
				LEFT JOIN tblEMEntityPhoneNumber EP
					ON G.intEntityId = EP.intEntityId  
				WHERE ISNULL(D.ysnActive,0) = 1
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateConsumptionSiteSearchView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateConsumptionSiteSearchView] SP'
GO
	EXEC ('uspTMRecreateConsumptionSiteSearchView')
GO
	PRINT 'END OF Execute [uspTMRecreateConsumptionSiteSearchView] SP'
GO