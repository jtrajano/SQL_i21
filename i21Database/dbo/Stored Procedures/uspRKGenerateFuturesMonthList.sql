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
		, @Month NVARCHAR(500)
		, @HasOptionMonths INT = 0
		, @CurrentFutureMonthsCount INT

	DECLARE @GenerateOptionMonthResult TABLE( strMissingFutureMonths NVARCHAR(500) COLLATE Latin1_General_CI_AS
		, strOrphanOptionMonths NVARCHAR(500) COLLATE Latin1_General_CI_AS);

	IF OBJECT_ID('tempdb..##AllowedFutMonth') IS NOT NULL DROP TABLE ##AllowedFutMonth
	
	SELECT *, intRowId = ROW_NUMBER() OVER (ORDER BY intMonthCode) 
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

	SELECT @FutMonthsToOpen = @intFutureMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(GETDATE())
		, @Count = 0

	IF OBJECT_ID('tempdb..##FinalFutMonths') IS NOT NULL DROP TABLE ##FinalFutMonths
	
	CREATE TABLE ##FinalFutMonths(
		intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT
		, intSeqNo INT
		, strFutureMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS)

	DECLARE @intCountAllowedMonths INT
	DECLARE @ProjectedFutureMonths TABLE(
		  intRowId INT IDENTITY(1,1)
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, dtmSpotDate DATE
		, ysnProcessed BIT DEFAULT 0);
	SELECT @intCountAllowedMonths = COUNT(*) FROM ##AllowedFutMonth

	DECLARE @intIndex1 int = 0;
	DECLARE @ProjectedMonthName NVARCHAR(10)
	DECLARE @ProjectedMonth NVARCHAR(10)
	DECLARE @ProjectedMonthSymbol NVARCHAR(10)
	DECLARE @tmpProjectedMonth DATE
	DECLARE @tmpSpothDate DATE

	WHILE (SELECT COUNT(*) FROM @ProjectedFutureMonths) < (@FutMonthsToOpen)
	BEGIN
		SET @intIndex1 = @intIndex1 + 1;
		SET @ProjectedMonth = NULL
		SET @tmpSpothDate = NULL

		SELECT @ProjectedMonthName= strMonth
			,@ProjectedMonthSymbol = strSymbol
		FROM ##AllowedFutMonth
		WHERE intRowId = @intIndex1;

		SELECT TOP(1) @ProjectedMonth = dbo.fnRKFormatDate(DATEADD(YEAR,1,CONVERT(DATETIME,'01 ' + strFutureMonth)), 'MMM yy')
		FROM tblRKFuturesMonth
		WHERE LEFT(LTRIM(RTRIM(strFutureMonth)),3) = @ProjectedMonthName
			AND intFutureMarketId = @FutureMarketId
		ORDER BY CONVERT(DATETIME,'01 ' + strFutureMonth) DESC

		IF(ISNULL(@ProjectedMonth, '') <> '') AND EXISTS(SELECT TOP 1 * FROM @ProjectedFutureMonths WHERE strMonth = @ProjectedMonth)
		BEGIN
			SET @ProjectedMonth = dbo.fnRKFormatDate(DATEADD(YEAR, 1,CONVERT(DATETIME,'01 ' + @ProjectedMonth)), 'MMM yy')
		END
		ELSE IF(ISNULL(@ProjectedMonth, '') = '')
		BEGIN
			SELECT @tmpProjectedMonth = CONVERT(DATE,@ProjectedMonthName + ' 1 ' + CONVERT(VARCHAR, YEAR(GETDATE())))
		
			SELECT @ProjectedMonth = CASE WHEN DATEDIFF(MONTH, GETDATE(), @tmpProjectedMonth) <= 0 THEN dbo.fnRKFormatDate(DATEADD(YEAR,1,@tmpProjectedMonth), 'MMM yy')
				ELSE dbo.fnRKFormatDate(@tmpProjectedMonth, 'MMM yy')
			END

			IF EXISTS(SELECT TOP 1 * FROM @ProjectedFutureMonths WHERE strMonth = @ProjectedMonth)
			BEGIN
				SET @ProjectedMonth = dbo.fnRKFormatDate(DATEADD(YEAR, 1, CONVERT(DATETIME,'01 ' + @ProjectedMonth)), 'MMM yy')
			END
		END

		IF(@intIndex1 = 1)
		BEGIN
			SELECT TOP 1 @tmpSpothDate = CONVERT(DATETIME, '1-' + strMonth + '-' + CONVERT(NVARCHAR, CONVERT(INT, YEAR(CONVERT(DATETIME,'01 ' + @ProjectedMonth))) - 1))
			FROM ##AllowedFutMonth ORDER BY intMonthCode DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @tmpSpothDate = CONVERT(DATETIME, '1-' + strMonth + '-' + CONVERT(NVARCHAR, CONVERT(INT, YEAR(CONVERT(DATETIME,'01 ' + @ProjectedMonth)))))
			FROM ##AllowedFutMonth
			WHERE intRowId = (@intIndex1 - 1);
		END

		INSERT INTO @ProjectedFutureMonths(strMonthName,strMonth, strSymbol, dtmSpotDate)
		SELECT @ProjectedMonthName, @ProjectedMonth, @ProjectedMonthSymbol, @tmpSpothDate
		 
		IF(@intIndex1 = @intCountAllowedMonths)
		BEGIN
			SET @intIndex1 = 0;
		END
	END

	SELECT RowNumber = ROW_NUMBER() OVER (ORDER BY strMonth)
		, intConcurrencyId = 1
		, strMonth
		, dtmFutureMonthsDate = CONVERT(DATE,'01 ' + P.strMonth)
		, intFutureMarketId = @FutureMarketId
		, strSymbol = P.strSymbol
		, strMonthName
		, strYear = YEAR(CONVERT(DATE,'01 ' + P.strMonth))
		, dtmFirstNoticeDate = NULL
		, dtmLastNoticeDate = NULL
		, dtmLastTradingDate = NULL
		, dtmSpotDate = dtmSpotDate
		, ysnExpired = 0
		, intMonthCode = P.strMonth
	INTO #FutTemp
	FROM @ProjectedFutureMonths P
	WHERE ISNULL(strMonth,'') <> ''

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
		, strFMonth = LTRIM(RTRIM(t.strMonthName COLLATE Latin1_General_CI_AS)) + ' ' + Right(t.strYear, 2) COLLATE Latin1_General_CI_AS
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

	SELECT @HasOptionMonths = CAST(ISNULL(ysnOptions,0) AS BIT) FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId

	IF (@intOptMonthsToOpen > 0 AND @HasOptionMonths = 1)
	BEGIN
		INSERT INTO @GenerateOptionMonthResult(
			strMissingFutureMonths
			,strOrphanOptionMonths
		)
		EXEC uspRKGenerateOptionsMonthList @FutureMarketId,@intCommodityMarketId,@intOptMonthsToOpen
	END

	DROP TABLE ##AllowedFutMonth
	--DROP TABLE ##FinalFutMonths
	DROP TABLE #FutTemp

	SELECT * FROM @GenerateOptionMonthResult
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