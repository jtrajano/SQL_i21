CREATE VIEW [dbo].[vyuTMOutOfRangeBurnRateSearch]
AS  
	SELECT 
		strCustomerNumber = B.strEntityNo
		,strCustomerName = B.strName
		,strSiteNumber = RIGHT('000'+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
		,strSiteAddress = C.strSiteAddress
		,strFillMethod = F.strFillMethod
		,dblCalculatedBurnRate = A.dblCalculatedBurnRate
		,dblBurnRate = A.dblBurnRateAfterDelivery
		,dblWinterDailyUse = A.dblWinterDailyUsageBetweenDeliveries 
		,dblSummerDailyUse = A.dblSummerDailyUsageBetweenDeliveries 
		,dtmInvoiceDate = A.dtmInvoiceDate
		,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY A.intDeliveryHistoryID)) AS INT)
		,intLocationId = C.intLocationId
		,intCustomerID = C.intCustomerID
		,dtmDateSync = D.dtmDateSync
		,intConcurrencyId = 0
		,intSiteID = C.intSiteID
	FROM tblTMDeliveryHistory  A
	INNER JOIN tblTMSite C 
		ON C.intSiteID = A.intSiteID 
	INNER JOIN (SELECT DISTINCT intSiteID, dtmDateSync FROM tblTMSyncOutOfRange) AS D 
		ON C.intSiteID = D.intSiteID AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmCreatedDate),0) = DATEADD(dd, DATEDIFF(dd, 0, D.dtmDateSync),0)
	INNER JOIN tblTMCustomer E 
		ON C.intCustomerID = E.intCustomerID
	INNER JOIN tblEMEntity B 
		ON E.intCustomerNumber = B.intEntityId
	LEFT JOIN tblTMFillMethod F
		ON C.intFillMethodId = F.intFillMethodId
GO