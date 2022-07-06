CREATE PROCEDURE [dbo].[uspCTGetPriceContractSequence]
	@intContractHeaderId NVARCHAR(MAX) = '0',
	@intContractDetailId NVARCHAR(MAX) = '0'
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX)
	
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractSeq ASC) AS INT) intUniqueId, *
		, dblConvertedBasis = CASE WHEN (SELECT 1 FROM tblCTCompanyPreference WHERE ysnEnableFreightBasis = 1) = 1
										THEN CASE WHEN strContractType = 'Purchase'
														THEN ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis) / 
															CASE WHEN intBasisCurrencyId = intCurrencyId THEN 1
																WHEN intBasisCurrencyId <> intCurrencyId AND ysnBasisSubCurrency = 1 THEN 100
																ELSE 0.01 END), 0)
															- ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId), 0)
												WHEN strContractType = 'Sale'
														THEN ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis) /
															CASE WHEN intBasisCurrencyId = intCurrencyId THEN 1
																WHEN intBasisCurrencyId <> intCurrencyId AND ysnBasisSubCurrency = 1 THEN 100
																ELSE 0.01 END), 0)
															+ ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId), 0) END
									ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis) /
										CASE WHEN intBasisCurrencyId = intCurrencyId THEN 1
											WHEN intBasisCurrencyId <> intCurrencyId AND ysnBasisSubCurrency = 1 THEN 100
											ELSE 0.01 END END
	FROM (
		SELECT CD.intContractHeaderId
			, CD.intContractDetailId
			, intOriginalFutureMarketId = CD.intFutureMarketId
			, intOriginalFutureMonthId = CD.intFutureMonthId
			, dblOriginalBasis = CD.dblBasis
			, dblTotalLots = ISNULL(tblLots.dblNoOfLots, 0)
			, dblAdditionalCost = CAST(NULL AS NUMERIC(18, 6))
			, intFinalPriceUOMId = CD.intPriceCommodityUOMId
			, dblQuantity = ISNULL(tblQuantity.dblQuantity, 0)
			, CD.intItemUOMId
			, CD.strPriceUOM
			, CD.strItemUOM
			, strFutureMarket = CD.strFutMarketName
			, CD.strFutureMonth
			, CD.intContractSeq
			, CD.strContractType
			, CD.intEntityId
			, CD.strEntityName
			, CD.strContractNumber
			, strMarketCurrency = CY.strCurrency
			, strMarketUOM = UM.strUnitMeasure
			, CD.ysnMultiplePriceFixation
			, CD.intCurrencyId
			, ysnSeqSubCurrency = SY.ysnSubCurrency
			, intMarketCurrencyId = MA.intCurrencyId
			, ysnMarketSubCurrency = CY.ysnSubCurrency
			, CD.intBasisCurrencyId
			, CD.ysnBasisSubCurrency
			, intBasisCommodityUOMId = BU.intCommodityUnitMeasureId 
			, CD.intDiscountScheduleCodeId
			, strDiscountScheduleCode = SI.strDescription 
			, CD.strPricingType
			, CD.dblRatio
			, CD.dblAppliedQty
			, CD.strBook
			, CD.strSubBook
			, CD.intNoOfLoad
			, CD.dblQuantityPerLoad
			, CD.intBookId
			, CD.intSubBookId
			, CD.dblFutures
			, intHeaderBookId = NULL
			, intHeaderSubBookId = NULL
			, intDetailBookId = CD.intBookId
			, intDetailSubBookId = CD.intSubBookId
			, CD.intContractStatusId
			, CD.ysnReadOnlyInterCoContract
		FROM vyuCTContractSequence		CD
		JOIN tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
			 								AND	CD.dblNoOfLots IS NOT NULL		 
			 								AND	ISNULL(CD.ysnMultiplePriceFixation, 0) = 0
			 								AND CD.intContractDetailId IN (SELECT ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractDetailId,','))
		JOIN tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId 
			 								AND PU.intUnitMeasureId =	IM.intUnitMeasureId
		JOIN tblRKFutureMarket			MA	ON	MA.intFutureMarketId=	CD.intFutureMarketId
		JOIN tblSMCurrency				CY	ON	CY.intCurrencyID	=	MA.intCurrencyId
		JOIN tblSMCurrency				SY	ON	SY.intCurrencyID	=	CD.intCurrencyId
		JOIN tblICUnitMeasure			UM	ON	UM.intUnitMeasureId	=	MA.intUnitMeasureId	
		LEFT JOIN tblICCommodityUnitMeasure	BU	ON	BU.intCommodityId	=	CD.intCommodityId 
			 								AND BU.intUnitMeasureId =	CD.intBasisUnitMeasureId
		LEFT JOIN tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
		LEFT JOIN tblICItem					SI	ON	SI.intItemId		=	SC.intItemId
		OUTER APPLY (
			SELECT SUM(dblNoOfLots) dblNoOfLots
			FROM (
				SELECT dblNoOfLots FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId
				UNION ALL SELECT dblNoOfLots FROM tblCTContractDetail WHERE intSplitFromId = CD.intContractDetailId
			) tbl
		) tblLots
		OUTER APPLY (
			SELECT SUM(dblQuantity) dblQuantity
			FROM (
				SELECT dblQuantity FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId
				UNION ALL SELECT dblQuantity FROM tblCTContractDetail WHERE intSplitFromId = CD.intContractDetailId
			) tbl
		) tblQuantity

		UNION ALL SELECT CH.intContractHeaderId
			, intContractDetailId = CAST(NULL AS INT)
			, intOriginalFutureMarketId = CH.intFutureMarketId
			, intOriginalFutureMonthId = CH.intFutureMonthId
			, dblOriginalBasis = CAST(NULL AS NUMERIC(18, 6))
			, dblTotalLots = CH.dblNoOfLots
			, dblAdditionalCost = CAST(NULL AS NUMERIC(18, 6))
			, intFinalPriceUOMId = CD.intPriceCommodityUOMId
			, CH.dblQuantity
			, intItemUOMId = CAST(NULL AS INT)
			, strPriceUOM = CD.strPriceUOM
			, strItemUOM = QM.strUnitMeasure
			, strFutureMarket = MA.strFutMarketName
			, strFutureMonth = REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ')--MO.strFutureMonth
			, intContractSeq = CAST(NULL AS INT)
			, CT.strContractType
			, CH.intEntityId
			, strEntityName = EY.strName
			, CH.strContractNumber
			, strMarketCurrency = CY.strCurrency
			, strMarketUOM = PM.strUnitMeasure
			, CH.ysnMultiplePriceFixation
			, CD.intCurrencyId
			, ysnSeqSubCurrency = CD.ysnSubCurrency
			, intMarketCurrencyId = MA.intCurrencyId
			, ysnMarketSubCurrency = CY.ysnSubCurrency
			, CD.intBasisCurrencyId
			, CD.ysnBasisSubCurrency
			, intBasisCommodityUOMId = BU.intCommodityUnitMeasureId
			, CD.intDiscountScheduleCodeId
			, strDiscountScheduleCode = SI.strDescription
			, CD.strPricingType
			, CD.dblRatio
			, CD.dblAppliedQty
			, BK.strBook
			, SB.strSubBook
			, CD.intNoOfLoad
			, CD.dblQuantityPerLoad
			, CH.intBookId
			, CH.intSubBookId
			, CD.dblFutures
			, intHeaderBookId = CH.intBookId
			, intHeaderSubBookId = CH.intSubBookId
			, intDetailBookId = NULL
			, intDetailSubBookId = NULL
			, CD.intContractStatusId
			, CH.ysnReadOnlyInterCoContract
		FROM tblCTContractHeader			CH	
		JOIN tblCTContractType			CT	ON	CT.intContractTypeId	=	CH.intContractTypeId
			 								AND CH.intContractHeaderId  IN (SELECT ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractHeaderId,','))
			 								AND	ISNULL(ysnMultiplePriceFixation, 0) = 1
			 								AND	CH.intContractHeaderId	IN	(SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId <> 2)
		JOIN tblEMEntity					EY	ON	EY.intEntityId			=	CH.intEntityId
		JOIN tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId
		JOIN tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CH.intFutureMarketId
		JOIN tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CH.intCommodityId 
			 								AND CU.intUnitMeasureId		=	MA.intUnitMeasureId
		JOIN tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	CH.intFutureMonthId
		JOIN tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN tblICUnitMeasure			PM	ON	PM.intUnitMeasureId		=	MA.intUnitMeasureId			
		CROSS APPLY (
			SELECT TOP 1 CDetail.intCurrencyId
				, ysnSubCurrency = CAST(ISNULL(CU.intMainCurrencyId, 0) AS BIT)
				, CDetail.intBasisCurrencyId
				, ysnBasisSubCurrency = SY.ysnSubCurrency
				, CDetail.intDiscountScheduleCodeId
				, strPricingType = PT.strPricingType
				, CDetail.dblRatio
				, dblAppliedQty = CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CDetail.intNoOfLoad, 0) - ISNULL(CDetail.dblBalanceLoad, 0)
									ELSE ISNULL(CDetail.dblQuantity, 0) - ISNULL(CDetail.dblBalance, 0) END
				, CDetail.intNoOfLoad
				, CDetail.dblQuantityPerLoad
				, CDetail.dblFutures
				, intBasisUnitMeasureId = BU.intUnitMeasureId
				, CDetail.intContractStatusId
				, intPriceCommodityUOMId = CUOM.intCommodityUnitMeasureId
				, strPriceUOM = UOM.strUnitMeasure
			FROM tblCTContractDetail CDetail
			JOIN tblCTContractHeader header ON header.intContractHeaderId = CDetail.intContractHeaderId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CDetail.intCurrencyId
			LEFT JOIN tblSMCurrency SY ON SY.intCurrencyID = CDetail.intBasisCurrencyId
			LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CDetail.intPricingTypeId
			LEFT JOIN tblICItemUOM BU ON BU.intItemUOMId = CDetail.intBasisUOMId
			LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = CDetail.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityId = header.intCommodityId AND CUOM.intUnitMeasureId = IUOM.intUnitMeasureId
			WHERE CDetail.intContractHeaderId IN (SELECT CONVERT(INT, ISNULL(Item, '0')) FROM dbo.fnSplitString(@intContractHeaderId, ','))
		) CD
		LEFT	JOIN	tblCTBook					BK	ON	BK.intBookId			=	CH.intBookId
		LEFT	JOIN	tblCTSubBook				SB	ON	SB.intSubBookId			=	CH.intSubBookId
		LEFT	JOIN	tblICCommodityUnitMeasure	BU	ON	BU.intCommodityId		=	CH.intCommodityId
														AND BU.intUnitMeasureId		=	CD.intBasisUnitMeasureId
		LEFT    JOIN	tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
		LEFT	JOIN	tblICItem					SI	ON	SI.intItemId			=	SC.intItemId
	)t

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH