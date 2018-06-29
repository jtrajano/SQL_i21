print N'BEGIN CONVERSION - i21 TANK MANAGEMENT..'
GO
print N'BEGIN Obsoleting Season Reset'
IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = N'ysnSeasonStart' AND Object_ID = Object_ID(N'tblTMDegreeDayReading'))
BEGIN
	EXEC ('
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE ysnSeasonStart = 1)
		BEGIN
			UPDATE tblTMDegreeDayReading 
			SET ysnSeasonStart = 1
			FROM (
				SELECT 
					Z.intDegreeDayReadingID
				FROM tblTMDegreeDayReading Z
				WHERE Z.dtmDate = (SELECT TOP 1 dtmDate 
								FROM tblTMDegreeDayReading
								WHERE intClockID = Z.intClockID
								ORDER BY dtmDate)
			) A
			WHERE tblTMDegreeDayReading.intDegreeDayReadingID = A.intDegreeDayReadingID
		END


		DECLARE @intSeasonResetArchiveID INT
		DECLARE @dtmFirstDate DATETIME

		SELECT 
			intSeasonResetArchiveID
		INTO #tmpSeasonResetId
		FROM tblTMSeasonResetArchive

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpSeasonResetId)
		BEGIN
			SELECT TOP 1 @intSeasonResetArchiveID = intSeasonResetArchiveID FROM #tmpSeasonResetId

			SELECT TOP 1 @dtmFirstDate = dtmDate 
			FROM tblTMDDReadingSeasonResetArchive 
			WHERE intSeasonResetArchiveID = @intSeasonResetArchiveID 
			ORDER BY dtmDate

			INSERT INTO tblTMDegreeDayReading(
				dtmDate
				,intDegreeDays
				,dblAccumulatedDegreeDay
				,intClockID
				,ysnSeasonStart
			)
			SELECT
				dtmDate = A.dtmDate
				,intDegreeDays = A.intDegreeDays
				,dblAccumulatedDegreeDay = A.dblAccumulatedDD
				,intClockID = A.intClockID
				,ysnSeasonStart = CASE WHEN A.dtmDate = @dtmFirstDate THEN 1 ELSE 0 END
			FROM tblTMDDReadingSeasonResetArchive A
			WHERE A.intSeasonResetArchiveID = @intSeasonResetArchiveID 
				AND NOT EXISTS(SELECT TOP 1 1 FROM tblTMDegreeDayReading WHERE dtmDate = A.dtmDate AND intClockID = A.intClockID)

			DELETE FROM #tmpSeasonResetId
			WHERE intSeasonResetArchiveID = @intSeasonResetArchiveID
		END

		DELETE FROM tblTMSeasonResetArchive
	')

	
END
GO
print N'END Obsoleting Season Reset'
GO

