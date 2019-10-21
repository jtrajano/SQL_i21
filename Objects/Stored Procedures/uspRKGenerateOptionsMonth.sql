CREATE PROCEDURE [dbo].[uspRKGenerateOptionsMonth]
	  @intFutureMarketId INT
	, @strOptionMonth NVARCHAR(10)
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
DECLARE @IntOptionMonthId INT
DECLARE @IntFutureMonthId INT
DECLARE @strMonth NVARCHAR(10)
DECLARE @intYear INT
DECLARE @strOptSymbol NVARCHAR(10)
DECLARE @strSymbol NVARCHAR(10)
DECLARE @dtmSpotDate DATETIME
DECLARE @strFutureMonth NVARCHAR(10)

BEGIN TRY
	SET @strMonth = LEFT(LTRIM(RTRIM(@strOptionMonth)), 3);
	SET @intYear = CONVERT(INT, RIGHT(LTRIM(RTRIM(@strOptionMonth)), 2));
	SET @IntOptionMonthId = 0;

	SELECT @strOptSymbol = strOptSymbol FROM tblRKFutureMarket WHERE intFutureMarketId = @intFutureMarketId
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
	
	SELECT @strFutureMonth = dbo.fnRKGetAssociatedFutureMonth(@intFutureMarketId, YEAR(CONVERT(DATETIME, '1' + LTRIM(RTRIM(@strOptionMonth)))), MONTH(CONVERT(DATETIME, '1' + LTRIM(RTRIM(@strOptionMonth)))))
	SELECT @IntFutureMonthId = dbo.fnRKGetFutureMonthId(@intFutureMarketId, @strFutureMonth)

	IF ISNULL(@IntFutureMonthId, 0) <> 0 
	BEGIN
		INSERT INTO tblRKOptionsMonth(intConcurrencyId
			, intFutureMarketId
			, intCommodityMarketId
			, strOptionMonth
			, intYear
			, intFutureMonthId
			, ysnMonthExpired
			, dtmExpirationDate
			, strOptMonthSymbol)
		VALUES(1
			,@intFutureMarketId
			,@intCommodityMarketId
			,@strOptionMonth
			,RIGHT(LTRIM(RTRIM(@strOptionMonth)), 2)
			,ISNULL(@IntFutureMonthId, 0)
			,0
			,NULL
			,@strOptSymbol + '' + @strSymbol + '' + Right(@intYear,2)
		)

		SET @IntOptionMonthId = SCOPE_IDENTITY();
	END
	
	SELECT @IntOptionMonthId;
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
