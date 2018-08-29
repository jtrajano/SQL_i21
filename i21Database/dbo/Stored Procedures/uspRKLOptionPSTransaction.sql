CREATE PROC [dbo].[uspRKLOptionPSTransaction]  
	@intTypeId int,
	@intEntityId int,
    @intFutureMarketId int,
    @intCommodityId int,
    @intOptionMonthId int,
    @dblStrike int,
    @dtmPositionAsOf datetime
AS  

SET @dtmPositionAsOf = convert(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

SELECT dblStrike,
	strInternalTradeNo,
	dtmTransactionDate,
	dtmFilledDate,
	strFutMarketName,
	strOptionMonth,
	strName,
	strAccountNumber,
	isnull(intTotalLot, 0) intTotalLot,
	isnull(dblOpenLots, 0) dblOpenLots,
	strOptionType,
	dblStrike,
	- dblPremium AS dblPremium,
	- dblPremiumValue AS dblPremiumValue,
	dblCommission,
	intFutOptTransactionId,
	((- dblPremiumValue) + (dblCommission)) AS dblNetPremium,
	dblMarketPremium,
	dblMarketValue,
	CASE WHEN strBuySell = 'B' THEN dblMarketValue - dblPremiumValue ELSE dblPremiumValue - dblMarketValue END AS dblMTM,
	strStatus,
	strCommodityCode,
	strLocationName,
	strBook,
	strSubBook,
	dblDelta,
	- (dblOpenLots * dblDelta * dblContractSize) AS dblDeltaHedge,
	strHedgeUOM,
	strBuySell,
	dblContractSize,
	intFutOptTransactionHeaderId,
	intCurrencyId,
	intCent,
	ysnSubCurrency,
	dtmExpirationDate,
	ysnExpired,
	intTypeId,
	intEntityId,
	intFutureMarketId,
	intCommodityId,
	intOptionMonthId
FROM (
	SELECT (intTotalLot - dblSelectedLot1 - intExpiredLots - intAssignedLots) AS dblOpenLots,
		'' AS dblSelectedLot,
		((intTotalLot - dblSelectedLot1) * dblContractSize * dblPremium) / CASE WHEN ysnSubCurrency = 'true' THEN intCent ELSE 1 END AS dblPremiumValue,
		((intTotalLot - dblSelectedLot1) * dblContractSize * dblMarketPremium) / CASE WHEN ysnSubCurrency = 'true' THEN intCent ELSE 1 END AS dblMarketValue,
		(- dblOptCommission * (intTotalLot - dblSelectedLot1)) / CASE WHEN ysnSubCurrency = 'true' THEN intCent ELSE 1 END AS dblCommission,
		*
	FROM (
		SELECT DISTINCT strInternalTradeNo AS strInternalTradeNo,
			dtmTransactionDate AS dtmTransactionDate,
			ot.dtmFilledDate AS dtmFilledDate,
			fm.strFutMarketName AS strFutMarketName,
			om.strOptionMonth AS strOptionMonth,
			e.strName AS strName,
			ba.strAccountNumber,
			ot.intNoOfContract AS intTotalLot,
			IsNull((
					SELECT SUM(AD.intMatchQty)
					FROM tblRKOptionsMatchPnS AD
					where  dtmMatchDate<=@dtmPositionAsOf
					GROUP BY AD.intLFutOptTransactionId
					HAVING ot.intFutOptTransactionId = AD.intLFutOptTransactionId
					), 0) AS dblSelectedLot1,
			ot.strOptionType,
			ot.dblStrike,
			ot.dblPrice AS dblPremium,
			fm.dblContractSize AS dblContractSize,
			isnull(dblOptCommission, 0) AS dblOptCommission,
			om.dtmExpirationDate,
			ot.strStatus,
			ic.strCommodityCode,
			cl.strLocationName,
			strBook,
			strSubBook,
			isnull((
					SELECT TOP 1 dblSettle
					FROM tblRKFuturesSettlementPrice sp
					JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId = spm.intFutureSettlementPriceId 
					AND sp.intFutureMarketId = ot.intFutureMarketId AND spm.intOptionMonthId = ot.intOptionMonthId 
					AND ot.dblStrike = spm.dblStrike AND spm.intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmPriceDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)
					ORDER BY sp.dtmPriceDate DESC
					), 0) AS dblMarketPremium,
			'' AS MarketValue,
			'' AS MTM,
			ot.intOptionMonthId,
			ot.intFutureMarketId,
			isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId = spm.intFutureSettlementPriceId 
					AND sp.intFutureMarketId = ot.intFutureMarketId AND spm.intOptionMonthId = ot.intOptionMonthId 
					AND ot.dblStrike = spm.dblStrike AND spm.intTypeId = (CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmPriceDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)
					ORDER BY 1 DESC
					), 0) AS dblDelta,
			'' AS DeltaHedge,
			um.strUnitMeasure AS strHedgeUOM,
			CASE WHEN strBuySell = 'Buy' THEN 'B' ELSE 'S' END strBuySell,
			intFutOptTransactionId,
			isnull((
					SELECT SUM(intLots)
					FROM tblRKOptionsPnSExpired ope
					WHERE ope.intFutOptTransactionId = ot.intFutOptTransactionId
					and dtmExpiredDate<=@dtmPositionAsOf
					), 0) intExpiredLots,
			isnull((
					SELECT SUM(intLots)
					FROM tblRKOptionsPnSExercisedAssigned opa
					WHERE opa.intFutOptTransactionId = ot.intFutOptTransactionId
					and dtmTranDate<=@dtmPositionAsOf
					), 0) intAssignedLots,
			c.intCurrencyID AS intCurrencyId,
			c.intCent,
			ysnSubCurrency,
			intFutOptTransactionHeaderId,
			CASE WHEN CONVERT(VARCHAR(10), dtmExpirationDate, 111) < CONVERT(VARCHAR(10), GETDATE(), 111) THEN 1 ELSE 0 END ysnExpired,
			CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END intTypeId,
			ot.intEntityId,
			ot.intCommodityId
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = ot.intFutureMarketId AND ot.strStatus = 'Filled'
		JOIN tblICUnitMeasure um ON fm.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICCommodity ic ON ic.intCommodityId = ot.intCommodityId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = ot.intLocationId
		JOIN tblRKOptionsMonth om ON ot.intOptionMonthId = om.intOptionMonthId
		JOIN tblRKBrokerageAccount ba ON ot.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
		LEFT JOIN tblRKBrokerageCommission bc ON bc.intFutureMarketId = ot.intFutureMarketId AND ba.intBrokerageAccountId = bc.intBrokerageAccountId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = bc.intFutCurrencyId
		LEFT JOIN tblCTBook b ON b.intBookId = ot.intBookId
		LEFT JOIN tblCTSubBook sb ON sb.intSubBookId = ot.intSubBookId
		WHERE ot.intInstrumentTypeId = 2 AND strBuySell = 'Buy'
		) t
	) t1
WHERE dblOpenLots > 0 
AND ISNULL(intTypeId, 0) = CASE WHEN isnull(@intTypeId, 0) = 0 THEN isnull(intTypeId, 0) ELSE @intTypeId END 
AND ISNULL(intEntityId, 0) = CASE WHEN isnull(@intEntityId, 0) = 0 THEN isnull(intEntityId, 0) ELSE @intEntityId END 
AND ISNULL(intFutureMarketId, 0) = CASE WHEN isnull(@intFutureMarketId, 0) = 0 THEN isnull(intFutureMarketId, 0) ELSE @intFutureMarketId END 
AND ISNULL(intCommodityId, 0) = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN isnull(intCommodityId, 0) ELSE @intCommodityId END 
AND ISNULL(intOptionMonthId, 0) = CASE WHEN isnull(@intOptionMonthId, 0) = 0 THEN isnull(intOptionMonthId, 0) ELSE @intOptionMonthId END 
AND ISNULL(dblStrike, 0) = CASE WHEN isnull(@dblStrike, 0) = 0 THEN isnull(dblStrike, 0) ELSE @dblStrike END 
AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)