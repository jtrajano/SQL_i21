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
			@intCommodityId				INT,
			@ysnEnableBudgetForBasisPricing BIT

	declare @intFinanceCostId Int
			
	SELECT @intCommodityId	=	intCommodityId FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId 
	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	SELECT TOP 1 @ysnEnableBudgetForBasisPricing = ysnEnableBudgetForBasisPricing, @intFinanceCostId = intFinanceCostId FROM tblCTCompanyPreference
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT 	@intPriceFixationId = NULL
		
		SELECT	@intPriceFixationId	=	intPriceFixationId,
				@intFinalPriceUOMId =	intFinalPriceUOMId, 
				@dblAdditionalCost	=	dblAdditionalCost,
				@dblFinalPrice		=	dblFinalPrice
		FROM	tblCTPriceFixation 
		WHERE intContractHeaderId = @intContractHeaderId
		AND intContractDetailId = @intContractDetailId
		
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
		SET	    CC.dblAccruedAmount	=	(CASE	WHEN CC.strCostMethod = 'Per Unit'
													THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, CM.intUnitMeasureId, CD.dblQuantity) * CC.dblRate * CASE WHEN CD.intCurrencyId != CD.intInvoiceCurrencyId THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
												WHEN CC.strCostMethod = 'Amount'
													THEN CC.dblRate *  CASE WHEN @intFinanceCostId =  CC.intItemId  THEN 1 
																		ELSE 
																			CASE WHEN CD.intCurrencyId != CC.intCurrencyId 
																			THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
																		END
												WHEN CC.strCostMethod = 'Per Container'
													THEN (CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers, 1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers, 1) END)) * ISNULL(CC.dblFX, 1)
												WHEN CC.strCostMethod = 'Percentage'
													THEN
															CASE WHEN @intFinanceCostId <> CC.intItemId THEN
																 CASE WHEN CD.intPricingTypeId <> 2 THEN  
																  dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, PU.intUnitMeasureId, CD.dblQuantity)   
																  * (CD.dblCashPrice / (CASE WHEN ISNULL(CY2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(CY2.intCent, 1) ELSE 1 END))  
																  * CC.dblRate/100   
																 ELSE  
																  CASE WHEN @ysnEnableBudgetForBasisPricing = CONVERT(BIT, 1) THEN    
																   CD.dblTotalBudget  * (CC.dblRate/100)  
																  ELSE  
																   dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, PU.intUnitMeasureId, CD.dblQuantity)   
																   * ((FSPM.dblLastSettle + CD.dblBasis) / (CASE WHEN ISNULL(CY2.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(CY2.intCent, 1) ELSE 1 END))  
																   * CC.dblRate/100  
																  END  
																 END  
															ELSE
															CC.dblRate
															END

												END)
										/ (CASE WHEN ISNULL(CY.ysnSubCurrency, CONVERT(BIT, 0)) = CONVERT(BIT, 1) THEN ISNULL(CY.intCent, 1) ELSE 1 END)
		FROM	tblCTContractCost	CC
		JOIN	tblCTContractDetail	CD	   ON CD.intContractDetailId	=	CC.intContractDetailId
		LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
		LEFT JOIN	tblICItemUOM		PU ON PU.intItemUOMId			=	CD.intPriceItemUOMId	
		LEFT JOIN	tblICItemUOM		QU ON QU.intItemUOMId			=	CD.intItemUOMId	
		LEFT JOIN	tblICItemUOM		CM ON CM.intUnitMeasureId		=	IU.intUnitMeasureId
									    AND CM.intItemId				=	CD.intItemId
		LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
		LEFT JOIN	tblSMCurrency		CY2	ON	CY2.intCurrencyID		=	CD.intCurrencyId
		LEFT JOIN  (
		select intFutureMarketId, MAX(intFutureSettlementPriceId) intFutureSettlementPriceId, MAX( dtmPriceDate) dtmPriceDate
		from tblRKFuturesSettlementPrice a
		Group by intFutureMarketId, intCommodityMarketId
	
		) FSP on FSP.intFutureMarketId = CD.intFutureMarketId
		LEFT JOIN tblRKFutSettlementPriceMarketMap FSPM on FSPM.intFutureSettlementPriceId = FSP.intFutureSettlementPriceId and CD.intFutureMonthId = FSPM.intFutureMonthId
		WHERE	CC.intContractDetailId = @intContractDetailId

		UPDATE  CC
		SET	    CC.dblActualAmount = tblBilled.dblTotal
		FROM	tblCTContractCost	CC
		JOIN	(
					SELECT Bill.intEntityVendorId
						  ,BillDetail.intContractDetailId
						  ,BillDetail.intItemId
						  ,SUM(BillDetail.dblTotal)  dblTotal
					FROM tblAPBillDetail BillDetail
					JOIN tblAPBill Bill ON Bill.intBillId = BillDetail.intBillId
					JOIN tblICItem Item ON Item.intItemId = BillDetail.intItemId
					WHERE  Item.strType ='Other Charge'
					AND ISNULL(BillDetail.intContractDetailId,0) <> 0
					GROUP BY Bill.intEntityVendorId
							,BillDetail.intContractDetailId
							,BillDetail.intItemId
				) tblBilled ON tblBilled.intContractDetailId = CC.intContractDetailId 
			 AND  tblBilled.intItemId						 = CC.intItemId 
			 AND  tblBilled.intEntityVendorId				 = CC.intVendorId
		WHERE	CC.intContractDetailId = @intContractDetailId

		/*CT-4526 ---Commented this block, intItemUOMId should be based on sequence basis Unit Measure and Cost Item --*/
		/*
		UPDATE	CC 
		SET		CC.intItemUOMId		=	CU.intItemUOMId
		FROM	tblCTContractCost	CC
		JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CD.intPriceItemUOMId
		JOIN	tblICItemUOM		CU	ON	CU.intItemId			=	CC.intItemId
										AND	CU.intUnitMeasureId		=	IU.intUnitMeasureId
		WHERE	CC.intContractDetailId = @intContractDetailId AND CC.ysnBasis = 1

		*/

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH