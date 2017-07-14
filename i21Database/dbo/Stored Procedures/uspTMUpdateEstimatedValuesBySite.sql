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
			@LastReadingDate	=	dtmDate
		FROM #tmpLatestReading ORDER BY dtmDate DESC

		SELECT @AccumulatedDD		=	SUM(intDegreeDays)
		FROM #tmpLatestReading 
		

		--Update dispatch
		UPDATE tblTMDispatch
		SET 
			dblPercentLeft =		CASE WHEN(@currentSeason = 'SUMMER') THEN
											(ISNULL(A.dblTotalCapacity,0) * ISNULL(tblTMDispatch.dblPercentLeft,0) / 100) 
												- (
													(DATEDIFF(DAY,ISNULL(A.dtmLastReadingUpdate,A.dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(A.dblSummerDailyUse,0)
													+ (
														(@AccumulatedDD 
														 -
														ISNULL(
														(	
															SELECT	
																	SUM(intDegreeDays) 
															FROM	#tmpLatestReading 
															WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
														),0))		

														/	(CASE WHEN ISNULL(A.dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(A.dblBurnRate,1) END)
													)
												)

										 ELSE
											(ISNULL(A.dblTotalCapacity,0) * ISNULL(tblTMDispatch.dblPercentLeft,0) / 100)
													- (
														(DATEDIFF(DAY,ISNULL(A.dtmLastReadingUpdate,A.dtmLastDeliveryDate),@LastReadingDate)) * ISNULL(A.dblWinterDailyUse,0)
														+ (
															(@AccumulatedDD 
															-
															ISNULL(
															(	
																SELECT	
																		SUM(intDegreeDays) 
																FROM	#tmpLatestReading 
																WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
															),0))		

															/	(CASE WHEN ISNULL(A.dblBurnRate,1) = 0 THEN 1 ELSE ISNULL(A.dblBurnRate,1) END)
														)
													)
										END
											/(CASE WHEN ISNULL(dblTotalCapacity,1) = 0 THEN 1 ELSE ISNULL(dblTotalCapacity,1) END) * 100

		FROM (SELECT * FROM tblTMSite) A
		WHERE tblTMDispatch.intSiteID = @intSiteId 
			AND CAST((ISNULL(A.dtmLastDeliveryDate,'1900-01-01')) as DATETIME) < @LastReadingDate
			AND A.ysnActive = 1
			AND CAST((ISNULL(A.dtmLastReadingUpdate,'1900-01-01')) as DATETIME) < @LastReadingDate



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
															SELECT	  
																   SUM(intDegreeDays) 
															FROM	#tmpLatestReading 
															WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
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
															SELECT	
																	SUM(intDegreeDays) 
															FROM	#tmpLatestReading 
															WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
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
															SELECT	
																	SUM(intDegreeDays) 
															FROM	#tmpLatestReading 
															WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
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
																SELECT	
																		SUM(intDegreeDays) 
																FROM	#tmpLatestReading 
																WHERE	DATEADD(dd, DATEDIFF(dd, 0, dtmDate),0) <= DATEADD(dd, DATEDIFF(dd, 0, ISNULL(dtmLastReadingUpdate,dtmLastDeliveryDate)),0)
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

