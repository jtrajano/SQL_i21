CREATE PROCEDURE [dbo].[uspCTSaveContract]
	
	@intContractHeaderId int,
	@strXML	NVARCHAR(MAX)
	
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
			@dblOriginalBasis			NUMERIC(18,6),
			@Action						NVARCHAR(100),
			@Condition					NVARCHAR(100),
			@idoc						INT,
			@intUniqueId				INT,
			@strRowState				NVARCHAR(100),
			@intNetWeightUOMId			INT,
			@dblNetWeight				NUMERIC(18,6),
			@intItemUOMId				INT

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
				@intLastModifiedById=	intLastModifiedById,
				@intNetWeightUOMId	=	intNetWeightUOMId,
				@dblNetWeight		=	dblNetWeight,
				@intItemUOMId		=	intItemUOMId
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId =	@intContractDetailId 
		
		IF ISNULL(@intNetWeightUOMId,0) > 0 AND @dblNetWeight IS NULL
		BEGIN
			UPDATE tblCTContractDetail SET dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,dblQuantity) WHERE intContractDetailId = @intContractDetailId
		END

		EXEC	uspCTSequencePriceChanged @intContractDetailId,null,'Sequence'
		
		IF @intPricingTypeId = 2 AND @dblOriginalBasis IS NULL
		BEGIN
			UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

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
		SET		PF.[dblTotalLots] = (SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId)
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

	--Slice
	EXEC uspQMSampleContractSlice @intContractHeaderId
	EXEC uspLGLoadContractSlice @intContractHeaderId
	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO