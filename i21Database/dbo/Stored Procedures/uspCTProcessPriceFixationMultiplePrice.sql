CREATE PROCEDURE [dbo].[uspCTProcessPriceFixationMultiplePrice]
	@intPriceContractId INT
	,@intUserId INT
AS

BEGIN

	DECLARE @ErrMsg nvarchar(max);

	BEGIN TRY

		declare
			@intActiveContractDetailId int
			,@dblSequenceQuantity numeric(18,6)
			,@dblQuantity numeric(18,6)
			,@dblQuantityToPriced numeric(18,6)
			,@dblCommulativePricedQuantity numeric(18,6) = 0
			,@intPriceFixationMultiplePriceId int
			,@intPriceFixationId int
			,@intActivePriceFixationDetailId int
			,@intActivePriceFixationDetailResetId int = 0
			,@intActivePriceFixationDetailMultiplePriceId int
			,@intExistingPriceFixationDetailMultiplePriceId int
			,@dblQuantityPerLot  numeric(18,6)
			;

		IF OBJECT_ID('tempdb..#tmpPriceFixation') IS NOT NULL DROP TABLE #tmpPriceFixation
		IF OBJECT_ID('tempdb..#tmpPriceFixationDetail') IS NOT NULL DROP TABLE #tmpPriceFixationDetail
		IF OBJECT_ID('tempdb..#tmpPriceFixationMultiplePrice') IS NOT NULL DROP TABLE #tmpPriceFixationMultiplePrice
		IF OBJECT_ID('tempdb..#tmpPriceFixationDetailMultiplePrice') IS NOT NULL DROP TABLE #tmpPriceFixationDetailMultiplePrice
		IF OBJECT_ID('tempdb..#tmpExistingPriceFixationDetailMultiplePrice') IS NOT NULL DROP TABLE #tmpExistingPriceFixationDetailMultiplePrice


		select
			pf.intPriceFixationId
			,pf.intPriceContractId
			,pf.intConcurrencyId
			,pf.intContractHeaderId
			,intContractDetailId = cd.intContractDetailId
			,pf.intOriginalFutureMarketId
			,pf.intOriginalFutureMonthId
			,pf.dblOriginalBasis
			,dblTotalLots = cd.dblQuantity / (ch.dblQuantity / ch.dblNoOfLots)
			,dblLotsFixed = 0
			,pf.intLotsHedged
			,pf.dblPolResult
			,pf.dblPremiumPoints
			,pf.ysnAAPrice
			,pf.ysnSettlementPrice
			,pf.ysnToBeAgreed
			,pf.dblSettlementPrice
			,pf.dblAgreedAmount
			,pf.intAgreedItemUOMId
			,pf.dblPolPct
			,pf.dblPriceWORollArb
			,pf.dblRollArb
			,pf.dblPolSummary
			,pf.dblAdditionalCost
			,pf.dblFinalPrice
			,pf.intFinalPriceUOMId
			,pf.ysnSplit
			,pf.intPriceFixationRefId
			,cd.dblQuantity
			,dblQuantityPerLot = (ch.dblQuantity / ch.dblNoOfLots)
		into #tmpPriceFixation
		from
			tblCTPriceFixation pf
			join tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId
			join tblCTContractDetail cd on cd.intContractHeaderId = ch.intContractHeaderId
		where
			pf.intPriceContractId = @intPriceContractId
			and isnull(ch.dblQuantity,0) > 0
			and isnull(ch.dblNoOfLots,0) > 0
		order by cd.intContractDetailId

		select @intActiveContractDetailId = min(intContractDetailId) from #tmpPriceFixation where intContractDetailId > isnull(@intActiveContractDetailId,0)
		while (@intActiveContractDetailId is not null)
		begin
			if not exists (select top 1 1 from tblCTPriceFixationMultiplePrice where intContractDetailId = @intActiveContractDetailId)
			begin
				insert into tblCTPriceFixationMultiplePrice
				select distinct
					pf.intPriceFixationId
					,pf.intPriceContractId
					,pf.intConcurrencyId
					,pf.intContractHeaderId
					,pf.intContractDetailId
					,pf.intOriginalFutureMarketId
					,pf.intOriginalFutureMonthId
					,pf.dblOriginalBasis
					,pf.dblTotalLots
					,pf.dblLotsFixed
					,pf.intLotsHedged
					,pf.dblPolResult
					,pf.dblPremiumPoints
					,pf.ysnAAPrice
					,pf.ysnSettlementPrice
					,pf.ysnToBeAgreed
					,pf.dblSettlementPrice
					,pf.dblAgreedAmount
					,pf.intAgreedItemUOMId
					,pf.dblPolPct
					,pf.dblPriceWORollArb
					,pf.dblRollArb
					,pf.dblPolSummary
					,pf.dblAdditionalCost
					,dblFinalPrice = null
					,pf.intFinalPriceUOMId
					,pf.ysnSplit
					,pf.intPriceFixationRefId
				from #tmpPriceFixation pf
				where pf.intContractDetailId = @intActiveContractDetailId
			end
			else
			begin
				update pfo set pfo.dblTotalLots = pf.dblTotalLots, pfo.intPriceContractId = @intPriceContractId, pfo.intPriceFixationId = pf.intPriceFixationId
				from #tmpPriceFixation pf
				join tblCTPriceFixationMultiplePrice pfo on pfo.intContractDetailId = pf.intContractDetailId
				where pf.intContractDetailId = @intActiveContractDetailId
			end
			
			select @intActiveContractDetailId = min(intContractDetailId) from #tmpPriceFixation where intContractDetailId > isnull(@intActiveContractDetailId,0)
		end

		IF OBJECT_ID('tempdb..#tmpPriceFixationMultiplePrice') IS NOT NULL DROP TABLE #tmpPriceFixationMultiplePrice
		select pfm.*,cd.dblQuantity
		into #tmpPriceFixationMultiplePrice
		from tblCTPriceFixationMultiplePrice pfm
		join tblCTContractDetail cd on cd.intContractDetailId = pfm.intContractDetailId
		where pfm.intPriceContractId = @intPriceContractId;
		
		IF OBJECT_ID('tempdb..#tmpPriceFixationDetail') IS NOT NULL drop table #tmpPriceFixationDetail
		select distinct
			pfd.*
		into #tmpPriceFixationDetail
		from
			tblCTPriceFixationMultiplePrice pfmp
			join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pfmp.intPriceFixationId
		where
			pfmp.intPriceContractId = @intPriceContractId
		order by
			pfd.intPriceFixationDetailId

		select distinct pfdm.intPriceFixationDetailMultiplePriceId
		into #tmpExistingPriceFixationDetailMultiplePrice
		from tblCTPriceFixationMultiplePrice pfm
		join tblCTPriceFixationDetailMultiplePrice pfdm on pfdm.intPriceFixationMultiplePriceId = pfm.intPriceFixationMultiplePriceId
		where pfm.intPriceContractId = @intPriceContractId
		order by pfdm.intPriceFixationDetailMultiplePriceId;

		delete pfdm
		from tblCTPriceFixationMultiplePrice pfm
		join tblCTPriceFixationDetailMultiplePrice pfdm on pfdm.intPriceFixationMultiplePriceId = pfm.intPriceFixationMultiplePriceId
		where pfm.intPriceContractId = @intPriceContractId;
		
		select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from #tmpPriceFixationDetail where dblQuantity > 0
		while (@intActivePriceFixationDetailId is not null)
		begin
			
			select @intPriceFixationMultiplePriceId = min(intPriceFixationMultiplePriceId) from #tmpPriceFixationMultiplePrice where dblQuantity > 0

			if (@intPriceFixationMultiplePriceId is null)
			begin
				update #tmpPriceFixationDetail set dblQuantity = dblQuantity - @dblQuantityToPriced where intPriceFixationDetailId = @intActivePriceFixationDetailId;
				select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from #tmpPriceFixationDetail where dblQuantity > 0;
			end

			while (@intPriceFixationMultiplePriceId is not null)
			begin
				select @dblQuantity = dblQuantity, @intPriceFixationId = intPriceFixationId from #tmpPriceFixationDetail where intPriceFixationDetailId = @intActivePriceFixationDetailId;
				select @dblSequenceQuantity = dblQuantity from #tmpPriceFixationMultiplePrice where intPriceFixationMultiplePriceId = @intPriceFixationMultiplePriceId;

				select @dblQuantityToPriced = case when @dblQuantity > @dblSequenceQuantity then @dblSequenceQuantity else @dblQuantity end;
				

				if (@dblQuantityToPriced > 0)
				begin
					
					select top 1 @dblQuantityPerLot = dblQuantityPerLot from #tmpPriceFixation where intPriceFixationId = @intPriceFixationId;
					
					select @intActivePriceFixationDetailMultiplePriceId = min(intPriceFixationDetailMultiplePriceId) from #tmpExistingPriceFixationDetailMultiplePrice
					if (isnull(@intActivePriceFixationDetailMultiplePriceId,0) = 0)
					begin

						insert into tblCTPriceFixationDetailMultiplePrice
						select
							intPriceFixationMultiplePriceId = @intPriceFixationMultiplePriceId
							,intPriceFixationDetailId  = @intActivePriceFixationDetailId
							,pfd.intPriceFixationId
							,pfd.intNumber
							,pfd.strTradeNo
							,pfd.strOrder
							,pfd.dtmFixationDate
							,dblQuantity = @dblQuantityToPriced
							,pfd.dblQuantityAppliedAndPriced
							,pfd.dblLoadAppliedAndPriced
							,pfd.dblLoadPriced
							,pfd.intQtyItemUOMId
							,dblNoOfLots = @dblQuantityToPriced / @dblQuantityPerLot
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
						from #tmpPriceFixationDetail pfd
						where pfd.intPriceFixationDetailId = @intActivePriceFixationDetailId;

					end
					else
					begin

						SET IDENTITY_INSERT tblCTPriceFixationDetailMultiplePrice ON

						insert into tblCTPriceFixationDetailMultiplePrice(
							intPriceFixationDetailMultiplePriceId
							,intPriceFixationMultiplePriceId
							,intPriceFixationDetailId
							,intPriceFixationId
							,intNumber
							,strTradeNo
							,strOrder
							,dtmFixationDate
							,dblQuantity
							,dblQuantityAppliedAndPriced
							,dblLoadAppliedAndPriced
							,dblLoadPriced
							,intQtyItemUOMId
							,dblNoOfLots
							,intFutureMarketId
							,intFutureMonthId
							,dblFixationPrice
							,dblFutures
							,dblBasis
							,dblPolRefPrice
							,dblPolPremium
							,dblCashPrice
							,intPricingUOMId
							,ysnHedge
							,ysnAA
							,dblHedgePrice
							,intHedgeFutureMonthId
							,intBrokerId
							,intBrokerageAccountId
							,intFutOptTransactionId
							,dblFinalPrice
							,strNotes
							,intPriceFixationDetailRefId
							,intBillId
							,intBillDetailId
							,intInvoiceId
							,intInvoiceDetailId
							,intDailyAveragePriceDetailId
							,dblHedgeNoOfLots
							,dblLoadApplied
							,ysnToBeDeleted
							,intAssignFuturesToContractSummaryId
							,dblPreviousQty
							,intConcurrencyId
						)
						select
							intPriceFixationDetailMultiplePriceId = @intActivePriceFixationDetailMultiplePriceId
							,intPriceFixationMultiplePriceId = @intPriceFixationMultiplePriceId
							,intPriceFixationDetailId  = @intActivePriceFixationDetailId
							,pfd.intPriceFixationId
							,pfd.intNumber
							,pfd.strTradeNo
							,pfd.strOrder
							,pfd.dtmFixationDate
							,dblQuantity = @dblQuantityToPriced
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
						from #tmpPriceFixationDetail pfd
						where pfd.intPriceFixationDetailId = @intActivePriceFixationDetailId;

						SET IDENTITY_INSERT tblCTPriceFixationDetailMultiplePrice OFF

						delete from #tmpExistingPriceFixationDetailMultiplePrice where intPriceFixationDetailMultiplePriceId = @intActivePriceFixationDetailMultiplePriceId;
					end

					update #tmpPriceFixationDetail set dblQuantity = dblQuantity - @dblQuantityToPriced where intPriceFixationDetailId = @intActivePriceFixationDetailId;
					update #tmpPriceFixationMultiplePrice set dblQuantity = dblQuantity - @dblQuantityToPriced  where intPriceFixationMultiplePriceId = @intPriceFixationMultiplePriceId;

				end

				select @intPriceFixationMultiplePriceId = case when @dblQuantity > 0 then min(intPriceFixationMultiplePriceId) else null end from #tmpPriceFixationMultiplePrice where dblQuantity > 0
			end

			select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from #tmpPriceFixationDetail where dblQuantity > 0
		end

		update pfm set pfm.dblLotsFixed = pfdm.dblLotFixed, pfm.dblFinalPrice = case when pfdm.dblLotFixed < pfm.dblTotalLots then  null else pfm.dblFinalPrice end from tblCTPriceFixationMultiplePrice pfm
		cross apply (select pfdm1.intPriceFixationMultiplePriceId, dblLotFixed = (sum(pfdm1.dblQuantity) / @dblQuantityPerLot) from tblCTPriceFixationDetailMultiplePrice pfdm1 where pfdm1.intPriceFixationMultiplePriceId = pfm.intPriceFixationMultiplePriceId group by pfdm1.intPriceFixationMultiplePriceId) pfdm
		where pfm.intPriceContractId = @intPriceContractId;
		
		delete from tblCTPriceFixationMultiplePrice where intPriceContractId = @intPriceContractId and isnull(dblLotsFixed,0) = 0;
				
		IF OBJECT_ID('tempdb..#tmpPriceFixation') IS NOT NULL DROP TABLE #tmpPriceFixation
		IF OBJECT_ID('tempdb..#tmpPriceFixationDetail') IS NOT NULL DROP TABLE #tmpPriceFixationDetail
		IF OBJECT_ID('tempdb..#tmpPriceFixationMultiplePrice') IS NOT NULL DROP TABLE #tmpPriceFixationMultiplePrice
		IF OBJECT_ID('tempdb..#tmpPriceFixationDetailMultiplePrice') IS NOT NULL DROP TABLE #tmpPriceFixationDetailMultiplePrice
		IF OBJECT_ID('tempdb..#tmpExistingPriceFixationDetailMultiplePrice') IS NOT NULL DROP TABLE #tmpExistingPriceFixationDetailMultiplePrice
		
	END TRY
	BEGIN CATCH
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
	END CATCH
	
END;
