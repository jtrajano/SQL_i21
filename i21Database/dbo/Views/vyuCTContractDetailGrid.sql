﻿CREATE VIEW dbo.vyuCTContractDetailGrid
AS
	SELECT	CD.*,

			CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty,
			CD.intContractStatusId intCurrentContractStatusId,
			MZ.strMarketZoneCode,
			IM.strItemNo,
			XM.strUnitMeasure strAdjustmentUOM,
			CL.strLocationName,
			FT.strFreightTerm,
			SV.strShipVia,
			CU.strCurrency,
			CY.strCurrency	strMainCurrency,
			CU.ysnSubCurrency,
			FR.strOrigin + FR.strDest strOriginDest,
			RG.strRailGrade,
			PT.strPricingType,
			OH.strContractOptDesc,
			DT.strDiscountType,
			DC.strDiscountId,
			PD.dblQuantityPriceFixed,
			PD.dblPFQuantityUOMId,
			PF.intTotalLots,
			PF.intLotsFixed,
			IC.strContractItemName,
			WM.strUnitMeasure strNetWeightUOM,
			PM.strUnitMeasure strPriceUOM,
			RY.strCountry AS strOrigin,
			IX.strIndex,
			CS.strContractStatus,
			PF.intPriceFixationId, 
			QA.strContainerNumber,
			QA.strSampleTypeName,
			QA.strSampleStatus,
			QA.dtmTestingEndDate,

			REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ')') strFutureMonth,
			CASE WHEN (SELECT COUNT(SA.intSpreadArbitrageId) FROM tblCTSpreadArbitrage SA  WHERE SA.intPriceFixationId = PF.intPriceFixationId) > 0
			THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)END AS ysnSpreadAvailable, 
			CASE WHEN intPFDCount > 0
			THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)END AS ysnFixationDetailAvailable,
			CASE	WHEN	CH.ysnCategory = 1
					THEN	dbo.fnCTConvertQtyToTargetCategoryUOM(CD.intCategoryUOMId,GU.intCategoryUOMId,1)
					ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CM.intItemUOMId,1) 
			END		AS		dblConversionFactor,
			ISNULL(QM.strUnitMeasure,YM.strUnitMeasure)	AS	strUOM,
			CASE	WHEN	CH.ysnLoad = 1
						THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalance,0)
						ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
			END		AS	dblAppliedQty,
			dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)	AS	dblExchangeRate

FROM		tblCTContractDetail			CD
	 JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=		CD.intContractHeaderId	
LEFT JOIN	tblARMarketZone				MZ	ON	MZ.intMarketZoneId				=		CD.intMarketZoneId
LEFT JOIN	tblICItem					IM	ON	IM.intItemId					=		CD.intItemId
LEFT JOIN	tblICItemUOM				XU	ON	XU.intItemUOMId					=		CD.intItemUOMId
LEFT JOIN	tblICUnitMeasure			XM	ON	XM.intUnitMeasureId				=		XU.intUnitMeasureId
LEFT JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId			=		CD.intCompanyLocationId
LEFT JOIN	tblSMFreightTerms			FT	ON	FT.intFreightTermId				=		CD.intFreightTermId
LEFT JOIN	tblSMShipVia				SV	ON	SV.intEntityShipViaId			=		CD.intShipViaId
LEFT JOIN	tblCTFreightRate			FR	ON	FR.intFreightRateId				=		CD.intFreightRateId
LEFT JOIN	tblCTRailGrade				RG	ON	RG.intRailGradeId				=		CD.intRailGradeId
LEFT JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=		CD.intPricingTypeId
LEFT JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=		CD.intFutureMarketId
LEFT JOIN	tblCTContractOptHeader		OH	ON	OH.intContractOptHeaderId		=		CD.intContractOptHeaderId
LEFT JOIN	tblCTDiscountType			DT	ON	DT.intDiscountTypeId			=		CD.intDiscountTypeId
LEFT JOIN	tblGRDiscountId				DC	ON	DC.intDiscountId				=		CD.intDiscountId
LEFT JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=		CD.intFutureMonthId
LEFT JOIN	tblCTIndex					IX	ON	IX.intIndexId					=		CD.intIndexId
LEFT JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId			=		CD.intContractStatusId

LEFT JOIN	tblICItemContract			IC	ON	IC.intItemContractId			=		CD.intItemContractId		
LEFT JOIN	tblSMCountry				RY	ON	RY.intCountryID					=		IC.intCountryId				
LEFT JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID				=		CD.intCurrencyId			
LEFT JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CU.intMainCurrencyId		

LEFT JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=		CD.intItemUOMId				
LEFT JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=		QU.intUnitMeasureId			

LEFT JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId					=		CD.intNetWeightUOMId		
LEFT JOIN	tblICUnitMeasure			WM	ON	WM.intUnitMeasureId				=		WU.intUnitMeasureId			

LEFT JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=		CD.intPriceItemUOMId		
LEFT JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId			

LEFT JOIN	tblICCommodityUnitMeasure	CO	ON	CO.intCommodityUnitMeasureId	=		CH.intCommodityUOMId		
LEFT JOIN	tblICItemUOM				CM	ON	CM.intItemId					=		CD.intItemId				
											AND	CM.intUnitMeasureId				=		CO.intUnitMeasureId			
LEFT JOIN	tblICCategoryUOM			YU	ON	YU.intCategoryUOMId				=		CD.intCategoryUOMId			
LEFT JOIN	tblICUnitMeasure			YM	ON	YM.intUnitMeasureId				=		YU.intUnitMeasureId			
LEFT JOIN	tblICCategoryUOM			GU	ON	GU.intCategoryId				=		CD.intCategoryId			
											AND	GU.intUnitMeasureId				=		CH.intCategoryUnitMeasureId		
LEFT JOIN	tblCTPriceFixation			PF	ON	CD.intContractDetailId			=		PF.intContractDetailId		
LEFT JOIN	(
			SELECT	 intPriceFixationId,
					 COUNT(intPriceFixationDetailId) intPFDCount,
					 SUM(dblQuantity) dblQuantityPriceFixed,
					 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
			FROM	 tblCTPriceFixationDetail
			GROUP BY intPriceFixationId
			)							PD	ON	PD.intPriceFixationId			=		PF.intPriceFixationId
LEFT JOIN	(
				SELECT * FROM 
				(
					SELECT	ROW_NUMBER() OVER (PARTITION BY SA.intContractDetailId ORDER BY SA.intSampleId DESC) intRowNum,
							SA.intContractDetailId,
							SA.strSampleNumber,
							SA.strContainerNumber,
							ST.strSampleTypeName,
							SS.strStatus AS strSampleStatus,
							SA.dtmTestingEndDate
					FROM	tblQMSample			SA
					JOIN	tblQMSampleType		ST  ON ST.intSampleTypeId	= SA.intSampleTypeId
					JOIN	tblQMSampleStatus	SS  ON SS.intSampleStatusId = SA.intSampleStatusId
					WHERE	SA.intContractDetailId IS NOT NULL
				) t
				WHERE intRowNum = 1
			)							QA	ON	QA.intContractDetailId			=		CD.intContractDetailId