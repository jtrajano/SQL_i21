CREATE view vyuRKGetBuySellTransaction
as
SELECT intFutureMonthId,strFutureMonth,intFutureMarketId,strFutMarketName,dblContractSize,intLocationId,intBrokerageAccountId,sum(dblBuy) dblBuy,sum(dblSell) dblSell,
dtmFutureMonthsDate
from(
 SELECT t.intFutureMonthId,fm.strFutureMonth,t.intFutureMarketId,strFutMarketName,
	case when strBuySell= 'Buy' then intNoOfContract else 0 end dblBuy,
	case when strBuySell= 'Sell' then intNoOfContract else 0 end dblSell,
	mar.dblContractSize,intLocationId,t.intBrokerageAccountId,dtmFutureMonthsDate
  FROM tblRKFutOptTransaction t
 JOIN tblRKFutOptTransactionHeader th on th.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId
 JOIN tblRKFutureMarket mar on mar.intFutureMarketId=t.intFutureMarketId
 JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId and th.intSelectedInstrumentTypeId=1 and t.intInstrumentTypeId=1
)t group by intFutureMonthId,strFutureMonth,intFutureMarketId,strFutMarketName,dblContractSize,intLocationId,intBrokerageAccountId,dtmFutureMonthsDate

