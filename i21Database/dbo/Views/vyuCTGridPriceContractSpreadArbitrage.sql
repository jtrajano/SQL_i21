CREATE VIEW [dbo].[vyuCTGridPriceContractSpreadArbitrage]
	
AS

	SELECT		SA.intSpreadArbitrageId,
				SA.intConcurrencyId,
				SA.intPriceFixationId,
				SA.dtmSpreadArbitrageDate,
				SA.intTypeRef,
				SA.strTradeType,
				SA.strOrder,
				SA.intNewFutureMarketId,
				SA.intNewFutureMonthId,
				SA.intOldFutureMarketId,
				SA.intOldFutureMonthId,
				SA.strBuySell,
				SA.dblSpreadPrice,
				SA.intSpreadUOMId,
				SA.dblSpreadAmount,
				SA.dblNoOfLots,
				SA.dblCommissionPrice,
				SA.dblCommission,
				SA.dblTotalSpread,
				SA.strRemarks,
				SA.ysnPriceImpact,
				SA.intCurrencyId,
				SA.ysnDerivative,
				SA.intInternalTradeNumberId,
				SA.intBrokerId,
				SA.intBrokerAccountId,
				SA.dblFX,

				PM.strUnitMeasure		AS strSpreadUOM,
				BM.strFutMarketName		AS strBuyFutureMarket,
				REPLACE(BO.strFutureMonth,' ','('+BO.strSymbol+') ') AS strBuyFutureMonth,
				SM.strFutMarketName		AS strSellFutureMarket,
				REPLACE(SO.strFutureMonth,' ','('+SO.strSymbol+') ') AS strSellFutureMonth,
				BM.intFutureMarketId	AS intBuyFutureMarketId,
				BO.intFutureMonthId		AS intBuyFutureMonthId,
				SM.intFutureMarketId	AS intSellFutureMarketId,
				SO.intFutureMonthId		AS intSellFutureMonthId,
				strCurrency = CU.strCurrency,
				strBroker = EY.strName,
				strBrokerAccount = BA.strAccountNumber,
				strInternalTradeNumber = TR.strInternalTradeNo,
				intInternalTradeNumberHeaderId = TR.intFutOptTransactionHeaderId

		FROM	tblCTSpreadArbitrage	SA
		JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=	SA.intSpreadUOMId
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId			LEFT
		JOIN	tblRKFutureMarket			BM	ON	BM.intFutureMarketId			=	CASE WHEN SA.strBuySell = 'Buy'		THEN SA.intNewFutureMarketId	ELSE	SA.intOldFutureMarketId END	LEFT
		JOIN	tblRKFuturesMonth			BO	ON	BO.intFutureMonthId				=	CASE WHEN SA.strBuySell = 'Buy'		THEN SA.intNewFutureMonthId		ELSE	SA.intOldFutureMonthId	END	LEFT
		JOIN	tblRKFutureMarket			SM	ON	SM.intFutureMarketId			=	CASE WHEN SA.strBuySell = 'Sell'	THEN SA.intNewFutureMarketId	ELSE	SA.intOldFutureMarketId END	LEFT
		JOIN	tblRKFuturesMonth			SO	ON	SO.intFutureMonthId				=	CASE WHEN SA.strBuySell = 'Sell'	THEN SA.intNewFutureMonthId		ELSE	SA.intOldFutureMonthId	END	
		LEFT JOIN tblEMEntity EY ON	EY.intEntityId = SA.intBrokerId
		LEFT JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = SA.intBrokerAccountId
		LEFT JOIN tblSMCurrency CU on CU.intCurrencyID = SA.intCurrencyId
		LEFT JOIN	tblRKFutOptTransaction TR on TR.intFutOptTransactionId = SA.intInternalTradeNumberId

