CREATE PROCEDURE [dbo].[uspCTSplitSequence]
	@intContractDetailId		INT,
	@dblQuantity				NUMERIC(18,6),
	@intUserId					INT,
	@intExternalId				INT,		
	@strScreenName				NVARCHAR(100),
	@intNewContractDetailId		INT OUTPUT,
	@intNewContractHeaderid		INT = NULL
AS

BEGIN TRY

SET NOCOUNT ON
		DECLARE @intNextSequence			INT,
				@XML						NVARCHAR(MAX),
				@dblNewQuantity				NUMERIC(18,6),
				
				@ErrMsg						NVARCHAR(MAX),
				@intContractHeaderId		INT,
				@dblHeaderQuantity			NUMERIC(18,6),
				@dblQuantityToDecrease		NUMERIC(18,6)

		SELECT	@intContractHeaderId	=	intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		SELECT	@dblHeaderQuantity		=	dblQuantity FROM tblCTContractHeader WHERE 	intContractHeaderId = @intContractHeaderId						
		
		SELECT	@intNextSequence	=	ISNULL(MAX(intContractSeq),0) + 1 
		FROM	tblCTContractDetail 
		WHERE	intContractHeaderId = ISNULL(@intNewContractHeaderid, @intContractHeaderId)

		SET @dblQuantityToDecrease = @dblQuantity * -1
		
		EXEC	uspCTUpdateSequenceQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblQuantityToDecrease,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intExternalId,
				@strScreenName			=	@strScreenName				
					
		IF OBJECT_ID('tempdb..#tblCTContractDetail') IS NOT NULL  					
			DROP TABLE #tblCTContractDetail

		SELECT * INTO #tblCTContractDetail FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		ALTER TABLE #tblCTContractDetail DROP COLUMN intContractDetailId

		UPDATE	#tblCTContractDetail 
		SET		dblQuantity			=	@dblQuantity,
				dblNetWeight		=	@dblQuantity,
				dblBalance			=	@dblQuantity,
				dblScheduleQty		=	NULL,
				intConcurrencyId	=	1,
				intContractStatusId =	1,
				intContractSeq		=	@intNextSequence,
				intSplitId			=	NULL,
				intContractHeaderId	=	ISNULL(@intNewContractHeaderid, @intContractHeaderId),
				intPricingTypeId	=	1

		EXEC	uspCTGetTableDataInXML '#tblCTContractDetail',null,@XML OUTPUT							
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractDetail',@XML,@intNewContractDetailId OUTPUT

		IF @strScreenName = 'Split'
		BEGIN
			UPDATE tblCTContractDetail SET ysnCreatedFromSplit = 1 WHERE intContractDetailId = @intNewContractDetailId
		END		

		SET @XML = NULL

		IF OBJECT_ID('tempdb..#tblCTContractCost') IS NOT NULL  					
			DROP TABLE #tblCTContractCost

		SELECT * INTO #tblCTContractCost FROM tblCTContractCost WHERE intContractDetailId = @intContractDetailId

		ALTER TABLE #tblCTContractCost DROP COLUMN intContractCostId

		UPDATE	#tblCTContractCost 
		SET		intContractDetailId	=	@intNewContractDetailId

		EXEC	uspCTGetTableDataInXML '#tblCTContractCost',null,@XML OUTPUT
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractCost',@XML

		SET @XML = NULL

		IF OBJECT_ID('tempdb..#tblCTContractOption') IS NOT NULL  					
			DROP TABLE #tblCTContractOption

		SELECT * INTO #tblCTContractOption FROM tblCTContractOption WHERE intContractDetailId = @intContractDetailId

		ALTER TABLE #tblCTContractOption DROP COLUMN intContractOptionId

		UPDATE	#tblCTContractOption 
		SET		intContractDetailId	=	@intNewContractDetailId

		EXEC	uspCTGetTableDataInXML '#tblCTContractOption',null,@XML OUTPUT
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractOption',@XML

		SET @XML = NULL

		IF OBJECT_ID('tempdb..#tblCTContractCertification') IS NOT NULL  					
			DROP TABLE #tblCTContractCertification

		SELECT * INTO #tblCTContractCertification FROM tblCTContractCertification WHERE intContractDetailId = @intContractDetailId

		ALTER TABLE #tblCTContractCertification DROP COLUMN intContractCertificationId

		UPDATE	#tblCTContractCertification 
		SET		intContractDetailId	=	@intNewContractDetailId

		EXEC	uspCTGetTableDataInXML '#tblCTContractCertification',null,@XML OUTPUT
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractCertification',@XML
		
		UPDATE	tblCTContractHeader
		SET		dblQuantity	=	@dblHeaderQuantity 
		FROM	tblCTContractHeader 
		WHERE 	intContractHeaderId = @intContractHeaderId	
		AND		@intNewContractHeaderid IS NULL
		
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO