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
	SELECT @CurrentOptionMonthsCount = COUNT(*) FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId;

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
			AND strOptionMonth NOT IN (
				SELECT strOptionMonth FROM vyuRKGetOptionTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId
			)
			AND intOptionMonthId NOT IN(
				SELECT TOP(@OptMonthsToOpen) intOptionMonthId FROM tblRKOptionsMonth
				ORDER BY CONVERT(DATETIME, REPLACE(strOptionMonth, ' ',  ' 1, '),103)  ASC
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
		, intMonthCode INT
		, strFuturesMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strOptionMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS)
		
	WHILE (SELECT COUNT(*) FROM ##FinalOptMonths) < @OptMonthsToOpen
	BEGIN
		SELECT @Top = @OptMonthsToOpen - COUNT(*) FROM ##FinalOptMonths
		
		INSERT INTO ##FinalOptMonths(intYear, strMonth, strMonthName, strMonthCode, strSymbol, intMonthCode, strFuturesMonth, intFutureMonthId, strOptionMonth)
		SELECT TOP (@Top) YEAR(@Date) + @Count
				,LTRIM(YEAR(@Date) + @Count) + ' - ' + strMonthCode
				,strMonth
				,strMonthCode
				,strSymbol
				,intMonthCode
				,CAST(DATENAME(month, CONVERT(DATETIME, CONVERT(NVARCHAR, dbo.fnRKGetClosestFutureMonth(@FutureMarketId, (YEAR(@Date) + @Count), intMonthCode)) + '-1-' + CONVERT(nvarchar, YEAR(@Date) + @Count))) AS CHAR(3)) + ' ' + RIGHT(CONVERT(nvarchar, YEAR(@Date) + @Count), 2)
				,dbo.fnRKGetFutureMonthId(@FutureMarketId, CAST(DATENAME(month, CONVERT(DATETIME, CONVERT(NVARCHAR, dbo.fnRKGetClosestFutureMonth(@FutureMarketId, (YEAR(@Date) + @Count), intMonthCode)) + '-1-' + CONVERT(nvarchar, YEAR(@Date) + @Count))) AS CHAR(3)) + ' ' + RIGHT(CONVERT(nvarchar, YEAR(@Date) + @Count), 2))
				,LTRIM(RTRIM(strMonth)) + ' ' + Right(LTRIM(YEAR(@Date) + @Count),2)
		FROM ##AllowedOptMonths
		WHERE intMonthCode > (CASE WHEN @Count = 0 THEN @CurrentMonthCode ELSE 0 END)
		ORDER BY intMonthCode
		
		SET @Count = @Count + 1
	END

	DECLARE @MissingFutureMonths VARCHAR(4000)
	SELECT @MissingFutureMonths = COALESCE(@MissingFutureMonths + ', ', '') + strFuturesMonth 
	FROM ##FinalOptMonths
	WHERE intFutureMonthId IS NULL
	GROUP BY strFuturesMonth

	DECLARE @OrphanOptionMonths VARCHAR(4000)
	SELECT @OrphanOptionMonths = COALESCE(@OrphanOptionMonths + ', ', '') + strOptionMonth 
	FROM ##FinalOptMonths
	WHERE intFutureMonthId IS NULL
	GROUP BY strOptionMonth

	IF ISNULL(@MissingFutureMonths,'') <> '' AND ISNULL(@OrphanOptionMonths,'') <> ''
	BEGIN
		DECLARE @ErrorMsg NVARCHAR(4000)
		SET @ErrorMsg = 'You need to create Futures Month: ' + @MissingFutureMonths +' to generate Option Months: ' + @OrphanOptionMonths;

		BEGIN
			RAISERROR(@ErrorMsg, 16, 1);
		END
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
		, intFutureMonthId
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
			, t.intFutureMonthId
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