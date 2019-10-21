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

	IF OBJECT_ID('tempdb..##AllowedFutMonths') IS NOT NULL DROP TABLE ##AllowedFutMonths
	
	SELECT *, intRowId = ROW_NUMBER() OVER (ORDER BY intMonthCode) 
	INTO ##AllowedFutMonths
	FROM (
		SELECT TOP 100 PERCENT REPLACE(strMonth,'ysnFut' ,'') strMonth
			, strMonthCode = (CASE WHEN strMonth = 'ysnFutJan' THEN '01'
				WHEN strMonth = 'ysnFutFeb' THEN '02'
				WHEN strMonth = 'ysnFutMar' THEN '03'
				WHEN strMonth = 'ysnFutApr' THEN '04'
				WHEN strMonth = 'ysnFutMay' THEN '05'
				WHEN strMonth = 'ysnFutJun' THEN '06'
				WHEN strMonth = 'ysnFutJul' THEN '07'
				WHEN strMonth = 'ysnFutAug' THEN '08'
				WHEN strMonth = 'ysnFutSep' THEN '09'
				WHEN strMonth = 'ysnFutOct' THEN '10'
				WHEN strMonth = 'ysnFutNov' THEN '11'
				WHEN strMonth = 'ysnFutDec' THEN '12' END) COLLATE Latin1_General_CI_AS
			, intMonthCode = (CASE WHEN strMonth = 'ysnFutJan' THEN 1
				WHEN strMonth = 'ysnFutFeb' THEN 2
				WHEN strMonth = 'ysnFutMar' THEN 3
				WHEN strMonth = 'ysnFutApr' THEN 4
				WHEN strMonth = 'ysnFutMay' THEN 5
				WHEN strMonth = 'ysnFutJun' THEN 6
				WHEN strMonth = 'ysnFutJul' THEN 7
				WHEN strMonth = 'ysnFutAug' THEN 8
				WHEN strMonth = 'ysnFutSep' THEN 9
				WHEN strMonth = 'ysnFutOct' THEN 10
				WHEN strMonth = 'ysnFutNov' THEN 11
				WHEN strMonth = 'ysnFutDec' THEN 12 END)
			, strSymbol = (CASE WHEN strMonth = 'ysnFutJan' THEN 'F'
				WHEN strMonth = 'ysnFutFeb' THEN 'G'
				WHEN strMonth = 'ysnFutMar' THEN 'H'
				WHEN strMonth = 'ysnFutApr' THEN 'J'
				WHEN strMonth = 'ysnFutMay' THEN 'K'
				WHEN strMonth = 'ysnFutJun' THEN 'M'
				WHEN strMonth = 'ysnFutJul' THEN 'N'
				WHEN strMonth = 'ysnFutAug' THEN 'Q'
				WHEN strMonth = 'ysnFutSep' THEN 'U'
				WHEN strMonth = 'ysnFutOct' THEN 'V'
				WHEN strMonth = 'ysnFutNov' THEN 'X'
				WHEN strMonth = 'ysnFutDec' THEN 'Z' END) COLLATE Latin1_General_CI_AS
		FROM (SELECT ysnFutJan
				, ysnFutFeb
				, ysnFutMar
				, ysnFutApr
				, ysnFutMay
				, ysnFutJun
				, ysnFutJul
				, ysnFutAug
				, ysnFutSep
				, ysnFutOct
				, ysnFutNov
				, ysnFutDec
			FROM tblRKFutureMarket
			WHERE intFutureMarketId = @intFutureMarketId
			) p UNPIVOT(ysnSelect
						FOR strMonth IN (ysnFutJan
										, ysnFutFeb
										, ysnFutMar
										, ysnFutApr
										, ysnFutMay
										, ysnFutJun
										, ysnFutJul
										, ysnFutAug
										, ysnFutSep
										, ysnFutOct
										, ysnFutNov
										, ysnFutDec))AS unpvt
		WHERE ysnSelect = 1
		ORDER BY intMonthCode
	) tblMonths

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

	DECLARE @intRowId AS INT
	SELECT @intRowId = intRowId FROM ##AllowedFutMonths WHERE strMonth = @strMonth

	IF(@intRowId = 1)
	BEGIN
		SELECT TOP 1 @dtmSpotDate = CONVERT(DATETIME, '1-' + strMonth + '-' + CONVERT(NVARCHAR, CONVERT(INT, YEAR(CONVERT(DATETIME,'01 ' + @strFutureMonth))) - 1))
		FROM ##AllowedFutMonths ORDER BY intMonthCode DESC
	END
	ELSE
	BEGIN
		SELECT TOP 1 @dtmSpotDate = CONVERT(DATETIME, '1-' + strMonth + '-' + CONVERT(NVARCHAR, CONVERT(INT, YEAR(CONVERT(DATETIME,'01 ' + @strFutureMonth)))))
		FROM ##AllowedFutMonths
		WHERE intRowId = (@intRowId - 1);
	END

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
		, LTRIM(RTRIM(@strFutureMonth))
		, @intFutureMarketId
		, @intCommodityMarketId
		, CONVERT(DATETIME, '1' + LTRIM(RTRIM(@strFutureMonth)))
		, @strSymbol
		, RIGHT(LTRIM(RTRIM(@strFutureMonth)), 2) COLLATE Latin1_General_CI_AS
		, NULL
		, NULL
		, NULL
		, @dtmSpotDate
		, 0)

	DROP TABLE ##AllowedFutMonths

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