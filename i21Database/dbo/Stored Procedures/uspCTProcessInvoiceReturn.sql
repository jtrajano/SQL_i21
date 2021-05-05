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
	,@intPriceFixationDetailId int
	,@ysnLoad bit
	,@dblQuantityPerLoad numeric(18,6)
	,@intPricingTypeId int
	,@intContractDetailId int
	,@intPriceFixationId int
	,@dblQuantityPerLot numeric(18,6)
	;

begin try


	/*Check Contract if Load Base*/
	select
		top 1
		@ysnLoad = ch.ysnLoad
		,@dblQuantityPerLoad = ch.dblQuantityPerLoad
		,@intPriceFixationDetailId = pfd.intPriceFixationDetailId
		,@intPricingTypeId = ch.intPricingTypeId
		,@intContractDetailId = pf.intContractDetailId
		,@dblQuantityPerLot = cd.dblQuantity / cd.dblNoOfLots
		,@intPriceFixationId = pf.intPriceFixationId
	from
		tblCTPriceFixationDetailAPAR ar
		,tblCTPriceFixationDetail pfd
		,tblCTPriceFixation pf
		,tblCTContractHeader ch
		,tblCTContractDetail cd
	where
		ar.intInvoiceDetailId = @intInvoiceDetailId
		and pfd.intPriceFixationDetailId = ar.intPriceFixationDetailId
		and pf.intPriceFixationId = pfd.intPriceFixationId
		and ch.intContractHeaderId = pf.intContractHeaderId
		and cd.intContractDetailId = pf.intContractDetailId

	if (isnull(@intPriceFixationDetailId,0) = 0)
	begin
		goto _return;
	end

	--update tblCTContractDetail set dblCashPrice = null, dblFutures = null,intPricingTypeId = @intPricingTypeId where intContractDetailId = @intContractDetailId;
	--update tblCTPriceFixation set dblFinalPrice = null, dblLotsFixed = dblTotalLots - (@dblQuantity / @dblQuantityPerLot) where intPriceFixationId = @intPriceFixationId;
	update tblCTPriceFixationDetailAPAR set ysnReturn = 1 where intInvoiceDetailId = @intInvoiceDetailId;

	set @dblQuantity = @dblQuantity * -1;

	if (@ysnLoad = convert(bit,1))
	begin
		set @dblQuantity = @dblQuantityPerLoad * -1;
	end

	exec uspCTCreatePricingAPARLink
		@intPriceFixationDetailId  = @intPriceFixationDetailId
		,@intHeaderId = @intNewInvoiceId
		,@intDetailId  = @intNewInvoiceDetialId
		,@intSourceHeaderId = null
		,@intSourceDetailId  = null
		,@dblQuantity = @dblQuantity
		,@strScreen = 'Invoice'
		,@ysnReturn = 1

	_return:

end try
begin catch
	set @ErrMsg = ERROR_MESSAGE()  
	raiserror (@ErrMsg,18,1,'WITH NOWAIT')  
end catch