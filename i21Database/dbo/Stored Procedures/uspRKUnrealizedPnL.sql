CREATE PROC [dbo].[uspRKUnrealizedPnL]    
  @dtmFromDate DATETIME  
 ,@dtmToDate DATETIME  
 ,@intCommodityId INT = NULL  
 ,@ysnExpired BIT  
 ,@intFutureMarketId INT = NULL  
 ,@intEntityId int = null    
 ,@intBrokerageAccountId INT = NULL  
 ,@intFutureMonthId INT = NULL  
 ,@strBuySell nvarchar(10)=NULL  
 ,@intBookId int=NULL  
 ,@intSubBookId int=NULL  
AS    
--declare @dtmFromDate DATETIME = getdate()-1000  
-- ,@dtmToDate DATETIME= getdate()  
-- ,@intCommodityId INT = NULL  
-- ,@ysnExpired BIT = 'true'  
-- ,@intFutureMarketId INT = NULL  
-- ,@intEntityId int = null    
-- ,@intBrokerageAccountId INT = NULL  
-- ,@intFutureMonthId INT = NULL  
-- ,@strBuySell nvarchar(10)=NULL  
-- ,@intBookId int=NULL  
-- ,@intSubBookId int=NULL  
-- drop table #temp  
  
SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)  
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), isnull(@dtmToDate, getdate()), 110), 110)  
  
SELECT CONVERT(INT, DENSE_RANK() OVER (  
   ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth)  
   )) RowNum  
 ,strFutMarketName + ' - ' + strFutureMonth + ' - ' + strName strMonthOrder  
 ,intFutOptTransactionId  
 ,GrossPnL dblGrossPnL  
 ,dblLong  
 ,dblShort  
 ,- abs(dblFutCommission) dblFutCommission  
 ,strFutMarketName  
 ,strFutureMonth  
 ,dtmTradeDate  
 ,strInternalTradeNo  
 ,strName  
 ,strAccountNumber  
 ,strBook  
 ,strSubBook  
 ,strSalespersonId  
 ,strCommodityCode  
 ,strLocationName  
 ,Long1 dblLong1  
 ,Sell1 dblSell1  
 ,intNet dblNet  
 ,dblActual  
 ,dblClosing  
 ,dblPrice  
 ,dblContractSize  
 ,- abs(dblFutCommission1) dblFutCommission1  
 ,MatchLong dblMatchLong  
 ,MatchShort dblMatchShort  
 ,NetPnL dblNetPnL  
 ,intFutureMarketId  
 ,intFutureMonthId  
 ,intOriginalQty dblOriginalQty  
 ,intFutOptTransactionHeaderId  
 ,intCommodityId  
 ,ysnExpired  
 --,dblVariationMargin  
 ,0.0 dblInitialMargin  
 ,LongWaitedPrice / case when isnull(dblLongTotalLotByMonth,0)=0 then 1 else dblLongTotalLotByMonth end LongWaitedPrice  
 ,ShortWaitedPrice / case when isnull(dblShortTotalLotByMonth,0)=0 then 1 else dblShortTotalLotByMonth end ShortWaitedPrice into #temp  
FROM (  
 SELECT *  
  ,(GrossPnL1 * (dblClosing - dblPrice) - dblFutCommission2) NetPnL  
  --,intNet * dblVariationMargin1 dblVariationMargin  
  ,GrossPnL1 * (dblClosing - dblPrice) GrossPnL  
  ,- dblFutCommission2 dblFutCommission  
  ,sum(dblShort) OVER (PARTITION BY intFutureMonthId,strName) dblShortTotalLotByMonth  
  ,sum(dblLong) OVER (PARTITION BY intFutureMonthId,strName) dblLongTotalLotByMonth  
  ,(dblLong*dblPrice) LongWaitedPrice,(dblShort*dblPrice) ShortWaitedPrice  
 FROM (  
  SELECT (convert(INT, isnull((Long1 - MatchLong), 0) - isnull(Sell1 - MatchShort, 0))) * dblContractSize / CASE   
    WHEN ysnSubCurrency = 1  
     THEN intCent  
    ELSE 1  
    END GrossPnL1     
   ,isnull((Long1 - MatchLong), 0) AS dblLong  
   ,isnull(Sell1 - MatchShort, 0) AS dblShort  
   ,convert(INT, isnull((Long1 - MatchLong), 0) - isnull(Sell1 - MatchShort, 0)) * - dblFutCommission1 / CASE   
    WHEN ComSubCurrency = 1  
     THEN ComCent  
    ELSE 1  
    END AS dblFutCommission2  
   ,convert(INT, isnull((Long1 - MatchLong), 0) - isnull(Sell1 - MatchShort, 0)) AS intNet  
   ,ISNULL(dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate), 0) AS dblClosing  
   ,*  
  FROM (  
   SELECT intFutOptTransactionId  
    ,fm.strFutMarketName  
    ,om.strFutureMonth  
    ,ot.intFutureMonthId  
    ,ot.intCommodityId  
    ,ot.intFutureMarketId  
    ,convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110) AS dtmTradeDate  
    ,ot.strInternalTradeNo  
    ,e.strName  
    ,acc.strAccountNumber  
    ,cb.strBook  
    ,csb.strSubBook  
    ,sp.strSalespersonId  
    ,icc.strCommodityCode  
    ,sl.strLocationName  
    ,ot.intNoOfContract AS intOriginalQty  
    ,isnull(CASE   
      WHEN ot.strBuySell = 'Buy'  
       THEN isnull(ot.intNoOfContract, 0)  
      ELSE NULL  
      END, 0) Long1  
    ,isnull(CASE   
      WHEN ot.strBuySell = 'Sell'  
       THEN isnull(ot.intNoOfContract, 0)  
      ELSE NULL  
      END, 0) Sell1  
    ,ot.intNoOfContract AS intNet1  
    ,ot.dblPrice AS dblActual  
    ,isnull(ot.dblPrice, 0) dblPrice  
    ,fm.dblContractSize dblContractSize  
    ,0 AS intConcurrencyId  
    ,  
    --CASE WHEN bc.intFuturesRateType= 1 then 0 else  isnull(bc.dblFutCommission,0) end as dblFutCommission1,    
    --This filter is to get the correct commission based on date        
    dblFutCommission1 = ISNULL((  
      SELECT TOP 1 (  
        CASE   
         WHEN bc.intFuturesRateType = 1  
          THEN 0  
         ELSE isnull(bc.dblFutCommission, 0) / CASE   
           WHEN cur.ysnSubCurrency = 1  
            THEN cur.intCent  
           ELSE 1  
           END  
         END  
        )  
      FROM tblRKBrokerageCommission bc  
      LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId  
      WHERE bc.intFutureMarketId = ot.intFutureMarketId  
       AND bc.intBrokerageAccountId = ot.intBrokerageAccountId  
       AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND isnull(bc.dtmEndDate,getdate())  
      ), 0)  
    ,ISNULL((  
      SELECT SUM(dblMatchQty)  
      FROM tblRKMatchFuturesPSDetail psd  
      JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId  
      WHERE psd.intLFutOptTransactionId = ot.intFutOptTransactionId  
       AND h.strType = 'Realize'  
       AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate  
      ), 0) AS MatchLong  
    ,ISNULL((  
      SELECT sum(dblMatchQty)  
      FROM tblRKMatchFuturesPSDetail psd  
      JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId  
      WHERE psd.intSFutOptTransactionId = ot.intFutOptTransactionId  
       AND h.strType = 'Realize'  
       AND convert(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate  
      ), 0) AS MatchShort  
    ,c.intCurrencyID AS intCurrencyId  
    ,c.intCent  
    ,c.ysnSubCurrency  
    ,intFutOptTransactionHeaderId  
    ,ysnExpired  
    ,c.intCent ComCent  
    ,c.ysnSubCurrency ComSubCurrency  
    --,IsNull(dbo.fnRKGetVariationMargin(ot.intFutOptTransactionId, @dtmToDate, ot.dtmFilledDate), 0.0) * fm.dblContractSize dblVariationMargin1  
   FROM tblRKFutOptTransaction ot  
   JOIN tblRKFuturesMonth om ON om.intFutureMonthId = ot.intFutureMonthId AND ot.strStatus = 'Filled' AND ot.intInstrumentTypeId = 1     
              AND convert(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate  
   JOIN tblRKBrokerageAccount acc ON acc.intBrokerageAccountId = ot.intBrokerageAccountId  
   JOIN tblICCommodity icc ON icc.intCommodityId = ot.intCommodityId  
   JOIN tblSMCompanyLocation sl ON sl.intCompanyLocationId = ot.intLocationId  
   JOIN tblARSalesperson sp ON sp.intEntityId = ot.intTraderId  
   JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId  
   JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId  
   JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId  
   LEFT JOIN tblCTBook cb ON cb.intBookId = ot.intBookId  
   LEFT JOIN tblCTSubBook csb ON csb.intSubBookId = ot.intSubBookId  
   WHERE isnull(ot.intCommodityId, 0) = CASE   
     WHEN ISNULL(@intCommodityId, 0) = 0  
      THEN isnull(ot.intCommodityId, 0)  
     ELSE @intCommodityId  
     END  
    AND isnull(ot.intFutureMarketId, 0) = CASE   
     WHEN ISNULL(@intFutureMarketId, 0) = 0  
      THEN isnull(ot.intFutureMarketId, 0)  
     ELSE @intFutureMarketId  
     END  
    AND isnull(ot.intBookId, 0) = CASE   
     WHEN ISNULL(@intBookId, 0) = 0  
      THEN isnull(ot.intBookId, 0)  
     ELSE @intBookId  
     END  
    AND isnull(ot.intSubBookId, 0) = CASE   
     WHEN ISNULL(@intSubBookId, 0) = 0  
      THEN isnull(ot.intSubBookId, 0)  
     ELSE @intSubBookId  
     END  
    AND isnull(ot.intEntityId, 0) = CASE   
     WHEN ISNULL(@intEntityId, 0) = 0  
      THEN ot.intEntityId  
     ELSE @intEntityId  
     END  
    AND isnull(ot.intBrokerageAccountId, 0) = CASE   
     WHEN ISNULL(@intBrokerageAccountId, 0) = 0  
      THEN ot.intBrokerageAccountId  
     ELSE @intBrokerageAccountId  
     END  
    AND isnull(ot.intFutureMonthId, 0) = CASE   
     WHEN ISNULL(@intFutureMonthId, 0) = 0  
      THEN ot.intFutureMonthId  
     ELSE @intFutureMonthId  
     END  
    AND ot.strBuySell = CASE   
     WHEN ISNULL(@strBuySell, '0') = '0'  
      THEN ot.strBuySell  
     ELSE @strBuySell  
     END  
  
    --AND isnull(om.ysnExpired, 0) = CASE   
    -- WHEN isnull(@ysnExpired, 'false') = 'true'  
    --  THEN isnull(om.ysnExpired, 0)  
    -- ELSE @ysnExpired  
    -- END  
      
   ) t1  
  ) t1  
 ) t1  
WHERE (  
  dblLong <> 0  
  OR dblShort <> 0  
  )  
ORDER BY RowNum ASC  
  
if (@ysnExpired= 1)  
select RowNum  ,strMonthOrder  ,intFutOptTransactionId  ,dblGrossPnL  ,dblLong  ,dblShort  ,dblFutCommission  ,strFutMarketName  ,strFutureMonth  ,dtmTradeDate  
,strInternalTradeNo  ,strName  ,strAccountNumber  ,strBook  ,strSubBook  ,strSalespersonId  ,strCommodityCode  ,strLocationName  ,dblLong1  ,dblSell1  ,dblNet  
,dblActual  ,dblClosing  ,dblPrice  ,dblContractSize  ,dblFutCommission1  ,dblMatchLong  ,dblMatchShort  ,dblNetPnL  ,intFutureMarketId  ,intFutureMonthId  ,dblOriginalQty  
,intFutOptTransactionHeaderId  ,intCommodityId  ,ysnExpired  ,dblNet*(IsNull(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize) dblVariationMargin  
,dblInitialMargin  ,LongWaitedPrice  ,ShortWaitedPrice from #temp   
ELSE   
select RowNum  ,strMonthOrder  ,intFutOptTransactionId  ,dblGrossPnL  ,dblLong  ,dblShort  ,dblFutCommission  ,strFutMarketName  ,strFutureMonth  ,dtmTradeDate  
,strInternalTradeNo  ,strName  ,strAccountNumber  ,strBook  ,strSubBook  ,strSalespersonId  ,strCommodityCode  ,strLocationName  ,dblLong1  ,dblSell1  ,dblNet  
,dblActual  ,dblClosing  ,dblPrice  ,dblContractSize  ,dblFutCommission1  ,dblMatchLong  ,dblMatchShort  ,dblNetPnL  ,intFutureMarketId  ,intFutureMonthId  ,dblOriginalQty  
,intFutOptTransactionHeaderId  ,intCommodityId  ,ysnExpired  ,dblNet*(IsNull(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize) dblVariationMargin  
,dblInitialMargin  ,LongWaitedPrice  ,ShortWaitedPrice from #temp where ysnExpired=0   
  