CREATE FUNCTION [dbo].[fnTMGetCalculatedBurnRate]
(
	@intSiteId INT
	,@intInvoiceDetailId INT
	,@intDDReadingId INT 
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
	DECLARE @dblEstimatedGallonsLeft NUMERIC(18,6)
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
	
	
	---Get Site Info
	SELECT
		@dblBurnRate = dblBurnRate
		,@dblPreviousBurnRate = dblPreviousBurnRate
		,@ysnAdjustBurnRate = ysnAdjustBurnRate
		,@intLastDeliveryDegreeDay = intLastDeliveryDegreeDay
		,@strBillingBy = strBillingBy
		,@dblLastMeterReading = dblLastMeterReading
		,@dblEstimatedGallonsLeft = dblEstimatedGallonsLeft
		,@dblSummerDailyUse = dblSummerDailyUse
		,@dblWinterDailyUse = dblWinterDailyUse
		,@dtmLastDeliveryDate = dtmLastDeliveryDate
	FROM tblTMSite
	WHERE intSiteID = @intSiteId
	
	--- Get Degree Day reading
	SELECT @dblAccumulatedDD = dblAccumulatedDegreeDay
		,@intClockId = intClockID
		,@dtmDeliveryDate = dtmDate
	FROM tblTMDegreeDayReading
	WHERE intDegreeDayReadingID = @intDDReadingId
	
	---	 get ellapse Degree Day between delivery
	SET @dblElapseDDBetweenDelivery = ROUND((ISNULL(@dblAccumulatedDD,0) - ISNULL(@intLastDeliveryDegreeDay,0)),0)
	
	--- get Invoice detail total
	SELECT @dblInvoiceItemTotal = dblTotal + ISNULL(dblTotalTax,0)
		,@dblInvoiceQuantity = dblQtyShipped
		,@dblMeterReading = dblNewMeterReading
	FROM tblARInvoiceDetail
	WHERE intInvoiceDetailId = @intInvoiceDetailId
	
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
		SET @dblGallonsUsed = @dblEstimatedGallonsLeft + @dblInvoiceQuantity - ((ISNULL(@dblPercentAfterDelivery,0)/100) * @dblTotalCapacity)
	END
	
	
	--Check the current Season and get the daily used
	IF((SELECT strCurrentSeason FROM tblTMClock WHERE intClockID = @intClockId) = 'Summer')
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
		SET @intElapseDays = DATEDIFF(DAY,@dtmDeliveryDate,@dtmLastDeliveryDate)
	END
	ELSE
	BEGIN
		SET @intElapseDays = 0
	END

	SET @dblElapseDDForCalc =  dbo.fnTMGetElapseDegreeDayForCalculation(@intSiteId,@intInvoiceDetailId)
	
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