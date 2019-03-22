CREATE VIEW [dbo].[vyuCTCustomerContract]

AS

			SELECT    intContractHeaderId				=	CD.intContractHeaderId
					, intContractDetailId				=	CD.intContractDetailId
					, strContractNumber					=	CH.strContractNumber
					, intContractSeq					=	CD.intContractSeq
					, strContractType					=	CT.strContractType
					, dtmStartDate						=	CD.dtmStartDate
					, dtmEndDate						=	CD.dtmEndDate
					, strContractStatus					=	CS.strContractStatus
					, intEntityCustomerId				=	CH.intEntityId	 
					, intCurrencyId						=	AD.intSeqCurrencyId
					, strCurrency						=	AD.strSeqCurrency		
					, intCompanyLocationId				=	CD.intCompanyLocationId	
					, intItemId							=	CD.intItemId
					, strItemNo							=	IM.strItemNo
					, strItemDescription				=	IM.strDescription
					, intOrderUOMId						=	CD.intItemUOMId
					, strOrderUnitMeasure				=	QM.strUnitMeasure
					, intItemUOMId						=	CD.intItemUOMId
					, strUnitMeasure					=	QM.strUnitMeasure
					, intPricingTypeId					=	PT.intPricingTypeId
					, strPricingType					=	PT.strPricingType	 
					, dblCashPrice						=	CASE	WHEN	CD.intPricingTypeId = 2 
																	THEN	dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId,CD.intFutureMonthId,GETDATE()) + CD.dblBasis
																	ELSE	AD.dblSeqPrice
															END
					, dblUnitPrice						=	(CASE	WHEN	CD.intPricingTypeId = 2 
																	THEN	dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId,CD.intFutureMonthId,GETDATE()) + CD.dblBasis
																	ELSE	AD.dblSeqPrice
															END) * ISNULL([dbo].[fnCalculateQtyBetweenUOM](CD.intItemUOMId, ISNULL(AD.intSeqPriceUOMId, CD.intItemUOMId), 1.000000),ISNULL(CD.dblQuantity, 0.000000))
					, intCurrencyExchangeRateTypeId		=	CD.intRateTypeId
					, strCurrencyExchangeRateType		=	ER.strCurrencyExchangeRateType
					, intCurrencyExchangeRateId			=	CD.intCurrencyExchangeRateId
					, dblCurrencyExchangeRate			=	ISNULL(CD.dblRate, 1.000000)
					, intSubCurrencyId					=   AD.intSeqCurrencyId
					, dblSubCurrencyRate				=   CASE WHEN AD.ysnSeqSubCurrency = 1 THEN CU.intCent ELSE 1.000000 END
					, strSubCurrency					=	AD.strSeqCurrency
					, dblOrderPrice						=	AD.dblSeqPrice
					, intPriceItemUOMId					=	AD.intSeqPriceUOMId
					, strPriceUnitMeasure				=	AD.strSeqPriceUOM
					, dblBalance						=	CD.dblBalance
					, dblScheduleQty					=	CD.dblScheduleQty
					, dblAvailableQty					=	ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)
					, dblDetailQuantity					=	CD.dblQuantity 
					, dblOrderQuantity					=	CD.dblQuantity
					, dblShipQuantity					=	CD.dblQuantity
					, dblPriceUOMQuantity				=	ISNULL([dbo].[fnCalculateQtyBetweenUOM](CD.intItemUOMId, ISNULL(AD.intSeqPriceUOMId, CD.intItemUOMId), 1.000000),ISNULL(CD.dblQuantity, 0.000000))
					, ysnUnlimitedQuantity				=	CAST(ISNULL(CH.ysnUnlimitedQuantity,0) AS BIT)
					, ysnLoad							=	CAST(ISNULL(CH.ysnLoad,0) AS BIT)
					, ysnAllowedToShow					=	CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT)
					, intFreightTermId					=	CD.intFreightTermId
					, intTermId							=	CH.intTermId
					, intShipViaId						=	CD.intShipViaId
					, intDestinationGradeId				=	CH.intGradeId
					, strDestinationGrade				=	GR.strWeightGradeDesc
					, intDestinationWeightId			=	CH.intWeightId
					, strDestinationWeight				=	WT.strWeightGradeDesc
					, intItemWeightUOMId				=	CD.intNetWeightUOMId
					, strWeightUnitMeasure				=	WM.strUnitMeasure
					, ysnMaxPrice						=	CH.ysnMaxPrice
					, intCompanyLocationPricingLevelId	=	CH.intCompanyLocationPricingLevelId
					, strType							=	IM.strType
					, strBundleType						=	IM.strBundleType
					, intBookId							=	NULL
					, intSubBookId						=	NULL
					, strBook							=	NULL
					, strSubBook						=	NULL
					, ysnBestPriceOnly					=	CH.ysnBestPriceOnly
    
			FROM	tblCTContractDetail				CD
			JOIN	tblCTContractHeader				CH	ON  CH.intContractHeaderId				=   CD.intContractHeaderId
														AND CH.intContractTypeId				=	2
														AND CD.intPricingTypeId				NOT IN	(4,7)
			JOIN	tblCTContractType				CT	ON  CT.intContractTypeId				=   CH.intContractTypeId
			JOIN	tblCTContractStatus				CS	ON  CS.intContractStatusId				=   CD.intContractStatusId
			JOIN	tblCTPricingType				PT	ON  PT.intPricingTypeId					=	CD.intPricingTypeId
			JOIN	tblICItem						IM	ON  IM.intItemId						=   CD.intItemId
			JOIN	tblICItemUOM					QU	ON  QU.intItemUOMId						=   CD.intItemUOMId
			JOIN	tblICUnitMeasure				QM	ON  QM.intUnitMeasureId					=   QU.intUnitMeasureId

	OUTER	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId)			AD

	LEFT	JOIN	tblICItemUOM					WU	ON  WU.intItemUOMId						=   CD.intNetWeightUOMId
	LEFT	JOIN	tblICUnitMeasure				WM	ON  WM.intUnitMeasureId					=   WU.intUnitMeasureId
	LEFT	JOIN	tblICItemUOM					PU	ON  PU.intItemUOMId						=   AD.intSeqPriceUOMId
	LEFT	JOIN	tblICUnitMeasure				PM	ON  PM.intUnitMeasureId					=   PU.intUnitMeasureId
	LEFT	JOIN	tblCTWeightGrade				WT	ON  WT.intWeightGradeId					=   CH.intWeightId
	LEFT	JOIN	tblCTWeightGrade				GR	ON  GR.intWeightGradeId					=   CH.intGradeId
	LEFT	JOIN	tblSMCurrency					CU	ON  CU.intCurrencyID					=	AD.intSeqCurrencyId
	LEFT	JOIN	tblSMCurrencyExchangeRateType	ER	ON  ER.intCurrencyExchangeRateTypeId	=   CD.intRateTypeId
