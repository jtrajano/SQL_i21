
CREATE PROCEDURE [dbo].[uspTMInventoryHistory]
	@intSiteNumber int
AS
BEGIN

	DECLARE @dtmDateTime DATETIME
    DECLARE @intHour int
	DECLARE @dblFuelVolume DECIMAL(18,6)

	IF  OBJECT_ID('tempdb..#tempInventoryHistory') IS NOT NULL
	DROP TABLE #tempInventoryHistory

	CREATE TABLE #tempInventoryHistory(
		[Id] INT IDENTITY(1, 1) primary key 
		,[dtmTempDateTime] datetime
		,[dblZero]		DECIMAL(18,6)
		,[dblOne]		DECIMAL(18,6)
		,[dblTwo]		DECIMAL(18,6)
		,[dblThree]		DECIMAL(18,6)
		,[dblFour]		DECIMAL(18,6)
		,[dblFive]		DECIMAL(18,6)
		,[dblSix]		DECIMAL(18,6)
		,[dblSeven]		DECIMAL(18,6)
		,[dblEight]		DECIMAL(18,6)
		,[dblNine]		DECIMAL(18,6)
		,[dblTen]		DECIMAL(18,6)
		,[dblEleven]	DECIMAL(18,6)
		,[dblTwelve]	DECIMAL(18,6)
		,[dblThirteen]  DECIMAL(18,6)
		,[dblFourteen]  DECIMAL(18,6)
		,[dblFifteen]   DECIMAL(18,6) 
		,[dblSixteen]   DECIMAL(18,6) 
		,[dblSeventeen]   DECIMAL(18,6) 
		,[dblEighteen]   DECIMAL(18,6) 
		,[dblNineteen]   DECIMAL(18,6) 
		,[dblTwenty]   DECIMAL(18,6) 
		,[dblTwentyOne] DECIMAL(18,6)
		,[dblTwentyTwo]   DECIMAL(18,6) 
		,[dblTwentyThree]   DECIMAL(18,6) 
	);

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR

   		SELECT distinct
		CONVERT(VARCHAR(10), B.dtmDateTime, 111)
		,DATEPART(HOUR, B.dtmDateTime)
		,B.dblFuelVolume
	FROM tblTMSite A
		INNER JOIN tblTMTankMonitor B
		ON B.intSiteId = A.intSiteID
	where A.intSiteNumber = @intSiteNumber

    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @dtmDateTime, @intHour,@dblFuelVolume
    WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @tempdtmDateTime DATETIME
		DECLARE @IdTemp int

		select top 1 @tempdtmDateTime = CONVERT(VARCHAR(10), dtmTempDateTime, 111), @IdTemp = Id from  #tempInventoryHistory order by Id desc
		if @tempdtmDateTime = @dtmDateTime
			BEGIN
			IF @intHour = 1
				BEGIN
					update #tempInventoryHistory set dblOne = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 2
				BEGIN
					update #tempInventoryHistory set dblTwo = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 3
				BEGIN
					update #tempInventoryHistory set dblThree = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 4
				BEGIN
					update #tempInventoryHistory set dblFour = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 5
				BEGIN
					update #tempInventoryHistory set dblFive = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 6
				BEGIN
					update #tempInventoryHistory set dblSix = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 7
				BEGIN
					update #tempInventoryHistory set dblSeven = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 8
				BEGIN
					update #tempInventoryHistory set dblEight = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 9
				BEGIN
					update #tempInventoryHistory set dblNine = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 10
				BEGIN
					update #tempInventoryHistory set dblTen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 11
				BEGIN
					update #tempInventoryHistory set dblEleven = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 12
				BEGIN
					update #tempInventoryHistory set dblTwelve = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 13
				BEGIN
					update #tempInventoryHistory set dblThirteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 14
				BEGIN
					update #tempInventoryHistory set dblFourteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 15
				BEGIN
					update #tempInventoryHistory set dblFifteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 16
				BEGIN
					update #tempInventoryHistory set dblSixteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 17
				BEGIN
					update #tempInventoryHistory set dblSeventeen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 18
				BEGIN
					update #tempInventoryHistory set dblEighteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 19
				BEGIN
					update #tempInventoryHistory set dblNineteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 20
				BEGIN
					update #tempInventoryHistory set dblTwenty = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 21
				BEGIN
					update #tempInventoryHistory set dblTwentyOne = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 22
				BEGIN
					update #tempInventoryHistory set dblTwentyTwo = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 23
				BEGIN
					update #tempInventoryHistory set dblTwentyThree = dblTwentyThree where Id = @IdTemp
				END
				ELSE IF @intHour = 24
				BEGIN
					update #tempInventoryHistory set dblZero = dblTwentyThree where Id = @IdTemp
				END
			END
		else
			BEGIN
				IF @intHour = 1
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblOne)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 2
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwo)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 3
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblThree)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 4
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblFour)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 5
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblFive)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 6
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblSix)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 7
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblSeven)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 8
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblEight)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 9
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblNine)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 10
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 11
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblEleven)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 12
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwelve)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 13
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblThirteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 14
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblFourteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 15
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblFifteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 16
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblSixteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 17
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblSeventeen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 18
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblEighteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 19
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblNineteen)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 20
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwenty)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 21
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwentyOne)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 22
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwentyTwo)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 23
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblTwentyThree)values(@dtmDateTime,@dblFuelVolume)
				END
				ELSE IF @intHour = 24
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblZero)values(@dtmDateTime,@dblFuelVolume)
				END
			END

	 FETCH NEXT FROM DataCursor INTO @dtmDateTime, @intHour,@dblFuelVolume
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

	select * from #tempInventoryHistory
END