CREATE VIEW vyuRKLFuturePSTransaction
AS
SELECT strTotalLot-dblSelectedLot1 AS dblBalanceLot, Case WHEN dblSelectedLot1=0 THEN strTotalLot else dblSelectedLot1 end dblSelectedLot ,* from (
SELECT 
	strBrokerTradeNo AS strTransactionNo
	,dtmTransactionDate as dtmTransactionDate
	,ot.strNoOfContract as strTotalLot
	,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD Group By AD.intLFutOptTransactionId 
			Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
	,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
	,dblPrice as dblPrice
	,strBook 
	,strSubBook 
	,intFutureMarketId 
	,ot.intBrokerageAccountId
	,ot.intLocationId
	,ot.intFutureMonthId
	,ot.intCommodityId
	,ot.intBrokerId
	,ot.intBookId
	,ot.intSubBookId
	,intFutOptTransactionId
 from tblRKFutOptTransaction ot
 JOIN tblCTBook b on b.intBookId=ot.intBookId
 JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId)t