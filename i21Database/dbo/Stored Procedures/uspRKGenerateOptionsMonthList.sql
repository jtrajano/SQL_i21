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
	
	IF OBJECT_ID('tempdb..##AllowedOptMonths') IS NOT NULL DROP TABLE ##AllowedOptMonths
	
	SELECT *, intRowId = ROW_NUMBER() OVER (ORDER BY intMonthCode) 
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
				WHEN strMonth = 'ysnOptDec' THEN '12' END) COLLATE Latin1_General_CI_AS
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
				WHEN strMonth = 'ysnOptDec' THEN 'Z' END) COLLATE Latin1_General_CI_AS
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

	SELECT @OptMonthsToOpen = @intOptMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(@Date)
		, @Count = 0

	IF EXISTS(SELECT TOP 1 1 FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId)
	BEGIN
		SELECT TOP 1 @Date = CASE WHEN ISNULL(AOM.strMonth, '') <> '' 
				THEN DATEADD(MONTH,-1, CONVERT(DATETIME,'01 ' + strOptionMonth))
			END
			,@CurrentMonthCode = CASE WHEN ISNULL(AOM.strMonth, '') <> '' 
				THEN MONTH(DATEADD(MONTH,-1, CONVERT(DATETIME,'01 ' + strOptionMonth)))
			END
		FROM tblRKOptionsMonth OM
		OUTER APPLY (
			SELECT TOP 1 * FROM ##AllowedOptMonths
			ORDER BY intMonthCode ASC
		) AOM
		WHERE OM.intFutureMarketId = @FutureMarketId
		ORDER BY CONVERT(DATETIME,'01 ' + strOptionMonth) DESC
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
		, strOptionMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intSeqNo INT)
	
	DECLARE @intTempOptMonthsToOpen INT
	SET @intTempOptMonthsToOpen = @OptMonthsToOpen * 2

	DECLARE @intCountAllowedMonths INT
	DECLARE @ProjectedOptionMonths TABLE(
		  intRowId INT IDENTITY(1,1)
		, strMonthName NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strOptionMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strSymbol NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT);

	SELECT @intCountAllowedMonths = COUNT(*) FROM ##AllowedOptMonths

	DECLARE @intIndex1 int = 0;
	DECLARE @ProjectedMonthName NVARCHAR(10)
	DECLARE @ProjectedMonth NVARCHAR(10)
	DECLARE @ProjectedMonthSymbol NVARCHAR(10)
	DECLARE @ProjectedOptFutureMonth NVARCHAR(10)
	DECLARE @tmpProjectedMonth DATE

	DECLARE @strOptSymbol NVARCHAR(5)
	SELECT @strOptSymbol = strOptSymbol FROM tblRKFutureMarket WHERE intFutureMarketId = @FutureMarketId

	WHILE (SELECT COUNT(*) FROM @ProjectedOptionMonths) < @OptMonthsToOpen
	BEGIN
		SET @intIndex1 = @intIndex1 + 1;
		SET @ProjectedMonth = NULL

		SELECT @ProjectedMonthName= strMonth
			,@ProjectedMonthSymbol = strSymbol
		FROM ##AllowedOptMonths
		WHERE intRowId = @intIndex1;

		SELECT TOP(1) @ProjectedMonth = FORMAT(DATEADD(YEAR,1,CONVERT(DATETIME,'01 ' + strOptionMonth)), 'MMM yy')
		FROM tblRKOptionsMonth
		WHERE LEFT(LTRIM(RTRIM(strOptionMonth)),3) = @ProjectedMonthName
			AND intFutureMarketId = @FutureMarketId
		ORDER BY CONVERT(DATETIME,'01 ' + strOptionMonth) DESC

		IF(ISNULL(@ProjectedMonth, '') <> '') AND EXISTS(SELECT TOP 1 * FROM @ProjectedOptionMonths WHERE strOptionMonth = @ProjectedMonth)
		BEGIN
			SET @ProjectedMonth = FORMAT(DATEADD(YEAR, 1,CONVERT(DATETIME,'01 ' + @ProjectedMonth)), 'MMM yy')
		END
		ELSE IF(ISNULL(@ProjectedMonth, '') = '')
		BEGIN
			SELECT @tmpProjectedMonth = CONVERT(DATE,@ProjectedMonthName + ' 1 ' + CONVERT(VARCHAR, YEAR(GETDATE())))
		
			SELECT @ProjectedMonth = CASE WHEN DATEDIFF(MONTH, GETDATE(), @tmpProjectedMonth) <= 0 THEN FORMAT(DATEADD(YEAR,1,@tmpProjectedMonth), 'MMM yy')
				ELSE FORMAT(@tmpProjectedMonth, 'MMM yy')
			END

			IF EXISTS(SELECT TOP 1 * FROM @ProjectedOptionMonths WHERE strOptionMonth = @ProjectedMonth)
			BEGIN
				SET @ProjectedMonth = FORMAT(DATEADD(YEAR, 1, CONVERT(DATETIME,'01 ' + @ProjectedMonth)), 'MMM yy')
			END
		END

		SET @ProjectedOptFutureMonth = dbo.fnRKGetAssociatedFutureMonth(@FutureMarketId, YEAR(CONVERT(DATETIME,'01 ' + @ProjectedMonth)), MONTH(CONVERT(DATETIME,'01 ' + @ProjectedMonth)))

		INSERT INTO @ProjectedOptionMonths(strMonthName,strOptionMonth, strSymbol, strFutureMonth, intFutureMonthId)
		SELECT @ProjectedMonthName
			, @ProjectedMonth
			,(@strOptSymbol + @ProjectedMonthSymbol + RIGHT(CONVERT(NVARCHAR, YEAR(CONVERT(DATETIME,'01 ' + @ProjectedMonth))),2))
			, @ProjectedOptFutureMonth
			,dbo.fnRKGetFutureMonthId(@FutureMarketId, @ProjectedOptFutureMonth)

		IF(@intIndex1 = @intCountAllowedMonths)
		BEGIN
			SET @intIndex1 = 0;
		END
	END

	DECLARE @MissingFutureMonths VARCHAR(4000)
	SELECT @MissingFutureMonths = COALESCE(@MissingFutureMonths + ', ', '') + strFutureMonth 
	FROM @ProjectedOptionMonths
	WHERE intFutureMonthId IS NULL
	GROUP BY strFutureMonth

	DECLARE @OrphanOptionMonths VARCHAR(4000)
	SELECT @OrphanOptionMonths = COALESCE(@OrphanOptionMonths + ', ', '') + strOptionMonth 
	FROM @ProjectedOptionMonths
	WHERE intFutureMonthId IS NULL
	GROUP BY strOptionMonth

	IF OBJECT_ID('tempdb..#OptTemp') IS NOT NULL DROP TABLE #OptTemp
	
	INSERT INTO tblRKOptionsMonth(intConcurrencyId
		, intFutureMarketId
		, intCommodityMarketId
		, strOptionMonth
		, intYear
		, intFutureMonthId
		, ysnMonthExpired
		, dtmExpirationDate
		, strOptMonthSymbol)
	SELECT 1
		, @FutureMarketId
		, @intCommodityMarketId
		,strOptionMonth
		,RIGHT(CONVERT(NVARCHAR, YEAR(CONVERT(DATETIME,'01 ' + strOptionMonth))), 2) COLLATE Latin1_General_CI_AS
		,intFutureMonthId
		,0
		,NULL
		,strSymbol
	FROM @ProjectedOptionMonths
	WHERE ISNULL(intFutureMonthId, '') <> '' 

	SELECT MissingFutureMonths = @MissingFutureMonths
		,OrphanOptionMonths = @OrphanOptionMonths;

	DROP TABLE ##AllowedOptMonths
	DROP TABLE ##FinalOptMonths
	--DROP TABLE #OptTemp

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