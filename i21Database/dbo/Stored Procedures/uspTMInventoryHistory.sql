
CREATE PROCEDURE [dbo].[uspTMInventoryHistory]
	@intSiteId int
AS
BEGIN

	DECLARE @dtmDateTimeOrder DATETIME
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
		B.dtmDateTime,
		CONVERT(VARCHAR(10), B.dtmDateTime, 111)
		,DATEPART(HOUR, B.dtmDateTime)
		,B.dblFuelVolume
	FROM tblTMSite A
		INNER JOIN tblTMTankReading B
		ON B.intSiteId = A.intSiteID
	where A.intSiteID = @intSiteId and ((DATEDIFF (day, B.dtmDateTime, getdate())) <= 28)
	order by B.dtmDateTime desc

    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @dtmDateTimeOrder, @dtmDateTime, @intHour,@dblFuelVolume
    WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @tempdtmDateTime DATETIME
		DECLARE @IdTemp int
		DECLARE @dblZero DECIMAL(18,6)
		DECLARE @dblOne		DECIMAL(18,6)
		DECLARE @dblTwo		DECIMAL(18,6)
		DECLARE @dblThree		DECIMAL(18,6)
		DECLARE @dblFour		DECIMAL(18,6)
		DECLARE @dblFive		DECIMAL(18,6)
		DECLARE @dblSix		DECIMAL(18,6)
		DECLARE @dblSeven		DECIMAL(18,6)
		DECLARE @dblEight		DECIMAL(18,6)
		DECLARE @dblNine		DECIMAL(18,6)
		DECLARE @dblTen		DECIMAL(18,6)
		DECLARE @dblEleven	DECIMAL(18,6)
		DECLARE @dblTwelve	DECIMAL(18,6)
		DECLARE @dblThirteen  DECIMAL(18,6)
		DECLARE @dblFourteen  DECIMAL(18,6)
		DECLARE @dblFifteen   DECIMAL(18,6) 
		DECLARE @dblSixteen   DECIMAL(18,6) 
		DECLARE @dblSeventeen  DECIMAL(18,6) 
		DECLARE @dblEighteen   DECIMAL(18,6) 
		DECLARE @dblNineteen   DECIMAL(18,6) 
		DECLARE @dblTwenty   DECIMAL(18,6) 
		DECLARE @dblTwentyOne DECIMAL(18,6)
		DECLARE @dblTwentyTwo   DECIMAL(18,6) 
		DECLARE @dblTwentyThree   DECIMAL(18,6) 


		select @dblZero = dblZero,@dblOne = dblOne,@dblTwo = dblTwo,@dblThree = dblThree,@dblFour = dblFour,@dblFive = dblFive,@dblSix = dblSix,@dblSeven = dblSeven,@dblEight = dblEight,
		@dblNine = dblNine,@dblTen = dblTen,@dblEleven = dblEleven,@dblTwelve = dblTwelve,@dblThirteen = dblThirteen,@dblFourteen = dblFourteen,@dblFifteen = dblFifteen,@dblSixteen = dblSixteen,
		@dblSeventeen = dblSeventeen,@dblEighteen = dblEighteen,@dblNineteen = dblNineteen,@dblTwenty = dblTwenty,@dblTwentyOne = dblTwentyOne,@dblTwentyTwo = dblTwentyTwo,@dblTwentyThree = dblTwentyThree 
		from #tempInventoryHistory

		select top 1 @tempdtmDateTime = CONVERT(VARCHAR(10), dtmTempDateTime, 111), @IdTemp = Id from  #tempInventoryHistory order by Id desc

		if @tempdtmDateTime = @dtmDateTime
			BEGIN
			print @tempdtmDateTime
			print @dtmDateTime 
				IF @intHour = 1 and @dblOne is null
				BEGIN
					update #tempInventoryHistory set dblOne = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 2 and @dblTwo is null
				BEGIN
					update #tempInventoryHistory set dblTwo = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 3 and @dblThree is null
				BEGIN
					update #tempInventoryHistory set dblThree = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 4 and @dblFour is null
				BEGIN
					update #tempInventoryHistory set dblFour = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 5 and @dblFive is null
				BEGIN
					update #tempInventoryHistory set dblFive = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 6 and @dblSix is null
				BEGIN
					update #tempInventoryHistory set dblSix = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 7 and @dblSeven is null
				BEGIN
					update #tempInventoryHistory set dblSeven = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 8 and @dblEight is null
				BEGIN
					update #tempInventoryHistory set dblEight = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 9 and @dblNine is null
				BEGIN
					update #tempInventoryHistory set dblNine = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 10 and @dblTen is null
				BEGIN
					update #tempInventoryHistory set dblTen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 11 and @dblEleven is null
				BEGIN
					update #tempInventoryHistory set dblEleven = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 12 and @dblTwelve is null
				BEGIN
					update #tempInventoryHistory set dblTwelve = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 13 and @dblThirteen is null
				BEGIN
					update #tempInventoryHistory set dblThirteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 14 and @dblFourteen is null
				BEGIN
					update #tempInventoryHistory set dblFourteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 15 and @dblFifteen is null
				BEGIN
					update #tempInventoryHistory set dblFifteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 16 and @dblSixteen is null
				BEGIN
					update #tempInventoryHistory set dblSixteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 17 and @dblSeventeen is null
				BEGIN
					update #tempInventoryHistory set dblSeventeen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 18 and @dblEighteen is null
				BEGIN
					update #tempInventoryHistory set dblEighteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 19 and @dblNineteen is null
				BEGIN
					update #tempInventoryHistory set dblNineteen = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 20 and @dblTwenty is null
				BEGIN
					update #tempInventoryHistory set dblTwenty = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 21 and @dblTwentyOne is null
				BEGIN
					update #tempInventoryHistory set dblTwentyOne = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 22 and @dblTwentyTwo is null
				BEGIN
					update #tempInventoryHistory set dblTwentyTwo = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 23 and @dblTwentyThree is null
				BEGIN
					update #tempInventoryHistory set dblTwentyThree = @dblFuelVolume where Id = @IdTemp
				END
				ELSE IF @intHour = 0 and @dblZero is null
				BEGIN
					update #tempInventoryHistory set dblZero = @dblFuelVolume where Id = @IdTemp
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
				ELSE IF @intHour = 0
				BEGIN
					INSERT INTO #tempInventoryHistory(dtmTempDateTime,dblZero)values(@dtmDateTime,@dblFuelVolume)
				END
			END

	 FETCH NEXT FROM DataCursor INTO @dtmDateTimeOrder, @dtmDateTime, @intHour,@dblFuelVolume
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

	select * from #tempInventoryHistory
END