GO
	PRINT 'START OF CREATING [uspTMUpdateEstimatedValuesBySite] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMUpdateEstimatedValuesBySite]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMUpdateEstimatedValuesBySite
GO

CREATE PROCEDURE uspTMUpdateEstimatedValuesBySite 
	@intSiteId AS INT
AS
BEGIN
	

	DECLARE @LastReadingDate DATETIME 
	DECLARE @AccumulatedDD INT
	DECLARE @intClockId INT

	---Get Clock Id used in the Site
	SELECT @intClockId = intClockID FROM tblTMSite WHERE intSiteID = @intSiteId

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
			dblEstimatedGallonsLeft =	CASE WHEN((SELECT UPPER(strCurrentSeason) FROM tblTMClock WHERE intClockID = @intClockId) = 'SUMMER') THEN
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
		,dblEstimatedPercentLeft =		CASE WHEN((SELECT UPPER(strCurrentSeason) FROM tblTMClock WHERE intClockID = @intClockId) = 'SUMMER') THEN
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


GO
	PRINT 'END OF CREATING [uspTMUpdateEstimatedValuesBySite] SP'
GO

