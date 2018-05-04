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
		
		UPDATE  CC
		SET	    CC.dblAccruedAmount	=	(CASE	
												WHEN	CC.strCostMethod = 'Per Unit'	THEN 
																							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
												WHEN	CC.strCostMethod = 'Amount'		THEN
																							CC.dblRate
												WHEN	CC.strCostMethod = 'Percentage' THEN 
																							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
										END)*CC.dblRemainingPercent/100
		FROM	tblCTContractCost	CC
		JOIN	tblCTContractDetail	CD	   ON CD.intContractDetailId	=	CC.intContractDetailId
		LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
		LEFT JOIN	tblICItemUOM		PU ON PU.intItemUOMId			=	CD.intPriceItemUOMId	
		LEFT JOIN	tblICItemUOM		QU ON QU.intItemUOMId			=	CD.intItemUOMId	
		LEFT JOIN	tblICItemUOM		CM ON CM.intUnitMeasureId		=	IU.intUnitMeasureId
									    AND CM.intItemId				=	CD.intItemId		
		WHERE	CC.intContractDetailId = @intContractDetailId

		UPDATE  CC
		SET	    CC.dblActualAmount = tblBilled.dblTotal
		FROM	tblCTContractCost	CC
		JOIN ( 
			   SELECT intContractCostId,SUM(dblTotal) dblTotal 
			   FROM tblAPBillDetail 
			   WHERE intContractCostId > 0 
			   GROUP BY intContractCostId
			 ) tblBilled ON tblBilled.intContractCostId = CC.intContractCostId
       
		/*
		JOIN	(
					SELECT Bill.intEntityVendorId
						  ,BillDetail.intContractDetailId
						  ,BillDetail.intItemId
						  ,SUM(BillDetail.dblTotal)  dblTotal
					FROM tblAPBillDetail BillDetail
					JOIN tblAPBill Bill ON Bill.intBillId = BillDetail.intBillId
					JOIN tblICItem Item ON Item.intItemId = BillDetail.intItemId
					WHERE 
						Item.strType ='Other Charge' 
					AND Item.strCostType IN('Freight','Commission')
					AND ISNULL(BillDetail.intContractDetailId,0) <> 0
					GROUP BY Bill.intEntityVendorId
							,BillDetail.intContractDetailId
							,BillDetail.intItemId
				) tblBilled ON tblBilled.intContractDetailId = CD.intContractDetailId 
			 AND  tblBilled.intItemId						 = CC.intItemId 
			 AND  tblBilled.intEntityVendorId				 = CH.intEntityId
		  */			
		WHERE	CC.intContractDetailId = @intContractDetailId

		UPDATE	CC 
		SET		CC.intItemUOMId		=	CU.intItemUOMId
		FROM	tblCTContractCost	CC
		JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intPriceItemUOMId
		JOIN	tblICItemUOM		CU	ON	CU.intItemId			=	CC.intItemId
										AND	CU.intUnitMeasureId		=	IU.intUnitMeasureId
		WHERE	CC.intContractDetailId = @intContractDetailId AND CC.ysnBasis = 1

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH