CREATE PROCEDURE uspRKGetFuturesMonthList 
	@FutureMarketId		INT
AS
BEGIN

	DECLARE @FutMonthsToOpen	INT,
			@AllowedMonthsCount	INT,
			@CurrentMonthCode	INT,
			@SQL				NVARCHAR(MAX),
			@Date				DATETIME,
			@Count				INT,
			@RowCount			INT,
			@Top				INT 		
			
	SELECT	@FutMonthsToOpen = intFutMonthsToOpen, 
			@Date = GETDATE(),
			@CurrentMonthCode = MONTH(@Date),
			@Count = 0
	FROM	tblRKFutureMarket 
	WHERE	intFutureMarketId = @FutureMarketId
	
	IF	OBJECT_ID('tempdb..##AllowedMonths') IS NOT NULL
		DROP TABLE ##AllowedMonths
		
	SELECT	REPLACE(strMonth,'ysnFut' ,'') strMonth,
			CASE	WHEN strMonth = 'ysnFutJan' THEN '01'
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
					WHEN strMonth = 'ysnFutDec' THEN '12'
			END AS strMonthCode,
			CASE	WHEN strMonth = 'ysnFutJan' THEN 1
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
					WHEN strMonth = 'ysnFutDec' THEN 12
			END AS intMonthCode	
	INTO	##AllowedMonths		
	FROM	(	SELECT	ysnFutJan,	ysnFutFeb,	ysnFutMar,	ysnFutApr,	ysnFutMay,	ysnFutJun,
						ysnFutJul,	ysnFutAug,	ysnFutSep,	ysnFutOct,	ysnFutNov,	ysnFutDec
				FROM	tblRKFutureMarket
				WHERE	intFutureMarketId = @FutureMarketId
			) p
			UNPIVOT
			(
				ysnSelect FOR strMonth IN 
				(
					ysnFutJan,	ysnFutFeb,	ysnFutMar,	ysnFutApr,	ysnFutMay,	ysnFutJun,
					ysnFutJul,	ysnFutAug,	ysnFutSep,	ysnFutOct,	ysnFutNov,	ysnFutDec
				)
			)AS unpvt
	WHERE	ysnSelect = 1
	ORDER BY intMonthCode

	SELECT	@AllowedMonthsCount = COUNT(*) FROM ##AllowedMonths

	IF	OBJECT_ID('tempdb..##FinalMonths') IS NOT NULL
		DROP TABLE ##FinalMonths
		
	CREATE TABLE ##FinalMonths
	(
		intYear		INT,
		strMonth	NVARCHAR(10) COLLATE Latin1_General_CI_AS,
		intMonthCode	INT
	)

	WHILE (SELECT  COUNT(*) FROM ##FinalMonths) < @FutMonthsToOpen
	BEGIN
		IF @AllowedMonthsCount > @FutMonthsToOpen
			SELECT @Top = @FutMonthsToOpen
		ELSE
			SELECT @Top = @FutMonthsToOpen - COUNT(*) FROM ##FinalMonths
						
		SET @SQL = 
		'
			INSERT	INTO ##FinalMonths 
			SELECT	TOP '+LTRIM(@Top)+' YEAR(@Date)+@Count,LTRIM(YEAR(@Date)+@Count)+'' - ''+strMonthCode,intMonthCode
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
			END  AS strMonthName
		INTO #Temp	
			
	FROM
	(
		SELECT strMonth FROM ##FinalMonths 
	)t
	WHERE ISNULL(strMonth,'') <> ''
	ORDER BY strMonth	
	SELECT DISTINCT strMonthName as strFutureMonth FROM #Temp
END 


