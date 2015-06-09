CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,
			CD.intConcurrencyId					AS	intDetailConcurrencyId,
			CD.intContractSeq,
			CD.intCompanyLocationId,		
				CL.strLocationName,
			CD.dtmStartDate,
			CD.intItemId,					
				IM.strItemNo,
				IM.strDescription				AS	strItemDescription,
			CD.dtmEndDate,
			CD.intFreightTermId,			
				FT.strFreightTerm,
			CD.intShipViaId,				
				SV.strShipVia,
			CD.dblQuantity						AS	dblDetailQuantity,
			CD.intUnitMeasureId,			
				U1.strUnitMeasure				AS	strDetailUnitMeasure,
			CD.intPricingTypeId,			
				PT.strPricingType,
			CD.dblFutures,
			CD.dblBasis,
			CD.intFutureMarketId,			
				FM.strFutMarketName,
			CD.intFutureMonthId,			
				MO.strFutureMonth,
			CD.dblCashPrice,
			CD.intCurrencyId,				
				CU.strCurrency,
			CD.dblRate,
			CD.strCurrencyReference,
			CD.intMarketZoneId,				
				MZ.strMarketZoneCode,
			CD.intDiscountTypeId,
			CD.intDiscountId,			
			CD.intContractOptHeaderId,		
				OH.strContractOptDesc,
			CD.strBuyerSeller,
			CD.intBillTo,					
				VR.strVendorId,
			CD.intFreightRateId,			
				FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,
			CD.strFobBasis,
			CD.intRailGradeId,				
				RG.strRailGrade,
			CD.strRemark,
			CD.dblOriginalQty,
			CD.dblBalance,
			CD.dblIntransitQty,
			CD.dblScheduleQty,
			CD.intPriceUOMId,
			CD.intPriceItemUOMId,
			CD.intLoadingPortId,
			CD.intDestinationPortId,
			CD.strShippingTerm,
			CD.intShippingLineId,
			CD.strVessel,
			CD.intDestinationCityId,
			CD.intShipperId,
			CD.strGarden,
			CD.strVendorLotID,
			CD.strInvoiceNo,
			CD.intPackingDescriptionId,
			CD.dblWeightPerUnit,
			CD.intWeightPerUnitUOMId,
			CD.intWeightPerUnitItemUOMId,
			CD.dblNoOfPacks,
			CD.intPackingTypeUOMId,
			CD.intPackingTypeItemUOMId,
			CD.intUnitsPerLayer,
			CD.intLayersPerPallet,
			CD.dtmEventStartDate,
			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,
			CD.intBookId,
			CD.intSubBookId,
			CD.intContainerTypeId,
			CD.intNumberOfContainers,
			CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,
			CD.dtmFXValidTo,
			CD.strFXRemarks,
			CD.dblAssumedFX,
			CD.strFixationBy,

			--Header Detail

			CH.*
			
	FROM	tblCTContractDetail		CD
	
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	vyuCTContractHeaderView	CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	JOIN	tblARMarketZone			MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		U1	ON	U1.intUnitMeasureId			=	CD.intUnitMeasureId			
	JOIN	tblCTPricingType		PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT
	JOIN	tblSMFreightTerms		FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia			SV	ON	SV.intShipViaID				=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader	OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate		FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade			RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket		FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor				VR	ON	VR.[intEntityVendorId]		=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency			CU	ON	CU.intCurrencyID			=	CD.intCurrencyId