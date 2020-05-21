CREATE PROCEDURE uspTMUpdateNextJulianDeliveryBySite 
	@intSiteId INT
AS
BEGIN
	DECLARE @dtmLastDeliveryDate DATETIME
	DECLARE @intGlobalJulianCalendarId INT
	DECLARE @intJan INT
	DECLARE @intFeb INT
	DECLARE @intMar INT
	DECLARE @intApr INT
	DECLARE @intMay INT
	DECLARE @intJun INT
	DECLARE @intJul INT
	DECLARE @intAug INT
	DECLARE @intSep INT
	DECLARE @intOct INT
	DECLARE @intNov INT
	DECLARE @intDec INT

	DECLARE @ysnEndCalc BIT 
	DECLARE @intCurrentCalcMonth INT
	DECLARE @intDaysLeftInMonth INT
	DECLARE @intDaysInMonth INT
	DECLARE @dtmCurrentCalcDate DATETIME
	DECLARE @dblPercentIntervalUsed NUMERIC(18,6)
	DECLARE @dblPercentNextMonth NUMERIC(18,6)
	DECLARE @intDaysInNextMonth INT
	DECLARE @intDaysBeforeDelivery INT
	DECLARE @intCurrentMonthInterval INT
	DECLARE @dblCurrentMonthIntervalPerDay NUMERIC(18,6)
	DECLARE @dblCurrentMonthMaxPercent NUMERIC(18,6)
	DECLARE @dblCurrentMonthRemainingInterval NUMERIC(18,6)


	IF EXISTS(SELECT TOP 1 1 FROM tblTMSite 
				WHERE intSiteID = @intSiteId 
					AND dtmLastDeliveryDate IS NOT NULL 
					AND intGlobalJulianCalendarId IS NOT NULL
					AND intFillMethodId = (SELECT TOP 1 intFillMethodId FROM tblTMFillMethod WHERE strFillMethod = 'Julian Calendar')
					AND ysnActive = 1)
	BEGIN
		SELECT TOP 1
			@intGlobalJulianCalendarId = intGlobalJulianCalendarId
			,@dtmLastDeliveryDate = dtmLastDeliveryDate
		FROM tblTMSite WHERE intSiteID = @intSiteId

		---GET JULIAN CAlendar details
		SELECT 
			@intJan = intJanuary
			,@intFeb = intFebruary
			,@intMar = intMarch
			,@intApr = intApril
			,@intMay = intMay
			,@intJun = intJune
			,@intJul = intJuly
			,@intAug = intAugust
			,@intSep = intSeptember
			,@intOct = intOctober
			,@intNov = intNovember
			,@intDec = intDecember
		FROM tblTMGlobalJulianCalendar
		WHERE intGlobalJulianCalendarId = @intGlobalJulianCalendarId

	
		SET @ysnEndCalc = 0
		SET @dtmCurrentCalcDate = @dtmLastDeliveryDate
		--SET @dblRemainingInterval = NULL
		SET @dblPercentNextMonth = 100
		SET @intDaysBeforeDelivery = 0

		WHILE(@ysnEndCalc = 0)
		BEGIN
			SET @intCurrentCalcMonth = MONTH(@dtmCurrentCalcDate)
			--January
			IF(@intCurrentCalcMonth = 1)
			BEGIN
				SET @intCurrentMonthInterval = @intJan
				--SET @intNextMonthInterval = @intFeb
			END
			--February
			IF(@intCurrentCalcMonth = 2)
			BEGIN
				SET @intCurrentMonthInterval = @intFeb
				--SET @intNextMonthInterval = @intMar
			END
			--March
			IF(@intCurrentCalcMonth = 3)
			BEGIN
				SET @intCurrentMonthInterval = @intMar
				--SET @intNextMonthInterval = @intApr
			END
			--April
			IF(@intCurrentCalcMonth = 4)
			BEGIN
				SET @intCurrentMonthInterval = @intApr
				--SET @intNextMonthInterval = @intMay
			END
			--May
			IF(@intCurrentCalcMonth = 5)
			BEGIN
				SET @intCurrentMonthInterval = @intMay
				--SET @intNextMonthInterval = @intJun
			END
			--June
			IF(@intCurrentCalcMonth = 6)
			BEGIN
				SET @intCurrentMonthInterval = @intJun
				--SET @intNextMonthInterval = @intJul
			END
			--July
			IF(@intCurrentCalcMonth = 7)
			BEGIN
				SET @intCurrentMonthInterval = @intJul
				--SET @intNextMonthInterval = @intAug
			END
			--August
			IF(@intCurrentCalcMonth = 8)
			BEGIN
				SET @intCurrentMonthInterval = @intAug
				--SET @intNextMonthInterval = @intSep
			END
			--September
			IF(@intCurrentCalcMonth = 9)
			BEGIN
				SET @intCurrentMonthInterval = @intSep
				--SET @intNextMonthInterval = @intOct
			END
			--October
			IF(@intCurrentCalcMonth = 10)
			BEGIN
				SET @intCurrentMonthInterval = @intOct
				--SET @intNextMonthInterval = @intNov
			END
			--November
			IF(@intCurrentCalcMonth = 11)
			BEGIN
				SET @intCurrentMonthInterval = @intNov
				--SET @intNextMonthInterval = @intDec
			END
			--December
			IF(@intCurrentCalcMonth = 12)
			BEGIN
				SET @intCurrentMonthInterval = @intDec
				--SET @intNextMonthInterval = @intJan
			END

			SET @intDaysInMonth = DATEDIFF(DAY, DATEADD(DAY, 1-DAY(@dtmCurrentCalcDate), @dtmCurrentCalcDate),DATEADD(MONTH, 1, DATEADD(DAY, 1-DAY(@dtmCurrentCalcDate), @dtmCurrentCalcDate)))

			IF(@dtmCurrentCalcDate = @dtmLastDeliveryDate)
			BEGIN
				SET @intDaysLeftInMonth = @intDaysInMonth - DAY(@dtmCurrentCalcDate) 
			END
			ELSE
			BEGIN
				--SET @intCurrentMonthInterval = @intDaysInMonth 
				SET @intDaysLeftInMonth = 	@intDaysInMonth
			END

			IF (isnull(@intCurrentMonthInterval,0) = 0)
			BEGIN
				-- The Julian Calendar value is zero - No need to update the Next Delivery Date.
				set @ysnEndCalc = 1;
				GOTO NoNeedToUpdate;
			END

		
			SET @dblCurrentMonthIntervalPerDay = 1/CAST(@intCurrentMonthInterval AS NUMERIC(18,6))
			SET @dblCurrentMonthMaxPercent = @dblCurrentMonthIntervalPerDay * @intDaysLeftInMonth * 100

			--CHECK if current month can consume the percentleft
			IF(@dblCurrentMonthMaxPercent >= @dblPercentNextMonth)
			BEGIN
				SET @dblCurrentMonthRemainingInterval = @dblPercentNextMonth/ (@dblCurrentMonthIntervalPerDay * 100)
				SET @intDaysBeforeDelivery = @intDaysBeforeDelivery + FLOOR(@dblCurrentMonthRemainingInterval)

				IF((@dblCurrentMonthRemainingInterval - FLOOR(@dblCurrentMonthRemainingInterval)) > 0)
				BEGIN
					SET @intDaysBeforeDelivery = @intDaysBeforeDelivery + 1
				END

				GOTO UpdateSite
			END

			SET @dblPercentIntervalUsed = CAST(@intDaysLeftInMonth AS NUMERIC(18,6)) * @dblCurrentMonthIntervalPerDay * 100

			SET @dblPercentNextMonth = @dblPercentNextMonth - @dblPercentIntervalUsed

			IF(@dblPercentNextMonth <= 0)
			BEGIN
				UpdateSite:
				UPDATE tblTMSite
				SET dtmNextDeliveryDate = DATEADD(DAY,@intDaysBeforeDelivery,@dtmLastDeliveryDate)
				,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
				WHERE intSiteID = @intSiteId
				SET @ysnEndCalc = 1
				PRINT @intDaysBeforeDelivery
			END
			ELSE
			BEGIN
				SET @intDaysBeforeDelivery = @intDaysBeforeDelivery + @intDaysLeftInMonth
				SET @dtmCurrentCalcDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @dtmCurrentCalcDate)+ 1, 0) 
			END
		END

		-- The Julian Calendar value is zero - No need to update the Next Delivery Date.
		NoNeedToUpdate:
	END
END
GO