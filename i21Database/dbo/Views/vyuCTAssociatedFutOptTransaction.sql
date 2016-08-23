﻿CREATE VIEW [dbo].[vyuCTAssociatedFutOptTransaction]
	
AS

	SELECT	OI.*,
			AI.intTotalSequence,
			AI.intOpenSequence,
			AI.intCompletedSequence,
			AI.dtmLastSequenceEndDate 
	FROM
	(
		SELECT	SY.intAssignFuturesToContractSummaryId,
	
				CD.intContractHeaderId,
				CH.strContractNumber,
				CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber,
				MA.strFutMarketName,
				MO.strFutureMonth,
				CD.dblBasis,
				CD.dblFutures,
				CD.dblCashPrice,
				PM.strUnitMeasure strPriceUOM,
				CY.strCurrency,
				CH.dtmContractDate,
				CD.intNumberOfContainers,
				CD.dblNoOfLots,
				IM.strItemNo,
			
				'Long' AS strDirectAssociation,

				FS.intFutOptTransactionId		AS	intShortFutOptTransactionId,
				FS.intFutOptTransactionHeaderId AS	intShortFutOptTransactionHeaderId,
				FS.strFutMarketName				AS	strShortFutMarketName,
				FS.dtmTransactionDate			AS	dtmShortTransactionDate,
				FS.strFutureMonthYear			AS	strShortFutureMonthYear,
				FS.strOptionMonthYear			AS	strShortOptionMonthYear,
				FS.strOptionType				AS	strShortOptionType,
				FS.strInstrumentType			AS	strShortInstrumentType,
				FS.dblStrike					AS	dblShortStrike,
				FS.strInternalTradeNo			AS	strShortInternalTradeNo,
				FS.strName						AS	strShortBrokerName,
				FS.strBrokerageAccount			AS	strShortBrokerageAccount,
				FS.intGetNoOfContract			AS	intShortGetNoOfContract,
				FS.dblContractSize				AS	dblShortContractSize,
				FS.intOpenContract				AS	intShortOpenContract,
				FS.strUnitMeasure				AS	strShortUnitMeasure,
				FS.strBuySell					AS	strShortBuySell,
				FS.dblPrice						AS	dblShortPrice,
				FS.strCommodityCode				AS	strShortCommodityCode,
				FS.strLocationName				AS	strShortLocationName,
				FS.strStatus					AS	strShortStatus,
				FS.strBook						AS	strShortBook,
				FS.strSubBook					AS	strShortSubBook,
				FS.dtmFilledDate				AS	dtmShortFilledDate,
				FS.intCommodityId				AS	intShortCommodityId,
				FS.strBankName					AS	strShortBankName,
				FS.strBankAccountNo				AS	strShortBankAccountNo,
				FS.strSelectedInstrumentType	AS	strShortSelectedInstrumentType,
				FS.dtmMaturityDate				AS	dtmShortMaturityDate,
				FS.strCurrencyExchangeRateType	AS	strShortCurrencyExchangeRateType,
				FS.strFromCurrency				AS	strShortFromCurrency,
				FS.strToCurrency				AS	strShortToCurrency,
				FS.dblContractAmount			AS	dblShortContractAmount,
				FS.dblExchangeRate				AS	dblShortExchangeRate,
				FS.dblMatchAmount				AS	dblShortMatchAmount,
				FS.dblAllocatedAmount			AS	dblShortAllocatedAmount,
				FS.dblUnAllocatedAmount			AS	dblShortUnAllocatedAmount,
				FS.dblSpotRate					AS	dblShortSpotRate,
				FS.ysnLiquidation				AS	ysnShortLiquidation,
				FS.ysnSwap						AS	ysnShortSwap,
				FS.dblHedgeQty					AS	dblShortHedgeQty,

				FL.intFutOptTransactionId		AS	intLongFutOptTransactionId,
				FL.intFutOptTransactionHeaderId AS	intLongFutOptTransactionHeaderId,
				FL.strFutMarketName				AS	strLongFutMarketName,
				FL.dtmTransactionDate			AS	dtmLongTransactionDate,
				FL.strFutureMonthYear			AS	strLongFutureMonthYear,
				FL.strOptionMonthYear			AS	strLongOptionMonthYear,
				FL.strOptionType				AS	strLongOptionType,
				FL.strInstrumentType			AS	strLongInstrumentType,
				FL.dblStrike					AS	dblLongStrike,
				FL.strInternalTradeNo			AS	strLongInternalTradeNo,
				FL.strName						AS	strLongBrokerName,
				FL.strBrokerageAccount			AS	strLongBrokerageAccount,
				FL.intGetNoOfContract			AS	intLongGetNoOfContract,
				FL.dblContractSize				AS	dblLongContractSize,
				FL.intOpenContract				AS	intLongOpenContract,
				FL.strUnitMeasure				AS	strLongUnitMeasure,
				FL.strBuySell					AS	strLongBuySell,
				FL.dblPrice						AS	dblLongPrice,
				FL.strCommodityCode				AS	strLongCommodityCode,
				FL.strLocationName				AS	strLongLocationName,
				FL.strStatus					AS	strLongStatus,
				FL.strBook						AS	strLongBook,
				FL.strSubBook					AS	strLongSubBook,
				FL.dtmFilledDate				AS	dtmLongFilledDate,
				FL.intCommodityId				AS	intLongCommodityId,
				FL.strBankName					AS	strLongBankName,
				FL.strBankAccountNo				AS	strLongBankAccountNo,
				FL.strSelectedInstrumentType	AS	strLongSelectedInstrumentType,
				FL.dtmMaturityDate				AS	dtmLongMaturityDate,
				FL.strCurrencyExchangeRateType	AS	strLongCurrencyExchangeRateType,
				FL.strFromCurrency				AS	strLongFromCurrency,
				FL.strToCurrency				AS	strLongToCurrency,
				FL.dblContractAmount			AS	dblLongContractAmount,
				FL.dblExchangeRate				AS	dblLongExchangeRate,
				FL.dblMatchAmount				AS	dblLongMatchAmount,
				FL.dblAllocatedAmount			AS	dblLongAllocatedAmount,
				FL.dblUnAllocatedAmount			AS	dblLongUnAllocatedAmount,
				FL.dblSpotRate					AS	dblLongSpotRate,
				FL.ysnLiquidation				AS	ysnLongLiquidation,
				FL.ysnSwap						AS	ysnLongSwap,
				FL.dblHedgeQty					AS	dblLongHedgeQty

		FROM	tblRKAssignFuturesToContractSummary	SY
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	SY.intContractDetailId
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId
		JOIN	tblICItem					IM	ON	IM.intItemId				=	CD.intItemId
		JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId			=	PU.intUnitMeasureId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID			=	CD.intCurrencyId
		JOIN	tblRKMatchFuturesPSDetail	MD	ON	MD.intLFutOptTransactionId	=	SY.intFutOptTransactionId
		JOIN	vyuRKFutOptTransaction		FL	ON	FL.intFutOptTransactionId	=	SY.intFutOptTransactionId
		JOIN	vyuRKFutOptTransaction		FS	ON	FS.intFutOptTransactionId	=	MD.intSFutOptTransactionId

		UNION ALL


		SELECT	SY.intAssignFuturesToContractSummaryId,
				
				CD.intContractHeaderId,
				CH.strContractNumber,
				CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber,
				MA.strFutMarketName,
				MO.strFutureMonth,
				CD.dblBasis,
				CD.dblFutures,
				CD.dblCashPrice,
				PM.strUnitMeasure strPriceUOM,
				CY.strCurrency,
				CH.dtmContractDate,
				CD.intNumberOfContainers,
				CD.dblNoOfLots,
				IM.strItemNo,

				'Short' AS strDirectAssociation,

				FS.intFutOptTransactionId		AS	intShortFutOptTransactionId,
				FS.intFutOptTransactionHeaderId AS	intShortFutOptTransactionHeaderId,
				FS.strFutMarketName				AS	strShortFutMarketName,
				FS.dtmTransactionDate			AS	dtmShortTransactionDate,
				FS.strFutureMonthYear			AS	strShortFutureMonthYear,
				FS.strOptionMonthYear			AS	strShortOptionMonthYear,
				FS.strOptionType				AS	strShortOptionType,
				FS.strInstrumentType			AS	strShortInstrumentType,
				FS.dblStrike					AS	dblShortStrike,
				FS.strInternalTradeNo			AS	strShortInternalTradeNo,
				FS.strName						AS	strShortBrokerName,
				FS.strBrokerageAccount			AS	strShortBrokerageAccount,
				FS.intGetNoOfContract			AS	intShortGetNoOfContract,
				FS.dblContractSize				AS	dblShortContractSize,
				FS.intOpenContract				AS	intShortOpenContract,
				FS.strUnitMeasure				AS	strShortUnitMeasure,
				FS.strBuySell					AS	strShortBuySell,
				FS.dblPrice						AS	dblShortPrice,
				FS.strCommodityCode				AS	strShortCommodityCode,
				FS.strLocationName				AS	strShortLocationName,
				FS.strStatus					AS	strShortStatus,
				FS.strBook						AS	strShortBook,
				FS.strSubBook					AS	strShortSubBook,
				FS.dtmFilledDate				AS	dtmShortFilledDate,
				FS.intCommodityId				AS	intShortCommodityId,
				FS.strBankName					AS	strShortBankName,
				FS.strBankAccountNo				AS	strShortBankAccountNo,
				FS.strSelectedInstrumentType	AS	strShortSelectedInstrumentType,
				FS.dtmMaturityDate				AS	dtmShortMaturityDate,
				FS.strCurrencyExchangeRateType	AS	strShortCurrencyExchangeRateType,
				FS.strFromCurrency				AS	strShortFromCurrency,
				FS.strToCurrency				AS	strShortToCurrency,
				FS.dblContractAmount			AS	dblShortContractAmount,
				FS.dblExchangeRate				AS	dblShortExchangeRate,
				FS.dblMatchAmount				AS	dblShortMatchAmount,
				FS.dblAllocatedAmount			AS	dblShortAllocatedAmount,
				FS.dblUnAllocatedAmount			AS	dblShortUnAllocatedAmount,
				FS.dblSpotRate					AS	dblShortSpotRate,
				FS.ysnLiquidation				AS	ysnShortLiquidation,
				FS.ysnSwap						AS	ysnShortSwap,
				FS.dblHedgeQty					AS	dblShortHedgeQty,

				FL.intFutOptTransactionId		AS	intLongFutOptTransactionId,
				FL.intFutOptTransactionHeaderId AS	intLongFutOptTransactionHeaderId,
				FL.strFutMarketName				AS	strLongFutMarketName,
				FL.dtmTransactionDate			AS	dtmLongTransactionDate,
				FL.strFutureMonthYear			AS	strLongFutureMonthYear,
				FL.strOptionMonthYear			AS	strLongOptionMonthYear,
				FL.strOptionType				AS	strLongOptionType,
				FL.strInstrumentType			AS	strLongInstrumentType,
				FL.dblStrike					AS	dblLongStrike,
				FL.strInternalTradeNo			AS	strLongInternalTradeNo,
				FL.strName						AS	strLongBrokerName,
				FL.strBrokerageAccount			AS	strLongBrokerageAccount,
				FL.intGetNoOfContract			AS	intLongGetNoOfContract,
				FL.dblContractSize				AS	dblLongContractSize,
				FL.intOpenContract				AS	intLongOpenContract,
				FL.strUnitMeasure				AS	strLongUnitMeasure,
				FL.strBuySell					AS	strLongBuySell,
				FL.dblPrice						AS	dblLongPrice,
				FL.strCommodityCode				AS	strLongCommodityCode,
				FL.strLocationName				AS	strLongLocationName,
				FL.strStatus					AS	strLongStatus,
				FL.strBook						AS	strLongBook,
				FL.strSubBook					AS	strLongSubBook,
				FL.dtmFilledDate				AS	dtmLongFilledDate,
				FL.intCommodityId				AS	intLongCommodityId,
				FL.strBankName					AS	strLongBankName,
				FL.strBankAccountNo				AS	strLongBankAccountNo,
				FL.strSelectedInstrumentType	AS	strLongSelectedInstrumentType,
				FL.dtmMaturityDate				AS	dtmLongMaturityDate,
				FL.strCurrencyExchangeRateType	AS	strLongCurrencyExchangeRateType,
				FL.strFromCurrency				AS	strLongFromCurrency,
				FL.strToCurrency				AS	strLongToCurrency,
				FL.dblContractAmount			AS	dblLongContractAmount,
				FL.dblExchangeRate				AS	dblLongExchangeRate,
				FL.dblMatchAmount				AS	dblLongMatchAmount,
				FL.dblAllocatedAmount			AS	dblLongAllocatedAmount,
				FL.dblUnAllocatedAmount			AS	dblLongUnAllocatedAmount,
				FL.dblSpotRate					AS	dblLongSpotRate,
				FL.ysnLiquidation				AS	ysnLongLiquidation,
				FL.ysnSwap						AS	ysnLongSwap,
				FL.dblHedgeQty					AS	dblLongHedgeQty

		FROM	tblRKAssignFuturesToContractSummary	SY
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	SY.intContractDetailId
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId
		JOIN	tblICItem					IM	ON	IM.intItemId				=	CD.intItemId
		JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId			=	PU.intUnitMeasureId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID			=	CD.intCurrencyId
		JOIN	tblRKMatchFuturesPSDetail	MD	ON	MD.intSFutOptTransactionId	=	SY.intFutOptTransactionId
		JOIN	vyuRKFutOptTransaction		FS	ON	FS.intFutOptTransactionId	=	SY.intFutOptTransactionId
		JOIN	vyuRKFutOptTransaction		FL	ON	FL.intFutOptTransactionId	=	MD.intLFutOptTransactionId
	)OI
	JOIN	(
				SELECT	DO.intContractHeaderId, 
						COUNT(1) AS intTotalSequence,
						(SELECT  COUNT(1) FROM  tblCTContractDetail DI WHERE DI.intContractHeaderId = DO.intContractHeaderId AND DI.intContractStatusId IN (1,4)) AS intOpenSequence,
						(SELECT  COUNT(1) FROM  tblCTContractDetail DI WHERE DI.intContractHeaderId = DO.intContractHeaderId AND DI.intContractStatusId = 5) AS intCompletedSequence,
						(SELECT  TOP 1 dtmEndDate FROM  tblCTContractDetail DI WHERE DI.intContractHeaderId = DO.intContractHeaderId ORDER BY DI.intContractDetailId DESC) AS dtmLastSequenceEndDate
				FROM	tblCTContractDetail DO
				GROUP BY intContractHeaderId
			) AI	ON	AI.intContractHeaderId	= OI.intContractHeaderId