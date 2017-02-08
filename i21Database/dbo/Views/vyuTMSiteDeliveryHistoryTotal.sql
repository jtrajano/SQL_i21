CREATE VIEW [dbo].[vyuTMSiteDeliveryHistoryTotal]  
AS 

SELECT 
	dblTotalSales = ISNULL(SUM(dblExtendedAmount),0.0)
	,dblTotalGallons = ISNULL(SUM(dblQuantityDelivered),0.0)
	,intSiteId 
	,intSeasonYear
	,intCurrentSeasonYear
	,intConcurrencyId = 0
FROM
(
	SELECT 
		A.dblExtendedAmount
		,A.dblQuantityDelivered
		,intSeasonYear = (SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmInvoiceDate,B.intClockID))
		,intSiteId = B.intSiteID
		,intCurrentSeasonYear = (SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),B.intClockID))
	FROM tblTMSite B
	LEFT JOIN tblTMDeliveryHistory A
		ON A.intSiteID = B.intSiteID
) Z
GROUP BY intSiteId, intSeasonYear, intCurrentSeasonYear
HAVING intSeasonYear >= (MAX(intSeasonYear) - 2)

GO
