CREATE PROCEDURE [dbo].[uspCTDeleteUnpostedInvoiceFromPricingUpdate]
	@InvoiceDetailIds nvarchar(100),
	@intUserId int
AS
begin try
	declare @strErrorMessage nvarchar(max);
	declare @intInvoiceDetailId int;
	declare @intInvoiceDetailParamId int;
	declare @intInvoiceId int;
	declare @Count int;
	declare @intActiveContractDetailId int;

	declare @ContractDetailId table(
		intContractDetailId int
	);

	insert into @ContractDetailId
	select distinct pf.intContractDetailId
	from fnSplitString(@InvoiceDetailIds,',') ss
	join tblCTPriceFixationDetailAPAR ar on ar.intInvoiceDetailId = ss.Item
	join tblCTPriceFixationDetail pfd on pfd.intPriceFixationDetailId = ar.intPriceFixationDetailId
	join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
	order by pf.intContractDetailId

	SELECT  di.intInvoiceId, di.intInvoiceDetailId
	INTO	#ItemInvoice
	FROM	fnSplitString(@InvoiceDetailIds,',') ss
	join tblARInvoiceDetail di on di.intInvoiceDetailId = ss.Item
	order by ss.Item

	select @intInvoiceDetailId = MIN(intInvoiceDetailId) FROM #ItemInvoice
	while (@intInvoiceDetailId is not null)
	begin

		set @intInvoiceDetailParamId = @intInvoiceDetailId;
		select @intInvoiceId = intInvoiceId FROM #ItemInvoice where intInvoiceDetailId = @intInvoiceDetailParamId;
		select @Count = COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId
		DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @intInvoiceDetailParamId
		
		if (@Count = 1)
		begin
			set @intInvoiceDetailParamId = null
		end

		EXEC uspARDeleteInvoice @intInvoiceId,@intUserId,@intInvoiceDetailParamId

		select @intInvoiceDetailId = MIN(intInvoiceDetailId) FROM #ItemInvoice where intInvoiceDetailId > @intInvoiceDetailId;
	end

	if exists (select top 1 1 from @ContractDetailId)
	begin
		select @intActiveContractDetailId = min(intContractDetailId) from @ContractDetailId;
		while (@intActiveContractDetailId is not null)
		begin
			declare @ysnDestinationWeightsAndGrades bit = 0;
			declare @ysnLoad bit = 0;
			declare @dblSequenceQty numeric(18,6);
			declare @dblSequenceBalance numeric(18,6);
			declare @intOldContractStatusId int;
			declare @intDWGIdId int;
			declare @dblTotalInvoiceQuantity numeric(18,6);
			declare @details nvarchar(max);
			declare @intContractHeaderId int;
			declare @intContractSeq int;
			declare @strVarStatus nvarchar(20);

			select @intDWGIdId = intWeightGradeId from tblCTWeightGrade where strWhereFinalized = 'Destination';
			
			select
				@dblSequenceQty = (case when isnull(ch.ysnLoad,0) = 1 then convert(numeric(18,6),isnull(cd.intNoOfLoad,0)) else cd.dblQuantity end)
				,@dblSequenceBalance = (case when isnull(ch.ysnLoad,0) = 1 then cd.dblBalanceLoad else cd.dblBalance end)
				,@intOldContractStatusId = cd.intContractStatusId
				,@strVarStatus = cs.strContractStatus
				,@ysnDestinationWeightsAndGrades = (case when ch.intWeightId = @intDWGIdId or ch.intGradeId = @intDWGIdId then 1 else 0 end)
				,@ysnLoad = isnull(ch.ysnLoad, 0)
				,@intContractHeaderId = ch.intContractHeaderId
				,@intContractSeq = cd.intContractSeq
			from
				tblCTContractDetail cd
				,tblCTContractHeader ch
				,tblCTContractStatus cs
			where
				cd.intContractDetailId = @intActiveContractDetailId
				and ch.intContractHeaderId = cd.intContractHeaderId
				and cs.intContractStatusId = cd.intContractStatusId

			if (@ysnDestinationWeightsAndGrades = 0)
			begin
				if (@dblSequenceBalance = 0)
				begin
					if (@ysnLoad = 0)
					begin
						select @dblTotalInvoiceQuantity = sum(dblQtyShipped) from tblARInvoiceDetail where intContractDetailId = @intActiveContractDetailId;
					end
					else
					begin
						select @dblTotalInvoiceQuantity = count(distinct intInvoiceId) from tblARInvoiceDetail where intContractDetailId = @intActiveContractDetailId;
					end

					if (@dblSequenceQty = @dblTotalInvoiceQuantity and @intOldContractStatusId in (1,4))
					begin
						update tblCTContractDetail set intContractStatusId = 5 where intContractDetailId = @intActiveContractDetailId;


						set @details = '
						{
							"change": "tblCTContractDetail"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Details"
							,"children": [
								{
									"action": "Updated"
									,"change": "Updated - Record: Contract Sequence ' + convert(nvarchar(20),@intContractSeq)+ '"
									,"iconCls": "small-tree-modified"
									,"children": [
										{
											"change": "Status"
											,"from": "' + @strVarStatus + '"
											,"to": "Complete"
											,"leaf": true
											,"iconCls": "small-gear"
										}
									]
								}
							]
						}
					'

					EXEC uspSMAuditLog
					@screenName = 'ContractManagement.view.Contract',
					@entityId = @intUserId,
					@actionType = 'Updated',
					@actionIcon = 'small-tree-modified',
					@keyValue = @intContractHeaderId,
					@details = @details


					end

					if (@dblSequenceQty > @dblTotalInvoiceQuantity and @intOldContractStatusId in (5))
					begin
						update tblCTContractDetail set intContractStatusId = 1 where intContractDetailId = @intActiveContractDetailId;


						set @details = '
						{
							"change": "tblCTContractDetail"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Details"
							,"children": [
								{
									"action": "Updated"
									,"change": "Updated - Record: Contract Sequence ' + convert(nvarchar(20),@intContractSeq)+ '"
									,"iconCls": "small-tree-modified"
									,"children": [
										{
											"change": "Status"
											,"from": "Complete"
											,"to": "Open"
											,"leaf": true
											,"iconCls": "small-gear"
										}
									]
								}
							]
						}
					'

					EXEC uspSMAuditLog
					@screenName = 'ContractManagement.view.Contract',
					@entityId = @intUserId,
					@actionType = 'Updated',
					@actionIcon = 'small-tree-modified',
					@keyValue = @intContractHeaderId,
					@details = @details
					end
				end
				else
				begin
					if (@intOldContractStatusId = 5)
					begin
						update tblCTContractDetail set intContractStatusId = 1 where intContractDetailId = @intActiveContractDetailId;


						set @details = '
						{
							"change": "tblCTContractDetail"
							,"iconCls":"small-tree-grid"
							,"changeDescription": "Details"
							,"children": [
								{
									"action": "Updated"
									,"change": "Updated - Record: Contract Sequence ' + convert(nvarchar(20),@intContractSeq)+ '"
									,"iconCls": "small-tree-modified"
									,"children": [
										{
											"change": "Status"
											,"from": "' + @strVarStatus + '"
											,"to": "Complete"
											,"leaf": true
											,"iconCls": "small-gear"
										}
									]
								}
							]
						}
					'

					EXEC uspSMAuditLog
					@screenName = 'ContractManagement.view.Contract',
					@entityId = @intUserId,
					@actionType = 'Updated',
					@actionIcon = 'small-tree-modified',
					@keyValue = @intContractHeaderId,
					@details = @details
					end
				end

			end

			select @intActiveContractDetailId = min(intContractDetailId) from @ContractDetailId where intContractDetailId > @intActiveContractDetailId;
		end
	end

end try
begin catch
		SET @strErrorMessage = ERROR_MESSAGE()  
		RAISERROR (@strErrorMessage,18,1,'WITH NOWAIT') 
end catch