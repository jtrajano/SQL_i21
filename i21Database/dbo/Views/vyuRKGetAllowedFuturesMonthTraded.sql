CREATE VIEW vyuRKGetAllowedFuturesMonthTraded
AS
SELECT	CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutureMarketId)) AS intRow, REPLACE(strMonth,'ysnFut' ,'') COLLATE Latin1_General_CI_AS AS strFutureMonth, intFutureMarketId	
FROM	(	SELECT	ysnFutJan,	ysnFutFeb,	ysnFutMar,	ysnFutApr,	ysnFutMay,	ysnFutJun,
					ysnFutJul,	ysnFutAug,	ysnFutSep,	ysnFutOct,	ysnFutNov,	ysnFutDec, intFutureMarketId
			FROM	tblRKFutureMarket
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

	
	
