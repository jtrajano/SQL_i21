CREATE VIEW [dbo].[vyuTMSiteDeliveryHistoryTotal]  
AS  
SELECT 
	dblTotalSales = ISNULL(SUM(A.dblExtendedAmount),0.0)
	,dblTotalGallons = ISNULL(SUM(A.dblQuantityDelivered),0.0)
	,Z.intSeasonYear
	,intSiteId = B.intSiteID
	,intRecordId = CAST((ROW_NUMBER() OVER (ORDER BY B.intSiteID)) AS INT)
	,intCurrentSeasonYear = X.intSeasonYear
	,intConcurrencyId = 0
FROM tblTMSite B
LEFT JOIN tblTMDeliveryHistory A
	ON A.intSiteID = B.intSiteID
OUTER APPLY (
	SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmInvoiceDate,B.intClockID)
)Z
OUTER APPLY (
	SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),B.intClockID)
)X
GROUP BY B.intSiteID, Z.intSeasonYear, X.intSeasonYear
HAVING Z.intSeasonYear >= (MAX(Z.intSeasonYear) - 2)

GO
