CREATE VIEW [dbo].[vyuTMDegreeDayReadingSearch]
AS  
	SELECT
		intClockId = A.intClockID
		,strClockNumber = B.strClockNumber
		,intSeasonYear = (SELECT TOP 1 intSeasonYear FROM dbo.fnTMGetSeasonYear(A.dtmDate, A.intClockID))
		,dtmDate = A.dtmDate
		,intDegreeDays = A.intDegreeDays
		,intAccumulatedDegreeDay = CAST(A.dblAccumulatedDegreeDay AS INT)
		,intConcurrencyId = A.intConcurrencyId
		,intDegreeDayReadingId = A.intDegreeDayReadingID
	FROM tblTMDegreeDayReading  A
	INNER JOIN tblTMClock B 
		ON A.intClockID = B.intClockID
	
GO