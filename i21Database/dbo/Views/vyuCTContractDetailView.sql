CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,				CD.intContractSeq,				CD.intConcurrencyId				AS	intDetailConcurrencyId,
			CD.intCompanyLocationId,			CD.dtmStartDate,				CD.intItemId,									
			CD.dtmEndDate,						CD.intFreightTermId,			CD.intShipViaId,								
			IU.intUnitMeasureId,				CD.intPricingTypeId,			CD.dblQuantity					AS	dblDetailQuantity,				
			CD.dblFutures,						CD.dblBasis,					CD.intFutureMarketId,							
			CD.intFutureMonthId,				CD.dblCashPrice,				CD.intCurrencyId,			
			CD.dblRate,							CD.strCurrencyReference,		CD.intMarketZoneId,								
			CD.intDiscountTypeId,				CD.intDiscountId,				CD.intContractOptHeaderId,						
			CD.strBuyerSeller,					CD.intBillTo,					CD.intFreightRateId,			
			CD.strFobBasis,						CD.intRailGradeId,				CD.strRemark,
			CD.dblOriginalQty,					CD.dblBalance,					CD.dblIntransitQty,
			CD.dblScheduleQty,					CD.intPriceUOMId,				CD.intPriceItemUOMId,
			CD.intLoadingPortId,				CD.intDestinationPortId,		CD.strShippingTerm,
			CD.intShippingLineId,				CD.strVessel,					CD.intDestinationCityId,
			CD.intShipperId,					CD.strGarden,					CD.strVendorLotID,
			CD.strInvoiceNo,					CD.intPackingDescriptionId,		CD.dblWeightPerUnit,
			CD.intWeightPerUnitUOMId,			CD.intWeightPerUnitItemUOMId,	CD.dblNoOfPacks,
			CD.intPackingTypeUOMId,				CD.intPackingTypeItemUOMId,		CD.intUnitsPerLayer,
			CD.intLayersPerPallet,				CD.dtmEventStartDate,			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,		CD.intBookId,					CD.intSubBookId,
			CD.intContainerTypeId,				CD.intNumberOfContainers,		CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,					CD.dtmFXValidTo,				CD.strFXRemarks,
			CD.dblAssumedFX,					CD.strFixationBy,				CD.intItemUOMId,

			IM.strItemNo,						FT.strFreightTerm,				IM.strDescription				AS	strItemDescription,
			SV.strShipVia,						PT.strPricingType,				U1.strUnitMeasure				AS	strItemUOM,
			FM.strFutMarketName,				MO.strFutureMonth,				CU.strCurrency,
			MZ.strMarketZoneCode,				OH.strContractOptDesc,			VR.strVendorId,
			RG.strRailGrade,					CL.strLocationName,				FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,
			SL.intStorageLocationId,			IM.strLotTracking,				SL.strName						AS	strStorageLocationName,
			strStockUOM,						strStockUOMType,				ISNULL(IU.dblUnitQty,0)			AS	dblItemUOMCF,  
			SB.intCompanyLocationSubLocationId,	SB.strSubLocationName,			ISNULL(intStockUOM,0)			AS intStockUOM,		
																				ISNULL(dblStockUOMCF,0)			AS dblStockUOMCF,	

			--Header Detail

			CH.intContractHeaderId,				CH.intHeaderConcurrencyId,		CH.intContractTypeId,
			CH.strContractType,					CH.intEntityId,					CH.strEntityName,
			CH.strEntityType,					CH.strEntityNumber,				CH.strEntityAddress,
			CH.strEntityCity,					CH.strEntityState,				CH.strEntityZipCode,
			CH.strEntityCountry,				CH.strEntityPhone,				CH.intDefaultLocationId,
			CH.intCommodityId,					CH.strCommodityCode,			CH.strCommodityDescription,
			CH.dblHeaderQuantity,				CH.intCommodityUnitMeasureId,	CH.strHeaderUnitMeasure,
			CH.intContractNumber,				CH.dtmContractDate,				CH.strCustomerContract,
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
			CH.intINCOLocationTypeId,			CH.intCountryId,				CH.strCountry
			
	FROM	tblCTContractDetail				CD
	
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	vyuCTContractHeaderView			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId
	JOIN	tblICUnitMeasure				U1	ON	U1.intUnitMeasureId			=	IU.intUnitMeasureId			
	JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			
	JOIN	tblICItemLocation				IL	ON	IL.intItemId				=	IM.intItemId				AND
													IL.intLocationId			=	CD.intCompanyLocationId		LEFT
	JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId		=	IL.intStorageLocationId		LEFT
	JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia					SV	ON	SV.intShipViaID				=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader			OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket				FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor						VR	ON	VR.[intEntityVendorId]		=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			LEFT
	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId			LEFT
	JOIN(
			SELECT  intItemUOMId AS intStockUOM,strUnitMeasure AS strStockUOM,strUnitType AS strStockUOMType,dblUnitQty AS dblStockUOMCF 
			FROM	tblICItemUOM			IU	LEFT 
			JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId 
			WHERE	ysnStockUnit = 1)		SU	ON	SU.intStockUOM				=	IU.intItemUOMId				LEFT
	JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	=	CASE WHEN CH.strINCOLocationType = 'Warehouse' THEN CH.intINCOLocationTypeId ELSE 0 END

	/*
	JOIN	tblICItemPricing			IP	ON	IP.intItemId				=	IM.intItemId				AND
												IP.intItemLocationId		=	IL.intItemLocationId		LEFT
	*/