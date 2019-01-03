CREATE FUNCTION [dbo].[fnRKGetAssociatedFutureMonth]
(
	@FutureMarketId INT
	,@Year NVARCHAR(10)
	,@Month NVARCHAR(10)
)
RETURNS NVARCHAR(10)

AS

BEGIN
	DECLARE @FutureMonth NVARCHAR(10)
	DECLARE @TempFutureMonth NVARCHAR(10)
	DECLARE @ExpectedFutureMonth DATE

	SELECT TOP 1 @TempFutureMonth = DATEPART(mm,dtmFutureMonthsDate) FROM tblRKFuturesMonth 
		WHERE intFutureMarketId = @FutureMarketId
			AND DATEPART(mm,dtmFutureMonthsDate) > @Month
		ORDER BY DATEPART(mm,dtmFutureMonthsDate) ASC

	IF(ISNULL(@TempFutureMonth, '') <> '')
	BEGIN
		IF EXISTS(SELECT TOP 1 * FROM tblRKFuturesMonth 
			WHERE intFutureMarketId = @FutureMarketId
				AND DATEPART(mm,dtmFutureMonthsDate) = @TempFutureMonth
				AND DATEPART(YYYY,dtmFutureMonthsDate) = CONVERT(INT, @Year))
		BEGIN
			SELECT TOP 1 @FutureMonth = strFutureMonth FROM tblRKFuturesMonth 
			WHERE intFutureMarketId = @FutureMarketId
				AND DATEPART(mm,dtmFutureMonthsDate) = @TempFutureMonth
				AND DATEPART(YYYY,dtmFutureMonthsDate) = CONVERT(INT, @Year)
		END
		ELSE 
		BEGIN
		    SET @ExpectedFutureMonth = CONVERT(DATE, @TempFutureMonth + '-1-' + @Year);
			SET @FutureMonth = LEFT(CONVERT(NVARCHAR, DATENAME(month, @ExpectedFutureMonth)),3) + ' ' + RIGHT(@Year, 2);
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @TempFutureMonth = DATEPART(mm,dtmFutureMonthsDate) FROM tblRKFuturesMonth 
		WHERE intFutureMarketId = @FutureMarketId
			AND DATEPART(mm,dtmFutureMonthsDate) < @Month
		ORDER BY DATEPART(mm,dtmFutureMonthsDate) ASC

		SET @Year = CONVERT(NVARCHAR, CONVERT(INT, @Year) + 1);
		SET @ExpectedFutureMonth = CONVERT(DATE, @TempFutureMonth + '-1-' + @Year);
		SET @FutureMonth = LEFT(CONVERT(NVARCHAR, DATENAME(month, @ExpectedFutureMonth)),3) + ' ' + RIGHT(CONVERT(NVARCHAR, DATEPART(YYYY, @ExpectedFutureMonth)),2);
	END

	RETURN @FutureMonth
END