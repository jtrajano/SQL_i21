CREATE PROCEDURE [dbo].[uspCTUpdateAdditionalCost]
	
	@intContractHeaderId int
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblCashPrice				NUMERIC(18,6),
			@dblNewAdditionalCost		NUMERIC(18,6),
			@intFinalPriceUOMId			INT,
			@dblAdditionalCost			NUMERIC(18,6),
			@dblFinalPrice				NUMERIC(18,6),
			@intPriceFixationId			INT,
			@intCommodityId				INT
			
	SELECT @intCommodityId	=	intCommodityId FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId 
	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT 	@intPriceFixationId = NULL
		
		SELECT	@intPriceFixationId	=	intPriceFixationId,
				@intFinalPriceUOMId =	intFinalPriceUOMId, 
				@dblAdditionalCost	=	dblAdditionalCost,
				@dblFinalPrice		=	dblFinalPrice
		FROM	tblCTPriceFixation 
		WHERE	intContractDetailId = @intContractDetailId
		
		IF ISNULL(@intPriceFixationId,0) > 0
		BEGIN
			SELECT	@dblNewAdditionalCost = 
					SUM(
					CASE	WHEN CC.strCostMethod = 'Per Unit' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFinalPriceUOMId,CM.intCommodityUnitMeasureId,CC.dblRate)
							WHEN CC.strCostMethod = 'Amount' THEN CC.dblRate
					END
					)
			FROM tblCTContractCost				CC
			LEFT JOIN tblICItemUOM				IM	ON	IM.intItemUOMId		=	CC.intItemUOMId
			LEFT JOIN tblICCommodityUnitMeasure CM	ON	CM.intUnitMeasureId =	IM.intUnitMeasureId AND 
														CM.intCommodityId	=	@intCommodityId
			WHERE	CC.intContractDetailId = @intContractDetailId AND CC.ysnAdditionalCost = 1

			UPDATE	tblCTPriceFixation 
			SET		dblAdditionalCost	=	@dblNewAdditionalCost,
					dblFinalPrice		=	@dblFinalPrice - ISNULL(@dblAdditionalCost,0) + ISNULL(@dblNewAdditionalCost,0)
			WHERE	intPriceFixationId	=	@intPriceFixationId
		END
		
		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH