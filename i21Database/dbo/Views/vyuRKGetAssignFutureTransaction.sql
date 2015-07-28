CREATE VIEW vyuRKGetAssignFutureTransaction

AS
SELECT 
		ot.intFutOptTransactionId,
		ot.strInternalTradeNo AS strInternalTradeNo,
		ot.strBrokerTradeNo AS strBrokerTradeNo
		,ot.dtmFilledDate as dtmFilledDate
		,strBuySell as strBuySell      
		,ot.intNoOfContract as intLots
		--,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD Group By AD.intSFutOptTransactionId 
		--Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLot1
		,0 as intBalanceLots
		,fm.strFutMarketName
		,fmh.strFutureMonth
		,ba.strAccountNumber
		,e.strName strBrokerName
		,c.strCommodityCode
		,scl.strLocationName
		,b.strBook
		,sb.strSubBook
		,fmh.ysnExpired      		   
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
JOIN tblRKFuturesMonth fmh on ot.intFutureMonthId=fmh.intFutureMonthId and ot.intFutureMarketId=fmh.intFutureMarketId
JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId 
JOIN tblEntity e on ot.intEntityId=e.intEntityId
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=ot.intLocationId
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
