CREATE FUNCTION [dbo].[fnTMGetElapseDegreeDayForCalculation]
(
	@intSiteId INT
	,@intDDReadingId INT 
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
	
	-----Get Site Info
	SELECT 
		@dtmOnHoldStartDate = dtmOnHoldStartDate
		,@dtmOnHoldEndDate = dtmOnHoldEndDate
		,@intLastDeliveryDegreeDay = intLastDeliveryDegreeDay
		,@ysnCalcOnHold = ysnHoldDDCalculations
		,@ysnOnHold = ysnOnHold
	FROM tblTMSite
	WHERE intSiteID = @intSiteId
	
	---Get Degree REading Info
	SELECT 
		@dblAccumulatedDD = dblAccumulatedDegreeDay
		,@dtmDeliveryDate = dtmDate
	FROM tblTMDegreeDayReading
	WHERE intDegreeDayReadingID = @intDDReadingId
	
	SET @intElapseDDBetweenDelivery = ROUND((ISNULL(@dblAccumulatedDD,0) - ISNULL(@intLastDeliveryDegreeDay,0)),0)
	
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
				SET @dblElapseDDDuringHold = ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay FROM tblTMDegreeDayReading WHERE dtmDate = @dtmOnHoldEndDate),0)
											-ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay FROM tblTMDegreeDayReading WHERE dtmDate = @dtmOnHoldStartDate),0)
			END
			ELSE
			BEGIN
				IF((@dtmDeliveryDate >= @dtmOnHoldStartDate) AND @dtmDeliveryDate <= @dtmOnHoldStartDate)
				BEGIN
					SET @dblElapseDDDuringHold = ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay FROM tblTMDegreeDayReading WHERE dtmDate = @dtmDeliveryDate),0)
												-ISNULL((SELECT TOP 1 dblAccumulatedDegreeDay FROM tblTMDegreeDayReading WHERE dtmDate = @dtmOnHoldStartDate),0)
				END	
			END
		END
	END
	
	SET @dblElapseDDForCalc =  @intElapseDDBetweenDelivery - @dblElapseDDDuringHold
	
	RETURN @dblReturnValue
END
GO