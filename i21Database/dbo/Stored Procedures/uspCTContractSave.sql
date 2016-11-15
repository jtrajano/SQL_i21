CREATE PROCEDURE [dbo].[uspCTContractSave]
	
	@intContractHeaderId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblCashPrice				NUMERIC(18,6),
			@intPricingTypeId			INT,
			@intLastModifiedById		INT,
			@ysnMultiplePriceFixation	BIT,
			@strContractNumber			NVARCHAR(100),
			@dblBasis					NUMERIC(18,6),
			@dblOriginalBasis			NUMERIC(18,6)
	
	SELECT	@ysnMultiplePriceFixation	=	ysnMultiplePriceFixation,
			@strContractNumber			=	strContractNumber
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId			=	@intContractHeaderId

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
				@dblOriginalBasis	=	dblOriginalBasis,
				@intLastModifiedById=	intLastModifiedById
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		EXEC	uspCTSequencePriceChanged @intContractDetailId
		
		IF @dblOriginalBasis IS NOT NULL AND  @dblBasis <> @dblOriginalBasis
		BEGIN
			EXEC uspCTUpdateSequenceBasis @intContractDetailId,@dblBasis
		END

		EXEC uspLGUpdateLoadItem @intContractDetailId

		EXEC uspCTSplitSequencePricing @intContractDetailId, @intLastModifiedById

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

	IF ISNULL(@ysnMultiplePriceFixation,0) = 0
	BEGIN
		UPDATE	PF
		SET		PF.[dblTotalLots] = CAST(CD.dblNoOfLots AS INT)
		FROM	tblCTPriceFixation	PF
		JOIN	tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
		WHERE	CD.intContractHeaderId = @intContractHeaderId
	END
	
	EXEC uspCTUpdateAdditionalCost @intContractHeaderId

	IF EXISTS(SELECT * FROM tblCTContractImport WHERE strContractNumber = @strContractNumber AND ysnImported = 0)
	BEGIN
		UPDATE	tblCTContractImport
		SET		ysnImported = 1,
				intContractHeaderId = @intContractHeaderId
		WHERE	strContractNumber = @strContractNumber AND ysnImported = 0
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO