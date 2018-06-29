CREATE PROCEDURE [dbo].[uspCTContractAdjustmentSave]
		
	@intAdjustmentId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@dblAdjustedQty			NUMERIC(18,6),
			@dblQuantityToUpdate	NUMERIC(18,6),
			@intUserId				INT,
			@XML					NVARCHAR(MAX)

	SELECT	@intContractDetailId	=	intContractDetailId,
			@dblAdjustedQty			=	dblAdjustedQty,
			@intUserId				=	ISNULL(intLastModifiedById,intCreatedById)
	FROM	tblCTContractAdjustment
	WHERE	intAdjustmentId	=	@intAdjustmentId

	SELECT	@dblQuantityToUpdate	=	dblQuantity	+ @dblAdjustedQty
	FROM	tblCTContractDetail
	WHERE	intContractDetailId =	@intContractDetailId

	SET @XML = '<tblCTContractDetails>'
	SET @XML +=		'<tblCTContractDetail>'
	SET @XML +=			'<intContractDetailId>'+LTRIM(@intContractDetailId)+'</intContractDetailId>'
	SET @XML +=			'<dblQuantity>'+LTRIM(@dblQuantityToUpdate)+'</dblQuantity>'
	SET @XML +=		'</tblCTContractDetail>'
	SET @XML +=	'</tblCTContractDetails>'

	EXEC uspCTValidateContractDetail @XML,'Modified'

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