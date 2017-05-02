CREATE PROCEDURE uspTMUpdateEstimatedValuesBySite 
	@intSiteId AS INT
AS
BEGIN
	

	DECLARE @LastReadingDate DATETIME 
	DECLARE @AccumulatedDD INT
	DECLARE @intClockId INT
	DECLARE @currentSeason NVARCHAR(10)
	
	

	---Get Clock Id used in the Site
	SELECT @intClockId = intClockID FROM tblTMSite WHERE intSiteID = @intSiteId
	SET @currentSeason = (SELECT (CASE WHEN (MONTH(GETDATE()) >= intBeginSummerMonth AND  MONTH(GETDATE()) < intBeginWinterMonth) THEN 'SUMMER' ELSE 'WINTER' END) FROM tblTMClock WHERE intClockID = @intClockId)

	IF OBJECT_ID('tempdb..#tmpLatestReading') IS NOT NULL DROP TABLE #tmpLatestReading

	SELECT * INTO #tmpLatestReading 
	FROM tblTMDegreeDayReading
	WHERE intClockID = @intClockId


	IF EXISTS(SELECT TOP 1 1 FROM #tmpLatestReading)
	BEGIN 

		SELECT TOP 1 
			@LastReadingDate	=	dtmDate, 
			@AccumulatedDD		=	dblAccumulatedDegreeDay
		FROM #tmpLatestReading ORDER BY dtmDate DESC

		UPDATE tblTMSite
		SET dtmLastReadingUpdate = @LastReadingDate,   
			dblEstimatedGallonsLeft =	CASE WHEN(@currentSeason = 'SUMMER') THEN
											ISNULL(dblEstimatedGallonsLeft,0) 
												- (
													(DATEDIFF(DAY,ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(dblSummerDailyUse,0)
													+ (
														(@AccumulatedDD 
														-
														ISNULL(
														(	
															SELECT	TOP 1  
																   dblAccumulatedDegreeDay 
															FROM	#tmpLatestReading 
															WHERE	DAY(dtmDate) = DAY(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))  
																	AND MONTH(dtmDate) = MONTH(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
																	AND YEAR(dtmDate) = YEAR(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
														),0))		

														/	(CASE WHEN ISNULL(dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(dblBurnRate,1) END)
													)
												)
										ELSE
											ISNULL(dblEstimatedGallonsLeft,0) 
												- (
													(DATEDIFF(DAY,ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(dblWinterDailyUse,0)
													+ (
														(@AccumulatedDD 
														-
														ISNULL(
														(	
															SELECT	TOP 1  
																	dblAccumulatedDegreeDay 
															FROM	#tmpLatestReading 
															WHERE	DAY(dtmDate) = DAY(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))  
																	AND MONTH(dtmDate) = MONTH(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
																	AND YEAR(dtmDate) = YEAR(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
														),0))		

														/	(CASE WHEN ISNULL(dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(dblBurnRate,1) END)
													)
												)
										END	
		,dblEstimatedPercentLeft =		CASE WHEN(@currentSeason = 'SUMMER') THEN
											ISNULL(dblEstimatedGallonsLeft,0) 
												- (
													(DATEDIFF(DAY,ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(dblSummerDailyUse,0)
													+ (
														(@AccumulatedDD 
														 -
														ISNULL(
														(	
															SELECT	TOP 1  
																	dblAccumulatedDegreeDay 
															FROM	#tmpLatestReading 
															WHERE	DAY(dtmDate) = DAY(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))  
																	AND MONTH(dtmDate) = MONTH(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
																	AND YEAR(dtmDate) = YEAR(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
														),0))		

														/	(CASE WHEN ISNULL(dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(dblBurnRate,1) END)
													)
												)

										 ELSE
											ISNULL(dblEstimatedGallonsLeft,0) 
													- (
														(DATEDIFF(DAY,ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(dblWinterDailyUse,0)
														+ (
															(@AccumulatedDD 
															-
															ISNULL(
															(	
																SELECT	TOP 1  
																		dblAccumulatedDegreeDay 
																FROM	#tmpLatestReading 
																WHERE	DAY(dtmDate) = DAY(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))  
																		AND MONTH(dtmDate) = MONTH(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
																		AND YEAR(dtmDate) = YEAR(ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate))
															),0))		

															/	(CASE WHEN ISNULL(dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(dblBurnRate,1) END)
														)
													)
										END
											/(CASE WHEN ISNULL(dblTotalCapacity,1) = 0 THEN 1 ELSE ISNULL(dblTotalCapacity,1) END) * 100

		WHERE intSiteID = @intSiteId
			AND CAST((ISNULL(dtmLastDeliveryDate,'1900-01-01')) as DATETIME) < @LastReadingDate
			AND ysnActive = 1
			AND CAST((ISNULL(dtmLastReadingUpdate,'1900-01-01')) as DATETIME) < @LastReadingDate

		UPDATE tblTMSite
		SET dblEstimatedGallonsLeft = 0
		WHERE intSiteID = @intSiteId	AND dblEstimatedGallonsLeft < 0

		UPDATE tblTMSite
		SET dblEstimatedPercentLeft = 0
		WHERE intSiteID = @intSiteId	AND dblEstimatedPercentLeft < 0
    
	END
END

