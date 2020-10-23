CREATE PROCEDURE [dbo].[uspCTProcessInvoiceReturn]
	@intInvoiceDetailId int				--> Invoice Detail Id
	,@intInvoiceId int					--> Invoice Id
	,@intNewInvoiceDetialId int			--> (Credit Memo) Invoice Detail Id
	,@intNewInvoiceId int				--> (Credit Memo) Invoice Id
	,@dblQuantity numeric(18,6)			--> (Credit Memo) Return Quantity

as

/*Declaration*/
declare
	@ErrMsg nvarchar(max)
	,@intNewPriceFixationDetailId int
	,@intPriceFixationDetailId int
	,@dblLoadPriced numeric(18,6)
	,@ysnLoad bit
	,@dblQuantityPerLoad numeric(18,6)
	;

begin try

	set @dblQuantity = @dblQuantity * -1;
	set @dblLoadPriced = null;

	/*Check Contract if Load Base*/
	select
		top 1
		@ysnLoad = ch.ysnLoad
		,@dblQuantityPerLoad = ch.dblQuantityPerLoad
		,@intPriceFixationDetailId = pfd.intPriceFixationDetailId
	from
		tblCTPriceFixationDetailAPAR ar
		,tblCTPriceFixationDetail pfd
		,tblCTPriceFixation pf
		,tblCTContractHeader ch
	where
		ar.intInvoiceDetailId = @intInvoiceDetailId
		and pfd.intPriceFixationDetailId = ar.intPriceFixationDetailId
		and pf.intPriceFixationId = pfd.intPriceFixationId
		and ch.intContractHeaderId = pf.intContractHeaderId

	if (isnull(@intPriceFixationDetailId,0) = 0)
	begin
		goto _return;
	end

	if (@ysnLoad = convert(bit,1))
	begin
		set @dblQuantity = @dblQuantityPerLoad * -1;
		set @dblLoadPriced = -1;
	end


	insert into tblCTPriceFixationDetail
	(
		intPriceFixationId
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
		,intConcurrencyId
	)
	select
		intPriceFixationId = pfd.intPriceFixationId
		,intNumber = (select count(a.intPriceFixationDetailId) + 1 from tblCTPriceFixationDetail a where a.intPriceFixationId = pfd.intPriceFixationId)
		,strTradeNo = pfd.strTradeNo + '-Return'
		,strOrder = pfd.strOrder
		,dtmFixationDate = pfd.dtmFixationDate
		,dblQuantity = @dblQuantity
		,dblQuantityAppliedAndPriced = 0.00
		,dblLoadAppliedAndPriced = null
		,dblLoadPriced = @dblLoadPriced
		,intQtyItemUOMId = pfd.intQtyItemUOMId
		,dblNoOfLots = pfd.dblNoOfLots
		,intFutureMarketId = pfd.intFutureMarketId
		,intFutureMonthId = pfd.intFutureMonthId
		,dblFixationPrice = pfd.dblFixationPrice
		,dblFutures = pfd.dblFutures
		,dblBasis = pfd.dblBasis
		,dblPolRefPrice = pfd.dblPolRefPrice
		,dblPolPremium = pfd.dblPolPremium
		,dblCashPrice = pfd.dblCashPrice
		,intPricingUOMId = pfd.intPricingUOMId
		,ysnHedge = null
		,ysnAA = null
		,dblHedgePrice = null
		,intHedgeFutureMonthId = null
		,intBrokerId = null
		,intBrokerageAccountId = null
		,intFutOptTransactionId = null
		,dblFinalPrice = pfd.dblFinalPrice
		,strNotes = pfd.strNotes
		,intPriceFixationDetailRefId = pfd.intPriceFixationDetailRefId
		,intBillId = pfd.intBillId
		,intBillDetailId = pfd.intBillDetailId
		,intInvoiceId = pfd.intInvoiceId
		,intInvoiceDetailId = pfd.intInvoiceDetailId
		,intDailyAveragePriceDetailId = pfd.intDailyAveragePriceDetailId
		,dblHedgeNoOfLots = null
		,dblLoadApplied = pfd.dblLoadApplied
		,ysnToBeDeleted = pfd.ysnToBeDeleted
		,intConcurrencyId = 1
	from
		tblCTPriceFixationDetailAPAR ar
		,tblCTPriceFixationDetail pfd
	where
		ar.intInvoiceDetailId = @intInvoiceDetailId
		and pfd.intPriceFixationDetailId = ar.intPriceFixationDetailId

	set @intNewPriceFixationDetailId = SCOPE_IDENTITY();
	
	exec uspCTCreatePricingAPARLink
		@intPriceFixationDetailId  = @intNewPriceFixationDetailId
		,@intHeaderId = @intNewInvoiceId
		,@intDetailId  = @intNewInvoiceDetialId
		,@intSourceHeaderId = null
		,@intSourceDetailId  = null
		,@dblQuantity = @dblQuantity
		,@strScreen = 'Invoice'

	_return:

end try
begin catch
	set @ErrMsg = ERROR_MESSAGE()  
	raiserror (@ErrMsg,18,1,'WITH NOWAIT')  
end catch