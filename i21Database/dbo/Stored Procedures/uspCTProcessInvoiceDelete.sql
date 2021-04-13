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
		,@dblForRemoveLoad numeric(18,6)
		,@details nvarchar(max)
		,@intPriceLayer int
		,@strPriceContractNo nvarchar(50)

		,@dblPricedQuantityOld numeric(18,6)
		,@dblNoOfLotsOld numeric(18,6)
		,@dblLoadPricedOld numeric(18,6)
		,@dblPricedQuantityNew numeric(18,6)
		,@dblNoOfLotsNew numeric(18,6)
		,@dblLoadPricedNew numeric(18,6)
		,@strLoadPricedChange nvarchar(max)
		,@dblLoadAppliedAndPricedOld numeric(18,6)
		,@dblLoadAppliedAndPricedNew numeric(18,6);
		--,@intRemovedInvoice int = 0;

	declare @PriceDetailToProcess table (
		intId int
		,intPriceFixationDetailId int
		,dblPricedQuantity numeric(18,6)
		,dblInvoicedQuantity numeric(18,6)
		,dblOverQuantity numeric(18,6)
		,dblPricedLots numeric(18,6)
		,dblForRemoveLots numeric(18,6)
		,intCurrentPriceContractId int
		,intNumber int
		,strPriceContractNo nvarchar(50)
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
		,intNumber int
		,strPriceContractNo nvarchar(50)
	)

	select
		@dblPricedQuantity = dblQuantity
		,@intPriceFixationId = intPriceFixationId
		,@intPriceLayer = intNumber
	from
		tblCTPriceFixationDetail
	where
		intPriceFixationDetailId = @intPriceFixationDetailId

	select @intContractPriceId = intPriceContractId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
	select @strPriceContractNo = strPriceContractNo from tblCTPriceContract where intPriceContractId = @intContractPriceId;

	select @ysnLoad = isnull(ch.ysnLoad,convert(bit,0)), @dblQuantityPerLoad = isnull(ch.dblQuantityPerLoad,0.00) from tblCTContractHeader ch, tblCTContractDetail cd where cd.intContractDetailId = @intContractDetailId and ch.intContractHeaderId = cd.intContractHeaderId;

	if (@ysnLoad = convert(bit,1))
	begin
		set @dblInvoiceDetailQuantity =  @dblQuantityPerLoad;
	end

	set @dblPricedQuantity = isnull(@dblPricedQuantity,0)

	begin try
	
		if (@dblPricedQuantity > @dblInvoiceDetailQuantity)
		begin

			select
				@dblNoOfLotsOld = dblNoOfLots
				,@dblPricedQuantityOld = dblQuantity
				,@dblLoadPricedOld = dblLoadPriced
				,@dblLoadAppliedAndPricedOld = dblLoadAppliedAndPriced
				,@dblNoOfLotsNew = (dblQuantity - @dblInvoiceDetailQuantity) / (dblQuantity / (case when isnull(dblNoOfLots,0) = 0 then 1 else dblNoOfLots end))
				,@dblPricedQuantityNew = dblQuantity - @dblInvoiceDetailQuantity
				,@dblLoadPricedNew = (case when @ysnLoad = convert(bit,1) then dblLoadPriced - 1 else dblLoadPriced end)
				,@dblLoadAppliedAndPricedNew = (case when @ysnLoad = convert(bit,1) then dblLoadAppliedAndPriced - 1 else dblLoadAppliedAndPriced end)
			from
				tblCTPriceFixationDetail
			where
				intPriceFixationDetailId = @intPriceFixationDetailId;

			update
				tblCTPriceFixationDetail
			set
				dblNoOfLots = @dblNoOfLotsNew				--dblNoOfLots - (@dblInvoiceDetailQuantity / (dblQuantity / case when isnull(dblNoOfLots,0) = 0 then 1 else dblNoOfLots end))
				,dblQuantity = @dblPricedQuantityNew		--dblQuantity - @dblInvoiceDetailQuantity
				,dblLoadPriced = @dblLoadPricedNew			--(case when @ysnLoad = convert(bit,1) then dblLoadPriced - 1 else dblLoadPriced end)
				,dblLoadAppliedAndPriced = @dblLoadAppliedAndPricedNew
			where
				intPriceFixationDetailId = @intPriceFixationDetailId;

			EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

			set @strLoadPricedChange = '';

			if (@ysnLoad = convert(bit,1))
			begin
				--set @intRemovedInvoice = 1; --this will used if there's a priced quantity that's no invoice yet.
				set @strLoadPricedChange = '
					,
					{
						"change": "Load Priced"
						,"from": "' + convert(nvarchar(50),@dblLoadPricedOld) + '"
						,"to": "' + convert(nvarchar(50),@dblLoadPricedNew) + ' "
						,"leaf": true
						,"iconCls": "small-gear"
					},
					{
						"change": "Load Applied & Priced"
						,"from": "' + convert(nvarchar(50),@dblLoadAppliedAndPricedOld) + '"
						,"to": "' + convert(nvarchar(50),@dblLoadAppliedAndPricedNew) + ' "
						,"leaf": true
						,"iconCls": "small-gear"
					}
				';
			end


			set @details = '
				{
					"change": "tblCTPriceFixation"
					,"iconCls":"small-tree-grid"
					,"changeDescription": "Details"
					,"children": [
						{
							"change": "tblCTPriceFixationDetail"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Pricing"
							,"children": [
								{
									"action": "Updated"
									,"change": "Updated - Record: Price Layer ' + convert(nvarchar(20),@intPriceLayer)+ '"
									,"iconCls": "small-tree-modified"
									,"children": [
										{
											"change": "No. of Lots"
											,"from": "' + convert(nvarchar(50),@dblNoOfLotsOld) + '"
											,"to": "' + convert(nvarchar(50),@dblNoOfLotsNew) + ' "
											,"leaf": true
											,"iconCls": "small-gear"
										},
										{
											"change": "Quantity"
											,"from": "' + convert(nvarchar(50),@dblPricedQuantityOld) + '"
											,"to": "' + convert(nvarchar(50),@dblPricedQuantityNew) + ' "
											,"leaf": true
											,"iconCls": "small-gear"
										}' + @strLoadPricedChange + '
									]
								}
							]
						}
					]
				}
			'

			EXEC uspSMAuditLog
			@screenName = 'ContractManagement.view.PriceContracts',
			@entityId = @UserId,
			@actionType = 'Updated',
			@actionIcon = 'small-tree-modified',
			@keyValue = @intContractPriceId,
			@details = @details

		end
		else
		begin

			if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
			begin
				update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd where pfd.intPriceFixationId = @intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
				set @strXML = '<tblCTPriceFixations>
									<tblCTPriceFixation>
										<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
										<strRowState>Delete</strRowState>
									</tblCTPriceFixation>
								</tblCTPriceFixations>';
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
				delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

				set @details = '
					{
						"change": "tblCTPriceFixation"
						,"iconCls": "small-tree-grid"
						,"changeDescription": "Details"
						,"children": [
							{
								"action": "Deleted"
								,"change": "Deleted-Record: Price Fixation '+CAST(@intPriceFixationId as varchar(15))+'"
								,"keyValue": '+CAST(@intPriceFixationId as varchar(15))+'
								,"iconCls": "small-tree-grid"
								,"leaf": true
							}
						]
					}
				';

				EXEC uspSMAuditLog
				@screenName = 'ContractManagement.view.PriceContracts',
				@entityId = @UserId,
				@actionType = 'Updated',
				@actionIcon = 'small-tree-modified',
				@keyValue = @intContractPriceId,
				@details = @details

				if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intContractPriceId) = 0)
				begin
					update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd, tblCTPriceFixation pf where pf.intPriceContractId = @intContractPriceId and pfd.intPriceFixationId = pf.intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
					EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
					delete from tblCTPriceContract where intPriceContractId = @intContractPriceId;
					EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

					EXEC dbo.uspSMAuditLog 
						 @keyValue			= @intContractPriceId
						,@screenName		= 'ContractManagement.view.PriceContracts'
						,@entityId			= @UserId
						,@actionType		= 'Deleted'
						,@changeDescription	= ''
						,@fromValue			= ''
						,@toValue			= ''

				end
			end
			else
			begin
				update tblCTPriceFixationDetailAPAR set ysnMarkDelete = 1 where intPriceFixationDetailId = @intPriceFixationDetailId;
				set @strXML = '<tblCTPriceFixationDetails>
									<tblCTPriceFixationDetail>
										<intPriceFixationDetailId>' + convert(nvarchar(20),@intPriceFixationDetailId) + '</intPriceFixationDetailId>
										<strRowState>Delete</strRowState>
									</tblCTPriceFixationDetail>
								</tblCTPriceFixationDetails>';
				EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
				delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId;
				EXEC uspCTSavePriceContract @intPriceContractId = @intContractPriceId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

				--set @details = '{"change": "tblCTPriceFixationDetail", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted-Record: '+CAST(@InvoiceDetailId as varchar(15))+'", "keyValue": '+CAST(@InvoiceDetailId as varchar(15))+', "iconCls": "small-new-minus", "leaf": true}]}';
				set @details = '
					{
						"actionType": "Updated"
						,"change": "tblCTPriceFixation"
						,"iconCls": "small-tree-grid"
						,"changeDescription": "Details"
						,"children": [
							{
								"change": "tblCTPriceFixationDetail"
								,"iconCls": "small-tree-grid"
								,"changeDescription": "Pricing"
								,"children": [
									{
										"action": "Deleted"
										,"change": "Deleted-Record: Price Layer '+CAST(@intPriceLayer as varchar(15))+'"
										,"keyValue": '+CAST(@intPriceFixationDetailId as varchar(15))+'
										,"iconCls": "small-tree-grid"
										,"leaf": true
									}
								]
							}
						]
					}
				'

				EXEC uspSMAuditLog
				@screenName = 'ContractManagement.view.PriceContracts',
				@entityId = @UserId,
				@actionType = 'Updated',
				@actionIcon = 'small-tree-modified',
				@keyValue = @intContractPriceId,
				@details = @details

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
				,intNumber = intNumber
				,strPriceContractNo = strPriceContractNo
			from
			(
			select
				intDetailId = pfd.intPriceFixationDetailId
				,dblCurrentPricedQuantity = pfd.dblQuantity
				,dblPricedLots = pfd.dblNoOfLots
				,dblInvoicedQuantity = sum(isnull(di.dblQtyShipped,0))
				,intCurrentPriceContractId = pf.intPriceContractId
				,intNumber = pfd.intNumber
				,strPriceContractNo = pc.strPriceContractNo
			from
				tblCTPriceFixationDetail pfd
				join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
				left join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				left join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
				left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
			where
				pfd.intPriceFixationId = @intPriceFixationId
			group by
				pfd.intPriceFixationDetailId
				,pfd.dblQuantity
				,pfd.dblNoOfLots
				,pf.intPriceContractId
				,pfd.intNumber
				,pc.strPriceContractNo
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
					,@intPriceLayer = intNumber
					,@strPriceContractNo = strPriceContractNo
				from @PriceDetailToProcess where intId = @intId

				if (@dblCurrentPricedQuantity <> @dblInvoicedQuantity and @dblInvoicedQuantity > 0)
				begin

					select
						@dblNoOfLotsOld = dblNoOfLots
						,@dblPricedQuantityOld = dblQuantity
						,@dblNoOfLotsNew = dblNoOfLots - @dblForRemoveLots
						,@dblPricedQuantityNew = @dblInvoicedQuantity
					from
						tblCTPriceFixationDetail
					where
						intPriceFixationDetailId = @intPriceFixationDetailId;

					update
						tblCTPriceFixationDetail
					set
						dblNoOfLots = @dblNoOfLotsNew--dblNoOfLots - @dblForRemoveLots
						,dblQuantity = @dblPricedQuantityNew--@dblInvoicedQuantity
					where
						intPriceFixationDetailId = @intDetailId;

					EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

					set @details = '
						{
							"change": "tblCTPriceFixation"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Details"
							,"children": [
								{
									"change": "tblCTPriceFixationDetail"
									,"iconCls":"small-tree-grid"
									,"changeDescription": "Pricing"
									,"children": [
										{
											"action": "Updated"
											,"change": "Updated - Record: Price Layer ' + convert(nvarchar(20),@intPriceLayer)+ '"
											,"iconCls": "small-tree-modified"
											,"children": [
												{
													"change": "No. of Lots"
													,"from": "' + convert(nvarchar(50),@dblNoOfLotsOld) + '"
													,"to": "' + convert(nvarchar(50),@dblNoOfLotsNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												},
												{
													"change": "Quantity"
													,"from": "' + convert(nvarchar(50),@dblPricedQuantityOld) + '"
													,"to": "' + convert(nvarchar(50),@dblPricedQuantityNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												}
											]
										}
									]
								}
							]
						}
					'

					EXEC uspSMAuditLog
					@screenName = 'ContractManagement.view.PriceContracts',
					@entityId = @UserId,
					@actionType = 'Updated',
					@actionIcon = 'small-tree-modified',
					@keyValue = @intCurrentPriceContractId,
					@details = @details

				end
				else
				begin
					if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
					begin
						if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intCurrentPriceContractId) = 1)
						begin
							update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd, tblCTPriceFixation pf where pf.intPriceContractId = @intCurrentPriceContractId and pfd.intPriceFixationId = pf.intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceContract where intPriceContractId = @intCurrentPriceContractId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

							EXEC dbo.uspSMAuditLog 
								 @keyValue			= @intCurrentPriceContractId
								,@screenName		= 'ContractManagement.view.PriceContracts'
								,@entityId			= @UserId
								,@actionType		= 'Deleted'
								,@changeDescription	= ''
								,@fromValue			= ''
								,@toValue			= ''

						end
						else
						begin
							update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd where pfd.intPriceFixationId = @intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
							set @strXML = '<tblCTPriceFixations>
												<tblCTPriceFixation>
													<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
													<strRowState>Delete</strRowState>
												</tblCTPriceFixation>
											</tblCTPriceFixations>';
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

							set @details = '
								{
									"change": "tblCTPriceFixation"
									,"iconCls": "small-tree-grid"
									,"changeDescription": "Details"
									,"children": [
										{
											"action": "Deleted"
											,"change": "Deleted-Record: Price Fixation '+CAST(@intPriceFixationId as varchar(15))+'"
											,"keyValue": '+CAST(@intPriceFixationId as varchar(15))+'
											,"iconCls": "small-tree-grid"
											,"leaf": true
										}
									]
								}
							';

							EXEC uspSMAuditLog
							@screenName = 'ContractManagement.view.PriceContracts',
							@entityId = @UserId,
							@actionType = 'Updated',
							@actionIcon = 'small-tree-modified',
							@keyValue = @intCurrentPriceContractId,
							@details = @details
						end
					end
					else
					begin
						update tblCTPriceFixationDetailAPAR set ysnMarkDelete = 1 where intPriceFixationDetailId = @intDetailId;
						set @strXML = '<tblCTPriceFixationDetails>
											<tblCTPriceFixationDetail>
												<intPriceFixationDetailId>' + convert(nvarchar(20),@intDetailId) + '</intPriceFixationDetailId>
												<strRowState>Delete</strRowState>
											</tblCTPriceFixationDetail>
										</tblCTPriceFixationDetails>';
						EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
						delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intDetailId;
						EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

						set @details = '
							{
								"actionType": "Updated"
								,"change": "tblCTPriceFixation"
								,"iconCls": "small-tree-grid"
								,"changeDescription": "Details"
								,"children": [
									{
										"change": "tblCTPriceFixationDetail"
										,"iconCls": "small-tree-grid"
										,"changeDescription": "Pricing"
										,"children": [
											{
												"action": "Deleted"
												,"change": "Deleted-Record: Price Layer '+CAST(@intPriceLayer as varchar(15))+'"
												,"keyValue": '+CAST(@intDetailId as varchar(15))+'
												,"iconCls": "small-tree-grid"
												,"leaf": true
											}
										]
									}
								]
							}
						';

						EXEC uspSMAuditLog
						@screenName = 'ContractManagement.view.PriceContracts',
						@entityId = @UserId,
						@actionType = 'Updated',
						@actionIcon = 'small-tree-modified',
						@keyValue = @intCurrentPriceContractId,
						@details = @details
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
				,intNumber = intNumber
				,strPriceContractNo = strPriceContractNo
			from
			(
			select
				pfd.intPriceFixationDetailId
				,pfd.dblNoOfLots
				,pfd.dblQuantity
				,pfd.dblLoadPriced
				,dblQuantityPerLoad = @dblQuantityPerLoad
				,intNoOfInvoices = count(ar.intPriceFixationDetailAPARId) --- @intRemovedInvoice
				,intNumber = pfd.intNumber
				,strPriceContractNo = pc.strPriceContractNo
			from
				tblCTPriceFixation pf
				join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
				left join tblCTPriceFixationDetailAPAR ar on ar.intPriceFixationDetailId = pfd.intPriceFixationDetailId
				left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
			where
				pf.intPriceFixationId = @intPriceFixationId
			group by
				pfd.intPriceFixationDetailId
				,pfd.dblNoOfLots
				,pfd.dblQuantity
				,pfd.dblLoadPriced
				,pfd.intNumber
				,pc.strPriceContractNo
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
					,@intPriceLayer = intNumber
					,@strPriceContractNo = strPriceContractNo
				from @PriceDetailToProcessLoad where intId = @intId

				if (@dblLoadPriced > @dblForRemoveLoad and @dblForRemoveLoad > 0)
				begin

					select
						@dblNoOfLotsOld = dblNoOfLots
						,@dblPricedQuantityOld = dblQuantity
						,@dblLoadPricedOld = dblLoadPriced
						,@dblLoadAppliedAndPricedOld = dblLoadAppliedAndPriced
						,@dblNoOfLotsNew = dblNoOfLots - @dblForRemoveLots
						,@dblPricedQuantityNew = dblQuantity - @dblOverQuantity
						,@dblLoadPricedNew = dblLoadPriced - @dblForRemoveLoad
						,@dblLoadAppliedAndPricedNew = dblLoadAppliedAndPriced - @dblForRemoveLoad
					from
						tblCTPriceFixationDetail
					where
						intPriceFixationDetailId = @intDetailId;

					update
						tblCTPriceFixationDetail
					set
						dblNoOfLots = @dblNoOfLotsNew 				--dblNoOfLots - @dblForRemoveLots
						,dblQuantity = @dblPricedQuantityNew 		--dblQuantity - @dblOverQuantity
						,dblLoadPriced = @dblLoadPricedNew 			--dblLoadPriced - @dblForRemoveLoad
						,dblLoadAppliedAndPriced = @dblLoadAppliedAndPricedNew
					where
						intPriceFixationDetailId = @intDetailId;

					EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

					set @details = '
						{
							"change": "tblCTPriceFixation"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Details"
							,"children": [
								{
									"change": "tblCTPriceFixationDetail"
									,"iconCls":"small-tree-grid"
									,"changeDescription": "Pricing"
									,"children": [
										{
											"action": "Updated"
											,"change": "Updated - Record: Price Layer ' + convert(nvarchar(20),@intPriceLayer)+ '"
											,"iconCls": "small-tree-modified"
											,"children": [
												{
													"change": "No. of Lots"
													,"from": "' + convert(nvarchar(50),@dblNoOfLotsOld) + '"
													,"to": "' + convert(nvarchar(50),@dblNoOfLotsNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												},
												{
													"change": "Quantity"
													,"from": "' + convert(nvarchar(50),@dblPricedQuantityOld) + '"
													,"to": "' + convert(nvarchar(50),@dblPricedQuantityNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												},
												{
													"change": "Load Priced"
													,"from": "' + convert(nvarchar(50),@dblLoadPricedOld) + '"
													,"to": "' + convert(nvarchar(50),@dblLoadPricedNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												},
												{
													"change": "Load Applied & Priced"
													,"from": "' + convert(nvarchar(50),@dblLoadAppliedAndPricedOld) + '"
													,"to": "' + convert(nvarchar(50),@dblLoadAppliedAndPricedNew) + ' "
													,"leaf": true
													,"iconCls": "small-gear"
												}
											]
										}
									]
								}
							]
						}
					'

					EXEC uspSMAuditLog
					@screenName = 'ContractManagement.view.PriceContracts',
					@entityId = @UserId,
					@actionType = 'Updated',
					@actionIcon = 'small-tree-modified',
					@keyValue = @intContractPriceId,
					@details = @details

				end
				else
				begin
					if ((select count(*) from tblCTPriceFixationDetail where intPriceFixationId = @intPriceFixationId) = 1)
					begin
						if ((select count(*) from tblCTPriceFixation where intPriceContractId = @intCurrentPriceContractId) = 1)
						begin
							update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd, tblCTPriceFixation pf where pf.intPriceContractId = @intCurrentPriceContractId and pfd.intPriceFixationId = pf.intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = 'Delete', @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceContract where intPriceContractId = @intCurrentPriceContractId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;


							EXEC dbo.uspSMAuditLog 
								 @keyValue			= @intCurrentPriceContractId
								,@screenName		= 'ContractManagement.view.PriceContracts'
								,@entityId			= @UserId
								,@actionType		= 'Deleted'
								,@changeDescription	= ''
								,@fromValue			= ''
								,@toValue			= ''
								
						end
						else
						begin
							update ar set ar.ysnMarkDelete = 1 from tblCTPriceFixationDetailAPAR ar, tblCTPriceFixationDetail pfd where pfd.intPriceFixationId = @intPriceFixationId and ar.intPriceFixationDetailId = pfd.intPriceFixationId;
							set @strXML = '<tblCTPriceFixations>
												<tblCTPriceFixation>
													<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>
													<strRowState>Delete</strRowState>
												</tblCTPriceFixation>
											</tblCTPriceFixations>';
							EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
							delete from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
							EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

							set @details = '
								{
									"change": "tblCTPriceFixation"
									,"iconCls": "small-tree-grid"
									,"changeDescription": "Details"
									,"children": [
										{
											"action": "Deleted"
											,"change": "Deleted-Record: Price Fixation '+CAST(@intPriceFixationId as varchar(15))+'"
											,"keyValue": '+CAST(@intPriceFixationId as varchar(15))+'
											,"iconCls": "small-tree-grid"
											,"leaf": true
										}
									]
								}
							';

							EXEC uspSMAuditLog
							@screenName = 'ContractManagement.view.PriceContracts',
							@entityId = @UserId,
							@actionType = 'Updated',
							@actionIcon = 'small-tree-modified',
							@keyValue = @intCurrentPriceContractId,
							@details = @details

						end
					end
					else
					begin
						update tblCTPriceFixationDetailAPAR set ysnMarkDelete = 1 where intPriceFixationDetailId = @intDetailId;
						set @strXML = '<tblCTPriceFixationDetails>
											<tblCTPriceFixationDetail>
												<intPriceFixationDetailId>' + convert(nvarchar(20),@intDetailId) + '</intPriceFixationDetailId>
												<strRowState>Delete</strRowState>
											</tblCTPriceFixationDetail>
										</tblCTPriceFixationDetails>';
						EXEC uspCTBeforeSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = @strXML, @ysnDeleteFromInvoice = 1;
						delete from tblCTPriceFixationDetail where intPriceFixationDetailId = @intDetailId;
						EXEC uspCTSavePriceContract @intPriceContractId = @intCurrentPriceContractId, @strXML = '', @ysnApprove = 0, @ysnProcessPricing = 0;

						set @details = '
							{
								"actionType": "Updated"
								,"change": "tblCTPriceFixation"
								,"iconCls": "small-tree-grid"
								,"changeDescription": "Details"
								,"children": [
									{
										"change": "tblCTPriceFixationDetail"
										,"iconCls": "small-tree-grid"
										,"changeDescription": "Pricing"
										,"children": [
											{
												"action": "Deleted"
												,"change": "Deleted-Record: Price Layer '+CAST(@intPriceLayer as varchar(15))+'"
												,"keyValue": '+CAST(@intDetailId as varchar(15))+'
												,"iconCls": "small-tree-grid"
												,"leaf": true
											}
										]
									}
								]
							}
						';

						EXEC uspSMAuditLog
						@screenName = 'ContractManagement.view.PriceContracts',
						@entityId = @UserId,
						@actionType = 'Updated',
						@actionIcon = 'small-tree-modified',
						@keyValue = @intCurrentPriceContractId,
						@details = @details

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