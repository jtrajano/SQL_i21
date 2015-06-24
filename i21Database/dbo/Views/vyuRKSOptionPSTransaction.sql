CREATE VIEW vyuRKSOptionPSTransaction
AS
SELECT strInternalTradeNo,dtmTransactionDate,dtmFilledDate,strFutMarketName,strOptionMonth,strName,strAccountNumber,isnull(intTotalLot,0) intTotalLot,isnull(dblOpenLots,0) dblOpenLots,
		strOptionType,dblStrike,dblPremium,dblPremiumValue,dblCommission,intFutOptTransactionId
 ,dblPremiumValue+dblCommission as dblNetPremium,
 dblMarketPremium,
 dblMarketValue,
 dblMarketValue - dblPremiumValue as dblMTM,
 dtmExpirationDate,strStatus,strCommodityCode,strLocationName,strBook,strSubBook,dblDelta,
 -(dblOpenLots*dblDelta*dblContractSize) AS dblDeltaHedge,
 strHedgeUOM,strBuySell,dblContractSize
  FROM (
SELECT (intTotalLot-dblSelectedLot1-intExpiredLots-intAssignedLots) AS dblOpenLots,'' as dblSelectedLot,
		(intTotalLot-dblSelectedLot1)*dblContractSize*dblPremium  as dblPremiumValue,
		(intTotalLot-dblSelectedLot1)*dblContractSize*dblMarketPremium  as dblMarketValue,
		-dblOptCommission*(intTotalLot-dblSelectedLot1) AS dblCommission,* from  (
SELECT DISTINCT
      strInternalTradeNo AS strInternalTradeNo
      ,dtmTransactionDate as dtmTransactionDate
      ,ot.dtmFilledDate as dtmFilledDate
      ,fm.strFutMarketName as strFutMarketName
      ,om.strOptionMonth as strOptionMonth
      ,e.strName as strName
      ,ba.strAccountNumber
      ,ot.intNoOfContract as intTotalLot
      ,IsNull((SELECT SUM (AD.intMatchQty) from tblRKOptionsMatchPnS AD Group By AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0) As dblSelectedLot1
      ,ot.strOptionType
      ,ot.dblStrike
      ,ot.dblPrice as dblPremium
      ,fm.dblContractSize as dblContractSize
      ,isnull(dblOptCommission,0) as dblOptCommission
      ,om.dtmExpirationDate
      ,ot.strStatus
      ,ic.strCommodityCode
      ,cl.strLocationName
      ,strBook 
      ,strSubBook 
        ,isnull((SELECT TOP 1 dblSettle  FROM tblRKFuturesSettlementPrice sp
		JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId 
		AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId 
		and ot.dblStrike=spm.dblStrike and spm.intTypeId= (case when ot.strOptionType='Put' then 1 else 2 end)
		ORDER BY sp.dtmPriceDate desc),0) as dblMarketPremium
      ,'' as MarketValue
      ,''as MTM,ot.intOptionMonthId ,ot.intFutureMarketId
	  ,isnull((SELECT TOP 1 dblDelta  FROM tblRKFuturesSettlementPrice sp
		JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId 
		AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId 
		and ot.dblStrike=spm.dblStrike and spm.intTypeId= (case when ot.strOptionType='Put' then 1 else 2 end)
		ORDER BY 1 desc),0) as dblDelta
	  ,'' as DeltaHedge
	  ,um.strUnitMeasure as strHedgeUOM
	  ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell,intFutOptTransactionId,
	   isnull((Select SUM(intLots) From tblRKOptionsPnSExpired ope where  ope.intFutOptTransactionId= ot.intFutOptTransactionId),0) intExpiredLots,    
	   isnull((Select SUM(intLots) FROM tblRKOptionsPnSExercisedAssigned opa where  opa.intFutOptTransactionId= ot.intFutOptTransactionId),0) intAssignedLots
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=2 --and ot.strStatus='Filled' 
join tblICUnitMeasure um on fm.intUnitMeasureId=um.intUnitMeasureId
JOIN tblICCommodity ic on ic.intCommodityId=ot.intCommodityId
JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=ot.intLocationId
JOIN tblRKOptionsMonth om on ot.intOptionMonthId=om.intOptionMonthId and ysnMonthExpired = 0
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId 
JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId 
	AND ba.intEntityId = ot.intEntityId  AND ot.intInstrumentTypeId IN(2,3) AND ba.intBrokerageAccountId=bc.intBrokerageAccountId 
JOIN tblEntity e on e.intEntityId=ba.intEntityId  
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
 )t)t1  where dblOpenLots > 0 and strBuySell='S'
