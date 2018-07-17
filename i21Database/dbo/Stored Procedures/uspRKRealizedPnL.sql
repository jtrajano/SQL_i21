CREATE PROC uspRKRealizedPnL  
	 @dtmFromDate DATETIME
	,@dtmToDate DATETIME
	,@intCommodityId INT = NULL
	,@ysnExpired BIT
	,@intFutureMarketId INT = NULL
	,@intEntityId INT = NULL
	,@intBrokerageAccountId INT = NULL
	,@intFutureMonthId INT = NULL
	,@strBuySell nvarchar(10)=NULL
AS  
SET @dtmFromDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

SELECT convert(int,DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) RowNum, strFutMarketName+ ' - ' + strFutureMonth + ' - ' + strName MonthOrder,
dblGrossPL - dblFutCommission  AS dblNetPL,dblGrossPL,
intMatchFuturesPSHeaderId ,
intMatchFuturesPSDetailId ,
intFutOptTransactionId ,
intLFutOptTransactionId ,
intSFutOptTransactionId ,
dblMatchQty,
dtmLTransDate ,
dtmSTransDate ,
dblLPrice,
dblSPrice,
strLBrokerTradeNo,
strSBrokerTradeNo,
dblContractSize,
dblFutCommission * -1 as dblFutCommission,
strFutMarketName,
strFutureMonth,
intMatchNo ,
dtmMatchDate ,
strName,
strAccountNumber,
strCommodityCode,
strLocationName,
intFutureMarketId ,
intCommodityId ,
ysnExpired ,intFutureMonthId
 from (
SELECT * FROM(  
SELECT   
((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize) as dblGrossPL1,((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize)/ case when ysnSubCurrency = 'true' then intCent else 1 end as dblGrossPL,* FROM  
( 
SELECT psh.intMatchFuturesPSHeaderId,  
    psd.intMatchFuturesPSDetailId,  
    ot.intFutOptTransactionId,    
    psd.intLFutOptTransactionId,  
    psd.intSFutOptTransactionId,  
    isnull(psd.dblMatchQty,0) as dblMatchQty,  
    convert(datetime,CONVERT(VARCHAR(10),ot.dtmTransactionDate,110),110) dtmLTransDate,  
    convert(datetime,CONVERT(VARCHAR(10),ot1.dtmTransactionDate,110),110) dtmSTransDate,  
    isnull(ot.dblPrice,0) dblLPrice,  
    isnull(ot1.dblPrice,0) dblSPrice,  
    ot.strInternalTradeNo strLBrokerTradeNo,  
    ot1.strInternalTradeNo strSBrokerTradeNo,  
    fm.dblContractSize dblContractSize,0 as intConcurrencyId,  
    --CASE WHEN bc.intFuturesRateType= 2 then isnull(bc.dblFutCommission,0)* isnull(psd.dblMatchQty,0)*2 else  isnull(bc.dblFutCommission,0)* isnull(psd.dblMatchQty,0) end as dblFutCommission1,  
	psd.dblFutCommission,
    fm.strFutMarketName,  
    om.strFutureMonth,  
    psh.intMatchNo,  
     CONVERT(DATETIME,CONVERT(VARCHAR(10),psh.dtmMatchDate,110),110) dtmMatchDate,  
    e.strName,  
    acc.strAccountNumber,  
    icc.strCommodityCode,  
    sl.strLocationName,ot.intFutureMonthId,ot.intCommodityId,ot.intFutureMarketId,
	c.intCurrencyID as intCurrencyId,c.intCent,c.ysnSubCurrency,ysnExpired,c.intCent ComCent,c.ysnSubCurrency ComSubCurrency                  
 FROM tblRKMatchFuturesPSHeader psh  
 JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId   
 JOIN tblRKFutOptTransaction ot on psd.intLFutOptTransactionId= ot.intFutOptTransactionId  
 JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   
 JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId  
 JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId  
 JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId  
 JOIN tblEMEntity e on e.intEntityId=ot.intEntityId  
 JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId  
 JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
 JOIN tblRKFutOptTransaction ot1 on psd.intSFutOptTransactionId= ot1.intFutOptTransactionId  
 WHERE ot.intCommodityId= CASE WHEN ISNULL(@intCommodityId,0)=0 then ot.intCommodityId else @intCommodityId end
	AND ot.intFutureMarketId= CASE WHEN ISNULL(@intFutureMarketId,0)=0 then ot.intFutureMarketId else @intFutureMarketId end
	AND ot.intEntityId= CASE WHEN ISNULL(@intEntityId,0)=0 then ot.intEntityId else @intEntityId end
	AND ot.intBrokerageAccountId= CASE WHEN ISNULL(@intBrokerageAccountId,0)=0 then ot.intBrokerageAccountId else @intBrokerageAccountId end
	AND ot.intFutureMonthId= CASE WHEN ISNULL(@intFutureMonthId,0)=0 then ot.intFutureMonthId else @intFutureMonthId end
	AND ot.strBuySell= CASE WHEN ISNULL(@strBuySell,'0')= '0' then ot.strBuySell else @strBuySell end
	AND CONVERT(DATETIME,CONVERT(VARCHAR(10),psh.dtmMatchDate,110),110) BETWEEN @dtmFromDate AND @dtmToDate
	AND psh.strType = 'Realize'
	AND isnull(ysnExpired,0) = case when isnull(@ysnExpired,'false')= 'true' then isnull(ysnExpired,0) else @ysnExpired end
	AND ot.intInstrumentTypeId =1
  )t)t1
  )t  ORDER BY RowNum ASC
