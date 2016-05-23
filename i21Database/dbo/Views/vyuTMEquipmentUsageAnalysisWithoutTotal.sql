CREATE VIEW [dbo].[vyuTMEquipmentUsageAnalysisWithoutTotal]  
AS  
SELECT
	strCustomerNumber = C.strEntityNo
	,strSiteNumber = RIGHT('0000' + CAST(ISNULL(C.intSiteNumber,0)AS NVARCHAR(4)),4) 
	,strItemDescription = C.strItemDescription
	,strItemNumber = C.strItemNo
	,strSiteDescription = C.strSiteDescription
	,strLeaseNumber = A.strLeaseNumber
	,dblLeaseAmount = ISNULL(B.dblAmount,0.0)
	,strDeviceSerialNumber = C.strSerialNumber
	,strDeviceDescription = C.strDeviceDescription
	,A.strEvaluationMethod
	,intSiteId = C.intSiteID
	,intTMCustomerId = C.intCustomerID
	,intEntityId = C.intEntityId
	,intLeaseId = A.intLeaseId
	,intItemId = C.intItemId
	,intConcurrencyId = 0
	,C.intCategoryId 
FROM tblTMLease A
INNER JOIN tblTMLeaseCode B
	ON A.intLeaseCodeId = B.intLeaseCodeId
LEFT JOIN ( SELECT 
				A.intLeaseId
				,G.strName
				,E.intSiteNumber
				,H.strItemNo
				,strItemDescription = H.strDescription
				,strSiteDescription = E.strDescription
				,strDeviceDescription = C.strDescription
				,C.strSerialNumber
				,E.intSiteID
				,E.intCustomerID
				,G.intEntityId
				,H.intItemId
				,H.intCategoryId 
				,intRecordCount  = ROW_NUMBER() OVER(PARTITION BY A.intLeaseId ORDER BY A.intLeaseId)
				,G.strEntityNo
			FROM tblTMLeaseDevice A
			INNER JOIN tblTMDevice C
				ON A.intDeviceId = C.intDeviceId
			LEFT JOIN tblTMSiteDevice D
				ON C.intDeviceId = D.intDeviceId
			LEFT JOIN tblTMSite E
				ON D.intSiteID = E.intSiteID
			LEFT JOIN tblTMCustomer F
				ON E.intCustomerID = F.intCustomerID
			LEFT JOIN tblEMEntity G
				ON F.intCustomerNumber = G.intEntityId
			LEFT JOIN tblICItem H
				ON E.intProduct = H.intItemId) C
	ON A.intLeaseId = C.intLeaseId
WHERE C.intRecordCount = 1 