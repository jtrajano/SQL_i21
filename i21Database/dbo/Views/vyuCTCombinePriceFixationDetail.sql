CREATE VIEW [dbo].[vyuCTCombinePriceFixationDetail]
	AS
	SELECT
		pfd.intPriceFixationDetailId
		,pfd.intPriceFixationId
		,pfd.intNumber
		,pfd.strTradeNo
		,pfd.strOrder
		,pfd.dtmFixationDate
		,pfd.dblQuantity
		,pfd.dblQuantityAppliedAndPriced
		,pfd.dblLoadAppliedAndPriced
		,pfd.dblLoadPriced
		,pfd.intQtyItemUOMId
		,pfd.dblNoOfLots
		,pfd.intFutureMarketId
		,pfd.intFutureMonthId
		,pfd.dblFixationPrice
		,pfd.dblFutures
		,pfd.dblBasis
		,pfd.dblPolRefPrice
		,pfd.dblPolPremium
		,pfd.dblCashPrice
		,pfd.intPricingUOMId
		,pfd.ysnHedge
		,pfd.ysnAA
		,pfd.dblHedgePrice
		,pfd.intHedgeFutureMonthId
		,pfd.intBrokerId
		,pfd.intBrokerageAccountId
		,pfd.intFutOptTransactionId
		,pfd.dblFinalPrice
		,pfd.strNotes
		,pfd.intPriceFixationDetailRefId
		,pfd.intBillId
		,pfd.intBillDetailId
		,pfd.intInvoiceId
		,pfd.intInvoiceDetailId
		,pfd.intDailyAveragePriceDetailId
		,pfd.dblHedgeNoOfLots
		,pfd.dblLoadApplied
		,pfd.ysnToBeDeleted
		,pfd.intAssignFuturesToContractSummaryId
		,pfd.dblPreviousQty
		,pfd.intConcurrencyId
		,ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	FROM
		tblCTContractHeader ch
		join tblCTPriceFixation pf
			on pf.intContractHeaderId = ch.intContractHeaderId
		join tblCTPriceFixationDetail pfd
			on pfd.intPriceFixationId = pf.intPriceFixationId
	where
		isnull(ch.ysnMultiplePriceFixation,0) = 0

	union all

	SELECT
		intPriceFixationDetailId = pfd.intPriceFixationDetailMultiplePriceId
		,intPriceFixationId = pf.intPriceFixationMultiplePriceId
		,pfd.intNumber
		,pfd.strTradeNo
		,pfd.strOrder
		,pfd.dtmFixationDate
		,pfd.dblQuantity
		,pfd.dblQuantityAppliedAndPriced
		,pfd.dblLoadAppliedAndPriced
		,pfd.dblLoadPriced
		,pfd.intQtyItemUOMId
		,pfd.dblNoOfLots
		,pfd.intFutureMarketId
		,pfd.intFutureMonthId
		,pfd.dblFixationPrice
		,pfd.dblFutures
		,pfd.dblBasis
		,pfd.dblPolRefPrice
		,pfd.dblPolPremium
		,pfd.dblCashPrice
		,pfd.intPricingUOMId
		,pfd.ysnHedge
		,pfd.ysnAA
		,pfd.dblHedgePrice
		,pfd.intHedgeFutureMonthId
		,pfd.intBrokerId
		,pfd.intBrokerageAccountId
		,pfd.intFutOptTransactionId
		,pfd.dblFinalPrice
		,pfd.strNotes
		,pfd.intPriceFixationDetailRefId
		,pfd.intBillId
		,pfd.intBillDetailId
		,pfd.intInvoiceId
		,pfd.intInvoiceDetailId
		,pfd.intDailyAveragePriceDetailId
		,pfd.dblHedgeNoOfLots
		,pfd.dblLoadApplied
		,pfd.ysnToBeDeleted
		,pfd.intAssignFuturesToContractSummaryId
		,pfd.dblPreviousQty
		,pfd.intConcurrencyId
		,ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	FROM
		tblCTContractHeader ch
		join tblCTPriceFixationMultiplePrice pf
			on pf.intContractHeaderId = ch.intContractHeaderId
		join tblCTPriceFixationDetailMultiplePrice pfd
			on pfd.intPriceFixationMultiplePriceId = pf.intPriceFixationMultiplePriceId
	where
		isnull(ch.ysnMultiplePriceFixation,0) = 1
