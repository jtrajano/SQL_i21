CREATE PROCEDURE [dbo].[uspCTLoadContractCost]
	@intContractDetailId INT

AS

	 Declare @ysnEnableBudgetForBasisPricing BIT  
	 declare @intFinanceCostId Int
	 SELECT TOP 1 @ysnEnableBudgetForBasisPricing = ysnEnableBudgetForBasisPricing, @intFinanceCostId = intFinanceCostId FROM tblCTCompanyPreference  

	SELECT CC.intContractCostId
		, CC.intConcurrencyId
		, CC.intPrevConcurrencyId
		, CC.intContractDetailId
		, CC.intItemId
		, CC.intVendorId
		, CC.strCostMethod
		, CC.intCurrencyId
		, CC.dblRate
		, CC.intItemUOMId
		, CC.intRateTypeId
		, CC.dblFX
		, CC.ysnAccrue
		, CC.ysnMTM
		, CC.ysnPrice
		, CC.ysnAdditionalCost
		, CC.ysnBasis
		, CC.ysnReceivable
		, CC.strParty
		, CC.strPaidBy
		, CC.dtmDueDate
		, CC.strReference
		, CC.ysn15DaysFromShipment
		, CC.strRemarks
		, CC.strStatus
		, CC.strCostStatus
		, CC.dblReqstdAmount
		, CC.dblRcvdPaidAmount
		, dblActualAmount = ISNULL(CC.dblActualAmount, 0.00)
		, CC.dblAccruedAmount
		, CC.dblRemainingPercent
		, CC.dtmAccrualDate
		, CC.strAPAR
		, CC.strPayToReceiveFrom
		, CC.strReferenceNo
		, CC.intContractCostRefId
		, ysnFromBasisComponent = CC.ysnBasis
		, IM.strItemNo
		, strItemDescription = IM.strDescription
		, strUOM = UM.strUnitMeasure
		, strVendorName = EY.strName
		, CD.intContractHeaderId
		, IU.intUnitMeasureId
		, CD.intContractSeq
		, CY.strCurrency
		, strContractSeq = CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)
		, ysnBilled = CAST(ISNULL((SELECT TOP 1 intBillDetailId FROM tblAPBillDetail WHERE intContractCostId = CC.intContractCostId),0) AS BIT)
		, CH.intTermId
		, IM.strCostType
		, IM.ysnInventoryCost
		, CH.strContractNumber
		, CH.dtmContractDate
		, strMainCurrency = MY.strCurrency
		, dblAmount = (CASE	WHEN CC.strCostMethod = 'Per Unit'
								THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, CM.intUnitMeasureId, CD.dblQuantity) * CC.dblRate * CASE WHEN CD.intCurrencyId != CD.intInvoiceCurrencyId THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
							WHEN CC.strCostMethod = 'Amount'
								THEN CC.dblRate * CASE WHEN @intFinanceCostId =  CC.intItemId  THEN 1 
												  ELSE 
														CASE WHEN CD.intCurrencyId !=  CC.intCurrencyId 
														THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
												  END
							WHEN CC.strCostMethod = 'Per Container'
								THEN (CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers, 1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers, 1) END)) * CASE WHEN CD.intCurrencyId != CD.intInvoiceCurrencyId THEN  ISNULL(CC.dblFX, 1) ELSE 1 END
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
		, RT.strCurrencyExchangeRateType
		, intHeaderBookId = CH.intBookId
		, intHeaderSubBookId = CH.intSubBookId
		, intDetailBookId = CD.intBookId
		, intDetailSubBookId = CD.intSubBookId
		, CD.dblQuantity
	FROM		tblCTContractCost	CC
	JOIN		tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
										AND CC.intContractDetailId  =	@intContractDetailId	
	JOIN		tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN		tblICItem			IM	ON	IM.intItemId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	IU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrency		CY2	ON	CY2.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblSMCurrency		MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId
	LEFT JOIN	tblEMEntity			EY	ON	EY.intEntityId			=	CC.intVendorId
	LEFT JOIN	tblEMEntityType		ET	ON	ET.intEntityId			=	EY.intEntityId
										AND ET.strType				=	'Vendor'
	LEFT JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
	LEFT JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId	
	LEFT JOIN	tblICItemUOM		CM	ON	CM.intUnitMeasureId		=	IU.intUnitMeasureId
										AND CM.intItemId			=	CD.intItemId	
	LEFT JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CC.intRateTypeId
	LEFT JOIN	tblCTBasisCost	    BC	ON	BC.intItemId			=	CC.intItemId
	LEFT JOIN  (
		select intFutureMarketId, MAX(intFutureSettlementPriceId) intFutureSettlementPriceId, MAX( dtmPriceDate) dtmPriceDate
		from tblRKFuturesSettlementPrice a
		Group by intFutureMarketId, intCommodityMarketId
	
	) FSP on FSP.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFutSettlementPriceMarketMap FSPM on FSPM.intFutureSettlementPriceId = FSP.intFutureSettlementPriceId and CD.intFutureMonthId = FSPM.intFutureMonthId	
	ORDER BY BC.intSort ASC