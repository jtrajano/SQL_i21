
Create PROCEDURE [dbo].[uspCTSplitItemContract]
	@intItemContractHeaderId		INT,
	@intUserId					INT
AS

BEGIN TRY
SET ANSI_WARNINGS OFF
SET NOCOUNT ON
		DECLARE @ErrMsg						NVARCHAR(MAX),
				@XML						NVARCHAR(MAX),
				@strContractNumber			NVARCHAR(100),
				@intContractHeaderId		INT,
				@dblHeaderQuantity			NUMERIC(18,6),
				@dblQuantity				NUMERIC(18,6),
				@dblSplitQuantity			NUMERIC(18,6),
				@intSplitId					INT,
				@intSplitDetailId			INT,
				@intEntityId				INT,
				@intNewContractHeaderId		INT,
				@intNewContractDetailId		INT,
				@intContractTypeId			INT,
				@strStartingNumber			NVARCHAR(100),
				@dblSplitPercent			NUMERIC(18,6),
				@ysnSplit					BIT,
				@intContractSeq				INT,
				@strSourceContractNumber	NVARCHAR(100)


		SELECT	@ysnSplit			=	ysnSplit,
				@intSplitId			=	intSplitId,
				@intContractTypeId	=	intContractTypeId,
				@strSourceContractNumber = strContractNumber
		FROM	tblCTItemContractHeader 
		WHERE 	intItemContractHeaderId		=	@intItemContractHeaderId						
		
		IF ISNULL(@ysnSplit,0) = 1
		BEGIN
			SET @ErrMsg = 'This Item Contract is already splitted. Cannot split further.'
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
		END

		SELECT @intSplitDetailId = MIN(intSplitDetailId) FROM tblEMEntitySplitDetail WHERE intSplitId = @intSplitId



		IF ISNULL(@intSplitId,0) = 0
		BEGIN
			SET @ErrMsg = 'No Split is selected for the sequence.'
			RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
		END

		WHILE ISNULL(@intSplitDetailId,0) > 0
		BEGIN
			SELECT	@intEntityId = intEntityId, @dblSplitPercent = dblSplitPercent FROM tblEMEntitySplitDetail WHERE intSplitDetailId = @intSplitDetailId

			--SELECT	@dblSplitQuantity = @dblQuantity * @dblSplitPercent / 100

			-----New Contract

			IF OBJECT_ID('tempdb..#tblCTItemContractHeader') IS NOT NULL  					
			DROP TABLE #tblCTItemContractHeader

			SELECT * INTO #tblCTItemContractHeader FROM tblCTItemContractHeader WHERE intItemContractHeaderId = @intItemContractHeaderId

			ALTER TABLE #tblCTItemContractHeader DROP COLUMN intItemContractHeaderId

			SELECT	@strStartingNumber = 'Item Contract'
			--EXEC	uspCTGetStartingNumber @strStartingNumber,@strContractNumber OUTPUT

			SELECT @strContractNumber = strPrefix + LTRIM(intNumber) FROM tblSMStartingNumber WHERE strTransactionType = @strStartingNumber  
			UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE  strTransactionType = @strStartingNumber 
			
			select @strContractNumber
			UPDATE tblCTItemContractHeader
			SET ysnSplit = CAST(1 as BIT)
			WHERE intItemContractHeaderId = @intItemContractHeaderId

	
			UPDATE	#tblCTItemContractHeader SET
					strContractNumber	=	@strContractNumber,
					intEntityId			=	@intEntityId, 
					intConcurrencyId	=	1,
					intSplitId			=	 null,
					ysnSplit					=	CAST(0 as BIT)

			EXEC	uspCTGetTableDataInXML '#tblCTItemContractHeader',null,@XML OUTPUT							
			EXEC	uspCTInsertINTOTableFromXML 'tblCTItemContractHeader',@XML,@intNewContractHeaderId OUTPUT

			SELECT	@ErrMsg = 'Split from item contract ' + @strSourceContractNumber
			SELECT	@strStartingNumber = LTRIM(@intNewContractHeaderId)
			exec uspSMAuditLog 'ContractManagement.view.ItemContract',@strStartingNumber,@intUserId,@ErrMsg,'small-new-plus'

			-----End New Contract

			SELECT @intContractSeq = MIN(intItemContractDetailId) FROM tblCTItemContractDetail WHERE intItemContractHeaderId = @intItemContractHeaderId and intContractStatusId not in (2,3)
			
				
			WHILE ISNULL(@intContractSeq,0) > 0
			BEGIN

				IF OBJECT_ID('tempdb..#tblCTItemContractDetail') IS NOT NULL  					
				DROP TABLE #tblCTItemContractDetail

				SELECT * INTO #tblCTItemContractDetail FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intContractSeq
				ALTER TABLE #tblCTItemContractDetail DROP COLUMN intItemContractDetailId

				UPDATE #tblCTItemContractDetail
				SET	   dblContracted			=	dblContracted * @dblSplitPercent / 100.0,
					   dblScheduled				=	0,
					   dblAvailable				=	dblContracted * @dblSplitPercent / 100.0,
					   dblApplied				=	0,
					   dblBalance				=	dblContracted * @dblSplitPercent / 100.0,
					   dblTotal					=	(dblContracted * @dblSplitPercent / 100.0) * dblPrice,
					   intContractStatusId		=	1,
					   intItemContractHeaderId	=	@intNewContractHeaderId

				EXEC	uspCTGetTableDataInXML '#tblCTItemContractDetail',null,@XML OUTPUT							
				EXEC	uspCTInsertINTOTableFromXML 'tblCTItemContractDetail',@XML,@intNewContractDetailId OUTPUT


				SELECT	@intContractSeq = ISNULL(MIN(intItemContractDetailId),0) FROM tblCTItemContractDetail WHERE intItemContractHeaderId = @intItemContractHeaderId AND intItemContractDetailId > @intContractSeq and intContractStatusId not in (2,3)
			END




			-----Create Detail for New Contract
			SELECT @intSplitDetailId = ISNULL(MIN(intSplitDetailId),0) FROM tblEMEntitySplitDetail WHERE intSplitId = @intSplitId and intSplitDetailId > @intSplitDetailId
			
		END

		
			UPDATE tblCTItemContractDetail
			SET intContractStatusId = 3
			WHERE intItemContractHeaderId = @intItemContractHeaderId

		
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH