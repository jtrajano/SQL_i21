CREATE FUNCTION [dbo].[fnTMComputeNewBurnRateZeroDeliveryTable]
(
	@intSiteId INT
	,@intDDReadingId INT 
	,@intPreviousDDReadingId INT 
	,@dblPercentLeft NUMERIC(18,6)
	,@intLastMonitorReadingEvent INT
)
RETURNS @tblReturnValue TABLE(
	dblBurnRate NUMERIC(18,6)
	,ysnMaxExceed BIT
)

BEGIN
	DECLARE @dblBurnRate NUMERIC(18,6)
	DECLARE @dblPreviousBurnRate NUMERIC(18,6)
	DECLARE @ysnAdjustBurnRate BIT
	DECLARE @dblBurnRateAverage NUMERIC(18,6)
	DECLARE @dblCalculatedBurnRate NUMERIC(18,6)
	DECLARE @dblBurnRateChangePercent NUMERIC(18,6)
	DECLARE @intMaxChageDown INT
	DECLARE @intMaxChangeUp INT
	DECLARE @ysnExceedMax BIT
	DECLARE @dblCappedOrFloored NUMERIC(18,6)
	DECLARE @dblReturnValue NUMERIC(18,6)
	DECLARE @intDeliveryDateLifetimeAccumDD INT
	DECLARE @intLastDeliveryDateLifetimeAccumDD INT
	DECLARE @intClockId INT

	DECLARE @intLastDeliveryDegreeDay INT
	DECLARE @dblElapseDDBetweenDelivery NUMERIC(18,6)
	DECLARE @dblAccumulatedDD NUMERIC(18,6)
	DECLARE @dblGallonsUsed NUMERIC(18,6)
	DECLARE @strBillingBy NVARCHAR(10)
	DECLARE @dblMeterConversionFactor NUMERIC(18, 8)
	DECLARE @dblLastMeterReading NUMERIC(18,6)
	DECLARE @dblInvoiceItemTotal NUMERIC(18,6)
	DECLARE @dblInvoiceQuantity NUMERIC(18,6)
	DECLARE @dblMeterReading NUMERIC(18,6)
	DECLARE @dblLastGallonsInTank NUMERIC(18,6)
	DECLARE @dblPercentAfterDelivery NUMERIC(18,6)
	DECLARE @dblTotalCapacity NUMERIC(18,6)
	DECLARE @dblSummerDailyUse NUMERIC(18,6)
	DECLARE @dblWinterDailyUse NUMERIC(18,6)
	DECLARE @dblDailyGalsUsed  NUMERIC(18,6)
	DECLARE @intElapseDays INT 
	DECLARE @dtmLastDeliveryDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @dblElapseDDForCalc NUMERIC(18,6)
	DECLARE @dblElapseDDDuringHold NUMERIC(18,6)

	DECLARE @intClockBeginSummerMonth INT
	DECLARE @intClockBeginWinterMonth INT
	
	
	DECLARE @dtmLastMonitorReadingEvent DATETIME
	DECLARE @strDescription NVARCHAR(500)
	DECLARE @intStart INT 
	DECLARE @intEnd INT 
	DECLARE @dblLastPercentFull NUMERIC(18,6)



	---Get Site Info
	SELECT
		@dblBurnRate = dblBurnRate
		,@dblPreviousBurnRate = dblPreviousBurnRate
		,@ysnAdjustBurnRate = ysnAdjustBurnRate
		,@intLastDeliveryDegreeDay = intLastDeliveryDegreeDay
		,@strBillingBy = strBillingBy
		,@dblLastMeterReading = dblLastMeterReading
		,@dblLastGallonsInTank = dblLastGalsInTank
		,@dblSummerDailyUse = dblSummerDailyUse
		,@dblWinterDailyUse = dblWinterDailyUse
		,@dtmLastDeliveryDate = dtmLastDeliveryDate
		,@dblTotalCapacity = dblTotalCapacity
	FROM tblTMSite
	WHERE intSiteID = @intSiteId
	
	---- Check for previous Reading 
	IF (ISNULL(@dblPreviousBurnRate,0) = 0)
	BEGIN
		INSERT INTO @tblReturnValue (dblBurnRate,ysnMaxExceed) VALUES (@dblBurnRate,0)
		RETURN
	END

	--- Get Last Monitor Reading 
	SELECT TOP 1 
		@intLastMonitorReadingEvent = intEventID
		,@dtmLastMonitorReadingEvent = dtmDate
		,@strDescription = strDescription
	FROM tblTMEvent 
	WHERE intSiteID = @intSiteId
		AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strDefaultEventType = 'Event-021')
		AND DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmLastDeliveryDate), 0)
	ORDER BY dtmDate DESC

	--Check if have last Monitor Reading and use it as the last delivery date
	IF(@intLastMonitorReadingEvent IS NOT NULL)
	BEGIN
		SET @intPreviousDDReadingId = ISNULL((SELECT TOP 1 intDegreeDayReadingID FROM tblTMDegreeDayReading WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) = DATEADD(dd, DATEDIFF(dd, 0, @dtmLastMonitorReadingEvent), 0)),@intPreviousDDReadingId)
		SET @intStart = CHARINDEX('Percent Full: ',@strDescription,1) + 14
		SET @intEnd =  CHARINDEX(CHAR(10), SUBSTRING(@strDescription,@intStart,LEN(@strDescription) - @intStart))
		SET @dblLastPercentFull = CAST((SELECT SUBSTRING(@strDescription,@intStart, @intEnd - 1)) AS NUMERIC(18,6))
		SET @dblLastGallonsInTank = ((ISNULL(@dblLastPercentFull,0)/100) * @dblTotalCapacity)
	END
	
		
	--- Get Degree Day reading
	SELECT @dblAccumulatedDD = dblAccumulatedDegreeDay
		,@intClockId = intClockID
		,@dtmDeliveryDate = dtmDate
	FROM tblTMDegreeDayReading
	WHERE intDegreeDayReadingID = @intDDReadingId

	--get the life time accumulated DD for last delivery and invoice date
	SET @intDeliveryDateLifetimeAccumDD = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmDeliveryDate AND intClockID = @intClockId),0)
	SET @intLastDeliveryDateLifetimeAccumDD = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmLastDeliveryDate AND intClockID = @intClockId),0)


	---	 get ellapse Degree Day between delivery
	SET @dblElapseDDBetweenDelivery = ABS(@intDeliveryDateLifetimeAccumDD - @intLastDeliveryDateLifetimeAccumDD)

	
	

	--Gals used
	SET @dblGallonsUsed = @dblLastGallonsInTank - ((ISNULL(@dblPercentLeft,0)/100) * @dblTotalCapacity)

	-- Get Clock Info
	SELECT TOP 1
		@intClockBeginSummerMonth = intBeginSummerMonth
		,@intClockBeginWinterMonth = intBeginWinterMonth
	FROM tblTMClock
	WHERE intClockID = @intClockId

	--Check the current Season and get the daily used
	IF(YEAR(@dtmDeliveryDate) >= @intClockBeginSummerMonth AND YEAR(@dtmDeliveryDate) < @intClockBeginWinterMonth)
	BEGIN
		SET @dblDailyGalsUsed = @dblSummerDailyUse
	END
	ELSE
	BEGIN
		SET @dblDailyGalsUsed = @dblWinterDailyUse
	END
		
	---Get Elapse days 
	IF(@dtmLastDeliveryDate IS NOT NULL AND @dtmDeliveryDate > @dtmLastDeliveryDate)
	BEGIN
		SET @intElapseDays = ABS(DATEDIFF(DAY,@dtmDeliveryDate,@dtmLastDeliveryDate))
	END
	ELSE
	BEGIN
		SET @intElapseDays = 0
	END

	SET @dblElapseDDForCalc =  dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intDDReadingId,NULL)
	
	IF (ISNULL(@dblGallonsUsed,0) <> 0 AND ((@dblGallonsUsed - (@intElapseDays * @dblDailyGalsUsed)) <> 0))
	BEGIN
		IF(ISNULL(@dblElapseDDForCalc,0) = 0)
		BEGIN
			SET	@dblCalculatedBurnRate = @dblBurnRate
		END
		ELSE
		BEGIN
			SET	@dblCalculatedBurnRate = @dblElapseDDForCalc /(@dblGallonsUsed - (@intElapseDays * @dblDailyGalsUsed))
		END
	END
	
	IF(ISNULL(@dblPreviousBurnRate,0) = 0)
	BEGIN
		SET @dblBurnRateAverage = (ISNULL(@dblCalculatedBurnRate,0) + @dblBurnRate)/2
	END
	ELSE
	BEGIN
		SET @dblBurnRateAverage = (ISNULL(@dblCalculatedBurnRate,0) + @dblBurnRate + @dblPreviousBurnRate)/3
	END
		
	---- Get Burn Rate Change Percent Synch out of range part
	SET @dblBurnRateChangePercent = ((@dblBurnRateAverage - @dblBurnRate)/@dblBurnRate) * 100
		
	SELECT TOP 1
		@intMaxChageDown = ISNULL(intFloorBurnRate,0)
		,@intMaxChangeUp = ISNULL(intCeilingBurnRate,0)
	FROM tblTMPreferenceCompany
		
	SET @ysnExceedMax = 0
	IF((@dblBurnRateChangePercent < 0 AND ABS(@dblBurnRateChangePercent) > @intMaxChageDown)
		OR (@dblBurnRateChangePercent >= 0 AND ABS(@dblBurnRateChangePercent) > @intMaxChangeUp))
	BEGIN
		SET @ysnExceedMax = 1
	END
		
	IF(@dblBurnRateChangePercent < 0)
	BEGIN
		SET @dblCappedOrFloored = 100 - @intMaxChageDown
	END
	ELSE
	BEGIN
		SET @dblCappedOrFloored = 100 + @intMaxChangeUp
	END
		
	
	
	IF(@ysnExceedMax = 1)
	BEGIN
		SET @dblReturnValue = ((@dblBurnRate * @dblCappedOrFloored)/100)
	END
	ELSE
	BEGIN
		SET @dblReturnValue = @dblBurnRateAverage
	END
	
	INSERT INTO @tblReturnValue (dblBurnRate,ysnMaxExceed) VALUES (@dblReturnValue,@ysnExceedMax)

	RETURN
END

GO