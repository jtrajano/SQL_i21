CREATE PROCEDURE uspTMUpdateNextJulianDelivery 
AS
BEGIN
	DECLARE @intSiteId INT

	IF OBJECT_ID('tempdb..#tmpSiteTable') IS NOT NULL DROP TABLE #tmpSiteTable
	SELECT 
		intSiteID
	INTO #tmpSiteTable
	FROM tblTMSite
	WHERE dtmLastDeliveryDate IS NOT NULL
	AND ysnActive = 1 
	AND intFillMethodId = (SELECT TOP 1 
								intFillMethodId 
							FROM tblTMFillMethod 
							WHERE strFillMethod = 'Julian Calendar')

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpSiteTable)
	BEGIN
		SELECT TOP 1
			@intSiteId = intSiteID
		FROM #tmpSiteTable

		EXEC uspTMUpdateNextJulianDeliveryBySite @intSiteId

		DELETE FROM #tmpSiteTable WHERE intSiteID = @intSiteId
	END
END
GO