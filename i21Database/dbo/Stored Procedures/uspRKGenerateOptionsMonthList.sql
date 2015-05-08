﻿CREATE PROCEDURE uspRKGenerateOptionsMonthList 
 
	@FutureMarketId		INT  ,
	@intOptMonthsToOpen INT
AS
BEGIN

	DECLARE @OptMonthsToOpen	INT,
			@AllowedMonthsCount	INT,
			@CurrentMonthCode	INT,
			@SQL				NVARCHAR(MAX),
			@Date				DATETIME,
			@Count				INT,
			@RowCount			INT,
			@Top				INT 		

IF 	EXISTS(SELECT * FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId)	
BEGIN		

	SELECT top 1 @OptMonthsToOpen = @intOptMonthsToOpen, 
			@Date = GETDATE(),
			@CurrentMonthCode = MONTH(@Date),
			@Count = 0
	FROM	tblRKOptionsMonth
	WHERE	intFutureMarketId = @FutureMarketId --order by dtmFutureMonthsDate desc
	
END
ELSE
BEGIN
SELECT	@OptMonthsToOpen = @intOptMonthsToOpen, 
			@Date = GETDATE(),
			@CurrentMonthCode = MONTH(@Date),
			@Count = 0
	FROM	tblRKFutureMarket 
	WHERE	intFutureMarketId = @FutureMarketId
END	

IF	OBJECT_ID('tempdb..##AllowedMonths') IS NOT NULL
		DROP TABLE ##AllowedMonths
		
	SELECT	REPLACE(strMonth,'ysnOpt' ,'') strMonth,
			CASE	WHEN strMonth = 'ysnOptJan' THEN '01'
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
					WHEN strMonth = 'ysnOptDec' THEN '12'
			END AS strMonthCode,
			CASE	WHEN strMonth = 'ysnOptJan' THEN 1
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
					WHEN strMonth = 'ysnOptDec' THEN 12
			END AS intMonthCode	
	INTO	##AllowedMonths		
	FROM	(	SELECT	ysnOptJan,	ysnOptFeb,	ysnOptMar,	ysnOptApr,	ysnOptMay,	ysnOptJun,
						ysnOptJul,	ysnOptAug,	ysnOptSep,	ysnOptOct,	ysnOptNov,	ysnOptDec
				FROM	tblRKFutureMarket
				WHERE	intFutureMarketId = @FutureMarketId
			) p
			UNPIVOT
			(
				ysnSelect FOR strMonth IN 
				(
					ysnOptJan,	ysnOptFeb,	ysnOptMar,	ysnOptApr,	ysnOptMay,	ysnOptJun,
					ysnOptJul,	ysnOptAug,	ysnOptSep,	ysnOptOct,	ysnOptNov,	ysnOptDec
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

	WHILE (SELECT  COUNT(*) FROM ##FinalMonths) < @OptMonthsToOpen
	BEGIN
		SELECT @Top = @OptMonthsToOpen - COUNT(*) FROM ##FinalMonths

		SET @SQL = 
		'
			INSERT	INTO ##FinalMonths 
			SELECT	TOP '+LTRIM(@Top)+' YEAR(@Date)+@Count,LTRIM(YEAR(@Date)+@Count)+'' - ''+strMonthCode,intMonthCode
			FROM	##AllowedMonths
			WHERE	intMonthCode > CASE WHEN @Count = 0 THEN  @CurrentMonthCode ELSE 0 END
			ORDER BY intMonthCode
		'
	
		EXEC sp_executesql @SQL,N'@Date DATETIME,@CurrentMonthCode INT,@Count INT',@Date = @Date,@CurrentMonthCode = @CurrentMonthCode,@Count= @Count
		SET @Count = @Count + 1

	END

	SELECT ROW_NUMBER() over (order by strMonth) as RowNumber,1 as intConcurrencyId,strMonth,replace(strMonth,' ','')+'-01' as dtmOptionMonthsDate,@FutureMarketId as intFutureMarketId,
			CASE	WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '01' THEN 'F' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '02' THEN 'G' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '03' THEN 'H' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '04' THEN 'J' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '05' THEN 'K' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '06' THEN 'M' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '07' THEN 'N' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '08' THEN 'Q' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '09' THEN 'U' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '10' THEN 'V' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '11' THEN 'X' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '12' THEN 'Z' 
			END  +	SUBSTRING(strMonth,3,0) AS strSymbol,
			   CASE WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '01' THEN 'Jan' 
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
			END  AS strMonthName,LEFT(strMonth,4) AS StrYear,null dtmFirstNoticeDate,null dtmLastNoticeDate,
			NULL dtmLastTradingDate, convert(DATETIME,null) dtmSpotDate,0 as ysnExpired,
			CASE	WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '01' THEN '1' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '02' THEN '2' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '03' THEN '3' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '04' THEN '4' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '05' THEN '5' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '06' THEN '6' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '07' THEN '7' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '08' THEN '8' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '09' THEN '9' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '10' THEN '10' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '11' THEN '11' 
					WHEN SUBSTRING(strMonth,LEN(strMonth)-1,LEN(strMonth)-1) = '12' THEN '12'  End
		AS strMonthId
		INTO #Temp				
	FROM
	(
		SELECT strMonth FROM ##FinalMonths 

	)t
	WHERE ISNULL(strMonth,'') <> ''
	ORDER BY strMonth
	--IF 	EXISTS(SELECT * FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId and dtmFutureMonthsDate is null)	
	--BEGIN	
	----UPDATE tblRKOptionsMonth SET dtmFutureMonthsDate = Convert(datetime,'1' + strFutureMonth )  where intFutureMarketId=@FutureMarketId and dtmFutureMonthsDate is null
	--END
	--IF EXISTS(SELECT * FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId)
	--BEGIN
	--	DECLARE @FutMonthDate datetime
	--	SELECT TOP 1 @FutMonthDate=dtmFutureMonthsDate FROM tblRKOptionsMonth WHERE intFutureMarketId = @FutureMarketId order by dtmFutureMonthsDate desc 
	--	UPDATE #Temp set dtmSpotDate=@FutMonthDate FROM #Temp WHERE RowNumber=1
	--	UPDATE a SET dtmSpotDate=replace(b.strMonth,' ','')+'-01' FROM #Temp a
	--	LEFT JOIN #Temp b on a.RowNumber - 1 = b.RowNumber WHERE a.RowNumber<>1
				
	--END
	--ELSE
	--BEGIN
	--	UPDATE a SET dtmSpotDate=REPLACE(b.strMonth,' ','')+'-01' FROM #Temp a
	--	LEFT JOIN #Temp b on a.RowNumber - 1 = b.RowNumber 
	--	IF EXISTS(SELECT strMonthId FROM #Temp WHERE convert(integer,strMonthId) < (select convert(integer,strMonthId) FROM #Temp WHERE RowNumber =1) )
	--	BEGIN
	--		DECLARE @MonthId int			
	--		DECLARE @strYear int				
	-- 		SELECT TOP 1 @MonthId=strMonthId FROM #Temp WHERE convert(integer,strMonthId)  < (SELECT convert(integer,strMonthId) strMonthId FROM #Temp WHERE RowNumber =1) order by convert(integer,strMonthId) desc
	--		SELECT top 1 @strYear=LEFT(dtmFutureMonthsDate,4) FROM #Temp WHERE RowNumber =2
	--		UPDATE #Temp set dtmSpotDate=convert(datetime,Ltrim(Rtrim(@strYear))+'-'+REPLACE(@MonthId,' ','')+'-01') FROM #Temp WHERE RowNumber = 1
	--	END
	--	ELSE
	--	BEGIN		
	--		DECLARE @MonthId1 int			
	--		DECLARE @intYear1 int
	--		SELECT top 1 @MonthId1=max(convert(integer,strMonthId)) FROM #Temp 
	--		SELECT top 1 @intYear1=(LEFT(dtmFutureMonthsDate,4)-1) FROM #Temp WHERE RowNumber =1
	--		UPDATE #Temp set dtmSpotDate=convert(datetime,Ltrim(Rtrim(@intYear1))+'-'+REPLACE(@MonthId1,' ','')+'-01') FROM #Temp WHERE RowNumber = 1		
	--	END
		
	--END

	INSERT INTO tblRKOptionsMonth(
								intConcurrencyId,
								intFutureMarketId,
								strOptionMonth,
								intYear,
								intFutureMonthId,
								ysnMonthExpired,
								dtmExpirationDate)	

SELECT * FROM (								
SELECT distinct t.intConcurrencyId,
		t.intFutureMarketId,
		ltrim(rtrim(t.strMonthName collate Latin1_General_CI_AS))+' ' + Right(t.StrYear,2) as  strOMonth,
		Right(StrYear,2) strYear,	
	    1 as intFutureMonthId,	
	    0 as ysnExpired, 
	    NULL as dtmExpirationDate
		
FROM #Temp t)t 
WHERE t.strOMonth not in(SELECT strOptionMonth collate Latin1_General_CI_AS from tblRKOptionsMonth where intFutureMarketId=@FutureMarketId)

END 


