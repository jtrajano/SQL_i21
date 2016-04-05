﻿CREATE VIEW [dbo].[vyuTMFailedLeaseBilling]  
AS  
SELECT 
	strBillToCustomerNo = J.strEntityNo
	,strBillToCustomerName = J.strName
	,strSiteCustomerNo = F.strEntityNo
	,strSiteCustomerName = F.strName
	,intSiteNumber =  RIGHT('0000'+CAST(D.intSiteNumber AS VARCHAR(4)),4)
	,strSiteDescription = D.strDescription
	,strSiteAddress = D.strSiteAddress
	,strSiteLocation = K.strLocationName
	,strDeviceType = L.strDeviceType
	,dblLeaseAmount = ISNULL(G.dblAmount,0.0)
	,intLeaseId = C.intLeaseId
	,dtmStartDate = C.dtmStartDate
	,strSerialNumber = B.strSerialNumber
	,intDeviceId = B.intDeviceId
	,strItemNumber = ISNULL(M.strItemNo,'')
	,dblBillAmount = (CASE WHEN C.strBillingType = 'Gallons' AND ISNULL((SELECT TOP 1 ysnEnableLeaseBillingAboveMinUse FROM tblTMPreferenceCompany),0) = 1 
							THEN 
								(CASE WHEN (SELECT COUNT(1) FROM tblTMLeaseMinimumUse Z WHERE D.dblTotalCapacity <= Z.dblSiteCapacity AND D.dblYTDGalsThisSeason > Z.dblMinimumUsage) > 0
									THEN
										0.0
									ELSE
										ISNULL(G.dblAmount,0.0)
									END)
							ELSE
								ISNULL(G.dblAmount,0.0)
							END)
	,intBillingMonth = C.intBillingMonth
	,dtmLastLeaseBillingDate = C.dtmLastLeaseBillingDate
	,dtmDontBillAfter = C.dtmDontBillAfter
	,strBillingFrequency = C.strBillingFrequency
	,ysnTaxable = ISNULL(G.ysnTaxable,0)
	,strSiteState =( CASE WHEN D.intTaxStateID  IS NULL
                THEN
                    ''
                ELSE
                    I.strTaxGroup
                END)
	,strSiteLocale1 = ''
	,strSiteLocale2 = ''
	,intSiteDeviceId = A.intSiteDeviceID
	,intConcurrencyId = A.intConcurrencyId
	,intEntityCustomerId = F.intEntityId
	,intCompanyLocation = D.intLocationId
	,strReason = O.strStatus
	,intItemId = G.intItemId
FROM tblTMSiteDevice A
INNER JOIN tblTMDevice B
	ON A.intDeviceId = B.intDeviceId
INNER JOIN tblTMLeaseDevice BB
	ON B.intDeviceId = BB.intDeviceId
INNER JOIN tblTMLease C
	ON BB.intLeaseId = C.intLeaseId
INNER JOIN tblTMSite D
	ON A.intSiteID = D.intSiteID
INNER JOIN tblTMCustomer E
	ON D.intCustomerID = E.intCustomerID
INNER JOIN tblEMEntity F
	ON E.intCustomerNumber = F.intEntityId		
LEFT JOIN tblTMLeaseCode G
	ON C.intLeaseCodeId = G.intLeaseCodeId
LEFT JOIN tblSMTaxGroup I
	ON D.intTaxStateID = I.intTaxGroupId
LEFT JOIN tblEMEntity J
	ON C.intBillToCustomerId = J.intEntityId
LEFT JOIN tblSMCompanyLocation K
	ON D.intLocationId = K.intCompanyLocationId
LEFT JOIN tblTMDeviceType L
	ON B.intDeviceTypeId = L.intDeviceTypeId
LEFT JOIN tblICItem M
	ON G.intItemId = M.intItemId
INNER JOIN tblTMCOBOLLeaseBilling O
	ON O.intDeviceID =  B.intDeviceId
GO