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
		tblCTContractDetail with (nolock)
	where
		isnull(intNoOfLoad,0) > 0
		and intContractDetailId = @intContractDetailId;

	/*If Load based*/
	if (@intNoOfLoad > 0)
	begin

		select @intInvoiceCount = count(*) from tblARInvoice i with (nolock) where i.intInvoiceId in (
			select intInvoiceId from tblARInvoiceDetail di with (nolock) where di.intContractDetailId = @intContractDetailId
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

			BEGIN TRY
				DECLARE @SingleAuditLogParam SingleAuditLogParam
				INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
						SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@intContractHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
						UNION ALL
						SELECT 2, '', '', 'tblCTContractDetails', NULL, NULL, NULL, NULL, NULL, 1
						UNION ALL
						SELECT 3, '', 'Updated', 'Updated - Record: ' + convert(nvarchar(20),@intContractDetailId), NULL, NULL, NULL, NULL, NULL, 2
						UNION ALL
						SELECT 4, '', '', 'Contract Status', @strOldStatus, @strNewStatus, NULL, NULL, NULL, 3

				EXEC uspSMSingleAuditLog 
					@screenName     = 'ContractManagement.view.Contract',
					@recordId       = @intContractHeaderId,
					@entityId       = @intUserId,
					@AuditLogParam  = @SingleAuditLogParam
			END TRY
			BEGIN CATCH
			END CATCH

			EXEC	uspCTCreateDetailHistory	@intContractHeaderId 	= NULL,--@intContractHeaderId,
												@intContractDetailId	= @intContractDetailId,
												@strSource 				= 'Contract',
												@strProcess 			= 'Update Sequence Status',
												@intUserId				= @intUserId

		end

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
