CREATE VIEW [dbo].[vyuTMDeliveriesSearch]
AS  
	SELECT 
		strCustomerNumber = B.strEntityNo
		,strCustomerName = B.strName
		,strSiteNumber = RIGHT('0000'+ CAST(C.intSiteNumber AS VARCHAR(4)),4)
		,F.dtmInvoiceDate
		,F.strBulkPlantNumber
		,strProductDelivered = I.strItemNo
		,F.strSalesPersonID
		,C.dblTotalCapacity
		,F.dblQuantityDelivered
		,F.dblCalculatedBurnRate
		,dblAverageBurnRate =CAST( CASE WHEN ISNULL(C.dblPreviousBurnRate, 0.0) = 0 THEN ((ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0))/2.0) ELSE (ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0) + C.dblPreviousBurnRate)/3.0 END AS NUMERIC(18,6))
		,dblPercentFilled = CAST( CASE WHEN ISNULL(C.dblTotalCapacity,0) = 0 THEN 0 ELSE F.dblQuantityDelivered / C.dblTotalCapacity * 100 END AS NUMERIC(18,6))
		,dblPercentIdeal = CAST( CASE WHEN ((ISNULL(C.dblTotalCapacity,0.0) * (I.dblDefaultFull/100.00)) - ISNULL(C.dblTotalReserve,0.0))  <= 0 THEN 0 ELSE F.dblQuantityDelivered / ((ISNULL(C.dblTotalCapacity,0.0) * (I.dblDefaultFull/100.00)) - ISNULL(C.dblTotalReserve,0.0)) END AS NUMERIC(18,6)) * 100
		,intConcurrencyId = 0
		,intCustomerID = C.intCustomerID
		,intSiteID = C.intSiteID
		,F.intDeliveryHistoryID
		,intLocationId = C.intLocationId
		,F.strInvoiceNumber
	FROM tblTMSite C 
	INNER JOIN tblTMCustomer E 
		ON C.intCustomerID = E.intCustomerID
	INNER JOIN tblEMEntity B 
		ON E.intCustomerNumber = B.intEntityId
	INNER JOIN tblTMDeliveryHistory F
		ON C.intSiteID = F.intSiteID
	INNER JOIN tblICItem I
		ON C.intProduct = I.intItemId
GO