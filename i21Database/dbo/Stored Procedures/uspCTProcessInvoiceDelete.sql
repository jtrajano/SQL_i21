CREATE PROCEDURE [dbo].[uspCTProcessInvoiceDelete]
	@dblInvoiceDetailQuantity numeric(18,6)
	,@intPriceFixationDetailId int
AS
BEGIN

	declare
		@dblPricedQuantity numeric(18,6)
		,@intPriceFixationId int
		,@intContractPriceId int
		,@intContractDetailId int
		,@strXML nvarchar(max)
		,@ysnLoad bit
		,@intId int
		,@intDetailId int 
		,@dblCurrentPricedQuantity numeric(18,6)
		,@dblInvoicedQuantity numeric(18,6)
		,@dblOverQuantity numeric(18,6)
		,@dblPricedLots numeric(18,6)
		,@dblForRemoveLots numeric(18,6)
		,@intCurrentPriceContractId int
		,@ErrMsg nvarchar(max);

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

	select
		@dblPricedQuantity = dblQuantity
		,@intPriceFixationId = intPriceFixationId
	from
		tblCTPriceFixationDetail
	where
		intPriceFixationDetailId = @intPriceFixationDetailId

	select @intContractPriceId = intPriceContractId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;

	set @dblPricedQuantity = isnull(@dblPricedQuantity,0)

	begin try
	
		if (@dblPricedQuantity > @dblInvoiceDetailQuantity)
		begin
			update
				tblCTPriceFixationDetail
			set
				dblNoOfLots = dblNoOfLots - (@dblInvoiceDetailQuantity / (dblQuantity / case when isnull(dblNoOfLots,0) = 0 then 1 else dblNoOfLots end))
				,dblQuantity = @dblPricedQuantity - @dblInvoiceDetailQuantity
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
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML;
				delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

				if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intContractPriceId) = 0)
				begin
					EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = 'Delete';
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
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML;
				delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
			end
		end

		update tblCTContractDetail set intPricingTypeId = 2,dblFutures = null, dblCashPrice = null,intConcurrencyId = (intConcurrencyId + 1) where intContractDetailId = @intContractDetailId;


		select @ysnLoad = isnull(ch.ysnLoad,convert(bit,0)) from tblCTContractHeader ch, tblCTContractDetail cd where cd.intContractDetailId = @intContractDetailId and ch.intContractHeaderId = cd.intContractHeaderId;

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
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = 'Delete';
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
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML;
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
						EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML;
						delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intDetailId;
						EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;
					end
				end

				select @intId = min(intId) from @PriceDetailToProcess where intId > @intId
			end

		end
    
	end try
	begin catch

		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 

	end catch

	

END