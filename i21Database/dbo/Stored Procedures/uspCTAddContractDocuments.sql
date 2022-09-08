CREATE PROCEDURE [dbo].[uspCTAddContractDocuments]
	@intContractHeaderId	INT
    ,@intUserId				INT

AS

BEGIN TRY
	declare
		@ErrMsg nvarchar(max)
		,@intBookId int
		,@intSubBookId int
		,@intContractTypeId int;
		;

	select @intBookId = isnull(intBookId,0), @intSubBookId = isnull(intSubBookId,0), @intContractTypeId = intContractTypeId from tblCTContractHeader where intContractHeaderId = @intContractHeaderId;

	if (@intContractTypeId <> 2)
	begin
		SET @ErrMsg = 'Unable to add documents for non-Sale contract.';
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT');
	end
	else
	begin

		declare @documents table ( intDocumentId int );
		declare @intDocumentId int;

		insert into @documents select intDocumentId = intDocumentId from tblICDocument where isnull(intBookId,0) = @intBookId and isnull(intSubBookId,0) = @intSubBookId order by strDocumentName;

		while exists (select top 1 1 from @documents)
		begin
			select top 1 @intDocumentId = intDocumentId from @documents
			if not exists (select top 1 1 from tblCTContractDocument where intContractHeaderId = @intContractHeaderId and intDocumentId = @intDocumentId)
			begin
				insert into tblCTContractDocument (
					intContractHeaderId
					,intDocumentId
					,intConcurrencyId
					,intContractDocumentRefId
					,dtmCreatedDate
					,intCreatedById
				)
				select
					intContractHeaderId = @intContractHeaderId
					,intDocumentId = @intDocumentId
					,intConcurrencyId = 1
					,intContractDocumentRefId = null
					,dtmCreatedDate = getdate()
					,intCreatedById = @intUserId

			end
			delete from @documents where intDocumentId = @intDocumentId;
		end

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
