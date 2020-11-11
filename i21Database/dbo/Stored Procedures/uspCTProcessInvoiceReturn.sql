CREATE PROCEDURE [dbo].[uspCTProcessInvoiceReturn]
	@intInvoiceDetailId int				--> Invoice Detail Id
	,@intInvoiceId int					--> Invoice Id
	,@intNewInvoiceDetialId int			--> (Credit Memo) Invoice Detail Id
	,@intNewInvoiceId int				--> (Credit Memo) Invoice Id
	,@dblQuantity numeric(18,6)			--> (Credit Memo) Return Quantity

as

declare
	@ErrMsg nvarchar(max)
	,@intContractDetailId int
	;

begin try

	select @intContractDetailId = intContractDetailId from tblARInvoiceDetail where intInvoiceDetailId = @intInvoiceDetailId;
	
	if (isnull(@intContractDetailId,0) = 0) goto _exit;

	update
		pfd
	set
		pfd.dblQuantityAppliedAndPriced = rd.dblInvoiceQuantityAppliedAndPriced
		,pfd.dblLoadAppliedAndPriced = rd.dblInvoiceLoadAppliedAndPriced
	from
		tblCTPriceFixationDetail pfd 
		join (
			select
				pfd.intPriceFixationDetailId
				,pfd.intNumber
				,pfd.dblQuantity
				,pfd.dblQuantityAppliedAndPriced
				,dblInvoiceQuantityAppliedAndPriced = sum(iq.dblQtyShipped)
				,pfd.dblLoadPriced
				,pfd.dblLoadAppliedAndPriced
				,dblInvoiceLoadAppliedAndPriced = convert(numeric(18,6),count(iq.intInvoiceDetailId))
			from
				tblCTPriceFixation pf
				join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
				join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				left join (
					select di.intInvoiceDetailId, di.dblQtyShipped from tblARInvoiceDetail di where di.intInventoryShipmentChargeId is null and isnull(di.ysnReturned,0) = 0
				) iq on iq.intInvoiceDetailId = ar.intInvoiceDetailId
			where
				pf.intContractDetailId = @intContractDetailId
			group by
				pfd.intPriceFixationDetailId
				,pfd.intNumber
				,pfd.dblQuantity
				,pfd.dblQuantityAppliedAndPriced
				,pfd.dblLoadPriced
				,pfd.dblLoadAppliedAndPriced
		) rd  on rd.intPriceFixationDetailId = pfd.intPriceFixationDetailId
	where
		isnull(pfd.dblQuantityAppliedAndPriced,0) <> isnull(rd.dblInvoiceQuantityAppliedAndPriced,0)
		or isnull(pfd.dblLoadAppliedAndPriced,0) <> isnull(rd.dblInvoiceLoadAppliedAndPriced,0)

	delete
		ar
	from
		tblCTPriceFixation pf
		join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
		join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
		join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
	where
		pf.intContractDetailId = @intContractDetailId
		and isnull(di.ysnReturned,0) = 1

	_exit:

end try
begin catch
	set @ErrMsg = ERROR_MESSAGE()  
	raiserror (@ErrMsg,18,1,'WITH NOWAIT')  
end catch