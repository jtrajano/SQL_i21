CREATE PROCEDURE uspCTCreatePrice
	@intContractDetailId int
	,@dblQuantityToPrice numeric(18,6)
	,@dblFutures numeric(18,6)
	,@intUserId int
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
		@dblSequenceQuantity = cd.dblQuantity
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
		,@intFinalPriceUOMId = ium.intUnitMeasureId
		,@intFinalCurrencyId = cd.intCurrencyId
		,@intOriginalFutureMarketId =  cd.intFutureMarketId
		,@intOriginalFutureMonthId = cd.intFutureMonthId
		,@dblOriginalBasis = cd.dblOriginalBasis
		,@dblTotalLots = cd.dblNoOfLots
		,@dblLotsFixed = @dblTotalLots
		,@intQtyItemUOMId = cd.intItemUOMId
		,@dblQuantityPerLot = cd.dblQuantity / cd.dblNoOfLots
	from
		tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		left join tblCTPriceFixation pf on pf.intContractDetailId = cd.intContractDetailId
		left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
		left join tblICItemUOM ium on ium.intItemUOMId = cd.intPriceItemUOMId
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
		set @ysnWithError = 1;
		set @ErrorMsg = 'There''s no available quantity to price for contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + '.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
	end

	if ((@dblSequenceQuantity - @dblTotalPricedQuantity) < @dblQuantityToPrice)
	begin
		set @ysnWithError = 1;
		set @ErrorMsg = 'There''s only ' + convert(nvarchar(50),(@dblSequenceQuantity - @dblTotalPricedQuantity)) + ' available quantity for pricing for contract ' + @strContractNumber + ', sequence ' + convert(nvarchar(20),@intContractSeq) + '' + '.';
		RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
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
			,intConcurrencyId = 1


		/*Update Price Fixation record
			dblPriceWORollArb
			dblLotsFixed
			dblFinalPrice
		*/

		select @dblTotalPricedQuantity = sum(dblQuantity) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId;
		update tblCTPriceFixation set dblLotsFixed = @dblTotalPricedQuantity / @dblQuantityPerLot where  intPriceFixationId = @intPriceFixationId;

		--exec dbo.uspCTUpdateAppliedAndPrice @intContractDetailId = @intContractDetailId, @dblBalance = @dblBalance;
		EXEC uspCTSavePriceContract @intPriceContractId = @intPriceContractId, @strXML = '', @dtmLocalDate = default;

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
			,intContractDetailId = @intContractDetailId
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
			,intConcurrencyId = 1


		/*Update Price Fixation record
			dblPriceWORollArb
			dblLotsFixed
			dblFinalPrice
		*/

		select @dblTotalPricedQuantity = sum(dblQuantity) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId;
		update tblCTPriceFixation set dblLotsFixed = @dblTotalPricedQuantity / @dblQuantityPerLot where  intPriceFixationId = @intPriceFixationId;

		--exec dbo.uspCTUpdateAppliedAndPrice @intContractDetailId = @intContractDetailId, @dblBalance = @dblBalance;
		EXEC uspCTSavePriceContract @intPriceContractId = @intPriceContractId, @strXML = '', @dtmLocalDate = default;

	end


end try
begin catch
	SET @ErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
end catch