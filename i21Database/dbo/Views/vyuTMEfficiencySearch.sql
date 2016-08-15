CREATE VIEW [dbo].[vyuTMEfficiencySearch]
AS  
	SELECT 
		strCustomerNumber = B.strEntityNo
		,strCustomerName = B.strName
		,strSiteNumber = RIGHT('000'+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
		,strSiteAddress = C.strSiteAddress
		,strFillMethod = F.strFillMethod
		,dblTotalCapacity = C.dblTotalCapacity
		,dblSales = ISNULL(I.dblSales,0.0)
		,dblQtyDelivered = ISNULL(I.dblQuantityDelivered,0.0)
		,dblQtyChangePercent = ISNULL(I.dblChangePercent,0.0)
		,intNumberOfDeliveries = CAST(ISNULL(I.intDeliveries,0.0) AS INT)
		,dblAverageQtyDelivered = ISNULL(I.dblAverageQtyDelivered,0.0)
		,dblAverageSales = ISNULL(I.dblAverageSales,0.0)
		,dblEfficiency = ISNULL(I.dblEfficiency,0.0)
		,dblAverageBurnRate = ISNULL(I.dblAverageBurnRate,0.0)
		,dblLastSales = ISNULL(I.dblLastSales,0.0)
		,dblLastQtyDelivered = ISNULL(I.dblLastQuantityDelivered,0.0)
		,dblLastQtyChangePercent = ISNULL(I.dblLastChangePercent,0.0)
		,intLastNumberOfDeliveries = CAST(ISNULL(I.intLastDeliveries,0.0) AS INT)
		,dblLastAverageQtyDelivered = ISNULL(I.dblLastAverageQtyDelivered,0.0)
		,dblLastAverageSales = ISNULL(I.dblLastAverageSales,0.0)
		,dblLastEfficiency = ISNULL(I.dblLastEfficiency,0.0)
		,dblLastAverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
		,dblLast2Sales = ISNULL(I.dblLast2Sales,0.0)
		,dblLast2QtyDelivered = ISNULL(I.dblLast2QuantityDelivered,0.0)
		,intLast2NumberOfDeliveries = CAST(ISNULL(I.intLast2Deliveries,0.0) AS INT)
		,dblLast2AverageQtyDelivered = ISNULL(I.dblLast2AverageQtyDelivered,0.0)
		,dblLast2AverageSales = ISNULL(I.dblLast2AverageSales,0.0)
		,dblLast2Efficiency = ISNULL(I.dblLast2Efficiency,0.0)
		,dblLast2AverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
		,intConcurrencyId = 0
		,intCustomerID = C.intCustomerID
		,intSiteID = C.intSiteID
		,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY C.intSiteID)) AS INT)
		,intLocationId = C.intLocationId
	FROM tblTMSite C 
	INNER JOIN tblTMCustomer E 
		ON C.intCustomerID = E.intCustomerID
	INNER JOIN tblEMEntity B 
		ON E.intCustomerNumber = B.intEntityId
	LEFT JOIN tblTMFillMethod F
		ON C.intFillMethodId = F.intFillMethodId
	OUTER APPLY (SELECT * FROM [fnTMGetSiteEfficiencyTable](C.intSiteID)) I
GO