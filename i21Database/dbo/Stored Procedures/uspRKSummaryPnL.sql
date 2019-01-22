CREATE PROC [dbo].[uspRKSummaryPnL] @dtmFromDate DATETIME,  
 @dtmToDate DATETIME,  
 @intCommodityId INT = NULL,  
 @ysnExpired BIT,  
 @intFutureMarketId INT = NULL,  
 @intEntityId INT = NULL,  
 @intBrokerageAccountId INT = NULL,  
 @intFutureMonthId INT = NULL,  
 @strBuySell NVARCHAR(10) = NULL,  
 @intBookId INT = NULL,  
 @intSubBookId INT = NULL  
AS  
 
SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)  
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), isnull(@dtmToDate,getdate()), 110), 110)  
  
DECLARE @UnRelaized AS TABLE (  
 intFutOptTransactionId INT,  
 dblGrossPnL NUMERIC(24, 10),  
 dblLong NUMERIC(24, 10),  
 dblShort NUMERIC(24, 10),  
 dblFutCommission NUMERIC(24, 10),  
 strFutMarketName NVARCHAR(100),  
 strFutureMonth NVARCHAR(100),  
 dtmTradeDate DATETIME,  
 strInternalTradeNo NVARCHAR(100),  
 strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 strBook NVARCHAR(100),  
 strSubBook NVARCHAR(100),  
 strSalespersonId NVARCHAR(100),  
 strCommodityCode NVARCHAR(100),  
 strLocationName NVARCHAR(100),  
 dblLong1 INT,  
 dblSell1 INT,  
 dblNet INT,  
 dblActual NUMERIC(24, 10),  
 dblClosing NUMERIC(24, 10),  
 dblPrice NUMERIC(24, 10),  
 dblContractSize NUMERIC(24, 10),  
 dblFutCommission1 NUMERIC(24, 10),  
 dblMatchLong NUMERIC(24, 10),  
 dblMatchShort NUMERIC(24, 10),  
 dblNetPnL NUMERIC(24, 10),  
 intFutureMarketId INT,  
 intFutureMonthId INT,  
 intOriginalQty INT,  
 intFutOptTransactionHeaderId INT,  
 strMonthOrder NVARCHAR(100),  
 RowNum INT,  
 intCommodityId INT,  
 ysnExpired BIT,  
 dblVariationMargin NUMERIC(24, 10),  
 dblInitialMargin NUMERIC(24, 10),  
 LongWaitedPrice NUMERIC(24, 10),  
 ShortWaitedPrice NUMERIC(24, 10)  
 )  
DECLARE @Relaized AS TABLE (  
 dblGrossPnL NUMERIC(24, 10),  
 intMatchFuturesPSHeaderId INT,  
 intMatchFuturesPSDetailId INT,  
 intFutOptTransactionId INT,  
 intLFutOptTransactionId INT,  
 intSFutOptTransactionId INT,  
 dblMatchQty NUMERIC(24, 10),  
 dtmLTransDate DATETIME,  
 dtmSTransDate DATETIME,  
 dblLPrice NUMERIC(24, 10),  
 dblSPrice NUMERIC(24, 10),  
 strLBrokerTradeNo NVARCHAR(100),  
 strSBrokerTradeNo NVARCHAR(100),  
 dblContractSize NUMERIC(24, 10),  
 dblFutCommission NUMERIC(24, 10),  
 strFutMarketName NVARCHAR(100),  
 strFutureMonth NVARCHAR(100),  
 intMatchNo INT,  
 dtmMatchDate DATETIME,  
 strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 strCommodityCode NVARCHAR(100),  
 strLocationName NVARCHAR(100),  
 dblNetPL NUMERIC(24, 10),  
 intFutureMarketId INT,  
 strMonthOrder NVARCHAR(100),  
 RowNum INT,  
 intCommodityId INT,  
 ysnExpired BIT,  
 intFutureMonthId INT,  
 strLInternalTradeNo nvarchar(100),  
 strSInternalTradeNo nvarchar(100),  
 strLRollingMonth nvarchar(100),  
 strSRollingMonth nvarchar(100),  
 intLFutOptTransactionHeaderId int,  
 intSFutOptTransactionHeaderId int,  
 strBook nvarchar(100),  
 strSubBook nvarchar(100),  
 dblClosing NUMERIC(24, 10)
 )  
  
INSERT INTO @UnRelaized (  
 RowNum,  
 strMonthOrder,  
 intFutOptTransactionId,  
 dblGrossPnL,  
 dblLong,  
 dblShort,  
 dblFutCommission,  
 strFutMarketName,  
 strFutureMonth,  
 dtmTradeDate,  
 strInternalTradeNo,  
 strName,  
 strAccountNumber,  
 strBook,  
 strSubBook,  
 strSalespersonId,  
 strCommodityCode,  
 strLocationName,  
 dblLong1,  
 dblSell1,  
 dblNet,  
 dblActual,  
 dblClosing,  
 dblPrice,  
 dblContractSize,  
 dblFutCommission1,  
 dblMatchLong,  
 dblMatchShort,  
 dblNetPnL,  
 intFutureMarketId,  
 intFutureMonthId,  
 intOriginalQty,  
 intFutOptTransactionHeaderId,  
 intCommodityId,  
 ysnExpired,  
 dblVariationMargin,  
 dblInitialMargin,  
 LongWaitedPrice,  
 ShortWaitedPrice  
 )  
EXEC uspRKUnrealizedPnL @dtmFromDate = @dtmFromDate,  
 @dtmToDate = @dtmToDate,  
 @intCommodityId = @intCommodityId,  
 @ysnExpired = @ysnExpired,  
 @intFutureMarketId = @intFutureMarketId,  
 @intEntityId = @intEntityId,  
 @intBrokerageAccountId = @intBrokerageAccountId,  
 @intFutureMonthId = @intFutureMonthId,  
 @strBuySell = @strBuySell,  
 @intBookId = @intBookId,  
 @intSubBookId = @intSubBookId  
  
INSERT INTO @Relaized (  
 RowNum,  
 strMonthOrder,  
 dblNetPL,  
 dblGrossPnL,  
 intMatchFuturesPSHeaderId,  
 intMatchFuturesPSDetailId,  
 intFutOptTransactionId,  
 intLFutOptTransactionId,  
 intSFutOptTransactionId,  
 dblMatchQty,  
 dtmLTransDate,  
 dtmSTransDate,  
 dblLPrice,  
 dblSPrice,  
 strLBrokerTradeNo,  
 strSBrokerTradeNo,  
 dblContractSize,  
 dblFutCommission,  
 strFutMarketName,  
 strFutureMonth,  
 intMatchNo,  
 dtmMatchDate,  
 strName,  
 strAccountNumber,  
 strCommodityCode,  
 strLocationName,  
 intFutureMarketId,  
 intCommodityId,  
 ysnExpired,  
 intFutureMonthId,strLInternalTradeNo ,strSInternalTradeNo,strLRollingMonth,strSRollingMonth,intLFutOptTransactionHeaderId,intSFutOptTransactionHeaderId  
 ,strBook,strSubBook  
 )  
EXEC uspRKRealizedPnL @dtmFromDate = @dtmFromDate,  
 @dtmToDate = @dtmToDate,  
 @intCommodityId = @intCommodityId,  
 @ysnExpired = @ysnExpired,  
 @intFutureMarketId = @intFutureMarketId,  
 @intEntityId = @intEntityId,  
 @intBrokerageAccountId = @intBrokerageAccountId,  
 @intFutureMonthId = @intFutureMonthId,  
 @strBuySell = @strBuySell,  
 @intBookId = @intBookId,  
 @intSubBookId = @intSubBookId  

UPDATE r
SET r.dblClosing = LS.dblLastSettle
FROM  @Relaized r
OUTER APPLY (
	SELECT TOP 1 dblLastSettle, intFutureMarketId, intFutureMonthId
	FROM tblRKFuturesSettlementPrice p
	INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
	WHERE p.intFutureMarketId = r.intFutureMarketId
		AND pm.intFutureMonthId = r.intFutureMonthId
		AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmToDate, 111)
	ORDER BY dtmPriceDate DESC
) LS
  
BEGIN  
  
DECLARE @Summary AS TABLE (  
   intFutureMarketId int,  
   intFutureMonthId int,  
   strFutMarketName nvarchar(100),  
   strFutureMonth nvarchar(100),  
   intLongContracts int,  
   dblLongAvgPrice NUMERIC(24, 10),  
   intShortContracts int,  
   dblShortAvgPrice NUMERIC(24, 10),  
   dblNet NUMERIC(24, 10),  
   dblUnrealized NUMERIC(24, 10),  
   dblClosing NUMERIC(24, 10),  
   dblFutCommission NUMERIC(24, 10),  
   dblPrice NUMERIC(24, 10),  
   dblRealized NUMERIC(24, 10),  
   dblVariationMargin NUMERIC(24, 10),  
   strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
   strAccountNumber VARCHAR(100) COLLATE Latin1_General_CI_AS,  
   dblTotal NUMERIC(24, 10),  
   ysnExpired BIT,  
   dtmTradeDate datetime   
 )  
  
   
 INSERT INTO @Summary (intFutureMarketId ,intFutureMonthId,strFutMarketName,strFutureMonth ,intLongContracts,dblLongAvgPrice ,intShortContracts ,dblShortAvgPrice ,dblNet,  
     dblUnrealized ,dblClosing ,dblFutCommission ,dblPrice ,dblRealized ,dblVariationMargin,strName ,strAccountNumber,dblTotal,ysnExpired,dtmTradeDate)  
 SELECT intFutureMarketId ,intFutureMonthId,strFutMarketName,strFutureMonth ,isnull(intLongContracts,0) intLongContracts,dblLongAvgPrice ,isnull(intShortContracts,0) intShortContracts  ,dblShortAvgPrice ,isnull(dblNet,0) dblNet,  
     dblUnrealized ,dblClosing ,dblFutCommission ,dblPrice ,dblRealized ,dblVariationMargin,strName ,strAccountNumber,  
  dblUnrealized + dblRealized AS dblTotal,ysnExpired,dtmTradeDate  
 FROM (  
  SELECT  intFutureMarketId,  
   intFutureMonthId,  
   strFutMarketName,  
   strFutureMonth,  
   SUM(ISNULL(dblLong, 0)) intLongContracts,  
   sum(LongWaitedPrice)  dblLongAvgPrice,  
   SUM(ISNULL(dblShort, 0)) intShortContracts,  
   --isnull(CASE WHEN SUM(ShortWaitedPrice) = 0 THEN NULL ELSE SUM(ShortWaitedPrice) / isnull(SUM(ISNULL(dblShort, 0)), NULL) END, 0)  
   sum(ShortWaitedPrice)  dblShortAvgPrice,  
   SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0)) AS dblNet,  
   isnull(SUM(dblNetPnL), 0) dblUnrealized,  
   isnull(max(dblClosing), 0) dblClosing,  
   isnull(SUM(dblFutCommission), 0) dblFutCommission,  
   isnull(SUM(dblPrice), 0) AS dblPrice,  
   isnull(SUM(dblGrossPnLRealized), 0) AS dblRealized,  
   isnull(SUM(dblVariationMargin), 0) AS dblVariationMargin,  
   strName,  
   strAccountNumber,ysnExpired,dtmTradeDate  
  FROM (  
   SELECT dblGrossPnL, 0 as dblGrossPnLRealized,  
    LongWaitedPrice,  
    dblLong,  
    dblShort,  
    ShortWaitedPrice,  
    dblFutCommission,  
    dblNet,  
    intFutOptTransactionId,  
    strFutMarketName,  
    strFutureMonth,  
    intFutureMonthId,  
    intCommodityId,  
    intFutureMarketId,  
    dtmTradeDate,  
    dblClosing AS dblClosing,  
    dblPrice,  
    dblNetPnL,  
    dblVariationMargin,      
    strName,  
    strAccountNumber,ysnExpired  
   FROM @UnRelaized  
     
   UNION  all
     
   SELECT  0 as dblGrossPnL, t.dblGrossPnL dblGrossPnLRealized,  
    null LongWaitedPrice,  
    null dblLong,  
    null dblShort,  
    null ShortWaitedPrice,  
    t.dblFutCommission,  
    t.dblMatchQty dblNet,  
    t.intFutOptTransactionId,  
    t.strFutMarketName,  
    t.strFutureMonth,  
    t.intFutureMonthId,  
    t.intCommodityId,  
    t.intFutureMarketId,  
    t.dtmMatchDate,  
    --ISNULL(dbo.fnRKGetLatestClosingPrice(intFutureMarketId, intFutureMonthId, @dtmToDate), 0) AS dblClosing,  
	dblClosing,
    t.dblSPrice as dblPrice,  
    null dblNetPnL,  
    null dblVariationMargin,      
    t.strName,  
    t.strAccountNumber,isnull(t.ysnExpired,0) as ysnExpired  
   FROM @Relaized t  
   ) t  
  GROUP BY intFutureMonthId,  
   intFutureMarketId,  
   strFutMarketName,  
   strFutureMonth,  
   strName,  
   strAccountNumber,ysnExpired,dtmTradeDate  
  ) t  

   
  
  select  intFutureMarketId,  
   intFutureMonthId,  
   strFutMarketName,  
   strFutureMonth,  
   sum(intLongContracts) dblLongContracts,  
   sum(dblLongAvgPrice) dblLongAvgPrice,  
   sum(intShortContracts) dblShortContracts,  
   sum(dblShortAvgPrice) dblShortAvgPrice,  
   sum(dblNet) dblNet,  
   sum(dblUnrealized) dblUnrealized,  
   max(dblClosing) dblClosing,  
   sum(dblFutCommission) dblFutCommission,  
   sum(dblPrice) dblPrice,  
   sum(dblRealized) dblRealized,  
   sum(dblVariationMargin) dblVariationMargin,  
   strName ,  
   '' strAccountNumber,  
   sum(dblTotal) dblTotal,  
   sum(dblInitialMargin) dblInitialMargin,  
   '' strBook,  
   '' strSubBook,  
   ysnExpired  
    from(  
 SELECT intFutureMarketId,  
   intFutureMonthId,  
   strFutMarketName,  
   strFutureMonth,  
   intLongContracts,  
   dblLongAvgPrice,  
   intShortContracts,  
   dblShortAvgPrice,  
   dblNet,  
   dblUnrealized,  
   dblClosing,  
   dblFutCommission,  
   dblPrice,  
   dblRealized,  
   dblVariationMargin,  
   strName ,  
   strAccountNumber,  
   dblTotal, (case when isnull(dblPerFutureContract,0)>0 then dblPerFutureContract*dblNet else     
  CASE WHEN dblContractMargin <= dblMinAmount THEN dblMinAmount  
     WHEN dblContractMargin >= dblMaxAmount THEN dblMaxAmount  
     ELSE dblContractMargin END end) as dblInitialMargin  
   ,ysnExpired  
  FROM(select *,((dblNet*isnull(dblPrice,0)*dblContractSize)*dblPercenatage)/100 as dblContractMargin from(  
  SELECT DISTINCT t.*,fm.dblContractSize,(select top 1 dblMinAmount from tblRKBrokerageCommission bc where bc.intFutureMarketId = fm.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId   
  and  @dtmToDate between bc.dtmEffectiveDate and  isnull(bc.dtmEndDate,getdate())) dblMinAmount,  
  (select top 1 dblMaxAmount from tblRKBrokerageCommission bc where bc.intFutureMarketId = fm.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId   
  and  @dtmToDate between bc.dtmEffectiveDate and  isnull(bc.dtmEndDate,getdate())) dblMaxAmount,  
  (select top 1 dblPercenatage from tblRKBrokerageCommission bc where bc.intFutureMarketId = fm.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId   
  and  @dtmToDate between bc.dtmEffectiveDate and  isnull(bc.dtmEndDate,getdate())) dblPercenatage,  
  (select top 1 dblPerFutureContract from tblRKBrokerageCommission bc where bc.intFutureMarketId = fm.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId   
  and  @dtmToDate between bc.dtmEffectiveDate and  isnull(bc.dtmEndDate,getdate())) dblPerFutureContract from @Summary t   
  join tblRKBrokerageAccount ba on t.strAccountNumber=ba.strAccountNumber  
  join tblEMEntity e on ba.intEntityId=e.intEntityId and e.strName=t.strName  
  join tblRKFutureMarket fm on t.intFutureMarketId=fm.intFutureMarketId  
  JOIN tblRKBrokerageCommission bc on bc.intBrokerageAccountId= ba.intBrokerageAccountId)t )t1)t2  
  group by intFutureMarketId, intFutureMonthId,strFutMarketName,strFutureMonth,strName,ysnExpired  
  ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC  
  END