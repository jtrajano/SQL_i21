CREATE PROCEDURE [dbo].[uspCTProcessInvoiceDelete]
	@dblInvoiceDetailQuantity numeric(18,6)
	,@intPriceFixationDetailId int
	,@UserId int = null
AS
BEGIN

	declare
		@dblPricedQuantity numeric(18,6)
		,@intPriceFixationId int
		,@intContractPriceId int
		,@intContractDetailId int
		,@strXML nvarchar(max)
		,@ysnLoad bit
		,@dblQuantityPerLoad numeric(18,6)
		,@intId int
		,@intDetailId int 
		,@dblCurrentPricedQuantity numeric(18,6)
		,@dblInvoicedQuantity numeric(18,6)
		,@dblOverQuantity numeric(18,6)
		,@dblPricedLots numeric(18,6)
		,@dblForRemoveLots numeric(18,6)
		,@intCurrentPriceContractId int
		,@ErrMsg nvarchar(max)

		,@dblQuantityPerLot numeric(18,6)
		,@dblLoadPriced numeric(18,6)
		,@intNoOfInvoices int
		,@dblForRemoveLoad numeric(18,6);

	declare @PriceDetailToProcess table (
		intId int
		,intPriceFixationDetailId int
		,dblPricedQuantity numeric(18,6)
		,dblInvoicedQuantity numeric(18,6)
		,dblOverQuantity numeric(18,6)
		,dblPricedLots numeric(18,6)
		,dblForRemoveLots numeric(18,6)
		,intCurrentPriceContractId int
	)

	declare @PriceDetailToProcessLoad table (
		intId int
		,intPriceFixationDetailId int
		,dblNoOfLots numeric(18,6)
		,dblQuantityPerLot numeric(18,6)
		,dblQuantity numeric(18,6)
		,dblLoadPriced numeric(18,6)
		,dblQuantityPerLoad numeric(18,6)
		,intNoOfInvoices int
		,dblForRemoveLoad numeric(18,6)
		,dblForRemoveQuantity numeric(18,6)
		,dblForRemoveLots numeric(18,6)
	)

	select
		@dblPricedQuantity = dblQuantity
		,@intPriceFixationId = intPriceFixationId
	from
		tblCTPriceFixationDetail
	where
		intPriceFixationDetailId = @intPriceFixationDetailId

	select @intContractPriceId = intPriceContractId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;

	select @ysnLoad = isnull(ch.ysnLoad,convert(bit,0)), @dblQuantityPerLoad = isnull(ch.dblQuantityPerLoad,0.00) from tblCTContractHeader ch, tblCTContractDetail cd where cd.intContractDetailId = @intContractDetailId and ch.intContractHeaderId = cd.intContractHeaderId;

	if (@ysnLoad = convert(bit,1))
	begin
		set @dblInvoiceDetailQuantity =  @dblQuantityPerLoad;
	end

	set @dblPricedQuantity = isnull(@dblPricedQuantity,0)

	begin try
	
		if (@dblPricedQuantity > @dblInvoiceDetailQuantity)
		begin
			update
				tblCTPriceFixationDetail
			set
				dblNoOfLots = dblNoOfLots - (@dblInvoiceDetailQuantity / (dblQuantity / case when isnull(dblNoOfLots,0) = 0 then 1 else dblNoOfLots end))
				,dblQuantity = dblQuantity - @dblInvoiceDetailQuantity
				,dblLoadPriced = (case when @ysnLoad = convert(bit,1) then dblLoadPriced - 1 else dblLoadPriced end)
			where
				intPriceFixationDetailId = @intPriceFixationDetailId;

			EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
		end
		else
		begin

			if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
			begin
				set @strXML = '<tblCTPriceFixations>
									<tblCTPriceFixation>
										<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
										<strRowState>Delete</strRowState>
									</tblCTPriceFixation>
								</tblCTPriceFixations>';
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
				delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

				if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intContractPriceId) = 0)
				begin
					EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
					delete from tblCTPriceContract where intPriceContractId = @intContractPriceId;
					EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
				end
			end
			else
			begin
				set @strXML = '<tblCTPriceFixationDetails>
									<tblCTPriceFixationDetail>
										<intPriceFixationDetailId>' + convert(nvarchar(20),@intPriceFixationDetailId) + '</intPriceFixationDetailId>
										<strRowState>Delete</strRowState>
									</tblCTPriceFixationDetail>
								</tblCTPriceFixationDetails>';
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
				delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
			end
		end

		update tblCTContractDetail set intPricingTypeId = 2,dblFutures = null, dblCashPrice = null,intConcurrencyId = (intConcurrencyId + 1) where intContractDetailId = @intContractDetailId;

		if (@ysnLoad = convert(bit,0))
		begin

			insert into @PriceDetailToProcess
			select
				intId = convert(int,ROW_NUMBER() over (order by intDetailId))
				,intPriceFixationDetailId = intDetailId
				,dblPricedQuantity = dblCurrentPricedQuantity
				,dblInvoicedQuantity
				,dblOverQuantity = dblCurrentPricedQuantity - dblInvoicedQuantity
				,dblPricedLots
				,dblForRemoveLots = (dblCurrentPricedQuantity - dblInvoicedQuantity) / (dblCurrentPricedQuantity / case when isnull(dblPricedLots,0) = 0 then 1 else dblPricedLots end)
				,intCurrentPriceContractId
			from
			(
			select
				intDetailId = pfd.intPriceFixationDetailId
				,dblCurrentPricedQuantity = pfd.dblQuantity
				,dblPricedLots = pfd.dblNoOfLots
				,dblInvoicedQuantity = sum(isnull(di.dblQtyShipped,0))
				,intCurrentPriceContractId = pf.intPriceContractId
			from
				tblCTPriceFixationDetail pfd
				join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
				left join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				left join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
			where
				pfd.intPriceFixationId = @intPriceFixationId
			group by
				pfd.intPriceFixationDetailId
				,pfd.dblQuantity
				,pfd.dblNoOfLots
				,pf.intPriceContractId
			)tbl
			where dblCurrentPricedQuantity > dblInvoicedQuantity

			select @intId = min(intId) from @PriceDetailToProcess

			while @intId is not null
			begin

				select
					@intDetailId = intPriceFixationDetailId
					,@dblCurrentPricedQuantity = dblPricedQuantity
					,@dblInvoicedQuantity = dblInvoicedQuantity
					,@dblOverQuantity = dblOverQuantity
					,@dblPricedLots = dblPricedLots
					,@dblForRemoveLots = dblForRemoveLots
					,@intCurrentPriceContractId = intCurrentPriceContractId
				from @PriceDetailToProcess where intId = @intId

				if (@dblCurrentPricedQuantity <> @dblInvoicedQuantity and @dblInvoicedQuantity > 0)
				begin
					update
						tblCTPriceFixationDetail
					set
						dblNoOfLots = dblNoOfLots - @dblForRemoveLots
						,dblQuantity = @dblInvoicedQuantity
					where
						intPriceFixationDetailId = @intDetailId;

					EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
				end
				else
				begin
					if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
					begin
						if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intCurrentPriceContractId) = 1)
						begin
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceContract where intPriceContractId = @intCurrentPriceContractId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
						end
						else
						begin
							set @strXML = '<tblCTPriceFixations>
												<tblCTPriceFixation>
													<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
													<strRowState>Delete</strRowState>
												</tblCTPriceFixation>
											</tblCTPriceFixations>';
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
						end
					end
					else
					begin
						set @strXML = '<tblCTPriceFixationDetails>
											<tblCTPriceFixationDetail>
												<intPriceFixationDetailId>' + convert(nvarchar(20),@intDetailId) + '</intPriceFixationDetailId>
												<strRowState>Delete</strRowState>
											</tblCTPriceFixationDetail>
										</tblCTPriceFixationDetails>';
						EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
						delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intDetailId;
						EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
					end
				end

				select @intId = min(intId) from @PriceDetailToProcess where intId > @intId
			end

		end
		else
		begin

			insert into @PriceDetailToProcessLoad
			select * from
			(
			select
				intId = convert(int,ROW_NUMBER() over (order by intPriceFixationDetailId))
				,intPriceFixationDetailId
				,dblNoOfLots
				,dblQuantityPerLot = dblQuantity / dblNoOfLots
				,dblQuantity
				,dblLoadPriced
				,dblQuantityPerLoad
				,intNoOfInvoices
				,dblForRemoveLoad = dblLoadPriced - intNoOfInvoices
				,dblForRemoveQuantity = (dblLoadPriced - intNoOfInvoices) * dblQuantityPerLoad
				,dblForRemoveLots = ((dblLoadPriced - intNoOfInvoices) * dblQuantityPerLoad) / (dblQuantity / dblNoOfLots)
			from
			(
			select
				pfd.intPriceFixationDetailId
				,pfd.dblNoOfLots
				,pfd.dblQuantity
				,pfd.dblLoadPriced
				,dblQuantityPerLoad = @dblQuantityPerLoad
				,intNoOfInvoices = count(ar.intPriceFixationDetailAPARId)
			from
				tblCTPriceFixation pf
				join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
				left join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
			where
				pf.intPriceFixationId = @intPriceFixationId
			group by
				pfd.intPriceFixationDetailId
				,pfd.dblNoOfLots
				,pfd.dblQuantity
				,pfd.dblLoadPriced
			) tbl
			)tbl1
			where tbl1.dblForRemoveQuantity > 0

			select @intId = min(intId) from @PriceDetailToProcessLoad

			while @intId is not null
			begin

				select
					@intDetailId = intPriceFixationDetailId
					,@dblPricedLots = dblNoOfLots
					,@dblQuantityPerLot = dblQuantityPerLot
					,@dblPricedQuantity = dblQuantity
					,@dblLoadPriced = dblLoadPriced
					,@dblQuantityPerLoad = @dblQuantityPerLoad
					,@intNoOfInvoices = intNoOfInvoices
					,@dblForRemoveLoad = dblForRemoveLoad
					,@dblOverQuantity = dblForRemoveQuantity
					,@dblForRemoveLots = dblForRemoveLots
				from @PriceDetailToProcessLoad where intId = @intId

				if (@dblLoadPriced > @dblForRemoveLoad and @dblForRemoveLoad > 0)
				begin
					update
						tblCTPriceFixationDetail
					set
						dblNoOfLots = dblNoOfLots - @dblForRemoveLots
						,dblQuantity = dblQuantity - @dblOverQuantity
						,dblLoadPriced = dblLoadPriced - @dblForRemoveLoad
					where
						intPriceFixationDetailId = @intDetailId;

					EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
				end
				else
				begin
					if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
					begin
						if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intCurrentPriceContractId) = 1)
						begin
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceContract where intPriceContractId = @intCurrentPriceContractId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
						end
						else
						begin
							set @strXML = '<tblCTPriceFixations>
												<tblCTPriceFixation>
													<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
													<strRowState>Delete</strRowState>
												</tblCTPriceFixation>
											</tblCTPriceFixations>';
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
						end
					end
					else
					begin
						set @strXML = '<tblCTPriceFixationDetails>
											<tblCTPriceFixationDetail>
												<intPriceFixationDetailId>' + convert(nvarchar(20),@intDetailId) + '</intPriceFixationDetailId>
												<strRowState>Delete</strRowState>
											</tblCTPriceFixationDetail>
										</tblCTPriceFixationDetails>';
						EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
						delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intDetailId;
						EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
					end
				end

				select @intId = min(intId) from @PriceDetailToProcessLoad where intId > @intId
			end

		end

		update
			pf
		set
			pf.dblLotsFixed = tbl.dblLotsFixed
		from tblCTPriceFixation pf
			left join
			(
			select
				pfd.intPriceFixationId
				,dblLotsFixed = sum(pfd.dblNoOfLots)
			from
				tblCTPriceFixationDetail pfd
			group by
				pfd.intPriceFixationId
			) tbl on tbl.intPriceFixationId = pf.intPriceFixationId
		where
			pf.intPriceFixationId = @intPriceFixationId;
    
	end try
	begin catch

		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 

	end catch

	

END