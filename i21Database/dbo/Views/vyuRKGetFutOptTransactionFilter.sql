CREATE VIEW vyuRKGetFutOptTransactionFilter
AS
SELECT DISTINCT convert(int,row_number() OVER(ORDER BY fm.intFutureMarketId)) intRowNum, fm.intFutureMarketId,strFutMarketName,
c.intCommodityId,c.strCommodityCode,
cur.intCurrencyID,cur.strCurrency
FROM tblRKFutureMarket fm 
JOIN tblRKCommodityMarketMapping cmm on fm.intFutureMarketId=cmm.intFutureMarketId
JOIN tblICCommodity c on c.intCommodityId=cmm.intCommodityId
JOIN tblSMCurrency cur on cur.intCurrencyID=fm.intCurrencyId