CREATE PROCEDURE [dbo].[uspCTUpdateSequenceStatus]
	@intContractDetailId int,
	@intUserId int
AS

BEGIN TRY
	
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intNoOfLoad int
		,@intOldContractStatusId int
		,@intInvoiceCount int
		,@intNewContractStatusId int
		,@strOldStatus nvarchar(100)
		,@strNewStatus nvarchar(100)
		,@details nvarchar(max)
		,@intContractHeaderId int;

	select
		@intNoOfLoad = intNoOfLoad
		,@intOldContractStatusId = intContractStatusId
		,@intContractHeaderId = intContractHeaderId
	from
		tblCTContractDetail
	where
		isnull(intNoOfLoad,0) > 0
		and intContractDetailId = @intContractDetailId;

	/*If Load based*/
	if (@intNoOfLoad > 0)
	begin

		select @intInvoiceCount = count(*) from tblARInvoice i where i.intInvoiceId in (
			select intInvoiceId from tblARInvoiceDetail di where di.intContractDetailId = @intContractDetailId
		)

		if (@intNoOfLoad <= @intInvoiceCount and (@intOldContractStatusId = 1 or @intOldContractStatusId = 4))
		BEGIN
			set @intNewContractStatusId = 5;
		END
		else
		begin
			if (@intNoOfLoad > @intInvoiceCount and @intOldContractStatusId = 5)
			begin
				set @intNewContractStatusId = 1;
			end
		end

		if (@intOldContractStatusId <> @intNewContractStatusId)
		begin
			update tblCTContractDetail set intContractStatusId = @intNewContractStatusId where intContractDetailId = @intContractDetailId;

			select @strOldStatus = strContractStatus from tblCTContractStatus where intContractStatusId = @intOldContractStatusId;
			select @strNewStatus = strContractStatus from tblCTContractStatus where intContractStatusId = @intNewContractStatusId;

			SET @details = '{"change": "tblCTContractDetails","children": [{"action": "Updated","change": "Updated - Record: ' + convert(nvarchar(20),@intContractDetailId)+ '","iconCls": "small-tree-modified","children": [{"change": "Contract Status","from": "' + @strOldStatus + '","to": "' + @strNewStatus + ' ","leaf": true,"iconCls": "small-gear"}]}],"iconCls":"small-tree-grid"}';

			EXEC	dbo.uspSMAuditLog
					@keyValue				= @intContractHeaderId,				
					@screenName				= 'ContractManagement.view.Contract', 
					@entityId				= @intUserId,	
					@actionType				= 'Updated',
					@actionIcon				= 'small-tree-modified',
					@changeDescription		= '',
					@fromValue				= '',
					@toValue				= '',
					@details				= @details 		

			EXEC	uspCTCreateDetailHistory	NULL, @intContractDetailId

		end

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
