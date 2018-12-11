CREATE VIEW vyuRKGetAllowedFuturesMonthTraded
AS
SELECT intFutureMarketId ,REPLACE(strMonth,'ysnFut' ,'') COLLATE Latin1_General_CI_AS AS strFutureMonth
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
		, intFutureMarketId
	FROM tblRKFutureMarket
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