CREATE PROCEDURE [dbo].[uspCTContractSave]
	
	@intContractHeaderId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblCashPrice				NUMERIC(18,6),
			@intPricingTypeId			INT,
			@ysnMultiplePriceFixation	BIT,
			@dblBasis					NUMERIC(18,6),
			@dblOriginalBasis			NUMERIC(18,6)
	
	SELECT @ysnMultiplePriceFixation = ysnMultiplePriceFixation FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId
	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@intPricingTypeId	=	NULL,
				@dblCashPrice		=	NULL,
				@dblBasis			=	NULL,
				@dblOriginalBasis	=	NULL

		SELECT	@intPricingTypeId	=	intPricingTypeId,
				@dblCashPrice		=	dblCashPrice,
				@dblBasis			=	dblBasis,
				@dblOriginalBasis	=	dblOriginalBasis
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF 		@intPricingTypeId	IN	(1,6)
		BEGIN	
			EXEC uspICUpdateInventoryReceiptUnitCost @intContractDetailId,@dblCashPrice
		END
		
		IF @dblOriginalBasis IS NOT NULL AND  @dblBasis <> @dblOriginalBasis
		BEGIN
			EXEC uspCTUpdateSequenceBasis @intContractDetailId,@dblBasis
		END

		EXEC uspLGUpdateLoadItem @intContractDetailId

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

	IF ISNULL(@ysnMultiplePriceFixation,0) = 0
	BEGIN
		UPDATE	PF
		SET		PF.intTotalLots = CAST(CD.dblNoOfLots AS INT)
		FROM	tblCTPriceFixation	PF
		JOIN	tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
		WHERE	CD.intContractHeaderId = @intContractHeaderId
	END
	
	EXEC uspCTUpdateAdditionalCost @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO