CREATE FUNCTION fnGetBusinessDate (
	@dtmTransactionDateTime DATETIME
	,@intLocationId NUMERIC(18, 0)
	)
RETURNS DATETIME
AS
BEGIN
	DECLARE @dtmBizDate DATETIME
	DECLARE @dtmBizDateFlag DATETIME
	DECLARE @dtmShiftStartTime DATETIME
	DECLARE @dtmShiftEndTime DATETIME
	DECLARE @intStartOffset INT
	DECLARE @intEndOffset INT
	DECLARE @intShiftSequence INT

	SET @dtmBizDateFlag = Convert(NVARCHAR, Convert(DATETIME, @dtmTransactionDateTime, 101), 101)

	SELECT @intShiftSequence = Min(intShiftSequence)
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId

	SELECT @dtmShiftStartTime = dtmShiftStartTime
		,@intStartOffset = intStartOffset
	FROM dbo.tblMFShift
	WHERE intShiftSequence = @intShiftSequence
		AND intLocationId = @intLocationId

	SELECT @intShiftSequence = Max(intShiftSequence)
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId

	SELECT @dtmShiftEndTime = dtmShiftEndTime
		,@intEndOffset = intEndOffset
	FROM tblMFShift
	WHERE intShiftSequence = @intShiftSequence
		AND intLocationId = @intLocationId

	SET @dtmShiftStartTime = DateAdd(dd, @intStartOffset, CONVERT(DATETIME, CONVERT(NVARCHAR, SubString(Convert(NVARCHAR, @dtmShiftStartTime), 12, 20), 101)) + @dtmBizDateFlag)
	SET @dtmShiftEndTime = DateAdd(ss, - 1, DateAdd(dd, @intEndOffset, CONVERT(DATETIME, CONVERT(NVARCHAR, SubString(Convert(NVARCHAR, @dtmShiftEndTime), 12, 20), 101)) + @dtmBizDateFlag))

	SELECT @dtmBizDate = CASE 
			WHEN @dtmTransactionDateTime < @dtmShiftStartTime
				THEN DateAdd(dd, - 1, @dtmBizDateFlag)
			WHEN @dtmTransactionDateTime > @dtmShiftEndTime
				THEN DateAdd(dd, 1, @dtmBizDateFlag)
			ELSE @dtmBizDateFlag
			END

	RETURN Convert(VARCHAR(30), @dtmBizDate, 101)
END
