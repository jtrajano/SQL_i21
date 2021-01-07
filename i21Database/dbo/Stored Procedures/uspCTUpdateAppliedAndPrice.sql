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
			,dblCorrectQuantityAppliedAndPriced = 0.00--pfd.dblQuantityAppliedAndPriced
			,dblCorrectLoadAppliedAndPriced = 0.00--pfd.dblLoadAppliedAndPriced 
		from
			tblCTPriceFixation pf
			,tblCTPriceFixationDetail pfd
		where
			pf.intContractDetailId = @intContractDetailId
			and pfd.intPriceFixationId = pf.intPriceFixationId;

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
						update @PurchasePricing set dblCorrectQuantityAppliedAndPriced = @dblPricedQuantity where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @dblSequenceAppliedQuantity = @dblSequenceAppliedQuantity - @dblPricedQuantity;
					end
					else
					begin
						update @PurchasePricing set dblCorrectQuantityAppliedAndPriced = @dblSequenceAppliedQuantity where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @dblSequenceAppliedQuantity = 0;
					end
				end
				else
				begin
					if (@intSequenceAppliedLoad > @dblPricedLoad)
					begin
						update @PurchasePricing set dblCorrectLoadAppliedAndPriced = @dblPricedLoad where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @intSequenceAppliedLoad = @intSequenceAppliedLoad - @dblPricedLoad;
					end
					else
					begin
						update @PurchasePricing set dblCorrectLoadAppliedAndPriced = @intSequenceAppliedLoad where intPriceFixationDetailId = @intActivePriceFixationDetailId;
						select @intSequenceAppliedLoad = 0;
					end
				end

				select @intActivePriceFixationDetailId = min(intPriceFixationDetailId) from @PurchasePricing where intPriceFixationDetailId > isnull(@intActivePriceFixationDetailId,0);
			end

		end

		update
			pfd
		set
			pfd.dblQuantityAppliedAndPriced = pp.dblCorrectQuantityAppliedAndPriced
			,pfd.dblLoadAppliedAndPriced = pp.dblCorrectLoadAppliedAndPriced
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
