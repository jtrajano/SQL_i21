﻿CREATE PROCEDURE uspRKGetOptionsMonthList
	@FutureMarketId INT

AS

BEGIN
	DECLARE @FutMonthsToOpen INT
		, @AllowedMonthsCount INT
		, @CurrentMonthCode INT
		, @SQL NVARCHAR(MAX)
		, @Date DATETIME
		, @Count INT
		, @RowCount INT
		, @Top INT
		
	SELECT	@FutMonthsToOpen = intFutMonthsToOpen
		, @Date = GETDATE()
		, @CurrentMonthCode = MONTH(@Date)
		, @Count = 0
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @FutureMarketId
	
	IF OBJECT_ID('tempdb..##AllowedMonths') IS NOT NULL
	BEGIN
		DROP TABLE ##AllowedMonths
	END

	SELECT REPLACE(strMonth,'ysnOpt' ,'') COLLATE Latin1_General_CI_AS strMonth
		, CASE WHEN strMonth = 'ysnOptJan' THEN '01'
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
				WHEN strMonth = 'ysnOptDec' THEN '12' END COLLATE Latin1_General_CI_AS AS strMonthCode
		, CASE WHEN strMonth = 'ysnOptJan' THEN 1
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
				WHEN strMonth = 'ysnOptDec' THEN 12 END AS intMonthCode
		, CASE WHEN strMonth = 'ysnOptJan' THEN 'F'
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
				WHEN strMonth = 'ysnOptDec' THEN 'Z' END AS strSymbol
	INTO ##AllowedMonths
	FROM (
		SELECT ysnOptJan
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
		WHERE intFutureMarketId = @FutureMarketId
	) p
	UNPIVOT (ysnSelect FOR strMonth IN (ysnOptJan
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
										, ysnOptDec)
	) AS unpvt
	WHERE ysnSelect = 1
	ORDER BY intMonthCode
	
	SELECT	@AllowedMonthsCount = COUNT(*) FROM ##AllowedMonths
	
	IF	OBJECT_ID('tempdb..##FinalMonths') IS NOT NULL
	BEGIN
		DROP TABLE ##FinalMonths
	END
	
	CREATE TABLE ##FinalMonths (intYear INT
		, strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
		, intMonthCode INT
		, strSymbol NVARCHAR(5) COLLATE Latin1_General_CI_AS)
	
	WHILE (SELECT  COUNT(*) FROM ##FinalMonths) < @FutMonthsToOpen
	BEGIN
		IF @AllowedMonthsCount > @FutMonthsToOpen
			SELECT @Top = @FutMonthsToOpen
		ELSE
			SELECT @Top = @FutMonthsToOpen - COUNT(*) FROM ##FinalMonths
						
		SET @SQL = 
		'
			INSERT	INTO ##FinalMonths 
			SELECT	TOP '+LTRIM(@Top)+' YEAR(@Date)+@Count,LTRIM(YEAR(@Date)+@Count)+'' - ''+strMonthCode COLLATE Latin1_General_CI_AS,intMonthCode,strSymbol COLLATE Latin1_General_CI_AS
			FROM	##AllowedMonths
			WHERE	intMonthCode > CASE WHEN @Count = 0 THEN  @CurrentMonthCode ELSE 0 END
			ORDER BY intMonthCode
		'
		EXEC sp_executesql @SQL,N'@Date DATETIME,@CurrentMonthCode INT,@Count INT',@Date = @Date,@CurrentMonthCode = @CurrentMonthCode,@Count= @Count
		SET @Count = @Count +1
	END
		

	SELECT 	CASE	WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '01' THEN 'Jan' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '02' THEN 'Feb' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '03' THEN 'Mar' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '04' THEN 'Apr' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '05' THEN 'May' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '06' THEN 'Jun' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '07' THEN 'Jul' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '08' THEN 'Aug' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '09' THEN 'Sep' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '10' THEN 'Oct' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '11' THEN 'Nov' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '12' THEN 'Dec' 
			END COLLATE Latin1_General_CI_AS AS strMonthName
			,intMonthCode
			,strSymbol 
		INTO #Temp	
			
	FROM
	(
		SELECT strMonth, intMonthCode, strSymbol FROM ##FinalMonths 
	)t
	WHERE ISNULL(strMonth,'') <> ''
	ORDER BY strMonth	
	SELECT DISTINCT strMonthName, intMonthCode, strSymbol into #temp1 FROM #Temp 
	SELECT strMonthName as strOptionMonth, intMonthCode, strSymbol FROM #temp1 order by convert(datetime,'01 '+strMonthName+'15') asc
END