CREATE PROCEDURE [dbo].[uspCTUpdateAppliedAndPrice]
	@intContractDetailId int
	,@dblBalance numeric(18,6)
as

	declare
		@errorMessage nvarchar(max)
		,@intPricingTypeId int
		,@intContractTypeId int
		,@ysnLoad bit
		,@dblQuantityPerLoad numeric(18,6)
		,@intActivePriceFixationDetailId int
		,@dblSequenceQuantity numeric(18,6)
		,@dblSequenceAppliedQuantity numeric(18,6)
		,@intSequenceLoad numeric(18,6)
		,@intSequenceAppliedLoad numeric(18,6)
		,@dblPricedLoad numeric(18,6)
		,@dblPricedQuantity numeric(18,6)
		;

	declare @PurchasePricing table (
			intPriceFixationDetailId int
			,dblQuantity numeric(18,6)
			,dblQuantityAppliedAndPriced numeric(18,6) null
			,dblLoadPriced numeric(18,6) null
			,dblLoadApplied numeric(18,6) null
			,dblLoadAppliedAndPriced numeric(18,6) null
			,dblCorrectQuantityAppliedAndPriced numeric(18,6) null
			,dblCorrectLoadAppliedAndPriced numeric(18,6) null
	)

	begin try

		select
			@intPricingTypeId = ch.intPricingTypeId
			,@intContractTypeId = ch.intContractTypeId
			,@ysnLoad = ch.ysnLoad
			,@dblQuantityPerLoad = ch.dblQuantityPerLoad
			,@dblSequenceQuantity = cd.dblQuantity
			,@dblSequenceAppliedQuantity = (cd.dblQuantity - @dblBalance)
			,@intSequenceLoad = cd.intNoOfLoad
			,@intSequenceAppliedLoad = (cd.intNoOfLoad - convert(int,@dblBalance))
		from
			tblCTContractDetail cd
			,tblCTContractHeader ch
		where
			cd.intContractDetailId = @intContractDetailId
			and ch.intContractHeaderId = cd.intContractHeaderId

		insert into @PurchasePricing (
			intPriceFixationDetailId
			,dblQuantity
			,dblQuantityAppliedAndPriced
			,dblLoadPriced
			,dblLoadApplied
			,dblLoadAppliedAndPriced
			,dblCorrectQuantityAppliedAndPriced
			,dblCorrectLoadAppliedAndPriced
		)
		select
			intPriceFixationDetailId = pfd.intPriceFixationDetailId
			,dblQuantity = pfd.dblQuantity
			,dblQuantityAppliedAndPriced = pfd.dblQuantityAppliedAndPriced
			,dblLoadPriced = pfd.dblLoadPriced
			,dblLoadApplied = pfd.dblLoadApplied
			,dblLoadAppliedAndPriced = pfd.dblLoadAppliedAndPriced 
			,dblCorrectQuantityAppliedAndPriced = 0.00
			,dblCorrectLoadAppliedAndPriced = 0.00
		from
			tblCTPriceFixation pf
			join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
			outer apply (
				select
					tbl.intPriceFixationDetailId
					,dblQuantityApplied = sum(tbl.dblQuantityApplied)
					,dblLoadApplied = sum(tbl.dblLoadApplied)
				from
				(
					select
						a.intPriceFixationDetailId
						,dblQuantityApplied = isnull(ap.dblApplied,ar.dblApplied)
						,dblLoadApplied = case when isnull(ap.dblApplied,ar.dblApplied) is null then 0 else 1 end
					from
						tblCTPriceFixationDetailAPAR a
						outer apply (select dblApplied = sum(b.dblQtyReceived) from tblAPBillDetail b where b.intBillDetailId = a.intBillDetailId) ap
						outer apply (select dblApplied = sum(b.dblQtyShipped) from tblARInvoiceDetail b where b.intInvoiceDetailId = a.intInvoiceDetailId and isnull(b.ysnReturned,0) = 0) ar
					where isnull(a.ysnReturn,0) = 0
				) tbl
				where
					tbl.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				group by
					tbl.intPriceFixationDetailId
			) applied
		where
			pf.intContractDetailId = @intContractDetailId;			

		if exists (select top 1 1 from @PurchasePricing)
		begin
			select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from @PurchasePricing where intPriceFixationDetailId > isnull(@intActivePriceFixationDetailId,0);
			while (@intActivePriceFixationDetailId is not null and @intActivePriceFixationDetailId > 0)
			begin
				select @dblPricedLoad = dblLoadPriced, @dblPricedQuantity = dblQuantity from @PurchasePricing where intPriceFixationDetailId = @intActivePriceFixationDetailId;
				if (isnull(@ysnLoad,0) = 0)
				begin
					if (@dblSequenceAppliedQuantity > @dblPricedQuantity)
					begin
						update @PurchasePricing set dblCorrectQuantityAppliedAndPriced = case when isnull(dblCorrectQuantityAppliedAndPriced,0) = 0 then @dblPricedQuantity else dblCorrectQuantityAppliedAndPriced end where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @dblSequenceAppliedQuantity = @dblSequenceAppliedQuantity - @dblPricedQuantity;
					end
					else
					begin
						update @PurchasePricing set dblCorrectQuantityAppliedAndPriced = case when isnull(dblCorrectQuantityAppliedAndPriced,0) = 0 then (case when @dblSequenceAppliedQuantity > @dblPricedQuantity then @dblPricedQuantity else @dblSequenceAppliedQuantity end) else dblCorrectQuantityAppliedAndPriced end where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @dblSequenceAppliedQuantity = case when @dblSequenceAppliedQuantity - @dblPricedQuantity < 0 then 0 else @dblSequenceAppliedQuantity - @dblPricedQuantity end;
					end
				end
				else
				begin
					if (@intSequenceAppliedLoad > @dblPricedLoad)
					begin
						update @PurchasePricing set dblCorrectLoadAppliedAndPriced = case when isnull(dblCorrectLoadAppliedAndPriced,0) = 0 then @dblPricedLoad else dblCorrectLoadAppliedAndPriced end where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @intSequenceAppliedLoad = @intSequenceAppliedLoad - @dblPricedLoad;
					end
					else
					begin
						update @PurchasePricing set dblCorrectLoadAppliedAndPriced = case when isnull(dblCorrectLoadAppliedAndPriced,0) = 0 then @intSequenceAppliedLoad else dblCorrectLoadAppliedAndPriced end where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @intSequenceAppliedLoad = 0;
					end
				end

				select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from @PurchasePricing where intPriceFixationDetailId > isnull(@intActivePriceFixationDetailId,0);
			end

		end

		update
			pfd
		set
			pfd.dblQuantityAppliedAndPriced = case when pfd.dblQuantity > pp.dblCorrectQuantityAppliedAndPriced then pp.dblCorrectQuantityAppliedAndPriced else pfd.dblQuantity end
			,pfd.dblLoadAppliedAndPriced = case when pfd.dblLoadPriced > pp.dblCorrectLoadAppliedAndPriced then pp.dblCorrectLoadAppliedAndPriced else pfd.dblLoadPriced end
		from
			tblCTPriceFixationDetail pfd
			,@PurchasePricing pp
		where
			pfd.intPriceFixationDetailId = pp.intPriceFixationDetailId
			and (
					pp.dblQuantityAppliedAndPriced <> pp.dblCorrectQuantityAppliedAndPriced
					or pp.dblLoadAppliedAndPriced <> pp.dblCorrectLoadAppliedAndPriced
				)

	end try
	begin catch
		SET @errorMessage = ERROR_MESSAGE();  
		RAISERROR (@errorMessage,18,1,'WITH NOWAIT'); 
	end catch