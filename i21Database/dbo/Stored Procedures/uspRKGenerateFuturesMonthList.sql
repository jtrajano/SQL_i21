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
	
	SELECT @FutMonthsToOpen = @intFutureMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(GETDATE())
		, @Count = 0

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
	
	SELECT @CurrentFutureMonthsCount = COUNT(*) FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId;

	IF(ISNULL(@FutMonthsToOpen,0) < @CurrentFutureMonthsCount)
	BEGIN
		DECLARE @ValidateCurrentFutureMonth TABLE(
		  intFutureMonthId INT
		, strFutureMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS);

		INSERT INTO @ValidateCurrentFutureMonth(intFutureMonthId, strFutureMonth)
		SELECT intMonthId, strMonth FROM dbo.fnRKGetFutureOptionMonthsNotInUse(@FutureMarketId, @FutMonthsToOpen, 1)
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM @ValidateCurrentFutureMonth)
		BEGIN
			DELETE FROM tblRKOptionsMonth 
			WHERE intFutureMarketId = @FutureMarketId 
			AND intFutureMonthId IN (
				SELECT intFutureMonthId 
				FROM @ValidateCurrentFutureMonth
				WHERE intFutureMonthId NOT IN(
					SELECT intFutureMonthId FROM vyuRKGetOptionTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId
				)
			)

			DELETE FROM tblRKFuturesMonth 
			WHERE intFutureMarketId = @FutureMarketId 
			AND intFutureMonthId IN (
				SELECT intFutureMonthId 
				FROM @ValidateCurrentFutureMonth
				WHERE intFutureMonthId NOT IN(
					SELECT intFutureMonthId FROM vyuRKGetFutureTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId
				)
			)
		END
		ELSE
		BEGIN
			RAISERROR('You cannot generate Future Trading Months. Current Future Trading Months already in use.', 16, 1);
		END		
	END

	DECLARE @ValidateFutureMonth TABLE(
		  intRowId INT
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, ysnProcessed BIT DEFAULT 0);

	INSERT INTO @ValidateFutureMonth(intRowId, strMonthName)
	SELECT intRowId = ROW_NUMBER() OVER (ORDER BY AM.strMonth), AM.strMonth 
	FROM (
		SELECT DISTINCT strMonth = LEFT(strFutureMonth,3) FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId
		AND LEFT(strFutureMonth,3) NOT IN (
			SELECT strMonth = CAST(strMonth as varchar(100)) COLLATE SQL_Latin1_General_CP1_CI_AS FROM ##AllowedFutMonth
		)
	) AM
	
	DECLARE @FMRowId AS INT = 0;
	WHILE EXISTS(SELECT TOP 1 1 FROM @ValidateFutureMonth WHERE ysnProcessed = 0)
	BEGIN
		SELECT TOP 1 @FMRowId = intRowId, @Month = strMonthName FROM @ValidateFutureMonth WHERE ysnProcessed = 0;
		UPDATE @ValidateFutureMonth SET ysnProcessed = 1 WHERE intRowId = @FMRowId;

		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuRKGetOptionTradingMonthsInUse WHERE LEFT(strMonthName,3) = @Month AND intFutureMarketId = @FutureMarketId)
		BEGIN
			DELETE FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId AND LEFT(strOptionMonth,3) = @Month 
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuRKGetFutureTradingMonthsInUse WHERE LEFT(strMonthName,3) = @Month AND intFutureMarketId = @FutureMarketId)
		BEGIN
			DELETE FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId AND LEFT(strFutureMonth,3) = @Month 
		END
	END

	IF OBJECT_ID('tempdb..##FinalFutMonths') IS NOT NULL DROP TABLE ##FinalFutMonths
	
	CREATE TABLE ##FinalFutMonths(
		intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonthCode NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT
		, intSeqNo INT)
	
	DECLARE @intTempFutMonthsToOpen INT
	SET @intTempFutMonthsToOpen = @FutMonthsToOpen * 2

	WHILE (SELECT COUNT(*) FROM ##FinalFutMonths) < @intTempFutMonthsToOpen
	BEGIN
		SELECT @Top = @intTempFutMonthsToOpen - COUNT(*) FROM ##FinalFutMonths
		
		INSERT INTO ##FinalFutMonths(
			 intYear
			,strMonth
			,strMonthName
			,strMonthCode
			,strSymbol
			,intMonthCode
		)
		SELECT TOP (@Top) YEAR(@Date) + @Count, LTRIM(YEAR(@Date) + @Count) + ' - ' + strMonthCode, strMonth, strMonthCode, strSymbol, intMonthCode
		FROM ##AllowedFutMonth
		WHERE intMonthCode > (CASE WHEN @Count = 0 THEN @CurrentMonthCode ELSE 0 END)
		ORDER BY intMonthCode
		
		SET @Count = @Count + 1
	END

	DECLARE @intCountAllowedMonths INT
	DECLARE @ProjectedFutureMonths TABLE(
		  intRowId INT IDENTITY(1,1)
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, ysnProcessed BIT DEFAULT 0);
	SELECT @intCountAllowedMonths = COUNT(*) FROM ##AllowedFutMonth

	DECLARE @intIndex1 int = 0;
	DECLARE @ProjectedMonthName NVARCHAR(10)
	DECLARE @ProjectedMonth NVARCHAR(10)

	WHILE (SELECT COUNT(*) FROM @ProjectedFutureMonths) < (@FutMonthsToOpen * 2)
	BEGIN
		SET @intIndex1 = @intIndex1 + 1;

		SELECT @ProjectedMonthName= strMonth
		FROM ##AllowedFutMonth
		WHERE intRowId = @intIndex1;

		SELECT TOP(1) @ProjectedMonth = strMonth
		FROM ##FinalFutMonths
		WHERE strMonthName = @ProjectedMonthName
		AND strMonth NOT IN(SELECT strMonth FROM @ProjectedFutureMonths)

		INSERT INTO @ProjectedFutureMonths(strMonthName,strMonth)
		SELECT @ProjectedMonthName, @ProjectedMonth
		 
		IF(@intIndex1 = @intCountAllowedMonths)
		BEGIN
			SET @intIndex1 = 0;
		END
	END

	UPDATE ##FinalFutMonths
	SET intSeqNo = PM.intRowId
	FROM ##FinalFutMonths FM
	INNER JOIN @ProjectedFutureMonths PM ON FM.strMonth = PM.strMonth

	IF @FutMonthsToOpen >= (SELECT COUNT(*) FROM ##AllowedFutMonth) 
	BEGIN
		DELETE FROM ##FinalFutMonths
		WHERE strMonth NOT IN (SELECT strMonth FROM @ProjectedFutureMonths)
	END
	ELSE 
	BEGIN
		DELETE FROM ##FinalFutMonths
		WHERE strMonth NOT IN (SELECT TOP(@FutMonthsToOpen) strMonth FROM ##FinalFutMonths ORDER BY CONVERT(DATETIME, REPLACE(strMonth, ' ', '') + '-01') ASC)
	END
	
	IF @FutMonthsToOpen >= (SELECT COUNT(*) FROM ##AllowedFutMonth) 
	BEGIN
		DELETE FROM ##FinalFutMonths
		WHERE intSeqNo NOT IN (SELECT TOP(@FutMonthsToOpen) intSeqNo FROM ##FinalFutMonths ORDER BY intSeqNo ASC)
	END
	ELSE 
	BEGIN
		DELETE FROM ##FinalFutMonths
		WHERE strMonth NOT IN (SELECT TOP(@FutMonthsToOpen) strMonth FROM ##FinalFutMonths ORDER BY CONVERT(DATETIME, REPLACE(strMonth, ' ', '') + '-01') ASC)
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

	IF EXISTS(SELECT TOP 1 1 FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId AND dtmFutureMonthsDate IS NULL)
	BEGIN
		UPDATE tblRKFuturesMonth
		SET dtmFutureMonthsDate = CONVERT(DATETIME, '1' + strFutureMonth)
		WHERE intFutureMarketId = @FutureMarketId AND dtmFutureMonthsDate IS NULL
	END
	
	IF EXISTS(SELECT TOP 1 1 FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId)
	BEGIN
		DECLARE @FutMonthDate DATETIME
		DECLARE @LastFutMonth NVARCHAR(100)
		DECLARE @SpotMonthCode INT

		SELECT @SpotMonthCode = intMonthCode
		FROM ##AllowedFutMonth
		WHERE intRowId = (
			SELECT intRowId =  CASE WHEN (intRowId - 1) = 0 THEN (SELECT TOP(1) intRowId FROM ##AllowedFutMonth ORDER BY intRowId DESC)
				ELSE (intRowId - 1) END
			FROM ##AllowedFutMonth
			WHERE intMonthCode = (
				SELECT TOP(1) intMonthCode FROM #FutTemp WHERE RowNumber = 1
			)
		)

		SELECT TOP 1 @FutMonthDate = dtmFutureMonthsDate
		FROM #FutTemp
		ORDER BY dtmFutureMonthsDate DESC

		SELECT TOP 1 @LastFutMonth = CASE 
			WHEN LTRIM(strYear) = DATEPART(YY, @FutMonthDate) THEN DATEADD(YEAR, -1, CONVERT(DATETIME, strMonthName + ' 01, ' + strYear)) 
			ELSE CONVERT(DATETIME, strMonthName + ' 01, ' + strYear)
		END
		FROM #FutTemp 
		WHERE dtmFutureMonthsDate <> @FutMonthDate
		ORDER BY intMonthCode DESC, dtmFutureMonthsDate DESC

		UPDATE #FutTemp    
		SET dtmSpotDate = CASE 
			WHEN (intMonthCode - @SpotMonthCode) < 0 
				THEN CONVERT(DATETIME, CONVERT(NVARCHAR(10),(CONVERT(INT, LTRIM(RTRIM(strYear))) - 1)) + '-' + CONVERT(NVARCHAR(10),@SpotMonthCode) + '-01') 
				ELSE CONVERT(DATETIME, LTRIM(RTRIM(strYear)) + '-' + CONVERT(NVARCHAR(10),@SpotMonthCode) + '-01')
			END
		FROM #FutTemp
		WHERE RowNumber = 1

		UPDATE a SET dtmSpotDate = REPLACE(b.strMonth,' ','')+'-01' FROM #FutTemp a
		LEFT JOIN #FutTemp b ON a.RowNumber - 1 = b.RowNumber
		WHERE a.RowNumber <> 1

		UPDATE FM SET dtmSpotDate = ISNULL(FT.dtmSpotDate, GETDATE()) FROM tblRKFuturesMonth FM
		LEFT JOIN #FutTemp FT ON FM.strFutureMonth = FT.strMonthName + ' ' + RIGHT(FT.strYear, 2)
		WHERE FM.intFutureMarketId = @FutureMarketId

		DELETE FROM tblRKFuturesMonth WHERE intFutureMarketId = @FutureMarketId 
		AND strFutureMonth NOT IN(
			SELECT strMonth = strMonthName + ' ' + RIGHT(strYear, 2)
			FROM #FutTemp
			WHERE intFutureMarketId = @FutureMarketId
		) AND NOT EXISTS(
			SELECT 1 FROM vyuRKGetFutureTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId
		)
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
			DECLARE @SpotDate DATETIME
			
			SELECT TOP 1 @MonthId = intMonthCode FROM #FutTemp WHERE CONVERT(INTEGER, intMonthCode) < (SELECT intMonthCode FROM #FutTemp WHERE RowNumber =1) ORDER BY intMonthCode DESC
			SELECT top 1 @strYear = LEFT(dtmFutureMonthsDate,4) FROM #FutTemp WHERE RowNumber =2
			SELECT @SpotDate = CONVERT(DATETIME, LTRIM(RTRIM(@strYear)) + '-' + REPLACE(@MonthId,' ','') + '-01');
		
			UPDATE #FutTemp
			--SET dtmSpotDate = CONVERT(DATETIME, LTRIM(RTRIM(@strYear)) + '-' + REPLACE(@MonthId,' ','') + '-01')
			SET dtmSpotDate = CASE WHEN (DATEDIFF(month, @SpotDate, dtmFutureMonthsDate) < 0) THEN DATEADD(year, -1, @SpotDate) ELSE @SpotDate END
			FROM #FutTemp
			WHERE RowNumber = 1
		END
		ELSE
		BEGIN
			DECLARE @MonthId1 INT
			DECLARE @intYear1 INT
			DECLARE @SpotDate1 DATETIME

			SELECT TOP 1 @MonthId1 = MAX(intMonthCode) FROM #FutTemp
			SELECT TOP 1 @intYear1 = (LEFT(dtmFutureMonthsDate,4)-1) FROM #FutTemp WHERE RowNumber = 1
			SELECT @SpotDate1 = CONVERT(DATETIME, LTRIM(RTRIM(@intYear1)) + '-' + REPLACE(@MonthId1,' ','') + '-01');

			UPDATE #FutTemp
			--SET dtmSpotDate = CONVERT(DATETIME,LTRIM(RTRIM(@intYear1)) + '-' + REPLACE(@MonthId1,' ','') + '-01')
			SET dtmSpotDate = CASE WHEN (DATEDIFF(month, @SpotDate1, dtmFutureMonthsDate) < 0) THEN DATEADD(year, -1, @SpotDate1) ELSE @SpotDate1 END
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
	--ORDER BY CONVERT(DATETIME,'01 ' + strFMonth) ASC

	SELECT @HasOptionMonths = CAST(ISNULL(ysnOptions,0) AS BIT) FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId

	IF (@intOptMonthsToOpen > 0 AND @HasOptionMonths = 1)
	BEGIN
	    INSERT INTO @GenerateOptionMonthResult(
			strMissingFutureMonths
			,strOrphanOptionMonths
		)
		EXEC uspRKGenerateOptionsMonthList @FutureMarketId,@intCommodityMarketId,@intOptMonthsToOpen
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM vyuRKGetOptionTradingMonthsInUse WHERE intFutureMarketId = @FutureMarketId)
		BEGIN
			DELETE FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId
		END
	END

	DROP TABLE ##AllowedFutMonth
	DROP TABLE ##FinalFutMonths
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