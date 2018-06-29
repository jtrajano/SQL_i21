CREATE VIEW [dbo].[vyuTMDegreeReadingSeasonYear]
AS  
	SELECT 
		A.dblAccumulatedDegreeDay
		,A.intDegreeDays
		,A.dtmDate
		,intClockId = A.intClockID
		,intSeasonYear = (SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmDate,A.intClockID))	
		,intDegreeDayReadingId = A.intDegreeDayReadingID
		,intConcurrencyId = 0
	FROM tblTMDegreeDayReading A
GO