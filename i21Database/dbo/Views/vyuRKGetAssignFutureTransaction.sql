﻿CREATE VIEW vyuRKGetAssignFutureTransaction

AS
SELECT * FROM(
	SELECT 
		*
		,dblLots-(dblAssignedLots1+dblHedgedLots1) as dblBalanceLots 
		,dblSContractBalanceLots = dblLots - dblAssignedLotsToSContract
		,dblPContractBalanceLots = dblLots - dblAssignedLotsToPContract
	FROM(
		SELECT 
				ot.intFutOptTransactionId,
				ot.strInternalTradeNo AS strInternalTradeNo,
				ot.strBrokerTradeNo AS strBrokerTradeNo
				,ot.dtmFilledDate as dtmFilledDate
				,strBuySell as strBuySell      
				,ot.dblNoOfContract as dblLots
				,IsNull((SELECT SUM(AD.dblAssignedLots)	FROM tblRKAssignFuturesToContractSummary AD 
						 WHERE  ot.intFutOptTransactionId = AD.intFutOptTransactionId), 0)  As dblAssignedLots1
				 ,IsNull((SELECT SUM(AD.dblHedgedLots)	FROM tblRKAssignFuturesToContractSummary AD 
				 WHERE  ot.intFutOptTransactionId = AD.intFutOptTransactionId), 0)  As dblHedgedLots1
				,IsNull(ot.dblSContractBalanceLots,0)  As dblAssignedLotsToSContract
				,IsNull(ot.dblPContractBalanceLots, 0)  As dblAssignedLotsToPContract
				,fm.strFutMarketName
				,fmh.strFutureMonth
				,ba.strAccountNumber
				,e.strName strBrokerName
				,c.strCommodityCode
				,scl.strLocationName,ot.dblPrice
				,b.strBook
				,sb.strSubBook
				,fmh.ysnExpired
				,ot.intFutOptTransactionHeaderId,ot.dtmCreateDateTime      		   
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
		JOIN tblRKFuturesMonth fmh on ot.intFutureMonthId=fmh.intFutureMonthId and ot.intFutureMarketId=fmh.intFutureMarketId
		JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId 
		JOIN tblEMEntity e on ot.intEntityId=e.intEntityId
		JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
		JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=ot.intLocationId
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
	)t
) t1