CREATE PROCEDURE [dbo].[uspCTGetPriceContractSequence]
		
	@intContractHeaderId NVARCHAR(MAX) = '0',
	@intContractDetailId NVARCHAR(MAX) = '0'
	
AS

BEGIN TRY
	
	DECLARE
		@ErrMsg	NVARCHAR(MAX)
		,@ysnMultiplePriceFixation bit
		;

	select
		top 1 @ysnMultiplePriceFixation = isnull(ch.ysnMultiplePriceFixation,0)
	from
		tblCTContractDetail cd 
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	where
		cd.intContractHeaderId = (case when isnull(@intContractHeaderId,'0') = '0' then cd.intContractHeaderId else (SELECT top 1 ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractHeaderId,',')) end)
		and cd.intContractDetailId = (case when isnull(@intContractDetailId,'0') = '0' then cd.intContractDetailId else (SELECT top 1 ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractDetailId,',')) end)

	if (@ysnMultiplePriceFixation = 1)
	begin
	
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractSeq ASC) AS INT) intUniqueId,
				*,
				CASE	WHEN (SELECT 1 FROM tblCTCompanyPreference WHERE ysnEnableFreightBasis = 1) = 1 THEN 
							CASE	WHEN strContractType = 'Purchase' THEN
											ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
											CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
													WHEN	intBasisCurrencyId <> intCurrencyId 
													AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
											END),0) - ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId),0)
									WHEN strContractType = 'Sale' THEN
											ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
											CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
													WHEN	intBasisCurrencyId <> intCurrencyId 
													AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
											END),0) + ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId),0)
									END
					ELSE
							dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
							CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
									WHEN	intBasisCurrencyId <> intCurrencyId 
									AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
							END
				END AS dblConvertedBasis			 
		FROM
		(
			SELECT 	CH.intContractHeaderId,
					CAST (NULL AS INT)    AS intContractDetailId,
					CH.intFutureMarketId			AS	intOriginalFutureMarketId,
					CH.intFutureMonthId				AS	intOriginalFutureMonthId,
					CAST (NULL AS NUMERIC(18,6))	AS	dblOriginalBasis,
					CH.dblNoOfLots					AS	dblTotalLots,
					CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
					CU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
					CH.dblQuantity,
					CAST (NULL AS INT)				AS	intItemUOMId,
					PM.strUnitMeasure				AS	strPriceUOM,
					QM.strUnitMeasure				AS	strItemUOM,
					MA.strFutMarketName				AS	strFutureMarket,
					MO.strFutureMonth				AS	strFutureMonth,
					CAST (NULL AS INT)				AS	intContractSeq,
					CT.strContractType,
					CH.intEntityId,
					EY.strName						AS	strEntityName,
					CH.strContractNumber,					
					CY.strCurrency					AS	strMarketCurrency,
					PM.strUnitMeasure				AS	strMarketUOM,				
					CH.ysnMultiplePriceFixation,
					CD.intCurrencyId,
					CD.ysnSubCurrency				AS	ysnSeqSubCurrency,
					MA.intCurrencyId				AS	intMarketCurrencyId,
					CY.ysnSubCurrency				AS	ysnMarketSubCurrency,
					CD.intBasisCurrencyId,
					CD.ysnBasisSubCurrency,
					BU.intCommodityUnitMeasureId	AS	intBasisCommodityUOMId,			
					CD.intDiscountScheduleCodeId,
					SI.strDescription				AS	strDiscountScheduleCode,
					CD.strPricingType,
					CD.dblRatio,
					CD.dblAppliedQty,
					BK.strBook,
					SB.strSubBook,
					CD.intNoOfLoad,
					CD.dblQuantityPerLoad,
					CH.intBookId,	
					CH.intSubBookId,
					CD.dblFutures
				
					,intHeaderBookId = NULL
					,intHeaderSubBookId = null
					,intDetailBookId = NULL
					,intDetailSubBookId = null
					,CH.ysnReadOnlyInterCoContract

			FROM	tblCTContractHeader			CH	
			JOIN	tblCTContractType			CT	ON	CT.intContractTypeId	=	CH.intContractTypeId
			JOIN	tblEMEntity					EY	ON	EY.intEntityId			=	CH.intEntityId
			JOIN	tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
			JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId
			JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CH.intFutureMarketId
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CH.intCommodityId 
													AND CU.intUnitMeasureId		=	MA.intUnitMeasureId
			JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	CH.intFutureMonthId
			JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
			JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId		=	MA.intUnitMeasureId
			CROSS APPLY
			(
				SELECT TOP 1
				CDetail.intCurrencyId
				,ysnSubCurrency = CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT)
				,CDetail.intBasisCurrencyId
				,ysnBasisSubCurrency = SY.ysnSubCurrency
				,CDetail.intDiscountScheduleCodeId
				,strPricingType = PT.strPricingType
				,CDetail.dblRatio
				,dblAppliedQty = CASE
									WHEN CH.ysnLoad = 1 THEN ISNULL(CDetail.intNoOfLoad,0) - ISNULL(CDetail.dblBalanceLoad,0)
									ELSE ISNULL(CDetail.dblQuantity,0) - ISNULL(CDetail.dblBalance,0)
								END
				,CDetail.intNoOfLoad
				,CDetail.dblQuantityPerLoad
				,CDetail.dblFutures
				,intBasisUnitMeasureId = BU.intUnitMeasureId	
				FROM tblCTContractDetail CDetail
				LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CDetail.intCurrencyId
				LEFT JOIN tblSMCurrency SY ON SY.intCurrencyID = CDetail.intBasisCurrencyId
				LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CDetail.intPricingTypeId
				LEFT JOIN tblICItemUOM BU ON BU.intItemUOMId = CDetail.intBasisUOMId
				WHERE intContractHeaderId in (SELECT convert(int,ISNULL(Item,'0')) FROM dbo.fnSplitString(@intContractHeaderId,','))    
			) CD


			LEFT	JOIN	tblCTBook					BK	ON	BK.intBookId			=	CH.intBookId						
			LEFT	JOIN	tblCTSubBook				SB	ON	SB.intSubBookId			=	CH.intSubBookId	
			LEFT	JOIN	tblICCommodityUnitMeasure	BU	ON	BU.intCommodityId		=	CH.intCommodityId 
															AND BU.intUnitMeasureId		=	CD.intBasisUnitMeasureId
			LEFT    JOIN	tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
			LEFT	JOIN	tblICItem					SI	ON	SI.intItemId		=	SC.intItemId
			where
				CH.intContractHeaderId  IN (SELECT ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractHeaderId,','))
				AND	ISNULL(ysnMultiplePriceFixation, 0) = 1
				AND	CH.intContractHeaderId	IN	(SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId <> 2)
		)t

	end
	else
	begin
	
		SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractSeq ASC) AS INT) intUniqueId,
				*,
				CASE	WHEN (SELECT 1 FROM tblCTCompanyPreference WHERE ysnEnableFreightBasis = 1) = 1 THEN 
							CASE	WHEN strContractType = 'Purchase' THEN
											ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
											CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
													WHEN	intBasisCurrencyId <> intCurrencyId 
													AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
											END),0) - ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId),0)
									WHEN strContractType = 'Sale' THEN
											ISNULL((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
											CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
													WHEN	intBasisCurrencyId <> intCurrencyId 
													AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
											END),0) + ISNULL((SELECT dblFreightBasis FROM tblCTContractDetail WHERE intContractDetailId = t.intContractDetailId),0)
									END
					ELSE
							dbo.fnCTConvertQuantityToTargetCommodityUOM(intFinalPriceUOMId,intBasisCommodityUOMId,dblOriginalBasis)/ 
							CASE	WHEN	intBasisCurrencyId = intCurrencyId	THEN 1
									WHEN	intBasisCurrencyId <> intCurrencyId 
									AND		ysnBasisSubCurrency = 1				THEN 100 ELSE 0.01 
							END
				END AS dblConvertedBasis			 
		FROM
		(
			SELECT	CD.intContractHeaderId,
					CD.intContractDetailId,
					CD.intFutureMarketId intOriginalFutureMarketId,
					CD.intFutureMonthId intOriginalFutureMonthId,
					CD.dblBasis dblOriginalBasis,
					dblTotalLots = ISNULL(tblLots.dblNoOfLots,0),
					CAST(NULL AS NUMERIC(18,6))		AS	dblAdditionalCost,
					 PU.intCommodityUnitMeasureId	AS	intFinalPriceUOMId,
					dblQuantity = ISNULL(tblQuantity.dblQuantity,0),				
					CD.intItemUOMId,
					CD.strPriceUOM,
					CD.strItemUOM,
					CD.strFutMarketName				AS strFutureMarket,
					CD.strFutureMonth,
					CD.intContractSeq,
					CD.strContractType,
					CD.intEntityId,
					CD.strEntityName,
					CD.strContractNumber,
					CY.strCurrency					AS strMarketCurrency,
					UM.strUnitMeasure				AS strMarketUOM,				
					CD.ysnMultiplePriceFixation,
					CD.intCurrencyId,
					SY.ysnSubCurrency				AS	ysnSeqSubCurrency,
					MA.intCurrencyId				AS	intMarketCurrencyId,
					CY.ysnSubCurrency				AS	ysnMarketSubCurrency,
					CD.intBasisCurrencyId,
					CD.ysnBasisSubCurrency,
					BU.intCommodityUnitMeasureId	AS	intBasisCommodityUOMId,
					CD.intDiscountScheduleCodeId,
					SI.strDescription				AS	strDiscountScheduleCode,
					CD.strPricingType,
					CD.dblRatio,
					CD.dblAppliedQty,
					CD.strBook,
					CD.strSubBook,
					CD.intNoOfLoad,
					CD.dblQuantityPerLoad,
					CD.intBookId,	
					CD.intSubBookId,
					CD.dblFutures

					,intHeaderBookId = NULL
					,intHeaderSubBookId = null
					,intDetailBookId = NULL
					,intDetailSubBookId = null
					,CD.ysnReadOnlyInterCoContract

			FROM	vyuCTContractSequence		CD
			JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
			JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId 
													AND PU.intUnitMeasureId =	IM.intUnitMeasureId
			JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId=	CD.intFutureMarketId
			JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID	=	MA.intCurrencyId
			JOIN	tblSMCurrency				SY	ON	SY.intCurrencyID	=	CD.intCurrencyId
			JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId	=	MA.intUnitMeasureId	
			LEFT	JOIN	tblICCommodityUnitMeasure	BU	ON	BU.intCommodityId	=	CD.intCommodityId 
															AND BU.intUnitMeasureId =	CD.intBasisUnitMeasureId
			LEFT    JOIN	tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
			LEFT	JOIN	tblICItem					SI	ON	SI.intItemId		=	SC.intItemId
			OUTER APPLY
			(
				SELECT SUM(dblNoOfLots) dblNoOfLots
				FROM 
				(
					SELECT	dblNoOfLots dblNoOfLots
					FROM	tblCTContractDetail
					WHERE	intContractDetailId = CD.intContractDetailId				
					UNION ALL
					SELECT	dblNoOfLots dblNoOfLots
					FROM	tblCTContractDetail
					WHERE	intSplitFromId = CD.intContractDetailId
				) tbl
			) tblLots
			OUTER APPLY
			(
				SELECT SUM(dblQuantity) dblQuantity
				FROM 
				(
					SELECT	dblQuantity
					FROM	tblCTContractDetail
					WHERE	intContractDetailId = CD.intContractDetailId
					UNION ALL
					SELECT	dblQuantity
					FROM	tblCTContractDetail
					WHERE	intSplitFromId = CD.intContractDetailId
				) tbl
			) tblQuantity
			where
				CD.dblNoOfLots IS NOT NULL		 
				AND	ISNULL(CD.ysnMultiplePriceFixation, 0) = 0
				AND CD.intContractDetailId IN (SELECT ISNULL(Item,'0') FROM dbo.fnSplitString(@intContractDetailId,','))
		)t

	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH