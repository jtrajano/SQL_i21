CREATE PROCEDURE [dbo].[uspCTContractAdjustmentSave]
		
	@intAdjustmentId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblAdjustedQty			NUMERIC(18,6),
			@intUserId				INT

	SELECT	@intContractDetailId	=	intContractDetailId,
			@dblAdjustedQty			=	dblAdjustedQty,
			@intUserId				=	ISNULL(intLastModifiedById,intCreatedById)
	FROM	tblCTContractAdjustment
	WHERE	intAdjustmentId	=	@intAdjustmentId

	EXEC	uspCTUpdateSequenceQuantity
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblAdjustedQty,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intAdjustmentId,
			@strScreenName			=	'Contract AdjustMent'

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH