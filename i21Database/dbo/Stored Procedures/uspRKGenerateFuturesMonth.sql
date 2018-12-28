CREATE PROCEDURE [dbo].[uspRKGenerateFuturesMonth]
	  @intFutureMarketId INT
	, @strFutureMonth NVARCHAR(10)
	, @intCommodityMarketId INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @IntFutureMonthId INT
DECLARE @strMonth NVARCHAR(10)
DECLARE @intYear INT
DECLARE @strSymbol NVARCHAR(10)
DECLARE @dtmSpotDate DATETIME

BEGIN TRY
	SET @strMonth = LEFT(LTRIM(RTRIM(@strFutureMonth)), 3);
	SET @intYear = CONVERT(INT, RIGHT(LTRIM(RTRIM(@strFutureMonth)), 2));

	SET @strSymbol = CASE 
			WHEN @strMonth = 'Jan' THEN 'F'
			WHEN @strMonth = 'Feb' THEN 'G'
			WHEN @strMonth = 'Mar' THEN 'H'
			WHEN @strMonth = 'Apr' THEN 'J'
			WHEN @strMonth = 'May' THEN 'K'
			WHEN @strMonth = 'Jun' THEN 'M'
			WHEN @strMonth = 'Jul' THEN 'N'
			WHEN @strMonth = 'Aug' THEN 'Q'
			WHEN @strMonth = 'Sep' THEN 'U'
			WHEN @strMonth = 'Oct' THEN 'V'
			WHEN @strMonth = 'Nov' THEN 'X'
			WHEN @strMonth = 'Dec' THEN 'Z'
		END

	SELECT TOP 1 @dtmSpotDate = CASE WHEN DATEPART(m, dtmFutureMonthsDate) = 1
			THEN CONVERT(DATETIME, CONVERT(NVARCHAR(10), DATEPART(m, dtmFutureMonthsDate)) + '-01-' + CONVERT(NVARCHAR(10), @intYear - 1)) 
		ELSE CONVERT(DATETIME, CONVERT(NVARCHAR(10), DATEPART(m, dtmFutureMonthsDate)) + '-01-' + CONVERT(NVARCHAR(10), @intYear))
	END
	FROM tblRKFuturesMonth
	WHERE intFutureMarketId = @intFutureMarketId
	AND DATEPART(m, dtmFutureMonthsDate) < DATEPART(m, CONVERT(DATE, '1' + @strFutureMonth))
	ORDER BY DATEPART(m, dtmFutureMonthsDate) DESC

	INSERT INTO tblRKFuturesMonth(intConcurrencyId
		, strFutureMonth
		, intFutureMarketId
		, intCommodityMarketId
		, dtmFutureMonthsDate
		, strSymbol
		, intYear
		, dtmFirstNoticeDate
		, dtmLastNoticeDate
		, dtmLastTradingDate
		, dtmSpotDate
		, ysnExpired)
	VALUES(1
		, @strFutureMonth
		, @intFutureMarketId
		, @intCommodityMarketId
		, CONVERT(DATETIME, '1' + LTRIM(RTRIM(@strFutureMonth)))
		, @strSymbol
		, RIGHT(LTRIM(RTRIM(@strFutureMonth)), 2)
		, NULL
		, NULL
		, NULL
		, @dtmSpotDate
		, 0)

    SET @IntFutureMonthId = SCOPE_IDENTITY();

	SELECT @IntFutureMonthId;
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH