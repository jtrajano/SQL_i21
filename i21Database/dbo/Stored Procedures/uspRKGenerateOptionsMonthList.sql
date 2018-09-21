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
				WHEN strMonth = 'ysnFutDec' THEN 'Z' END)
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
	
	IF OBJECT_ID('tempdb..##FinalFutMonths') IS NOT NULL DROP TABLE ##FinalFutMonths
	
	CREATE TABLE ##FinalFutMonths(
		intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT)
		
	WHILE (SELECT COUNT(*) FROM ##FinalFutMonths) < @OptMonthsToOpen
	BEGIN
		SELECT @Top = @OptMonthsToOpen - COUNT(*) FROM ##FinalFutMonths
		
		INSERT INTO ##FinalFutMonths
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
	FROM  ##FinalFutMonths
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
	DROP TABLE ##FinalFutMonths
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