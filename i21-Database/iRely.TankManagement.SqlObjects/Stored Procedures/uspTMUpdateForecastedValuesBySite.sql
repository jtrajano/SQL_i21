CREATE PROCEDURE uspTMUpdateForecastedValuesBySite 
	@intSiteId AS INT
AS
BEGIN
	
	DECLARE @intClockId INT
	DECLARE @estimateGallonsLeft NUMERIC(18,6)
	DECLARE @lastReadingUpdate DATETIME
	DECLARE @usableGallonsRunOut NUMERIC(18,6)
	DECLARE @usableGallonsForcastedDelivery NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay NUMERIC(18,6)
	DECLARE @wintersummerAmountUsed NUMERIC(18,6)
	DECLARE @noUseableGalsTotal NUMERIC(18,6)
	DECLARE @foreCastedDeliveryFinished BIT
	DECLARE @forcastedRunOutFinished BIT
	DECLARE @forCastedDeliveryDate DATETIME
	DECLARE @forcatedRunOutDate DATETIME
	DECLARE @currentDate DATETIME
	DECLARE @lastReadingDate1 DATETIME
	DECLARE @burnRate NUMERIC(18,6)
	DECLARE @totalReserve NUMERIC(18,6)
	DECLARE @noDaysUseableGalsTotalRunOut NUMERIC(18,6)
	DECLARE @noDaysUseableGalsTotalForcastedDelivery NUMERIC(18,6)
	DECLARE @daysInMonth INT
	DECLARE @winterDailyUse NUMERIC(18,6)
	DECLARE @summerDailyUse NUMERIC(18,6)
	DECLARE @month1 NUMERIC(18,6)
	DECLARE @month2 NUMERIC(18,6)
	DECLARE @month3 NUMERIC(18,6)
	DECLARE @month4 NUMERIC(18,6)
	DECLARE @month5 NUMERIC(18,6)
	DECLARE @month6 NUMERIC(18,6)
	DECLARE @month7 NUMERIC(18,6)
	DECLARE @month8 NUMERIC(18,6)
	DECLARE @month9 NUMERIC(18,6)
	DECLARE @month10 NUMERIC(18,6)
	DECLARE @month11 NUMERIC(18,6)
	DECLARE @month12 NUMERIC(18,6)
	DECLARE @currentMonth INT
	DECLARE @txttmp varchar
	DECLARE @currentSeason NVARCHAR(20)

	DECLARE @finalRunOutDate DATETIME
	DECLARE @finalForeCastedDate DATETIME

	DECLARE @fuelConsumptionPerDay1 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay2 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay3 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay4 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay5 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay6 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay7 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay8 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay9 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay10 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay11 NUMERIC(18,6)
	DECLARE @fuelConsumptionPerDay12 NUMERIC(18,6)

	---Get Clock Reading Id used by site
	SELECT @intClockId = intClockID FROM tblTMSite WHERE intSiteID = @intSiteId

	SET @lastReadingDate1 = (SELECT TOP 1 dtmDate FROM tblTMDegreeDayReading ORDER BY dtmDate DESC)
	SET @currentSeason = (SELECT strCurrentSeason FROM tblTMClock WHERE intClockID = @intClockId)

	SELECT 
		@month1		= ISNULL(dblJanuaryDailyAverage,0),
		@month2		= ISNULL(dblFebruaryDailyAverage,0),
		@month3		= ISNULL(dblMarchDailyAverage,0),
		@month4		= ISNULL(dblAprilDailyAverage,0),
		@month5		= ISNULL(dblMayDailyAverage,0),
		@month6		= ISNULL(dblJuneDailyAverage,0),
		@month7		= ISNULL(dblJulyDailyAverage,0),
		@month8		= ISNULL(dblAugustDailyAverage,0),
		@month9		= ISNULL(dblSeptemberDailyAverage,0),
		@month10	= ISNULL(dblOctoberDailyAverage,0),
		@month11	= ISNULL(dblNovemberDailyAverage,0),
		@month12	= ISNULL(dblDecemberDailyAverage,0)
	FROM tblTMClock 
	WHERE intClockID = @intClockId

	SELECT TOP 1
		@intSiteId			= intSiteID,
		@estimateGallonsLeft	= CAST(dblEstimatedGallonsLeft AS NUMERIC(18,6)),
		@lastReadingUpdate		= ISNULL(dtmLastReadingUpdate, dtmLastDeliveryDate),
		@burnRate				= dblBurnRate,
		@totalReserve			= dblTotalReserve,
		@winterDailyUse			= ISNULL(dblWinterDailyUse,0.0),
		@summerDailyUse			= ISNULL(dblSummerDailyUse,0.0)    
	FROM tblTMSite 
	WHERE intSiteID = @intSiteId

	SET @foreCastedDeliveryFinished = 0
	SET @forcastedRunOutFinished = 0
	SET @usableGallonsRunOut = (@estimateGallonsLeft) 
	SET @usableGallonsForcastedDelivery = (@estimateGallonsLeft - @totalReserve)

	SET @wintersummerAmountUsed = CASE WHEN @currentSeason = 'Winter' THEN
											@winterDailyUse
										WHEN @currentSeason = 'Summer' THEN
											@summerDailyUse
									ELSE
										(SELECT 0)
									END

	SET @currentDate = @lastReadingUpdate
	SET @foreCastedDeliveryFinished = 0
	SET @forcastedRunOutFinished = 0
	SET @forCastedDeliveryDate = NULL
	SET @forcatedRunOutDate = NULL

	IF (@burnRate <> 0 AND @burnRate IS NOT NULL)
	BEGIN
		WHILE (@forcastedRunOutFinished <> 1)
		BEGIN
			SET @currentMonth = DATEPART(MONTH, @currentDate)
			SET @fuelConsumptionPerDay = ((CASE WHEN @currentMonth = 1 THEN
												@month1 
											WHEN @currentMonth = 2 THEN
												@month2
											WHEN @currentMonth = 3 THEN
												@month3
											WHEN @currentMonth = 4 THEN
												@month4
											WHEN @currentMonth = 5 THEN
												@month5
											WHEN @currentMonth = 6 THEN
												@month6
											WHEN @currentMonth = 7 THEN
												@month7
											WHEN @currentMonth = 8 THEN
												@month8
											WHEN @currentMonth = 9 THEN
												@month9
											WHEN @currentMonth = 10 THEN
												@month10
											WHEN @currentMonth = 11 THEN
												@month11
											WHEN @currentMonth = 12 THEN
												@month12
											END
											) 
										/ @burnRate) 
										+ @wintersummerAmountUsed

			SET @fuelConsumptionPerDay1 = (@month1/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay2 = (@month2/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay3 = (@month3/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay4 = (@month4/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay5 = (@month5/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay6 = (@month6/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay7 = (@month7/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay8 = (@month8/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay9 = (@month9/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay10 = (@month10/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay11 = (@month11/@burnRate) + @wintersummerAmountUsed
			SET @fuelConsumptionPerDay12 = (@month12/@burnRate) + @wintersummerAmountUsed

			IF(@fuelConsumptionPerDay = 0 AND @fuelConsumptionPerDay1 = 0 AND @fuelConsumptionPerDay2 = 0 
											AND @fuelConsumptionPerDay3 = 0 AND @fuelConsumptionPerDay4 = 0 
											AND @fuelConsumptionPerDay5 = 0 AND @fuelConsumptionPerDay6 = 0 
											AND @fuelConsumptionPerDay7 = 0 AND @fuelConsumptionPerDay8 = 0
											AND @fuelConsumptionPerDay9 = 0 AND @fuelConsumptionPerDay10 = 0
											AND @fuelConsumptionPerDay11 = 0 AND @fuelConsumptionPerDay12 = 0)
			BEGIN
				UPDATE tblTMSite
				SET dtmRunOutDate = NULL
					,dtmForecastedDelivery = NULL
				WHERE intSiteID = @intSiteId
				GOTO LOOPCONTINUE
			END

			IF (@fuelConsumptionPerDay = 0) 
			BEGIN
				SET @currentDate = DATEADD(MONTH, 1, @currentDate)
				GOTO CONTINUEWHILE
			END

			SET @noDaysUseableGalsTotalRunOut = CASE WHEN (@usableGallonsRunOut % @fuelConsumptionPerDay) = 0 THEN (@usableGallonsRunOut / @fuelConsumptionPerDay)
												ELSE CAST((@usableGallonsRunOut / @fuelConsumptionPerDay) AS INT) + 1
												END
			SET @noDaysUseableGalsTotalForcastedDelivery = CASE WHEN (@usableGallonsForcastedDelivery % @fuelConsumptionPerDay) = 0 THEN (@usableGallonsForcastedDelivery / @fuelConsumptionPerDay)
															ELSE  CAST((@usableGallonsForcastedDelivery / @fuelConsumptionPerDay) AS INT) + 1
															END

			SET @daysInMonth = CASE WHEN MONTH(@currentDate) IN (1, 3, 5, 7, 8, 10, 12) THEN 31
									WHEN MONTH(@currentDate) IN (4, 6, 9, 11) THEN 30
								ELSE 
								CASE WHEN (YEAR(@currentDate) % 4    = 0 AND
										YEAR(@currentDate) % 100 != 0) OR
										(YEAR(@currentDate) % 400  = 0)
									THEN 29
									ELSE 28
								END            
								END

			IF (@foreCastedDeliveryFinished <> 1)
			BEGIN
				IF (@noDaysUseableGalsTotalForcastedDelivery <= @daysInMonth - DATEPART(DAY, @currentDate))
				BEGIN
					SET @forCastedDeliveryDate = DATEADD(DAY, @noDaysUseableGalsTotalForcastedDelivery, @currentDate)
					SET @foreCastedDeliveryFinished = 1

					DECLARE @ForeCastedDate AS DATETIME				
					SET @ForeCastedDate = @currentDate
					WHILE (CAST(@noDaysUseableGalsTotalForcastedDelivery AS INT) !< 1)
						BEGIN
							SET @ForeCastedDate = DATEADD(DAY, 1, @ForeCastedDate)
							SET @noDaysUseableGalsTotalForcastedDelivery = @noDaysUseableGalsTotalForcastedDelivery - 1

							IF (CAST(@noDaysUseableGalsTotalForcastedDelivery AS INT) = 0)
							BEGIN
								SET @finalForeCastedDate = @ForeCastedDate
							END
						END

					UPDATE tblTMSite
					SET dtmForecastedDelivery = @ForeCastedDate
					WHERE intSiteID = @intSiteId
				END    
			END

			IF (@noDaysUseableGalsTotalRunOut <= (@daysInMonth - DATEPART(DAY, @currentDate)))
			BEGIN

				IF (@foreCastedDeliveryFinished = 0)
				BEGIN
					SET @forCastedDeliveryDate = DATEADD(DAY,@noDaysUseableGalsTotalForcastedDelivery,@currentDate)
					SET @foreCastedDeliveryFinished = 1
				END

				SET @forcatedRunOutDate = DATEADD(DAY,@noDaysUseableGalsTotalRunOut,@currentDate)
				SET @forcastedRunOutFinished = 1

				DECLARE @RunOutDate AS DATETIME				
				SET @RunOutDate = @currentDate
				WHILE (CAST(@noDaysUseableGalsTotalRunOut AS INT) !< 1)
					BEGIN
						SET @RunOutDate = DATEADD(DAY, 1, @RunOutDate)
						SET @noDaysUseableGalsTotalRunOut = @noDaysUseableGalsTotalRunOut - 1					
						IF (CAST(@noDaysUseableGalsTotalRunOut AS INT) = 0)
							BEGIN
								SET @finalRunOutDate = @RunOutDate
							END
					END

				UPDATE tblTMSite
				SET dtmRunOutDate = @RunOutDate
				WHERE intSiteID = @intSiteId
			END
			ELSE
			BEGIN
				SET @usableGallonsRunOut = @usableGallonsRunOut -((@daysInMonth - DATEPART(DAY, @currentDate) + 1) * @fuelConsumptionPerDay)
				SET @usableGallonsForcastedDelivery = @usableGallonsForcastedDelivery -((@daysInMonth - DATEPART(DAY, @currentDate) + 1) * @fuelConsumptionPerDay)
                
				IF(DATEPART(MONTH, @currentDate) <> 12)
				BEGIN
					SET @currentDate = (convert(datetime,  CONVERT(varchar,DATEPART(MONTH, @currentDate)+1) + '/1/' + CONVERT(varchar,DATEPART(YEAR, @currentDate)), 101)) -- mm/dd/yyyy
				END
				ELSE
				BEGIN
					IF ((DATEPART(YEAR, @currentDate) + 1) < 10000)
					BEGIN
						SET @currentDate = (convert(datetime,  '1/1/' + CONVERT(varchar,DATEPART(YEAR, @currentDate) + 1), 101)) -- mm/dd/yyyy
					END
					ELSE
					BEGIN
						SET @currentDate = convert(datetime,  '1/1/9999',101)
						SET @usableGallonsRunOut = 0
						SET @usableGallonsForcastedDelivery = 0
						GOTO CONTINUESET
					END
				END
				CONTINUESET:
			END
			CONTINUEWHILE: 
		END
	END
	LOOPCONTINUE:
END



