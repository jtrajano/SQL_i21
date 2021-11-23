CREATE PROCEDURE [dbo].[uspApiSchemaTMClockReading]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	-- VALIDATE Clock Number
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Clock Number'
		, strValue = CR.strClockNumber
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CR.intRowNumber
		, strMessage = 'Cannot find the Clock Number ''' + CR.strClockNumber + ''' in i21 Clocks'
	FROM tblApiSchemaTMClockReading CR
	LEFT JOIN tblTMClock C ON C.strClockNumber = CR.strClockNumber
	WHERE C.intClockID IS NULL 
	AND CR.guiApiUniqueId = @guiApiUniqueId

	DECLARE @intClockId INT = NULL
		, @dtmReadingDate DATETIME = NULL
		, @intDegreeDay INT = NULL
		, @intAccumulatedDegreeDay INT = NULL
		, @intRowNumber INT = NULL

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR
	SELECT C.intClockID
		, CR.dtmReadingDate AS dtmReadingDate
		, CR.intDegreeDay AS intDegreeDay
		, CR.intAccumulatedDegreeDay AS intAccumulatedDegreeDay
		, CR.intRowNumber
	FROM tblApiSchemaTMClockReading CR
	INNER JOIN tblTMClock C ON C.strClockNumber = CR.strClockNumber
	WHERE CR.guiApiUniqueId = @guiApiUniqueId

	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intClockId, @dtmReadingDate, @intDegreeDay, @intAccumulatedDegreeDay, @intRowNumber
	WHILE @@FETCH_STATUS = 0
    BEGIN

		DECLARE @intDegreeDayReadingId INT = NULL

		SELECT @intDegreeDayReadingId = intDegreeDayReadingID FROM tblTMDegreeDayReading WHERE intClockID = @intClockId AND dtmDate = @dtmReadingDate

		IF(@intDegreeDayReadingId IS NOT NULL)
		BEGIN
			INSERT INTO tblTMDegreeDayReading (intClockID, dtmDate, intDegreeDays, dblAccumulatedDegreeDay, guiApiUniqueId, intRowNumber)
			VALUES (@intClockId, @dtmReadingDate, @intDegreeDay, @intAccumulatedDegreeDay, @guiLogId, @intRowNumber)

			INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage
			)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel = 'Success'
				, strStatus = 'Success'
				, intRowNo = @intRowNumber
				, strMessage = 'Successfully added'	

		END
		ELSE BEGIN
			UPDATE tblTMDegreeDayReading SET intDegreeDays = @intDegreeDay
				, dblAccumulatedDegreeDay = @intAccumulatedDegreeDay
				, guiApiUniqueId = @guiLogId
				, intRowNumber = @intRowNumber 
			WHERE intDegreeDayReadingID = @intDegreeDayReadingId

			INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage
			)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel = 'Success'
				, strStatus = 'Success'
				, intRowNo = @intRowNumber
				, strMessage = 'Successfully updated'
		END
		
		FETCH NEXT FROM DataCursor INTO @intClockId, @dtmReadingDate, @intDegreeDay, @intAccumulatedDegreeDay, @intRowNumber
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor



END
