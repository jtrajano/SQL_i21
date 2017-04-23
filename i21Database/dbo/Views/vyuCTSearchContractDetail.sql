CREATE VIEW [dbo].[vyuCTSearchContractDetail]
AS

	SELECT	CD.intContractDetailId,		 	
			CD.intContractSeq,					
			CD.dtmStartDate,									
			CD.dtmEndDate,				
			CD.dblQuantity					AS	dblDetailQuantity,				
			CD.dblFutures,						
			CD.dblBasis,						
			CD.dblCashPrice,		
			CD.dblRate,						
			CD.strFobBasis,					
			CD.strRemark,				
			CD.dblBalance,					
			CD.dblIntransitQty,
			CD.dblScheduleQty,				
			CD.strShippingTerm,			
			CD.strVessel,				
			CD.strVendorLotID,
			CD.strInvoiceNo,					
			CD.dblNoOfLots,					
			CD.dtmEventStartDate,			
			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,		
			CD.intNumberOfContainers,	
			CD.dtmFXValidFrom,					
			CD.dtmFXValidTo,				
			CD.strFXRemarks,
			CD.dblAssumedFX,					
			CD.strFixationBy,						
			CD.dblAdjustment,		
			CD.strReference,	
			CD.strBuyerSeller,
			CD.dblOriginalQty,
			CD.intPricingTypeId,
			CD.strERPPONumber,
			CD.strERPItemNumber,
			CD.strERPBatchNumber,
			CD.dblNetWeight,
			CD.dblTotalCost,

			IC.strContractItemName,
			IC.strContractItemNo,
			U4.strUnitMeasure				AS	strWeightUOM,
			IM.strItemNo,		
			IM.strShortName					AS	strItemShortName,		
			FT.strFreightTerm,				
			IM.strDescription				AS	strItemDescription,
			SV.strShipVia,						
			PT.strPricingType,				
			U1.strUnitMeasure				AS	strItemUOM,
			FM.strFutMarketName,				
			MO.strFutureMonth,				
			U2.strUnitMeasure				AS	strPriceUOM,
			MZ.strMarketZoneCode,				
			OH.strContractOptDesc,			
			U3.strUnitMeasure				AS	strAdjUOM,
			RG.strRailGrade,					
			CL.strLocationName,				
			FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,				
			CU.strCurrency,					
			LP.strCity						AS	strLoadingPoint,
			DP.strCity						AS	strDestinationPoint,
			ISNULL(IG.strCountry,OG.strCountry)					AS	strOrigin,
			CA.strDescription				AS	strProductType,
			dbo.fnCTGetApprovedSampleQuantity(CD.intContractDetailId) AS dblApprovedQty,
			SB.strSubLocationName,
			--Required by other modules
		
			IM.strLotTracking,				
			SL.strName						AS	strStorageLocationName,		
			CS.strContractStatus,			
			IX.strIndex,						
			VR.strVendorId,					
			RV.dblReservedQuantity,											
			ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0)											AS	dblUnReservedQuantity,
			ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0)											AS	dblAllocatedQty,
			ISNULL(CD.dblQuantity,0) - ISNULL(PA.dblAllocatedQty,0) - ISNULL(SA.dblAllocatedQty,0)				AS	dblUnAllocatedQty,
			dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,IU.intUnitMeasureId,CH.intStockCommodityUnitMeasureId,CD.dblQuantity)			AS	dblQtyInCommodityStockUOM,
			--Header
	
			CH.*
			

	FROM	tblCTContractDetail				CD LEFT	
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
	JOIN	vyuCTSearchContract				CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		LEFT		
	JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId		=	CD.intContractStatusId		LEFT	
	JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT	
	JOIN	tblCTIndex						IX	ON	IX.intIndexId				=	CD.intIndexId				LEFT
	JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId				LEFT	
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId				LEFT
	JOIN	tblICUnitMeasure				U1	ON	U1.intUnitMeasureId			=	IU.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		LEFT
	JOIN	tblICUnitMeasure				U2	ON	U2.intUnitMeasureId			=	PU.intUnitMeasureId			LEFT	
	JOIN	tblICItemUOM					AU	ON	AU.intItemUOMId				=	CD.intAdjItemUOMId			LEFT
	JOIN	tblICUnitMeasure				U3	ON	U3.intUnitMeasureId			=	AU.intUnitMeasureId			LEFT	
	JOIN	tblICItemUOM					SM	ON	SM.intItemId				=	CD.intItemId				AND														
													SM.ysnStockUnit				=	1							LEFT
	JOIN	tblICItemUOM					WU	ON	WU.intItemUOMId				=	CD.intNetWeightUOMId		LEFT
	JOIN	tblICUnitMeasure				U4	ON	U4.intUnitMeasureId			=	WU.intUnitMeasureId			LEFT

	JOIN	tblICItemContract				IC	ON	IC.intItemContractId		=	CD.intItemContractId		LEFT
	JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia					SV	ON	SV.intEntityShipViaId		=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader			OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket				FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor						VR	ON	VR.intEntityVendorId		=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			LEFT
	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId			LEFT
	JOIN	tblICItemLocation				IL	ON	IL.intItemId				=	IM.intItemId				AND
													IL.intLocationId			=	CD.intCompanyLocationId		LEFT
	JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId		=	IL.intStorageLocationId		LEFT
	JOIN	tblSMCity						LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
	JOIN	tblSMCity						DP	ON	DP.intCityId				=	CD.intDestinationPortId		LEFT
	JOIN	tblSMCountry					OG	ON	OG.intCountryID				=	IM.intOriginId				LEFT
	JOIN	tblSMCountry					IG	ON	IG.intCountryID				=	IC.intCountryId				LEFT
	JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	= CD.intSubLocationId 	LEFT
	JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intProductTypeId
												AND	CA.strType					=	'ProductType'				LEFT
	JOIN	(
				SELECT		intContractDetailId,ISNULL(SUM(dblReservedQuantity),0) AS dblReservedQuantity 
				FROM		tblLGReservation 
				Group By	intContractDetailId
			)								RV	ON	RV.intContractDetailId		=	CD.intContractDetailId		LEFT	
	JOIN	(
				SELECT		intPContractDetailId,ISNULL(SUM(dblPAllocatedQty),0)  AS dblAllocatedQty,MIN(intPUnitMeasureId) intAllocationUOMId
				FROM		tblLGAllocationDetail 
				Group By	intPContractDetailId
			)								PA	ON	PA.intPContractDetailId		=	CD.intContractDetailId		LEFT	
	JOIN	(
				SELECT		intSContractDetailId,ISNULL(SUM(dblSAllocatedQty),0)  AS dblAllocatedQty,MIN(intSUnitMeasureId) intAllocationUOMId
				FROM		tblLGAllocationDetail 
				Group By	intSContractDetailId
			)								SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId