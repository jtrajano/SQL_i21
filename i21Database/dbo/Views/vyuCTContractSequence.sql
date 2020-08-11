CREATE VIEW [dbo].[vyuCTContractSequence]

AS
			--Detail
	SELECT	CD.intContractDetailId,	CD.intContractSeq,		CD.intCompanyLocationId,			
			CD.dtmStartDate,		CD.intItemId,			CD.dtmEndDate,														
			QU.intUnitMeasureId,	CD.intPricingTypeId,	CD.dblQuantity,				
			CD.dblFutures,			CD.dblBasis,			CD.intFutureMarketId,							
			CD.intFutureMonthId,	CD.dblCashPrice,		CD.intCurrencyId,			
			CD.intContractStatusId,	CD.strBuyerSeller,		CD.dblBalance,					
			CD.dblScheduleQty,		CD.intPriceItemUOMId,	CD.intNetWeightUOMId,								
			CD.dblNoOfLots,			CD.intItemUOMId,		CD.dblNetWeight,	
			CD.intBookId,			CD.intSubBookId,		CD.intDiscountScheduleCodeId,
			CD.strERPPONumber,		CD.intSplitFromId,		CD.dtmPlannedAvailabilityDate,
			CD.strERPItemNumber,	CD.strERPBatchNumber,	CD.intBasisCurrencyId,
			CD.intBasisUOMId,		CD.dblRatio,			CD.intNoOfLoad,
			CD.dblQuantityPerLoad,

			--Detail Join
			IM.strItemNo,			PT.strPricingType,		IM.strDescription			AS	strItemDescription,
			FM.strFutMarketName,							QM.strUnitMeasure			AS	strItemUOM, QM.intUnitMeasureId AS intItemReportUOMId,
			CL.strLocationName,		IM.strShortName,		PM.strUnitMeasure			AS	strPriceUOM,			
			CU.intMainCurrencyId,	CU.strCurrency,			PU.intUnitMeasureId			AS	intPriceUnitMeasureId,
			CY.strCurrency			AS	strMainCurrency,	WM.strUnitMeasure			AS	strNetWeightUOM,
			IC.strContractItemNo,	IC.strContractItemName,	SY.ysnSubCurrency			AS	ysnBasisSubCurrency,
			REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ')						AS	strFutureMonth,
			LEFT(CONVERT(DATE,'01 '+MO.strFutureMonth),7) + ' ('+MO.strFutureMonth+')'	AS strFutureMonthYear,
			SL.strName				AS strStorageLocation,	UL.strSubLocationName		AS	strSubLocation,
			BK.strBook,				SB.strSubBook,			PG.strName					AS	strPurchasingGroup ,				
			CE.strEntityNo			AS	strCreatedByNo,		PA.strDescription			AS	strProductType,
			BU.intUnitMeasureId		AS	intBasisUnitMeasureId,

			--Detail Computed Columns
			CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT)									AS	ysnSubCurrency,
			ISNULL(CD.dblBalance,0)		-	ISNULL(CD.dblScheduleQty,0)					AS	dblAvailableQty,
			CASE	WHEN	CH.ysnLoad = 1
					THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalanceLoad,0)
					ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
			END																			AS	dblAppliedQty,
			CH.strContractNumber + ' - ' +LTRIM(CD.intContractSeq)						AS	strSequenceNumber,
			C1.intCommodityUnitMeasureId												AS	intPriceCommodityUOMId,

			--Header
			CH.intContractHeaderId,	CH.intContractTypeId,		CH.intCommodityId,								
			CH.strContractNumber,	CH.dtmContractDate,			CH.ysnSigned,					
			CH.ysnPrinted,			CH.intSalespersonId,		CH.ysnMultiplePriceFixation,			
																CH.strCustomerContract	AS	strEntityContract,		
			--Header Join
			TP.strContractType,		CO.strCommodityCode,		EY.strName				AS	strEntityName,
			EY.intEntityId,										CO.strDescription		AS	strCommodityDescription,
			CH.intBookId																AS	intHeaderBookId,
			CH.intSubBookId																AS	intHeaderSubBookId,
			CD.intBookId																AS	intDetailBookId,
			CD.intSubBookId																AS	intDetailSubBookId
	FROM	tblCTContractDetail			CD	
	JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CH.intEntityId			
	JOIN	tblCTContractType			TP	ON	TP.intContractTypeId		=	CH.intContractTypeId		LEFT
	JOIN	tblICCommodity				CO	ON	CO.intCommodityId			=	CH.intCommodityId			LEFT
			
	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CD.intContractStatusId		LEFT	
	JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT
	JOIN	tblICItemContract			IC	ON	IC.intItemContractId		=	CD.intItemContractId		LEFT	
	JOIN	tblICItem					IM	ON	IM.intItemId				=	CD.intItemId				LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId				=	CD.intItemUOMId				LEFT
	JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId			=	QU.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		LEFT
	JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId			=	PU.intUnitMeasureId			LEFT	
	JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId				=	CD.intNetWeightUOMId		LEFT
	JOIN	tblICUnitMeasure			WM	ON	WM.intUnitMeasureId			=	WU.intUnitMeasureId			LEFT	
	JOIN	tblICItemUOM				BU	ON	BU.intItemUOMId				=	CD.intBasisUOMId			LEFT

	JOIN	tblRKFutureMarket			FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			LEFT
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID			=	CU.intMainCurrencyId		LEFT
	JOIN	tblSMCurrency				SY	ON	SY.intCurrencyID			=	CD.intBasisCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	C1	ON	C1.intCommodityId			=	CH.intCommodityId
											AND	C1.intUnitMeasureId			=	PU.intUnitMeasureId			LEFT
	--JOIN	tblICCommodityAttribute		CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
	--										AND	CA.strType					=	'Origin'					LEFT
	JOIN	tblSMPurchasingGroup		PG	ON	PG.intPurchasingGroupId		=	CD.intPurchasingGroupId		LEFT
	JOIN	tblICStorageLocation		SL	ON	SL.intStorageLocationId		=	CD.intStorageLocationId		LEFT
	JOIN	tblEMEntity					CE	ON	CE.intEntityId				=	CD.intCreatedById			LEFT
	JOIN	tblICCommodityAttribute		PA	ON	PA.intCommodityAttributeId	=	IM.intProductTypeId			LEFT
	JOIN	tblCTBook					BK	ON	BK.intBookId				=	CD.intBookId				LEFT
	JOIN	tblCTSubBook				SB	ON	SB.intSubBookId				=	CD.intSubBookId				LEFT
	JOIN	tblSMCompanyLocationSubLocation	UL	ON	UL.intCompanyLocationSubLocationId	=	CD.intSubLocationId