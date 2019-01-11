CREATE PROCEDURE [dbo].[uspCTLoadPriceContractFixation]
	
	@intPriceContractId INT
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX)
	
		DECLARE @temp AS TABLE
		(
			[intPriceFixationId] [int] NULL,
			[intPriceContractId] [int] NULL,
			[intConcurrencyId] [int] NULL,
			[intContractHeaderId] [int] NULL,
			[intContractDetailId] [int] NULL,
			[intOriginalFutureMarketId] [int] NULL,
			[intOriginalFutureMonthId] [int] NULL,
			[dblOriginalBasis] [numeric](18, 6) NULL,
			[dblTotalLots] [numeric](18, 6) NULL,
			[dblLotsFixed] [numeric](18, 6) NULL,
			[intLotsHedged] [int] NULL,
			[dblPolResult] [numeric](18, 6) NULL,
			[dblPremiumPoints] [numeric](18, 6) NULL,
			[ysnAAPrice] [bit] NULL,
			[ysnSettlementPrice] [bit] NULL,
			[ysnToBeAgreed] [bit] NULL,
			[dblSettlementPrice] [numeric](18, 6) NULL,
			[dblAgreedAmount] [numeric](18, 6) NULL,
			[intAgreedItemUOMId] [int] NULL,
			[dblPolPct] [numeric](18, 6) NULL,
			[dblPriceWORollArb] [numeric](18, 6) NULL,
			[dblRollArb] [numeric](18, 6) NULL,
			[dblPolSummary] [numeric](18, 6) NULL,
			[dblAdditionalCost] [numeric](18, 6) NULL,
			[dblFinalPrice] [numeric](18, 6) NULL,
			[intFinalPriceUOMId] [int] NULL,
			[ysnSplit] [bit] NULL,
			[dblQuantity] [numeric](18, 6) NULL,
			[strPriceUOM] [nvarchar](50) NULL,
			[strItemUOM] [nvarchar](50) NULL,
			[intItemUOMId] [int] NULL,
			[intFutureMarketId] [int] NULL,
			[strFutureMarket] [nvarchar](30) NULL,
			[intFutureMonthId] [int] NULL,
			[strFutureMonth] [nvarchar](20) NULL,
			[intContractSeq] [int] NULL,
			[strContractType] [nvarchar](50) NULL,
			[strEntityName] [nvarchar](100) NULL,
			[strContractNumber] [nvarchar](50) NULL,
			[dblConvertedBasis] [numeric](18, 6) NULL,
			[strMarketCurrency] [nvarchar](40) NULL,
			[strMarketUOM] [nvarchar](50) NULL,
			[ysnMultiplePriceFixation] [bit] NULL,
			[intCurrencyId] [int] NULL,
			[ysnSeqSubCurrency] [bit] NULL,
			[intMarketCurrencyId] [int] NULL,
			[ysnMarketSubCurrency] [bit] NULL,
			[intBasisCurrencyId] [int] NULL,
			[ysnBasisSubCurrency] BIT NULL,
			[intBasisCommodityUOMId] [int] NULL,
			[intDiscountScheduleCodeId] [int] NULL,
			[strDiscountScheduleCode] [nvarchar](250) NULL,
			[strPricingType] [nvarchar](100) NULL,
			[dblRatio] [numeric](18, 6) NULL,
			[dblAppliedQty] [numeric](18, 6) NULL
		) 

		SELECT * INTO #tblCTPriceFixation FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId

		INSERT INTO @temp 

		SELECT	PF.intPriceFixationId,
				PF.intPriceContractId,
				PF.intConcurrencyId,
				PF.intContractHeaderId,
				PF.intContractDetailId,
				PF.intOriginalFutureMarketId,
				PF.intOriginalFutureMonthId,
				PF.dblOriginalBasis,
				PF.dblTotalLots,
				PF.dblLotsFixed,
				PF.intLotsHedged,
				PF.dblPolResult,
				PF.dblPremiumPoints,
				PF.ysnAAPrice,
				PF.ysnSettlementPrice,
				PF.ysnToBeAgreed,
				PF.dblSettlementPrice,
				PF.dblAgreedAmount,
				PF.intAgreedItemUOMId,
				PF.dblPolPct,
				PF.dblPriceWORollArb,
				PF.dblRollArb,
				PF.dblPolSummary,
				PF.dblAdditionalCost,
				PF.dblFinalPrice,
				PF.intFinalPriceUOMId,
				PF.ysnSplit,

				(SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE CD.intContractDetailId IN (intContractDetailId,intSplitFromId)) AS dblQuantity,
				CD.strPriceUOM,
				CD.strItemUOM,
				CD.intItemUOMId,
				CD.intFutureMarketId,
				CD.strFutMarketName AS strFutureMarket,
				CD.intFutureMonthId,
				CD.strFutureMonth,
				CD.intContractSeq,
				CD.strContractType,
				CD.strEntityName,
				CD.strContractNumber,
				dbo.fnCTConvertQuantityToTargetCommodityUOM( CD.intPriceCommodityUOMId,BU.intCommodityUnitMeasureId,CD.dblBasis) / 
				CASE	WHEN	intBasisCurrencyId = CD.intCurrencyId	THEN 1
						WHEN	CD.intBasisCurrencyId <> CD.intCurrencyId 
						AND		CD.ysnBasisSubCurrency = 1			THEN 100 
						ELSE 0.01 
				END	AS dblConvertedBasis,
				CY.strCurrency	AS strMarketCurrency,
				UM.strUnitMeasure AS strMarketUOM,
				CD.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				CD.ysnSubCurrency				AS	ysnSeqSubCurrency,
				MA.intCurrencyId				AS	intMarketCurrencyId,
				CY.ysnSubCurrency				AS	ysnMarketSubCurrency,	
				CD.intBasisCurrencyId,
				CD.ysnBasisSubCurrency,
				BU.intCommodityUnitMeasureId	AS	intBasisCommodityUOMId,			
				CD.intDiscountScheduleCodeId,
				SI.strDescription				AS	strDiscountScheduleCode,
				CASE WHEN CH.intPricingTypeId = 8 THEN 'Ratio' ELSE CD.strPricingType END AS strPricingType,
				CD.dblRatio,
				CD.dblAppliedQty,
				CD.strBook,
				CD.strSubBook
		

		FROM	#tblCTPriceFixation			PF
		JOIN	vyuCTContractSequence		CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
LEFT	JOIN	tblICCommodityUnitMeasure	BU	ON	BU.intCommodityId		=	CD.intCommodityId 
												AND BU.intUnitMeasureId		=	CD.intBasisUnitMeasureId
LEFT    JOIN	tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
LEFT	JOIN	tblICItem					SI	ON	SI.intItemId			=	SC.intItemId


		INSERT INTO @temp 

		SELECT	PF.intPriceFixationId,
				PF.intPriceContractId,
				PF.intConcurrencyId,
				PF.intContractHeaderId,
				PF.intContractDetailId,
				PF.intOriginalFutureMarketId,
				PF.intOriginalFutureMonthId,
				PF.dblOriginalBasis,
				PF.dblTotalLots,
				PF.dblLotsFixed,
				PF.intLotsHedged,
				PF.dblPolResult,
				PF.dblPremiumPoints,
				PF.ysnAAPrice,
				PF.ysnSettlementPrice,
				PF.ysnToBeAgreed,
				PF.dblSettlementPrice,
				PF.dblAgreedAmount,
				PF.intAgreedItemUOMId,
				PF.dblPolPct,
				PF.dblPriceWORollArb,
				PF.dblRollArb,
				PF.dblPolSummary,
				PF.dblAdditionalCost,
				PF.dblFinalPrice,
				PF.intFinalPriceUOMId,
				PF.ysnSplit,

				CH.dblQuantity,
				PM.strUnitMeasure		AS	strPriceUOM,
				QM.strUnitMeasure		AS	strItemUOM,
				NULL,
				CH.intFutureMarketId,
				MA.strFutMarketName		AS	strFutureMarket,
				CH.intFutureMonthId,
				MO.strFutureMonth,
				NULL,
				CT.strContractType,
				EY.strName				AS	strEntityName,
				CH.strContractNumber,
				NULL					AS	dblConvertedBasis,
				CY.strCurrency			AS	strMarketCurrency,
				UM.strUnitMeasure		AS	strMarketUOM,
				CH.ysnMultiplePriceFixation,
				CD.intCurrencyId,
				CD.ysnSubCurrency		AS	ysnSeqSubCurrency,
				MA.intCurrencyId		AS	intMarketCurrencyId,
				CY.ysnSubCurrency		AS	ysnMarketSubCurrency,
				NULL,
				NULL,
				NULL,			
				CD.intDiscountScheduleCodeId,
				SI.strDescription				AS	strDiscountScheduleCode,
				CASE WHEN CH.intPricingTypeId = 8 THEN 'Ratio' ELSE CD.strPricingType END AS strPricingType,
				CD.dblRatio,
				CD.dblAppliedQty,
				BK.strBook,
				SB.strSubBook

		FROM	#tblCTPriceFixation			PF	
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId 
		JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId		=	CU.intUnitMeasureId
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	PF.intContractHeaderId
		JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CH.intFutureMarketId
		JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId		=	MA.intUnitMeasureId	
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	CH.intFutureMonthId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId			=	CH.intEntityId
		JOIN	tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId
		CROSS APPLY fnCTGetTopOneSequence(CH.intContractHeaderId,0)	CD
LEFT	JOIN	tblCTBook					BK	ON	BK.intBookId			=	CH.intBookId						
LEFT	JOIN	tblCTSubBook				SB	ON	SB.intSubBookId			=	CH.intSubBookId	
LEFT    JOIN	tblGRDiscountScheduleCode	SC	ON	SC.intDiscountScheduleCodeId =	CD.intDiscountScheduleCodeId
LEFT	JOIN	tblICItem					SI	ON	SI.intItemId			=	SC.intItemId
		WHERE	ISNULL(CH.ysnMultiplePriceFixation,0) = 1
	
	SELECT * FROM @temp

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
