CREATE PROCEDURE [dbo].uspTMCreateDeliveryHistoryAdjustment
	@intSiteId INT,
	@strLocationName NVARCHAR(50),
	@strInvoiceNumber NVARCHAR(50),
	@strItemNo NVARCHAR(50),
	@dtmInvoiceDate DATETIME,
	@dblQuantity NUMERIC(18,6),
	@dblPercentAfterDelivery NUMERIC(18,6),
	@intClockId INT,
	@intUserId INT
AS
BEGIN

	DECLARE @intInvoiceDegreeDay INT
	DECLARE @intDegreeDayOnLastDeliveryDate INT
	DECLARE @intElapseDegreeDayBetweenDelivery INT
	DECLARE @dblBurnRate INT
	DECLARE @intElapsedDegreeDaysBetweenDeliveries INT
	DECLARE @intElapsedDaysBetweenDeliveries INT
	

	DECLARE @dblSiteBurnRate NUMERIC(18,6)
	DECLARE @dtmSiteLastDeliveryDate DATETIME
	DECLARE @intSiteDegreeDayOnLastDeliveryDate INT
	DECLARE @strSeason NVARCHAR(10)
	DECLARE @dblSiteSummerDailyUse NUMERIC(18,6)
	DECLARE @dblSiteWinterDailyUse NUMERIC(18,6)
	DECLARE @dblSiteEstimatedGallonsLeft NUMERIC(18,6)
	DECLARE @dblSiteEstimatedPercentLeft NUMERIC(18,6)
	DECLARE @dblSiteTotalCapacity NUMERIC(18,6)
	DECLARE @dblSiteMeterReading NUMERIC(18,6)

	DECLARE @intDeliveryHistoryLastDegreeDay INT
	DECLARE @dtmDeliveryHistoryLastInvoiceDate DATETIME
	
	SET	@strSeason = (SELECT (CASE WHEN (MONTH(@dtmInvoiceDate) >= intBeginSummerMonth AND  MONTH(@dtmInvoiceDate) < intBeginWinterMonth) THEN 'Summer' ELSE 'Winter' END) FROM tblTMClock WHERE intClockID = @intClockId)
	

	SELECT TOP 1
		@intInvoiceDegreeDay = [dblAccumulatedDegreeDay]
	FROM tblTMDegreeDayReading
	WHERE intClockID = @intClockId
		AND DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) = DATEADD(dd, DATEDIFF(dd, 0, @dtmInvoiceDate),0)

	
	SELECT TOP 1 
		@intSiteDegreeDayOnLastDeliveryDate = intLastDeliveryDegreeDay
		,@dblSiteBurnRate = dblBurnRate
		,@dtmSiteLastDeliveryDate = dtmLastDeliveryDate
		,@dblSiteSummerDailyUse = dblSummerDailyUse
		,@dblSiteWinterDailyUse = dblWinterDailyUse
		,@dblSiteEstimatedGallonsLeft = dblEstimatedGallonsLeft
		,@dblSiteTotalCapacity = dblTotalCapacity
		,@dblSiteEstimatedPercentLeft = dblEstimatedPercentLeft
		,@dblSiteMeterReading = dblLastMeterReading
	FROM tblTMSite
	WHERE intSiteID = @intSiteId

	IF(ISNULL(@dtmSiteLastDeliveryDate,'1/1/1900') < @dtmInvoiceDate)
	BEGIN
		---No existing Delivery
		IF(@dtmSiteLastDeliveryDate IS NULL)
		BEGIN
			SET @intDegreeDayOnLastDeliveryDate = 0
			SET @intElapsedDegreeDaysBetweenDeliveries = 0
			SET @intElapsedDaysBetweenDeliveries = 0
		END
		ELSE
		BEGIN
			SET @intDegreeDayOnLastDeliveryDate = @intSiteDegreeDayOnLastDeliveryDate
			SET @intElapsedDegreeDaysBetweenDeliveries = @intInvoiceDegreeDay - @intSiteDegreeDayOnLastDeliveryDate
			SET @intElapsedDaysBetweenDeliveries = DATEDIFF(dd,@dtmSiteLastDeliveryDate,@dtmInvoiceDate)
		END

		SET @dblBurnRate = @dblSiteBurnRate

		--Update Site

		UPDATE tblTMSite
			SET dtmLastDeliveryDate = @dtmInvoiceDate
				,intLastDeliveryDegreeDay = @intInvoiceDegreeDay
				,dblLastDeliveredGal = @dblQuantity
				,dblEstimatedPercentLeft = @dblPercentAfterDelivery
				,dblEstimatedGallonsLeft = (@dblPercentAfterDelivery/100) *  @dblSiteTotalCapacity
				,intNextDeliveryDegreeDay = @intInvoiceDegreeDay + dblDegreeDayBetweenDelivery
				,dtmLastReadingUpdate = @dtmInvoiceDate
		WHERE intSiteID = @intSiteId
	END
	ELSE
	BEGIN
		--print 'less than last delivery'
		SELECT TOP 1
			 @dtmDeliveryHistoryLastInvoiceDate = dtmInvoiceDate
			 ,@intDeliveryHistoryLastDegreeDay = intDegreeDayOnDeliveryDate
		FROM tblTMDeliveryHistory
		WHERE dtmInvoiceDate < @dtmInvoiceDate
			AND ysnMeterReading <> 1
			AND intSiteID = @intSiteId
		ORDER BY dtmInvoiceDate DESC

		IF(@dtmDeliveryHistoryLastInvoiceDate IS NOT NULL)
		BEGIN
			SET @intDegreeDayOnLastDeliveryDate = @intDeliveryHistoryLastDegreeDay
			SET @intElapsedDegreeDaysBetweenDeliveries = @intInvoiceDegreeDay - @intDeliveryHistoryLastDegreeDay
			SET @intElapsedDaysBetweenDeliveries = DATEDIFF(dd,@dtmDeliveryHistoryLastInvoiceDate,@dtmInvoiceDate)
		END
		ELSE
		BEGIN
			SET @intDegreeDayOnLastDeliveryDate = 0
			SET @intElapsedDegreeDaysBetweenDeliveries = 0
			SET @intElapsedDaysBetweenDeliveries = 0
		END

		
		SET @dblBurnRate = @dblSiteBurnRate
		
	END


	INSERT INTO tblTMDeliveryHistory (
		intSiteID
		,strInvoiceNumber
		,strBulkPlantNumber
		,dtmInvoiceDate
		,strProductDelivered
		,dblQuantityDelivered
		,[intDegreeDayOnDeliveryDate]
        ,[intDegreeDayOnLastDeliveryDate]
        ,[dblBurnRateAfterDelivery]
        ,[dblCalculatedBurnRate]
        ,[ysnAdjustBurnRate]
        ,[intElapsedDegreeDaysBetweenDeliveries]
        ,[intElapsedDaysBetweenDeliveries]
        ,[strSeason]
        ,[dblWinterDailyUsageBetweenDeliveries]
        ,[dblSummerDailyUsageBetweenDeliveries]
        ,[dblGallonsInTankbeforeDelivery]
        ,[dblGallonsInTankAfterDelivery]
        ,[dblEstimatedPercentBeforeDelivery]
        ,[dblActualPercentAfterDelivery]
        ,[dblMeterReading]
        ,[dblLastMeterReading]
        ,[intUserID]
		,[dtmLastUpdated]
		,ysnManualAdjustment
	)
	SELECT TOP 1
		intSiteID									= @intSiteId
		,strInvoiceNumber							= @strInvoiceNumber
		,strBulkPlantNumber							= @strLocationName
		,dtmInvoiceDate								= @dtmInvoiceDate
		,strProductDelivered						= @strItemNo
		,dblQuantityDelivered						= @dblQuantity
		,intDegreeDayOnDeliveryDate					= @intInvoiceDegreeDay
        ,intDegreeDayOnLastDeliveryDate				= @intDegreeDayOnLastDeliveryDate
        ,dblBurnRateAfterDelivery					= @dblBurnRate
        ,dblCalculatedBurnRate						= @dblBurnRate
        ,ysnAdjustBurnRate							= 0
        ,intElapsedDegreeDaysBetweenDeliveries		= @intElapsedDegreeDaysBetweenDeliveries
        ,intElapsedDaysBetweenDeliveries			= @intElapsedDaysBetweenDeliveries
        ,strSeason									= @strSeason
        ,dblWinterDailyUsageBetweenDeliveries		= @dblSiteWinterDailyUse
        ,dblSummerDailyUsageBetweenDeliveries		= @dblSiteSummerDailyUse
        ,dblGallonsInTankbeforeDelivery				= @dblSiteEstimatedGallonsLeft
        ,dblGallonsInTankAfterDelivery				= (@dblPercentAfterDelivery/100) *  @dblSiteTotalCapacity
        ,dblEstimatedPercentBeforeDelivery			= @dblSiteEstimatedPercentLeft
        ,dblActualPercentAfterDelivery				= @dblPercentAfterDelivery
        ,dblMeterReading							= 0
        ,dblLastMeterReading						= @dblSiteMeterReading
        ,intUserID									= @intUserId
		,dtmLastUpdated								= GETDATE()
		,ysnManualAdjustment						= 1
		
END
GO