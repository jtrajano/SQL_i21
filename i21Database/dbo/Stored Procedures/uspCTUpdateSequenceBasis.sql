CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBasis]

	@intContractDetailId	INT,
	@dblNewBasis			NUMERIC(18,6)

AS
	DECLARE @intPriceFixationId INT

	SELECT @intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId

	IF @intPriceFixationId IS NULL RETURN

	UPDATE tblCTContractDetail SET dblOriginalBasis = @dblNewBasis WHERE intContractDetailId = @intContractDetailId

	UPDATE	FD
	SET		FD.dblBasis		 =	@dblNewBasis, 
			FD.dblCashPrice	 =	FD.dblCashPrice - FD.dblBasis + @dblNewBasis,
			FD.dblFinalPrice =	FD.dblFinalPrice - 
								dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intPricingUOMId,FD.dblBasis) + 
								dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intPricingUOMId,@dblNewBasis)
	FROM	tblCTPriceFixationDetail	FD
	JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId = FD.intPriceFixationId
	WHERE	FD.intPriceFixationId = @intPriceFixationId

	
	UPDATE PF
	SET		PF.dblPriceWORollArb =	PF.dblPriceWORollArb - 
									dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,PF.dblOriginalBasis) +
									dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,@dblNewBasis),
			PF.dblOriginalBasis	 =	@dblNewBasis

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractDetail			CD	ON	PF.intContractDetailId	=	CD.intContractDetailId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICItemUOM				IU	ON	IU.intItemUOMId			=	CD.intPriceItemUOMId
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CH.intCommodityId
											AND	CU.intUnitMeasureId		=	IU.intUnitMeasureId
	WHERE	PF.intPriceFixationId = @intPriceFixationId