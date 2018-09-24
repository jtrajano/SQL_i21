CREATE PROCEDURE uspRKGenerateFuturesMonthList
	@FutureMarketId INT
	, @intCommodityMarketId INT
	, @intFutureMonthsToOpen INT
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

	DECLARE @FutMonthsToOpen INT
		, @CurrentMonthCode INT
		, @Date DATETIME
		, @Count INT
		, @Top INT
	
	SELECT @FutMonthsToOpen = @intFutureMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(GETDATE())
		, @Count = 0

	IF OBJECT_ID('tempdb..##AllowedFutMonth') IS NOT NULL DROP TABLE ##AllowedFutMonth
	
	SELECT TOP (@FutMonthsToOpen) * 
	INTO ##AllowedFutMonth
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
				WHEN strMonth = 'ysnFutDec' THEN '12' END)
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
				WHEN strMonth = 'ysnFutDec' THEN 'Z' END)
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
			WHERE intFutureMarketId = @FutureMarketId   --and intCommodityMarketId = @intCommodityMarketId
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
	
	IF OBJECT_ID('tempdb..##FinalFutMonths') IS NOT NULL DROP TABLE ##FinalFutMonths
	
	CREATE TABLE ##FinalFutMonths(
		intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT)
		
	WHILE (SELECT COUNT(*) FROM ##FinalFutMonths) < @FutMonthsToOpen
	BEGIN
		SELECT @Top = @FutMonthsToOpen - COUNT(*) FROM ##FinalFutMonths
		
		INSERT INTO ##FinalFutMonths
		SELECT TOP (@Top) YEAR(@Date) + @Count, LTRIM(YEAR(@Date) + @Count) + ' - ' + strMonthCode, strMonth, strMonthCode, strSymbol, intMonthCode
		FROM ##AllowedFutMonth
		WHERE intMonthCode > (CASE WHEN @Count = 0 THEN @CurrentMonthCode ELSE 0 END)
		ORDER BY intMonthCode
		
		SET @Count = @Count + 1
	END
	
	SELECT RowNumber = ROW_NUMBER() OVER (ORDER BY strMonth)
		, intConcurrencyId = 1
		, strMonth
		, dtmFutureMonthsDate = REPLACE(strMonth, ' ', '') + '-01'
		, intFutureMarketId = @FutureMarketId
		, strSymbol
		, strMonthName
		, strYear = LEFT(strMonth, 4)
		, dtmFirstNoticeDate = NULL
		, dtmLastNoticeDate = NULL
		, dtmLastTradingDate = NULL
		, dtmSpotDate = CONVERT(DATETIME, NULL)
		, ysnExpired = 0
		, intMonthCode
	INTO #FutTemp
	FROM ##FinalFutMonths
	WHERE ISNULL(strMonth,'') <> ''
	ORDER BY strMonth

	DROP TABLE ##AllowedFutMonth
	DROP TABLE ##FinalFutMonths

	IF EXISTS(SELECT TOP 1 1 FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId AND dtmFutureMonthsDate IS NULL)
	BEGIN
		UPDATE tblRKFuturesMonth
		SET dtmFutureMonthsDate = CONVERT(DATETIME, '1' + strFutureMonth)
		WHERE intFutureMarketId = @FutureMarketId AND dtmFutureMonthsDate IS NULL
	END
	
	IF EXISTS(SELECT TOP 1 1 FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId)
	BEGIN
		DECLARE @FutMonthDate DATETIME
		SELECT TOP 1 @FutMonthDate = dtmFutureMonthsDate
		FROM tblRKFuturesMonth
		WHERE intFutureMarketId = @FutureMarketId
		ORDER BY dtmFutureMonthsDate DESC
		
		UPDATE #FutTemp
		SET dtmSpotDate = @FutMonthDate
		FROM #FutTemp
		WHERE RowNumber = 1
		
		UPDATE a SET dtmSpotDate = REPLACE(b.strMonth,' ','')+'-01' FROM #FutTemp a
		LEFT JOIN #FutTemp b ON a.RowNumber - 1 = b.RowNumber
		WHERE a.RowNumber <> 1
	END
	ELSE
	BEGIN
		UPDATE a
		SET dtmSpotDate = REPLACE(b.strMonth,' ','')+'-01'
		FROM #FutTemp a
		LEFT JOIN #FutTemp b
		ON a.RowNumber - 1 = b.RowNumber
		
		IF EXISTS(SELECT intMonthCode FROM #FutTemp WHERE intMonthCode < (SELECT intMonthCode FROM #FutTemp WHERE RowNumber =1))
		BEGIN 
			DECLARE @MonthId INT
			DECLARE @strYear int
			SELECT TOP 1 @MonthId = intMonthCode FROM #FutTemp WHERE CONVERT(INTEGER, intMonthCode) < (SELECT intMonthCode FROM #FutTemp WHERE RowNumber =1) ORDER BY intMonthCode DESC
			SELECT top 1 @strYear = LEFT(dtmFutureMonthsDate,4) FROM #FutTemp WHERE RowNumber =2
		
			UPDATE #FutTemp
			SET dtmSpotDate = CONVERT(DATETIME, LTRIM(RTRIM(@strYear)) + '-' + REPLACE(@MonthId,' ','') + '-01')
			FROM #FutTemp
			WHERE RowNumber = 1
		END
		ELSE
		BEGIN
			DECLARE @MonthId1 INT
			DECLARE @intYear1 INT
			SELECT TOP 1 @MonthId1 = MAX(intMonthCode) FROM #FutTemp
			SELECT TOP 1 @intYear1 = (LEFT(dtmFutureMonthsDate,4)-1) FROM #FutTemp WHERE RowNumber = 1

			UPDATE #FutTemp
			SET dtmSpotDate = CONVERT(DATETIME,LTRIM(RTRIM(@intYear1)) + '-' + REPLACE(@MonthId1,' ','') + '-01')
			FROM #FutTemp
			WHERE RowNumber = 1 
		END
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
		SELECT * FROM (            
	SELECT DISTINCT t.intConcurrencyId
		, strFMonth = LTRIM(RTRIM(t.strMonthName COLLATE Latin1_General_CI_AS)) + ' ' + Right(t.strYear, 2)
		, t.intFutureMarketId
		, intCommodityMarketId = @intCommodityMarketId
		, t.dtmFutureMonthsDate
		, t.strSymbol
		, strYear = Right(strYear,2)
		, t.dtmFirstNoticeDate
		, t.dtmLastNoticeDate
		, t.dtmLastTradingDate
		, dtmSpotDate = ISNULL(t.dtmSpotDate, '')
		, t.ysnExpired
	FROM #FutTemp t) t
	WHERE t.strFMonth NOT IN(SELECT strFutureMonth COLLATE Latin1_General_CI_AS FROM tblRKFuturesMonth WHERE intCommodityMarketId = @intCommodityMarketId)
	ORDER BY CONVERT(DATETIME,'01 ' + strFMonth) ASC

	IF (@intOptMonthsToOpen > 0)
	BEGIN
		EXEC uspRKGenerateOptionsMonthList @FutureMarketId,@intCommodityMarketId,@intOptMonthsToOpen
	END

	DROP TABLE #FutTemp
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