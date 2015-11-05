﻿CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,				CD.intContractSeq,				CD.intConcurrencyId				AS	intDetailConcurrencyId,
			CD.intCompanyLocationId,			CD.dtmStartDate,				CD.intItemId,									
			CD.dtmEndDate,						CD.intFreightTermId,			CD.intShipViaId,								
			IU.intUnitMeasureId,				CD.intPricingTypeId,			CD.dblQuantity					AS	dblDetailQuantity,				
			CD.dblFutures,						CD.dblBasis,					CD.intFutureMarketId,							
			CD.intFutureMonthId,				CD.dblCashPrice,				CD.intCurrencyId,			
			CD.dblRate,							CD.intContractStatusId,			CD.intMarketZoneId,								
			CD.intDiscountTypeId,				CD.intDiscountId,				CD.intContractOptHeaderId,						
			CD.strBuyerSeller,					CD.intBillTo,					CD.intFreightRateId,			
			CD.strFobBasis,						CD.intRailGradeId,				CD.strRemark,
			CD.dblOriginalQty,					CD.dblBalance,					CD.dblIntransitQty,
			CD.dblScheduleQty,					CD.strPackingDescription,		CD.intPriceItemUOMId,
			CD.intLoadingPortId,				CD.intDestinationPortId,		CD.strShippingTerm,
			CD.intShippingLineId,				CD.strVessel,					CD.intDestinationCityId,
			CD.intShipperId,					CD.strGarden,					CD.strVendorLotID,
			CD.strInvoiceNo,					CD.dblNoOfLots,					CD.intUnitsPerLayer,
			CD.intLayersPerPallet,				CD.dtmEventStartDate,			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,		CD.intBookId,					CD.intSubBookId,
			CD.intContainerTypeId,				CD.intNumberOfContainers,		CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,					CD.dtmFXValidTo,				CD.strFXRemarks,
			CD.dblAssumedFX,					CD.strFixationBy,				CD.intItemUOMId,
			CD.intIndexId,						CD.dblAdjustment,				CD.intAdjItemUOMId,		
			CD.intDiscountScheduleCodeId,		CD.dblOriginalBasis,			CD.strLoadingPointType,
			CD.strDestinationPointType,			CD.intItemContractId,

			IM.strItemNo,						FT.strFreightTerm,				IM.strDescription				AS	strItemDescription,
			SV.strShipVia,						PT.strPricingType,				U1.strUnitMeasure				AS	strItemUOM,
			FM.strFutMarketName,				MO.strFutureMonth,				U2.strUnitMeasure				AS	strPriceUOM,
			MZ.strMarketZoneCode,				OH.strContractOptDesc,			U3.strUnitMeasure				AS	strAdjUOM,
			RG.strRailGrade,					CL.strLocationName,				FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,
			IX.strIndexType,													LP.strCity						AS	strLoadingPoint,	
																				DP.strCity						AS	strDestinationPoint,
																				DC.strCity						AS	strDestinationCity,
																				PU.intUnitMeasureId				AS	intPriceUnitMeasureId,
			ISNULL(CD.dblBalance,0) -	ISNULL(CD.dblScheduleQty,0)												AS	dblAvailableQty,
			CH.strContractNumber + LTRIM(CD.intContractSeq)														AS	strSequenceNumber,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblCashPrice)				AS	dblCashPriceInQtyUOM,
			
			--Required by other modules

			SL.intStorageLocationId,			IM.strLotTracking,				SL.strName						AS	strStorageLocationName,
			SU.strStockUOM,						SU.strStockUOMType,				ISNULL(IU.dblUnitQty,0)			AS	dblItemUOMCF,  
			SB.intCompanyLocationSubLocationId,	SB.strSubLocationName,			ISNULL(SU.intStockUOM,0)		AS	intStockUOM,		
			CU.strCurrency,						CS.strContractStatus,			ISNULL(SU.dblStockUOMCF,0)		AS	dblStockUOMCF,	
			IX.strIndex,						VR.strVendorId,					CD.strReference,
			IM.intPurchaseTaxGroupId,			SP.intSupplyPointId,			SP.intEntityVendorId			AS	intTerminalId,
			SP.intRackPriceSupplyPointId,		IM.intOriginId,
			RV.dblReservedQuantity,				IM.intLifeTime,					IM.strLifeTimeType,
			ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0) AS dblUnReservedQuantity,
			ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) AS dblAllocatedQty,
			ISNULL(CD.dblQuantity,0) - ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0) AS dblUnAllocatedQty,
			CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT) AS ysnAllowedToShow,
			CASE	WHEN	ISNULL(PF.intTotalLots,0) = 0 
							THEN	'Unpriced'
					ELSE
							CASE	WHEN ISNULL(PF.intTotalLots,0)-ISNULL(intLotsFixed,0) = 0
										THEN 'Fully Priced' 
									WHEN ISNULL(intLotsFixed,0) = 0 
										THEN 'Unpriced'
									ELSE 'Partially Priced' 
							END
			END		AS strPricingStatus,

			--Header Detail

			CH.intContractHeaderId,				CH.intHeaderConcurrencyId,		CH.intContractTypeId,
			CH.strContractType,					CH.intEntityId,					CH.strEntityName,
			CH.strEntityType,					CH.strEntityNumber,				CH.strEntityAddress,
			CH.strEntityCity,					CH.strEntityState,				CH.strEntityZipCode,
			CH.strEntityCountry,				CH.strEntityPhone,				CH.intDefaultLocationId,
			CH.intCommodityId,					CH.strCommodityCode,			CH.strCommodityDescription,
			CH.dblHeaderQuantity,				CH.intCommodityUnitMeasureId,	CH.strHeaderUnitMeasure,
			CH.strContractNumber,				CH.dtmContractDate,				CH.strCustomerContract,
			CH.dtmDeferPayDate,					CH.dblDeferPayRate,				CH.intContractTextId,
			CH.strTextCode,						CH.strInternalComments,			CH.ysnSigned,
			CH.ysnPrinted,						CH.intSalespersonId,			CH.strSalespersonId,
			CH.intGradeId,						CH.strGrade,					CH.intWeightId,
			CH.strWeight,						CH.intCropYearId,				CH.strContractComments,
			CH.intAssociationId,				CH.strAssociationName,			CH.intTermId,
			CH.strTerm,							CH.intApprovalBasisId,			CH.strApprovalBasis,
			CH.strApprovalBasisDescription,		CH.intContractBasisId,			CH.strContractBasis,
			CH.strContractBasisDescription,		CH.intPositionId,				CH.strPosition,
			CH.intInsuranceById,				CH.strInsuranceBy,				CH.strInsuranceByDescription,
			CH.intInvoiceTypeId,				CH.strInvoiceType,				CH.strInvoiceTypeDescription,
			CH.dblTolerancePct,					CH.dblProvisionalInvoicePct,	CH.ysnPrepaid,
			CH.ysnSubstituteItem,				CH.ysnUnlimitedQuantity,		CH.ysnMaxPrice,			
			CH.intINCOLocationTypeId,			CH.intCountryId,				CH.strCountry,
			CH.ysnMultiplePriceFixation,		CH.strINCOLocation
			
	FROM	tblCTContractDetail				CD
	
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	vyuCTContractHeaderView			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		LEFT		
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
	JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia					SV	ON	SV.[intEntityShipViaId]		=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader			OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket				FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor						VR	ON	VR.[intEntityVendorId]		=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			LEFT
	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId			LEFT
	JOIN	tblICItemLocation				IL	ON	IL.intItemId				=	IM.intItemId				AND
													IL.intLocationId			=	CD.intCompanyLocationId		LEFT
	JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId		=	IL.intStorageLocationId		LEFT
	JOIN	tblCTPriceFixation				PF	ON	PF.intContractDetailId		=	CD.intContractDetailId		LEFT
	JOIN	tblSMCity						LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
	JOIN	tblSMCity						DP	ON	DP.intCityId				=	CD.intLoadingPortId			LEFT
	JOIN	tblSMCity						DC	ON	DC.intCityId				=	CD.intDestinationCityId		LEFT
	JOIN(
			SELECT  intItemUOMId AS intStockUOM,strUnitMeasure AS strStockUOM,strUnitType AS strStockUOMType,dblUnitQty AS dblStockUOMCF 
			FROM	tblICItemUOM			IU	LEFT 
			JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId 
			WHERE	ysnStockUnit = 1)		SU	ON	SU.intStockUOM				=	IU.intItemUOMId				LEFT
	JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	= IL.intSubLocationId 	LEFT
	JOIN	tblTRSupplyPoint				SP	ON	SP.intEntityVendorId		=	IX.intVendorId	AND 
													SP.intEntityLocationId = IX.intVendorLocationId				LEFT
	JOIN	(
				SELECT		intContractDetailId,ISNULL(SUM(dblReservedQuantity),0) AS dblReservedQuantity 
				FROM		tblLGReservation 
				Group By	intContractDetailId
			)								RV	ON	RV.intContractDetailId		=	CD.intContractDetailId		LEFT	
	JOIN	(
				SELECT		intPContractDetailId,ISNULL(SUM(dblPAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intPContractDetailId
			)								PA	ON	PA.intPContractDetailId		=	CD.intContractDetailId		LEFT	
	JOIN	(
				SELECT		intSContractDetailId,ISNULL(SUM(dblSAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intSContractDetailId
			)								SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId	