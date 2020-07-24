CREATE PROCEDURE [dbo].[uspCTSplitSequenceAndCreateNewContract]
	@intContractDetailId		INT,
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

		SELECT	@intContractHeaderId	=	intContractHeaderId,
				@intSplitId				=	intSplitId,
				@dblQuantity			=	dblQuantity,
				@ysnSplit				=	ysnSplit,
				@intContractSeq			=	intContractSeq
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId		=	@intContractDetailId

		SELECT	@dblHeaderQuantity		=	dblQuantity,
				@intContractTypeId		=	intContractTypeId,
				@strSourceContractNumber=	strContractNumber
		FROM	tblCTContractHeader 
		WHERE 	intContractHeaderId		=	@intContractHeaderId						
		
		IF ISNULL(@ysnSplit,0) = 1
		BEGIN
			SET @ErrMsg = 'Selected sequence is already splitted. Cannot split further.'
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

			SELECT	@dblSplitQuantity = @dblQuantity * @dblSplitPercent / 100

			-----New Contract

			IF OBJECT_ID('tempdb..#tblCTContractHeader') IS NOT NULL  					
			DROP TABLE #tblCTContractHeader

			SELECT * INTO #tblCTContractHeader FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

			ALTER TABLE #tblCTContractHeader DROP COLUMN intContractHeaderId

			SELECT	@strStartingNumber = CASE WHEN @intContractTypeId = 1 THEN 'PurchaseContract' ELSE 'SaleContract' END
			EXEC	uspCTGetStartingNumber @strStartingNumber,@strContractNumber OUTPUT

			UPDATE	#tblCTContractHeader 
			SET		dblQuantity			=	@dblSplitQuantity,
					strContractNumber	=	@strContractNumber,
					intEntityId			=	@intEntityId

			EXEC	uspCTGetTableDataInXML '#tblCTContractHeader',null,@XML OUTPUT							
			EXEC	uspCTInsertINTOTableFromXML 'tblCTContractHeader',@XML,@intNewContractHeaderId OUTPUT

			SELECT	@ErrMsg = 'Split from contract ' + @strSourceContractNumber + ' and sequence ' + LTRIM(@intContractSeq)
			SELECT	@strStartingNumber = LTRIM(@intNewContractHeaderId)
			exec uspSMAuditLog 'ContractManagement.view.Contract',@strStartingNumber,@intUserId,@ErrMsg,'small-new-plus'

			-----End New Contract

			-----Copy condition

			SET @XML = NULL

			IF OBJECT_ID('tempdb..#tblCTContractCondition') IS NOT NULL  					
				DROP TABLE #tblCTContractCondition

			SELECT * INTO #tblCTContractCondition FROM tblCTContractCondition WHERE intContractHeaderId = @intContractHeaderId

			ALTER TABLE #tblCTContractCondition DROP COLUMN intContractConditionId

			UPDATE	#tblCTContractCondition
			SET		intContractHeaderId	=	@intNewContractHeaderId

			EXEC	uspCTGetTableDataInXML '#tblCTContractCondition',null,@XML OUTPUT
			EXEC	uspCTInsertINTOTableFromXML 'tblCTContractCondition',@XML

			-----End Copy condition

			-----Copy Document

			SET @XML = NULL

			IF OBJECT_ID('tempdb..#tblCTContractDocument') IS NOT NULL  					
				DROP TABLE #tblCTContractDocument

			SELECT * INTO #tblCTContractDocument FROM tblCTContractDocument WHERE intContractHeaderId = @intContractHeaderId

			ALTER TABLE #tblCTContractDocument DROP COLUMN intContractDocumentId

			UPDATE	#tblCTContractDocument
			SET		intContractHeaderId	=	@intNewContractHeaderId

			EXEC	uspCTGetTableDataInXML '#tblCTContractDocument',null,@XML OUTPUT
			EXEC	uspCTInsertINTOTableFromXML 'tblCTContractDocument',@XML

			-----End Copy Document

			-----Create Detail for New Contract

			EXEC uspCTSplitSequence @intContractDetailId, @dblSplitQuantity, @intUserId, @intContractDetailId, 'Split', @intNewContractDetailId OUTPUT,@intNewContractHeaderId

			UPDATE	tblCTSequenceUsageHistory 
			SET		intExternalId		=	@intNewContractDetailId, 
					strNumber			=	@strContractNumber,
					intExternalHeaderId	=	@intNewContractHeaderId 
			WHERE	intContractDetailId	=	@intContractDetailId
			AND		intExternalId		=	@intContractDetailId
			
			UPDATE	tblCTContractDetail SET intContractStatusId = 3,ysnSplit = 1 WHERE intContractDetailId = @intContractDetailId
			UPDATE	tblCTContractDetail SET intContractStatusId = 1, intSplitFromId = @intContractDetailId WHERE intContractDetailId = @intNewContractHeaderId

			EXEC uspCTUpdateAdditionalCost @intContractHeaderId
			IF @intNewContractHeaderId IS NOT NULL
			BEGIN
				EXEC uspCTUpdateAdditionalCost @intNewContractHeaderId
				EXEC uspCTCreateDetailHistory @intContractHeaderId = @intNewContractHeaderId,
											  @intContractDetailId = NULL,
											  @strComment		   = 'Split Sequence And Create New Contract',
											  @strSource		   = 'Contract',
										      @strProcess		   = 'Split Sequence And Create New Contract',
											  @intUserId		   = @intUserId
			END

			SELECT	@intSplitDetailId = MIN(intSplitDetailId) FROM tblEMEntitySplitDetail WHERE intSplitId = @intSplitId AND intSplitDetailId > @intSplitDetailId
		END
		
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO