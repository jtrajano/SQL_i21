CREATE PROCEDURE uspCTCreatePrice
	@intContractDetailId int
	,@dblQuantityToPrice numeric(18,6)
	,@dblFutures numeric(18,6)
	,@intUserId int
	,@intAssignFuturesToContractSummaryId int
	,@ysnAllowToPriceRemainingQtyToPrice bit = 0
AS

declare
	@ErrorMsg nvarchar(max)
	,@ysnWithError bit = 0
	,@dblSequenceQuantity numeric(18,6)
	,@dblBalance numeric(18,6)
	,@dblBasis numeric(18,6)
	,@intPriceContractId int
	,@intPriceFixationId int
	,@strContractNumber nvarchar(50)
	,@intContractSeq int
	,@dblTotalPricedQuantity numeric(18,6)
	,@dblTotalPricedLots numeric(18,6)
	,@dblTotalPricedFutures numeric(18,6)
	,@dblTotalWeightedAvg numeric(18,6)
	,@intPricingType int
	,@intContractHeaderId int
	,@intCommodityId int
	,@intItemId int
	,@intItemUOMId int
	,@intFinalPriceUOMId int
	,@intFinalCurrencyId int
	,@intOriginalFutureMarketId int
	,@intOriginalFutureMonthId int
	,@dblOriginalBasis int
	,@dblTotalLots numeric(18,6)
	,@dblQuantityPerLot numeric(18,6)
	,@dblLotsFixed numeric(18,6)
	,@intQtyItemUOMId int
	,@strPriceContractNo nvarchar(50)
	,@intStartingNumberId int
	,@strTradeNo nvarchar(50)
	,@intNumber int
	,@ysnMultiplePriceFixation bit
	;

begin try

	if (@dblQuantityToPrice <= 0)
	begin
		set @ysnWithError = 1;
		set @ErrorMsg = convert(nvarchar(50),@dblQuantityToPrice) + ' quantity is not valid for pricing.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	if (@dblFutures is null)
	begin
		set @ysnWithError = 1;
		set @ErrorMsg = 'Futures price is not valid.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	select
		@dblSequenceQuantity = CASE WHEN isnull(ch.ysnMultiplePriceFixation,0)  = 1 THEN ch.dblQuantity ELSE cd.dblQuantity  END
		,@dblBalance = cd.dblBalance
		,@dblBasis = cd.dblBasis
		,@intPriceContractId = pc.intPriceContractId
		,@intPriceFixationId = pf.intPriceFixationId
		,@strContractNumber = ch.strContractNumber
		,@intContractSeq = cd.intContractSeq
		,@dblTotalPricedQuantity = isnull(pfd.dblTotalPricedQuantity,0)
		,@intPricingType = cd.intPricingTypeId
		,@intContractHeaderId = ch.intContractHeaderId
		,@intCommodityId = ch.intCommodityId
		,@intItemId = cd.intItemId
		,@intItemUOMId = cd.intPriceItemUOMId
		,@intFinalPriceUOMId = comm.intCommodityUnitMeasureId
		,@intFinalCurrencyId = cd.intCurrencyId
		,@intOriginalFutureMarketId =  cd.intFutureMarketId
		,@intOriginalFutureMonthId = cd.intFutureMonthId
		,@dblOriginalBasis = isnull(cd.dblOriginalBasis,cd.dblBasis)
		,@dblTotalLots = (case when ch.ysnMultiplePriceFixation = 1 then ch.dblNoOfLots else cd.dblNoOfLots end)
		,@dblLotsFixed = @dblTotalLots
		,@intQtyItemUOMId = cd.intItemUOMId
		,@dblQuantityPerLot = cd.dblQuantity / (case when ch.ysnMultiplePriceFixation = 1 then cd.dblQuantity / (ch.dblQuantity/ch.dblNoOfLots) else cd.dblNoOfLots end)
		,@ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		left join tblCTPriceFixation pf on isnull(pf.intContractDetailId,0) = (case when ch.ysnMultiplePriceFixation = 1 then isnull(pf.intContractDetailId,0) else cd.intContractDetailId end) and pf.intContractHeaderId = cd.intContractHeaderId
		left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
		left join tblICItemUOM ium on ium.intItemUOMId = cd.intPriceItemUOMId
		left join tblICCommodityUnitMeasure comm on comm.intUnitMeasureId = ium.intUnitMeasureId and comm.intCommodityId = ch.intCommodityId
		cross apply (
			select dblTotalPricedQuantity = sum(pfd.dblQuantity) from tblCTPriceFixationDetail pfd where pfd.intPriceFixationId = pf.intPriceFixationId
		) pfd
	where
		cd.intContractDetailId = @intContractDetailId;

	if (@intPricingType = 1)
	begin
		set @ysnWithError = 1;
		set @ErrorMsg = 'Contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + ' is already priced.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	if (@intPricingType not in (2,3))
	begin
		set @ysnWithError = 1;
		set @ErrorMsg = 'Contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + ' is not available for pricing.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	if (@dblSequenceQuantity <= @dblTotalPricedQuantity)
	begin
		if (@ysnAllowToPriceRemainingQtyToPrice = 1)
		begin
			return
		end

		set @ysnWithError = 1;
		set @ErrorMsg = 'There''s no available quantity to price for contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + '.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	if ((@dblSequenceQuantity - @dblTotalPricedQuantity) < @dblQuantityToPrice)
	begin
		if (@ysnAllowToPriceRemainingQtyToPrice = 1)
		begin
			set @dblQuantityToPrice = @dblSequenceQuantity - @dblTotalPricedQuantity
		end
		else
		begin
			set @ysnWithError = 1;
			set @ErrorMsg = 'There''s only ' + convert(nvarchar(50),(@dblSequenceQuantity - @dblTotalPricedQuantity)) + ' available quantity for pricing for contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + '' + '.';
			RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
		end
	end

	if (isnull(@intPriceContractId,0) > 0)
	begin
	
		/*Create Price Fixation Detail record*/
		
		select @intStartingNumberId = intStartingNumberId from tblSMStartingNumber where strModule = 'Contract Management' and strTransactionType = 'Price Fixation Trade No';

		exec dbo.uspSMGetStartingNumber 
			@intStartingNumberId  = @intStartingNumberId
			,@strID	= @strTradeNo out
			,@intCompanyLocationId = default

		select @intNumber = max(intNumber) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId;
		select @intNumber = isnull(@intNumber,1);

		insert into tblCTPriceFixationDetail (
			intPriceFixationId
			,intNumber
			,strTradeNo
			,strOrder
			,dtmFixationDate
			,dblQuantity
			,intQtyItemUOMId
			,dblNoOfLots
			,intFutureMarketId
			,intFutureMonthId
			,dblFixationPrice
			,dblFutures
			,dblBasis
			,dblCashPrice
			,intPricingUOMId
			,ysnHedge
			,ysnAA
			,dblFinalPrice
			,strNotes
			,ysnToBeDeleted
			,intAssignFuturesToContractSummaryId
			,intConcurrencyId
		)
		select 
			intPriceFixationId = @intPriceFixationId
			,intNumber = @intNumber
			,strTradeNo = @strTradeNo
			,strOrder = 'Confirmed'
			,dtmFixationDate = getdate()
			,dblQuantity = @dblQuantityToPrice
			,intQtyItemUOMId = @intQtyItemUOMId
			,dblNoOfLots = @dblQuantityToPrice / @dblQuantityPerLot
			,intFutureMarketId = @intOriginalFutureMarketId
			,intFutureMonthId = @intOriginalFutureMonthId
			,dblFixationPrice = @dblFutures
			,dblFutures = @dblFutures
			,dblBasis = @dblBasis
			,dblCashPrice = @dblFutures + @dblBasis
			,intPricingUOMId = @intFinalPriceUOMId
			,ysnHedge = 0
			,ysnAA = 0
			,dblFinalPrice = @dblFutures + @dblBasis
			,strNotes = ''
			,ysnToBeDeleted = 0
			,intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
			,intConcurrencyId = 1


		/*Update Price Fixation record
			dblPriceWORollArb
			dblLotsFixed
			dblFinalPrice
		*/

		select
			@dblTotalPricedQuantity = sum(dblQuantity)
			,@dblTotalPricedLots = sum(dblNoOfLots)
			,@dblTotalPricedFutures = sum(dblFutures)
			,@dblTotalWeightedAvg = sum(dblNoOfLots * dblFutures)
		from
			tblCTPriceFixationDetail
		where
			intPriceFixationId = @intPriceFixationId;

		update
			tblCTPriceFixation
		set
			dblLotsFixed = @dblTotalPricedQuantity / @dblQuantityPerLot
			,dblPriceWORollArb = @dblTotalWeightedAvg / @dblTotalPricedLots
		where
			intPriceFixationId = @intPriceFixationId;

		EXEC uspCTPostProcessPriceContract @intPriceContractId = @intPriceContractId, @intUserId = @intUserId, @dtmLocalDate = default;

	end
	else
	begin
		
		select @intStartingNumberId = intStartingNumberId from tblSMStartingNumber where strModule = 'Contract Management' and strTransactionType = 'Price Contract';

		exec dbo.uspSMGetStartingNumber 
			@intStartingNumberId  = @intStartingNumberId
			,@strID	= @strPriceContractNo out
			,@intCompanyLocationId = default

		Insert into tblCTPriceContract (
			strPriceContractNo
			,intCommodityId
			,intFinalPriceUOMId
			,intFinalCurrencyId
			,intCreatedById
			,dtmCreated
			,intLastModifiedById
			,dtmLastModified
			,intConcurrencyId
			,intCompanyId
			,intPriceContractRefId
		)
		select
			strPriceContractNo = @strPriceContractNo
			,intCommodityId = @intCommodityId
			,intFinalPriceUOMId = @intFinalPriceUOMId
			,intFinalCurrencyId = @intFinalCurrencyId
			,intCreatedById = @intUserId
			,dtmCreated = getdate()
			,intLastModifiedById = @intUserId
			,dtmLastModified = getdate()
			,intConcurrencyId = 1
			,intCompanyId = null
			,intPriceContractRefId = null

		select @intPriceContractId = SCOPE_IDENTITY();

		/*Create Price Fixation record*/
		insert into tblCTPriceFixation(
			intPriceContractId
			,intConcurrencyId
			,intContractHeaderId
			,intContractDetailId
			,intOriginalFutureMarketId
			,intOriginalFutureMonthId
			,dblOriginalBasis
			,dblTotalLots
			,ysnAAPrice
			,ysnSettlementPrice
			,ysnToBeAgreed
			,dblPriceWORollArb
			,dblFinalPrice
			,intFinalPriceUOMId
			,ysnSplit
		)
		select
			intPriceContractId = @intPriceContractId
			,intConcurrencyId = 1
			,intContractHeaderId = @intContractHeaderId
			,intContractDetailId = (case when @ysnMultiplePriceFixation = 0 then @intContractDetailId else null end)
			,intOriginalFutureMarketId = @intOriginalFutureMarketId
			,intOriginalFutureMonthId = @intOriginalFutureMonthId
			,dblOriginalBasis = @dblOriginalBasis
			,dblTotalLots = @dblTotalLots
			,ysnAAPrice = 1
			,ysnSettlementPrice = 0
			,ysnToBeAgreed = 0
			,dblPriceWORollArb = @dblFutures
			,dblFinalPrice = @dblFutures + @dblBasis
			,intFinalPriceUOMId = @intFinalPriceUOMId
			,ysnSplit = 0

		select @intPriceFixationId = SCOPE_IDENTITY();		

		/*Create Price Fixation Detail record*/
		
		select @intStartingNumberId = intStartingNumberId from tblSMStartingNumber where strModule = 'Contract Management' and strTransactionType = 'Price Fixation Trade No';

		exec dbo.uspSMGetStartingNumber 
			@intStartingNumberId  = @intStartingNumberId
			,@strID	= @strTradeNo out
			,@intCompanyLocationId = default

		select @intNumber = max(intNumber) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId;
		select @intNumber = isnull(@intNumber,1);

		insert into tblCTPriceFixationDetail (
			intPriceFixationId
			,intNumber
			,strTradeNo
			,strOrder
			,dtmFixationDate
			,dblQuantity
			,intQtyItemUOMId
			,dblNoOfLots
			,intFutureMarketId
			,intFutureMonthId
			,dblFixationPrice
			,dblFutures
			,dblBasis
			,dblCashPrice
			,intPricingUOMId
			,ysnHedge
			,ysnAA
			,dblFinalPrice
			,strNotes
			,ysnToBeDeleted
			,intAssignFuturesToContractSummaryId
			,intConcurrencyId
		)
		select 
			intPriceFixationId = @intPriceFixationId
			,intNumber = @intNumber
			,strTradeNo = @strTradeNo
			,strOrder = 'Confirmed'
			,dtmFixationDate = getdate()
			,dblQuantity = @dblQuantityToPrice
			,intQtyItemUOMId = @intQtyItemUOMId
			,dblNoOfLots = @dblQuantityToPrice / @dblQuantityPerLot
			,intFutureMarketId = @intOriginalFutureMarketId
			,intFutureMonthId = @intOriginalFutureMonthId
			,dblFixationPrice = @dblFutures
			,dblFutures = @dblFutures
			,dblBasis = @dblBasis
			,dblCashPrice = @dblFutures + @dblBasis
			,intPricingUOMId = @intFinalPriceUOMId
			,ysnHedge = 0
			,ysnAA = 0
			,dblFinalPrice = @dblFutures + @dblBasis
			,strNotes = ''
			,ysnToBeDeleted = 0
			,intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
			,intConcurrencyId = 1


		/*Update Price Fixation record
			dblPriceWORollArb
			dblLotsFixed
			dblFinalPrice
		*/

		select
			@dblTotalPricedQuantity = sum(dblQuantity)
			,@dblTotalPricedLots = sum(dblNoOfLots)
			,@dblTotalPricedFutures = sum(dblFutures)
			,@dblTotalWeightedAvg = sum(dblNoOfLots * dblFutures)
		from
			tblCTPriceFixationDetail
		where
			intPriceFixationId = @intPriceFixationId;

		update
			tblCTPriceFixation
		set
			dblLotsFixed = @dblTotalPricedQuantity / @dblQuantityPerLot
			,dblPriceWORollArb = @dblTotalWeightedAvg / @dblTotalPricedLots
		where
			intPriceFixationId = @intPriceFixationId;

		EXEC uspCTPostProcessPriceContract @intPriceContractId = @intPriceContractId, @intUserId = @intUserId, @dtmLocalDate = default;

	end


end try
begin catch
	SET @ErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
end catch