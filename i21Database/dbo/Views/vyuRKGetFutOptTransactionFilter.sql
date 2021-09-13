CREATE VIEW vyuRKGetFutOptTransactionFilter
AS

SELECT DISTINCT convert(int,row_number() OVER(ORDER BY fm.intFutureMarketId)) intRowNum, fm.intFutureMarketId,strFutMarketName,
c.intCommodityId,c.strCommodityCode,
cur.intCurrencyID,cur.strCurrency,fm.ysnOptions
    ,fm.ysnActive
	,intSelectedInstrumentTypeId = instrumentType.intSelectedInstrumentTypeId
FROM tblRKFutureMarket fm 
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblICCommodity c on c.intCommodityId=cmm.intCommodityId
JOIN tblSMCurrency cur on cur.intCurrencyID=fm.intCurrencyId
OUTER APPLY (
	SELECT intSelectedInstrumentTypeId = 1
	UNION
	SELECT intSelectedInstrumentTypeId = 3
) instrumentType

UNION ALL

SELECT intRowNum = 1 
	,intFutureMarketId = NULL
	,strFutMarketName = NULL
	,intCommodityId = intCommodityId
	,strCommodityCode = strCommodityCode
	,intCurrencyID = NULL
	,strCurrency = NULL
	,ysnOptions = 0
    ,ysnActive = 1
	,intSelectedInstrumentTypeId = 2
FROM tblICCommodity C
WHERE C.strCommodityCode = 'Currency'