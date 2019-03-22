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
			,intCurrentSeasonYear = D.intCurrentSeasonYear
		FROM tblTMSite B
		LEFT JOIN tblTMDeliveryHistory A
			ON A.intSiteID = B.intSiteID
		LEFT JOIN(
			--GEt the last 3 season reset date and the earliest of them of each clock
			SELECT 
				ZZ.intClockID 
				,dtmStartSeason =	(
										SELECT TOP 1 dtmDate
										FROM(
											SELECT
												intClockID
												,dtmDate
												,intRowId = ROW_NUMBER() OVER (PARTITION BY intClockID ORDER BY dtmDate DESC)
											FROM tblTMDegreeDayReading
											WHERE ysnSeasonStart = 1) AA
										WHERE AA.intRowId IN (1,2,3)
											AND AA.intClockID = ZZ.intClockID
										ORDER BY AA.intRowId DESC
									)
			FROM tblTMClock ZZ
		) C ON B.intClockID = C.intClockID
		LEFT JOIN(
			SELECT 
				AA.intClockID 
				,intCurrentSeasonYear = (SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(GETDATE(),AA.intClockID))
			FROM tblTMClock AA
		)D ON B.intClockID = D.intClockID
		WHERE  DATEADD(dd, DATEDIFF(dd, 0, A.dtmInvoiceDate), 0) >=  DATEADD(dd, DATEDIFF(dd, 0, ISNULL(C.dtmStartSeason,'1/1/1900')), 0)
	) Z
	GROUP BY intSiteId, intSeasonYear, intCurrentSeasonYear

GO
