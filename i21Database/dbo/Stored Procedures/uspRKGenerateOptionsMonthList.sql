CREATE PROCEDURE uspRKGenerateOptionsMonthList
	@FutureMarketId INT
	, @intCommodityMarketId INT
	, @intOptMonthsToOpen INT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY
	DECLARE @OptMonthsToOpen INT
		, @CurrentMonthCode INT
		, @Date    DATETIME
		, @Count    INT
		, @Top    INT
	
	SELECT @OptMonthsToOpen = @intOptMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(@Date)
		, @Count = 0
	
	IF OBJECT_ID('tempdb..##AllowedOptMonths') IS NOT NULL DROP TABLE ##AllowedOptMonths
	
	SELECT TOP (@OptMonthsToOpen) * 
	INTO ##AllowedOptMonths
	FROM (
		SELECT TOP 100 PERCENT strMonth = REPLACE(strMonth, 'ysnOpt' , '')
			, strMonthCode = (CASE WHEN strMonth = 'ysnOptJan' THEN '01'
				WHEN strMonth = 'ysnOptFeb' THEN '02'
				WHEN strMonth = 'ysnOptMar' THEN '03'
				WHEN strMonth = 'ysnOptApr' THEN '04'
				WHEN strMonth = 'ysnOptMay' THEN '05'
				WHEN strMonth = 'ysnOptJun' THEN '06'
				WHEN strMonth = 'ysnOptJul' THEN '07'
				WHEN strMonth = 'ysnOptAug' THEN '08'
				WHEN strMonth = 'ysnOptSep' THEN '09'
				WHEN strMonth = 'ysnOptOct' THEN '10'
				WHEN strMonth = 'ysnOptNov' THEN '11'
				WHEN strMonth = 'ysnOptDec' THEN '12' END)
			, intMonthCode = (CASE WHEN strMonth = 'ysnOptJan' THEN 1
				WHEN strMonth = 'ysnOptFeb' THEN 2
				WHEN strMonth = 'ysnOptMar' THEN 3
				WHEN strMonth = 'ysnOptApr' THEN 4
				WHEN strMonth = 'ysnOptMay' THEN 5
				WHEN strMonth = 'ysnOptJun' THEN 6
				WHEN strMonth = 'ysnOptJul' THEN 7
				WHEN strMonth = 'ysnOptAug' THEN 8
				WHEN strMonth = 'ysnOptSep' THEN 9
				WHEN strMonth = 'ysnOptOct' THEN 10
				WHEN strMonth = 'ysnOptNov' THEN 11
				WHEN strMonth = 'ysnOptDec' THEN 12 END)
			, strSymbol = (CASE WHEN strMonth = 'ysnOptJan' THEN 'F'
				WHEN strMonth = 'ysnOptFeb' THEN 'G'
				WHEN strMonth = 'ysnOptMar' THEN 'H'
				WHEN strMonth = 'ysnOptApr' THEN 'J'
				WHEN strMonth = 'ysnOptMay' THEN 'K'
				WHEN strMonth = 'ysnOptJun' THEN 'M'
				WHEN strMonth = 'ysnOptJul' THEN 'N'
				WHEN strMonth = 'ysnOptAug' THEN 'Q'
				WHEN strMonth = 'ysnOptSep' THEN 'U'
				WHEN strMonth = 'ysnOptOct' THEN 'V'
				WHEN strMonth = 'ysnOptNov' THEN 'X'
				WHEN strMonth = 'ysnOptDec' THEN 'Z' END)
		 FROM (SELECT ysnOptJan
					, ysnOptFeb
					, ysnOptMar
					, ysnOptApr
					, ysnOptMay
					, ysnOptJun
					, ysnOptJul
					, ysnOptAug
					, ysnOptSep
					, ysnOptOct
					, ysnOptNov
					, ysnOptDec
				FROM tblRKFutureMarket
				WHERE intFutureMarketId = @FutureMarketId  --and intCommodityMarketId = @intCommodityMarketId
				) p UNPIVOT(ysnSelect
							FOR strMonth IN (ysnOptJan
											, ysnOptFeb
											, ysnOptMar
											, ysnOptApr
											, ysnOptMay
											, ysnOptJun
											, ysnOptJul
											, ysnOptAug
											, ysnOptSep
											, ysnOptOct
											, ysnOptNov
											, ysnOptDec))AS unpvt
		WHERE ysnSelect = 1
		ORDER BY intMonthCode
	) tblMonths
	
	DECLARE @CurrentOptionMonthsCount INT
	SELECT @CurrentOptionMonthsCount = COUNT(*) FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId;

	IF(ISNULL(@OptMonthsToOpen,0) < @CurrentOptionMonthsCount)
	BEGIN
		DECLARE @ValidateCurrentOptionMonth TABLE(
		  intOptionMonthId INT
		, strOptionMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS);

		INSERT INTO @ValidateCurrentOptionMonth(intOptionMonthId, strOptionMonth)
		SELECT intMonthId, strMonth FROM dbo.fnRKGetFutureOptionMonthsNotInUse(@FutureMarketId, @OptMonthsToOpen, 0)
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM @ValidateCurrentOptionMonth)
		BEGIN
			DELETE FROM tblRKOptionsMonth 
			WHERE intFutureMarketId = @FutureMarketId 
			AND intFutureMonthId IN (
				SELECT intFutureMonthId 
				FROM @ValidateCurrentOptionMonth
				WHERE intFutureMonthId NOT IN(
					SELECT intFutureMonthId FROM vyuRKGetOptionTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId
				)
			)
		END
		ELSE
		BEGIN
			RAISERROR('You cannot generate Option Trading Months. Current Option Trading Months already in use.', 16, 1);
		END

	END
	
	IF OBJECT_ID('tempdb..##FinalOptMonths') IS NOT NULL DROP TABLE ##FinalOptMonths
	
	CREATE TABLE ##FinalOptMonths(
		intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT)
		
	WHILE (SELECT COUNT(*) FROM ##FinalOptMonths) < @OptMonthsToOpen
	BEGIN
		SELECT @Top = @OptMonthsToOpen - COUNT(*) FROM ##FinalOptMonths
		
		INSERT INTO ##FinalOptMonths
		SELECT TOP (@Top) YEAR(@Date) + @Count, LTRIM(YEAR(@Date) + @Count) + ' - ' + strMonthCode, strMonth, strMonthCode, strSymbol, intMonthCode
		FROM ##AllowedOptMonths
		WHERE intMonthCode > (CASE WHEN @Count = 0 THEN @CurrentMonthCode ELSE 0 END)
		ORDER BY intMonthCode
		
		SET @Count = @Count + 1
	END
	
	IF OBJECT_ID('tempdb..#OptTemp') IS NOT NULL DROP TABLE #OptTemp
	
	SELECT RowNumber = ROW_NUMBER() OVER (ORDER BY strMonth)
		, intConcurrencyId = 1,strMonth
		, dtmOptionMonthsDate = REPLACE(strMonth, ' ', '') + '-01'
		, intFutureMarketId = @FutureMarketId
		, strSymbol
		, strMonthName
		, strMonthCode
		, LEFT(strMonth, 4) AS strYear
		, dtmFirstNoticeDate = NULL
		, dtmLastNoticeDate = NULL
		, dtmLastTradingDate = NULL
		, dtmSpotDate = CONVERT(DATETIME, NULL) 
		, ysnExpired = 0
		, intMonthCode
	INTO #OptTemp
	FROM  ##FinalOptMonths
	WHERE ISNULL(strMonth,'') <> ''
	ORDER BY strMonth
	
	DECLARE @strOptSymbol NVARCHAR(5)
	SELECT @strOptSymbol = strOptSymbol FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId
	
	INSERT INTO tblRKOptionsMonth(intConcurrencyId
		, intFutureMarketId
		, intCommodityMarketId
		, strOptionMonth
		, intYear
		, intFutureMonthId
		, ysnMonthExpired
		, dtmExpirationDate
		, strOptMonthSymbol)
	SELECT * FROM (
		SELECT DISTINCT t.intConcurrencyId
			, t.intFutureMarketId
			, intCommodityMarketId = @intCommodityMarketId
			, strOMonth = LTRIM(RTRIM(t.strMonthName COLLATE Latin1_General_CI_AS)) + ' ' + Right(t.strYear,2)
			, strYear = Right(strYear,2)
			, intFutureMonthId = dbo.fnRKGetFutureMonthId(@FutureMarketId, strYear, strMonthCode)
			, ysnExpired = 0
			, dtmExpirationDate = NULL
			, strSymbol = @strOptSymbol + '' + strSymbol + '' + Right(strYear,2)
		FROM #OptTemp t)t
	WHERE t.strOMonth NOT IN (SELECT strOptionMonth COLLATE Latin1_General_CI_AS
							FROM tblRKOptionsMonth
							WHERE intCommodityMarketId =@intCommodityMarketId)
	ORDER BY CONVERT(DATETIME,'01 ' + strOMonth) ASC

	DROP TABLE ##AllowedOptMonths
	DROP TABLE ##FinalOptMonths
	DROP TABLE #OptTemp

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