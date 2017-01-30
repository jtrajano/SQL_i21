CREATE FUNCTION [dbo].[fnTMGetElapseDegreeDayForCalculation]
(
	@intSiteId INT
	,@intDDReadingId INT
	,@intDeliveryHistoryId INT = NULL
)
RETURNS NUMERIC(18,6) AS
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
	DECLARE @dblElapseDDDuringHold NUMERIC(18,6)
	DECLARE @intElapseDDBetweenDelivery INT
	DECLARE @dblAccumulatedDD NUMERIC(18,6)
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @dtmOnHoldEndDate DATETIME
	DECLARE @dtmOnHoldStartDate DATETIME
	DECLARE @intLastDeliveryDegreeDay INT
	DECLARE @ysnCalcOnHold BIT
	DECLARE @ysnOnHold BIT
	DECLARE @dblElapseDDForCalc NUMERIC(18,6)

	DECLARE @intDeliveryDateLifetimeAccumDD INT
	DECLARE @intLastDeliveryDateLifetimeAccumDD INT
	DECLARE @intClockId INT
	DECLARE @dtmLastDeliveryDate DATETIME
	

	IF(@intDeliveryHistoryId IS NULL)
	BEGIN
		-----Get Site Info
		SELECT 
			@dtmOnHoldStartDate = dtmOnHoldStartDate
			,@dtmOnHoldEndDate = dtmOnHoldEndDate
			,@intLastDeliveryDegreeDay = intLastDeliveryDegreeDay
			,@ysnCalcOnHold = ysnHoldDDCalculations
			,@ysnOnHold = ysnOnHold
			,@dtmLastDeliveryDate = dtmLastDeliveryDate
		FROM tblTMSite
		WHERE intSiteID = @intSiteId
	END
	ELSE
	BEGIN
		---Get Site Info from delivery history
		SELECT
			@dtmOnHoldStartDate = dtmSiteOnHoldStartDate
			,@dtmOnHoldEndDate = dtmSiteOnHoldEndDate
			,@intLastDeliveryDegreeDay = intDegreeDayOnLastDeliveryDate
			,@ysnCalcOnHold = ysnSiteHoldDDCalculations
			,@dtmLastDeliveryDate = A.dtmSiteLastDelivery
			,@ysnOnHold = ysnSiteOnHold
		FROM tblTMDeliveryHistory A
		WHERE A.intDeliveryHistoryID = @intDeliveryHistoryId
	END
	
	SELECT TOP 1 @intClockId = intClockID FROM tblTMSite WHERE intSiteID = @intSiteId

	---Get Degree REading Info
	SELECT 
		@dblAccumulatedDD = dblAccumulatedDegreeDay
		,@dtmDeliveryDate = dtmDate
	FROM tblTMDegreeDayReading
	WHERE intDegreeDayReadingID = @intDDReadingId

	--get the life time accumulated DD for last delivery and invoice date
	SET @intDeliveryDateLifetimeAccumDD = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmDeliveryDate AND intClockID = @intClockId),0)
	SET @intLastDeliveryDateLifetimeAccumDD = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmLastDeliveryDate AND intClockID = @intClockId),0)
	
	---	 get ellapse Degree Day between delivery
	SET @intElapseDDBetweenDelivery = ABS(@intDeliveryDateLifetimeAccumDD - @intLastDeliveryDateLifetimeAccumDD)
	
	
	-----Get Elapse DD for calculation
	IF(@ysnOnHold = 0)
	BEGIN
		SET @dblElapseDDDuringHold = 0
	END
	ELSE
	BEGIN
		SET @dblElapseDDDuringHold = 0
		IF(ISNULL(@ysnCalcOnHold,0) = 1)
		BEGIN
			IF(@dtmDeliveryDate > @dtmOnHoldEndDate)
			BEGIN
				SET @dblElapseDDDuringHold = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmOnHoldEndDate AND intClockID = @intClockId),0)
											-ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmOnHoldStartDate AND intClockID = @intClockId),0)
			END
			ELSE
			BEGIN
				IF((@dtmDeliveryDate >= @dtmOnHoldStartDate) AND @dtmDeliveryDate <= @dtmOnHoldEndDate)
				BEGIN
					SET @dblElapseDDDuringHold = ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmDeliveryDate AND intClockID = @intClockId),0) 
												-ISNULL((SELECT SUM(intDegreeDays) FROM tblTMDegreeDayReading WHERE dtmDate <=  @dtmOnHoldStartDate AND intClockID = @intClockId),0) 
				END	
			END
		END
	END
	
	SET @dblElapseDDForCalc =  @intElapseDDBetweenDelivery - @dblElapseDDDuringHold
	SET @dblReturnValue = @dblElapseDDForCalc
	RETURN @dblReturnValue
END
GO