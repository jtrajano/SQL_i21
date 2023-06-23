﻿CREATE FUNCTION [dbo].[fnTMGetCalculatedBurnRate]
(
	@intSiteId INT
	,@intInvoiceDetailId INT
	,@intDDReadingId INT 
	,@ysnMultipleInvoice BIT = 0
	,@intDeliveryHistoryId INT = NULL
)
RETURNS NUMERIC(18,6) AS
BEGIN
	DECLARE @dblBurnRate NUMERIC(18,6)
	DECLARE @dblPreviousBurnRate NUMERIC(18,6)
	DECLARE @ysnAdjustBurnRate BIT
	DECLARE @dblBurnRateAverage NUMERIC(18,6)
	DECLARE @dblCalculatedBurnRate NUMERIC(18,6)
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
	DECLARE @intClockId INT
	DECLARE @intElapseDays INT 
	DECLARE @dtmLastDeliveryDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @dblElapseDDForCalc NUMERIC(18,6)
	DECLARE @dblElapseDDDuringHold NUMERIC(18,6)
	DECLARE @intInvoiceId INT

	DECLARE @intDeliveryDateLifetimeAccumDD INT
	DECLARE @intLastDeliveryDateLifetimeAccumDD INT
	DECLARE @intClockBeginSummerMonth INT
	DECLARE @intClockBeginWinterMonth INT
	
	
	SET @ysnMultipleInvoice = 1
	IF(@intDeliveryHistoryId IS NULL)
	BEGIN
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
	END
	ELSE
	BEGIN
		---Get Site Info from delivery history
		SELECT
			@dblBurnRate = A.dblSiteBurnRate
			,@dblPreviousBurnRate = A.dblSitePreviousBurnRate
			,@ysnAdjustBurnRate = A.ysnAdjustBurnRate
			,@intLastDeliveryDegreeDay = A.intDegreeDayOnLastDeliveryDate
			,@strBillingBy = B.strBillingBy
			,@dblLastMeterReading = A.dblLastMeterReading
			,@dblLastGallonsInTank = A.dblSiteLastGalsInTank
			,@dblSummerDailyUse = A.dblSummerDailyUsageBetweenDeliveries
			,@dblWinterDailyUse = A.dblWinterDailyUsageBetweenDeliveries
			,@dtmLastDeliveryDate = A.dtmSiteLastDelivery
			,@dblTotalCapacity = B.dblTotalCapacity
		FROM tblTMDeliveryHistory A
		INNER JOIN tblTMSite B
			ON A.intSiteID = B.intSiteID
		WHERE A.intDeliveryHistoryID = @intDeliveryHistoryId
	
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
	
	--get percent after deliver
	SELECT TOP 1 @dblPercentAfterDelivery = dblPercentFull, @intInvoiceId  = intInvoiceId FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId 

	--- get Invoice detail total
	-------CHECK if multiple Invoice scenario
	IF(@ysnMultipleInvoice <> 1)
	BEGIN
		SELECT @dblInvoiceItemTotal = dblTotal + ISNULL(dblTotalTax,0)
			,@dblInvoiceQuantity = dblQtyShipped
			,@dblMeterReading = dblNewMeterReading
		FROM tblARInvoiceDetail
		WHERE intInvoiceDetailId = @intInvoiceDetailId
	END
	ELSE
	BEGIN
		SELECT  @dblInvoiceItemTotal = SUM(dblTotal) + SUM(ISNULL(dblTotalTax,0))
			,@dblInvoiceQuantity = SUM(dblQtyShipped)
		FROM tblARInvoiceDetail
		WHERE intSiteId = (SELECT TOP 1 intSiteId FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId)
			AND intInvoiceId = @intInvoiceId
	END
	
	----Check for flow meter
	IF(@strBillingBy = 'Flow Meter')
	BEGIN
		-------GEt Conversion factor for flow meter device
		SET @dblMeterConversionFactor = ISNULL((
										SELECT TOP 1 D.dblConversionFactor
										FROM tblTMSiteDevice A
										INNER JOIN tblTMDevice B
											ON A.intDeviceId = B.intDeviceId
										INNER JOIN tblTMDeviceType C
											ON B.intDeviceTypeId = C.intDeviceTypeId
												AND C.strDeviceType = 'Flow Meter'
										INNER JOIN tblTMMeterType D
											ON B.intMeterTypeId = D.intMeterTypeId
										WHERE A.intSiteID = @intSiteId
										ORDER BY A.intSiteDeviceID ASC
									 ),0.0)
		---Set Gallons Used									 
		SET @dblGallonsUsed = (ISNULL(@dblMeterReading,0.0) -  ISNULL(@dblLastMeterReading,0.0)) * @dblMeterConversionFactor
	END
	ELSE
	BEGIN
		---Set Gallons Used
		SET @dblGallonsUsed = @dblLastGallonsInTank + @dblInvoiceQuantity - ((ISNULL(@dblPercentAfterDelivery,0)/100) * @dblTotalCapacity)
	END
	

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

	SET @dblElapseDDForCalc =  dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intDDReadingId,@intDeliveryHistoryId)
	
	IF (ISNULL(@dblGallonsUsed,0) <> 0 AND ((@dblGallonsUsed - (@intElapseDays * @dblDailyGalsUsed)) <> 0))
	BEGIN
		IF(ISNULL(@dblElapseDDForCalc,0) = 0)
		BEGIN
			RETURN @dblBurnRate
		END
		ELSE
		BEGIN
			RETURN @dblElapseDDForCalc /(@dblGallonsUsed - (@intElapseDays * @dblDailyGalsUsed))
		END
	END
	
	RETURN @dblBurnRate
END