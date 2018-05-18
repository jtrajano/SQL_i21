CREATE PROCEDURE [dbo].[uspCTValidateContractAfterSave]

	@intContractHeaderId INT
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblAllocatedQty			NUMERIC(18,6),
			@dblQuantity				NUMERIC(18,6),
			@ysnRequireProducerQty		BIT,
			@dblProducerQuantity		NUMERIC(18,6),
			@intContractSeq				INT

	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	SELECT @ysnRequireProducerQty	=	ysnRequireProducerQty FROM tblCTCompanyPreference

	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN

		SELECT	@dblAllocatedQty	=	dblAllocatedQty,
				@dblQuantity		=	dblQuantity,
				@intContractSeq		=	intContractSeq
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF	@dblAllocatedQty > @dblQuantity
		BEGIN
			SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@dblAllocatedQty)+' as it is used in Allocation.'
			RAISERROR(@ErrMsg,16,1) 
		END

		IF	@ysnRequireProducerQty	=	1
		BEGIN
			SELECT @dblProducerQuantity	=	SUM(ISNULL(dblQuantity,0))	FROM	tblCTContractCertification WHERE intContractDetailId = @intContractDetailId
			IF	@dblProducerQuantity > @dblQuantity
			BEGIN
				SET @ErrMsg = 'Sum of producer''s quantity('+dbo.fnRemoveTrailingZeroes(@dblProducerQuantity)+') is greater than sequence '+LTRIM(@intContractSeq)+' quantity('+dbo.fnRemoveTrailingZeroes(@dblQuantity)+').'
				RAISERROR(@ErrMsg,16,1) 
			END
		END

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO