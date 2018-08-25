﻿CREATE PROC [dbo].[uspRKUnrealizedPnL]  
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

SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
 
SELECT CONVERT(INT,DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) RowNum, strFutMarketName+ ' - ' + strFutureMonth + ' - ' + strName MonthOrder,
intFutOptTransactionId ,GrossPnL ,dblLong ,dblShort ,dblFutCommission ,strFutMarketName ,strFutureMonth ,dtmTradeDate ,strInternalTradeNo ,strName ,strAccountNumber 
,strBook ,strSubBook ,strSalespersonId ,strCommodityCode ,strLocationName ,Long1 ,Sell1 ,intNet ,dblActual,dblClosing ,dblPrice ,dblContractSize ,dblFutCommission1 
,MatchLong ,MatchShort ,NetPnL ,intFutureMarketId ,intFutureMonthId ,intOriginalQty ,intFutOptTransactionHeaderId ,intCommodityId ,ysnExpired ,dblVariationMargin ,0.0 dblInitialMargin 
,LongWaitedPrice,ShortWaitedPrice
 from 
(SELECT *,(GrossPnL1 * (dblClosing - dblPrice)-dblFutCommission2)  NetPnL,intNet*dblVariationMargin1 dblVariationMargin
,GrossPnL1 * (dblClosing - dblPrice) GrossPnL,-dblFutCommission2 dblFutCommission
 FROM (  
SELECT (convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)))*dblContractSize/ case when ysnSubCurrency = 'true' then intCent else 1 end  GrossPnL1,isnull(((Long1-MatchLong)*dblPrice),0) LongWaitedPrice,  
isnull((Long1-MatchLong),0) as dblLong,isnull(Sell1-MatchShort,0) as dblShort, isnull(((Sell1-MatchShort)*dblPrice),0) ShortWaitedPrice,  
convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)) * -dblFutCommission1 / case when ComSubCurrency = 'true' then ComCent else 1 end  AS dblFutCommission2,
convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)) as  intNet,  
ISNULL(dbo.fnRKGetLatestClosingPrice (intFutureMarketId,intFutureMonthId,@dtmToDate),0) as dblClosing,     
* FROM (   
SELECT  intFutOptTransactionId,
		fm.strFutMarketName,  
		om.strFutureMonth,
		ot.intFutureMonthId,
		ot.intCommodityId,
		ot.intFutureMarketId,  
		convert(datetime,CONVERT(VARCHAR(10),ot.dtmFilledDate,110),110) as dtmTradeDate,  
		ot.strInternalTradeNo,  
		e.strName,  
		acc.strAccountNumber,  
		cb.strBook,  
		csb.strSubBook,  
		sp.strSalespersonId,  
		icc.strCommodityCode,  
		sl.strLocationName,     
		ot.intNoOfContract as intOriginalQty,  
		isnull(Case WHEN ot.strBuySell='Buy' THEN isnull(ot.intNoOfContract,0) ELSE null end,0) Long1 ,  
		isnull(Case WHEN ot.strBuySell='Sell' THEN isnull(ot.intNoOfContract,0) ELSE null end,0) Sell1,
		ot.intNoOfContract as intNet1,  
		ot.dblPrice as dblActual,  		
		isnull(ot.dblPrice,0) dblPrice,  
		fm.dblContractSize dblContractSize,0 as intConcurrencyId,  
		--CASE WHEN bc.intFuturesRateType= 1 then 0 else  isnull(bc.dblFutCommission,0) end as dblFutCommission1,  
		 --This filter is to get the correct commission based on date						
       dblFutCommission1 = ISNULL((select TOP 1
		(case when bc.intFuturesRateType = 1 then 0  
			else  isnull(bc.dblFutCommission,0) / case when cur.ysnSubCurrency = 'true' then cur.intCent else 1 end 
		end) 
		from tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
		where bc.intFutureMarketId = ot.intFutureMarketId and bc.intBrokerageAccountId = ot.intBrokerageAccountId and  ot.dtmTransactionDate between bc.dtmEffectiveDate and bc.dtmEndDate),0),
	  
	   ISNULL((SELECT SUM(dblMatchQty) from tblRKMatchFuturesPSDetail psd 
				JOIN tblRKMatchFuturesPSHeader h on psd.intMatchFuturesPSHeaderId=h.intMatchFuturesPSHeaderId
				WHERE psd.intLFutOptTransactionId=ot.intFutOptTransactionId AND h.strType = 'Realize' 
					  AND convert(datetime,CONVERT(VARCHAR(10),h.dtmMatchDate,110),110) <= @dtmToDate),0) as MatchLong,  
	   ISNULL((SELECT sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd
			   JOIN tblRKMatchFuturesPSHeader h on psd.intMatchFuturesPSHeaderId=h.intMatchFuturesPSHeaderId
			  WHERE psd.intSFutOptTransactionId=ot.intFutOptTransactionId AND h.strType = 'Realize' 
			  AND convert(datetime,CONVERT(VARCHAR(10),h.dtmMatchDate,110),110) <= @dtmToDate),0) as MatchShort,            
		c.intCurrencyID as intCurrencyId,c.intCent,c.ysnSubCurrency,intFutOptTransactionHeaderId,ysnExpired,c.intCent ComCent,c.ysnSubCurrency ComSubCurrency            
		,IsNull(dbo.fnRKGetVariationMargin (ot.intFutOptTransactionId ,@dtmToDate,ot.dtmFilledDate), 0.0)*fm.dblContractSize dblVariationMargin1
			
 FROM tblRKFutOptTransaction ot   
 JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   and ot.strStatus='Filled'
 JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId  
 JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId  
 JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId  
 JOIN tblARSalesperson sp on sp.intEntityId= ot.intTraderId  
 JOIN tblEMEntity e on e.intEntityId=ot.intEntityId  
 JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId  
 JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
 LEFT JOIN tblCTBook cb on cb.intBookId= ot.intBookId  
 LEFT JOIN tblCTSubBook csb on csb.intSubBookId=ot.intSubBookId 
 WHERE isnull(ot.intCommodityId,0)= CASE WHEN ISNULL(@intCommodityId,0)=0 then isnull(ot.intCommodityId,0) else @intCommodityId end
	AND isnull(ot.intFutureMarketId,0)= CASE WHEN ISNULL(@intFutureMarketId,0)=0 then isnull(ot.intFutureMarketId,0) else @intFutureMarketId end
	AND isnull(ot.intBookId,0)= CASE WHEN ISNULL(@intBookId,0)=0 then isnull(ot.intBookId,0) else @intBookId end
	AND isnull(ot.intSubBookId,0)= CASE WHEN ISNULL(@intSubBookId,0)=0 then isnull(ot.intSubBookId,0) else @intSubBookId end
	AND isnull(ot.intEntityId,0)= CASE WHEN ISNULL(@intEntityId,0)=0 then ot.intEntityId else @intEntityId end
	AND isnull(ot.intBrokerageAccountId,0)= CASE WHEN ISNULL(@intBrokerageAccountId,0)=0 then ot.intBrokerageAccountId else @intBrokerageAccountId end
	AND isnull(ot.intFutureMonthId,0)= CASE WHEN ISNULL(@intFutureMonthId,0)=0 then ot.intFutureMonthId else @intFutureMonthId end
	AND ot.strBuySell= CASE WHEN ISNULL(@strBuySell,'0')= '0'  then ot.strBuySell else @strBuySell end
	AND convert(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) BETWEEN @dtmFromDate AND @dtmToDate
	AND isnull(ysnExpired,0) = case when isnull(@ysnExpired,'false')= 'true' then isnull(ysnExpired,0) else @ysnExpired end
	AND ot.intInstrumentTypeId =1
  )t1)t1 
)t1 where (dblLong<>0 or dblShort <>0) 
ORDER BY RowNum ASC