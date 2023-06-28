﻿CREATE VIEW [dbo].[vyuCTContractDetailView]

AS

	SELECT	CD.intContractDetailId,				CD.intContractSeq,				CD.intConcurrencyId				AS	intDetailConcurrencyId,
			CD.intCompanyLocationId,			CD.dtmStartDate,				CD.intItemId,									
			CD.dtmEndDate,						CD.intFreightTermId,			CD.intShipViaId,								
			IU.intUnitMeasureId,				CD.intPricingTypeId,			CD.dblQuantity					AS	dblDetailQuantity,				
			CD.dblFutures,						CD.dblBasis,					CD.intFutureMarketId,							
			CD.intFutureMonthId,				CD.dblCashPrice,				CD.intCurrencyId,			
			CASE WHEN smcp.intDefaultCurrencyId = isnull(INV.intMainCurrencyId,CD.intInvoiceCurrencyId) THEN 1 ELSE dbo.fnCTGetDefaultCurrencyExchangeRate(isnull(INV.intMainCurrencyId,CD.intInvoiceCurrencyId),smcp.intDefaultCurrencyId) END as dblRate,
			CD.intContractStatusId,				CD.intMarketZoneId,								
			CD.intDiscountTypeId,				CD.intDiscountId,				CD.intContractOptHeaderId,						
			CD.strBuyerSeller,					CD.intBillTo,					CD.intFreightRateId,			
			CD.strFobBasis,						CD.intRailGradeId,				CD.strRemark,
			CD.dblOriginalQty,					dblBalance = case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end,					CD.dblIntransitQty,
			dblScheduleQty = case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end,					CD.strPackingDescription,		intPriceItemUOMId = isnull(CD.intPriceItemUOMId,CD.intItemUOMId),
			CD.intLoadingPortId,				CD.intDestinationPortId,		CD.strShippingTerm,
			CD.intShippingLineId,				CD.strVessel,					CD.intDestinationCityId,
			CD.intShipperId,					CD.intNetWeightUOMId,			CD.strVendorLotID,
			CD.strInvoiceNo,					CD.dblNoOfLots,					CD.intUnitsPerLayer,
			CD.intLayersPerPallet,				CD.dtmEventStartDate,			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,		CD.intBookId,					CD.intSubBookId,
			CD.intContainerTypeId,				CD.intNumberOfContainers,		CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,					CD.dtmFXValidTo,				CD.strFXRemarks,
			CD.dblAssumedFX,					CD.strFixationBy,				CD.intItemUOMId,
			CD.intIndexId,						CD.dblAdjustment,				CD.intAdjItemUOMId,		
			CD.intDiscountScheduleCodeId,		CD.dblOriginalBasis,			CD.strLoadingPointType,
			CD.strDestinationPointType,			CD.intItemContractId,			CD.intNoOfLoad,
			CD.dblQuantityPerLoad,				CD.strReference,				CD.intStorageScheduleRuleId,
			CD.dblNetWeight,					CD.ysnUseFXPrice,				CD.intSplitId,
			CD.intFarmFieldId,					CD.intRateTypeId,				CD.intCurrencyExchangeRateId,
			CD.strItemSpecification,
			CD.dblQualityPremium,
			CD.dblOptionalityPremium,			CD.strContractReference,

			IM.strItemNo,						FT.strFreightTerm,				IM.strDescription				AS	strItemDescription,
			SV.strShipVia,						PT.strPricingType,				U1.strUnitMeasure				AS	strItemUOM,
			FM.strFutMarketName,				MO.strFutureMonth,				U2.strUnitMeasure				AS	strPriceUOM,
			MZ.strMarketZoneCode,				OH.strContractOptDesc,			U3.strUnitMeasure				AS	strAdjUOM,
			RG.strRailGrade,					CL.strLocationName,				FR.strOrigin+' - '+FR.strDest	AS	strOriginDest,
			IX.strIndexType,					EF.strFieldNumber,				LP.strCity						AS	strLoadingPoint,	
			SR.strScheduleDescription,			IM.strShortName,				DP.strCity						AS	strDestinationPoint,
			SK.intStockUOMId,					SK.strStockUnitMeasure,			DC.strCity						AS	strDestinationCity,
			SK.intStockUnitMeasureId,			IC.strContractItemName,			PU.intUnitMeasureId				AS	intPriceUnitMeasureId,
			ST.strSplitNumber,													U4.strUnitMeasure				AS	strStockItemUOM,
			CU.intMainCurrencyId,				CU.strCurrency,					CY.strCurrency					AS	strMainCurrency,
			ISNULL(IM.ysnUseWeighScales,0)		ysnUseWeighScales,				U7.strUnitMeasure				AS	strNetWeightUOM,
			BK.strBook,							SO.strSubBook,					ST.strDescription				AS	strSplitDescription,
			CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT)															AS	ysnSubCurrency,
			MONTH(dtmUpdatedAvailabilityDate)																	AS	intUpdatedAvailabilityMonth,
			YEAR(dtmUpdatedAvailabilityDate)																	AS	intUpdatedAvailabilityYear,
			ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0)		-	ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0)											AS	dblAvailableQty,
			dbo.fnCTConvertQtyToTargetItemUOM(	CD.intItemUOMId,SK.intStockUOMId,
												ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0) - ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0))			AS	dblAvailableQtyInItemStockUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,SK.intStockUOMId,ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0))			AS	dblBalanceInItemStockUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,SK.intStockUOMId,ISNULL(CD.dblQuantity,0))		AS	dblQuantityInItemStockUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,SK.intStockUOMId,ISNULL(CD.dblQuantityPerLoad,0))	AS	dblQtyPerLoadInItemStockUOM,
			CASE	WHEN	CH.ysnLoad = 1
					THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalanceLoad,0)
					ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0)												
			END																									AS	dblAppliedQty,
			CH.strContractNumber + ' - ' +LTRIM(CD.intContractSeq)												AS	strSequenceNumber,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblCashPrice)				AS	dblCashPriceInQtyUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity)				AS	dblQtyInPriceUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,SM.intItemUOMId,CD.dblQuantity)					AS	dblQtyInStockUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(SM.intItemUOMId,CD.intPriceItemUOMId,CD.dblCashPrice)				AS	dblCashPriceInStockUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(ISNULL(AD.intSeqPriceUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)),CD.intItemUOMId,1)AS	dblPriceToQtyConvFactor,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intNetWeightUOMId,CD.intItemUOMId,1)							AS	dblWeightToQtyConvFactor,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0)		
																		      -	ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0))	AS	dblAvailableNetWeight,
			CD.dblBalanceLoad - ISNULL(CD.dblScheduleLoad, 0) AS dblAvailableLoad,
			CD.dblFutures	/ CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END						AS	dblMainFutures,
			CD.dblBasis		/ CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END						AS	dblMainBasis,
			CD.dblCashPrice / CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END						AS	dblMainCashPrice,
			
			--Required by other modules

			SL.intStorageLocationId,			IM.strLotTracking,				SL.strName						AS	strStorageLocationName,
			SU.strStockUOM,						SU.strStockUOMType,				ISNULL(IU.dblUnitQty,0)			AS	dblItemUOMCF,  
			SB.intCompanyLocationSubLocationId,	SB.strSubLocationName,			ISNULL(SU.intStockUOM,0)		AS	intStockUOM,		
												CS.strContractStatus,			ISNULL(SU.dblStockUOMCF,0)		AS	dblStockUOMCF,	
			IX.strIndex,						VR.strVendorId,					
			SP.intSupplyPointId,												SP.intEntityVendorId			AS	intTerminalId,
			SP.intRackPriceSupplyPointId,		IM.intOriginId,					CA.strDescription				AS	strItemOrigin,
			RV.dblReservedQuantity,				IM.intLifeTime,					IC.intCountryId					AS	intItemContractOriginId,
			IM.strLifeTimeType,													CG.strCountry					AS	strItemContractOrigin,
			CA1.intCountryID AS intOriginCountryId, CA1.strDescription AS strItemOriginCountry,
			ISNULL(CD.dblQuantity,0) - ISNULL(RV.dblReservedQuantity,0)											AS	dblUnReservedQuantity,
			ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0)											AS	dblAllocatedQty,
			ISNULL(CD.dblQuantity,0) - ISNULL(PA.dblAllocatedQty,0) - ISNULL(SA.dblAllocatedQty,0)				AS	dblUnAllocatedQty,
			ISNULL(PA.intAllocationUOMId,SA.intAllocationUOMId)													AS	intAllocationUOMId,
			ISNULL(U5.strUnitMeasure,U6.strUnitMeasure)                                                         AS  strAllocationUOM,
			CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT)							AS	ysnAllowedToShow,
			dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)											AS	dblExchangeRate,
			CASE	WHEN	CD.intPricingTypeId = 2
					THEN	CASE	WHEN	ISNULL(PF.[dblTotalLots],0) = 0 
									THEN	'Unpriced'
							ELSE
									CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL([dblLotsFixed],0) = 0
												THEN 'Fully Priced' 
											WHEN ISNULL([dblLotsFixed],0) = 0 
												THEN 'Unpriced'
											ELSE 'Partially Priced' 
									END
							END
					
					WHEN	CD.intPricingTypeId = 1
							THEN	'Priced'
					ELSE	''
			END		COLLATE Latin1_General_CI_AS AS strPricingStatus,
			CAST(ISNULL(PF.[dblTotalLots] - ISNULL(PF.[dblLotsFixed],0),CD.dblNoOfLots)	AS NUMERIC(18, 6))			AS	dblUnpricedLots,
			CAST(ISNULL(PF.[dblTotalLots] - ISNULL(PF.intLotsHedged,0),CD.dblNoOfLots)	AS NUMERIC(18, 6))			AS	dblUnhedgedLots,
			CAST(ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalanceLoad,0) AS INT)										AS	intLoadReceived,
			CAST(CASE WHEN DATEADD(d, 0, DATEDIFF(d, 0, GETUTCDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysPurchase,0),ISNULL(CD.dtmStartDateUTC,CD.dtmStartDate)) AND CH.intContractTypeId = 1 THEN 1
					WHEN DATEADD(d, 0, DATEDIFF(d, 0, GETUTCDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysSales,0),ISNULL(CD.dtmStartDateUTC,CD.dtmStartDate)) AND CH.intContractTypeId = 2 THEN 1
					ELSE 0 END AS BIT) AS ysnEarlyDayPassed,
			CAST(CASE WHEN IM.strType = 'Bundle' THEN 1 ELSE 0 END AS BIT) AS ysnBundleItem,
			IM.strBundleType,
			dbo.fnCTGetContractPrice(CD.intContractDetailId) dblContractPrice,

			AD.intSeqCurrencyId,				AD.ysnSeqSubCurrency,			AD.intSeqPriceUOMId,
			AD.dblSeqPrice,						AD.strSeqCurrency,				AD.strSeqPriceUOM,
			AD.dblQtyToPriceUOMConvFactor,		AD.dblCostUnitQty,				AD.dblNetWtToPriceUOMConvFactor,
			AD.dblSeqBasis,						AD.intSeqBasisCurrencyId,		AD.intSeqBasisUOMId,	
			AD.ysnValidFX,						AD.dblSeqPrice * AD.dblQtyToPriceUOMConvFactor AS dblPricePerUnit,
			ISNULL(WU.dblUnitQty,1)	AS dblWeightUnitQty,
			ISNULL(IU.dblUnitQty,1)	AS dblUnitQty,
			RT.strCurrencyExchangeRateType,		RT.strDescription	AS strCurrencyExchangeRateTypeDesc,
			CP.ysnRequireProducerQty,

			CASE	WHEN	CD.intPricingTypeId = 2
					THEN	dblSeqBasis
					WHEN	CD.intPricingTypeId = 3
					THEN	dblSeqFutures
					ELSE	dblSeqPrice
			END		dblSeqCost,

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
			CH.strTextCode,						CH.strInternalComment,			CH.ysnSigned,
			CH.ysnPrinted,						CH.intSalespersonId,			CH.strSalespersonId,
			CH.intGradeId,						CH.strGrade,					CH.intWeightId,
			CH.strWeight,						CH.intCropYearId,				CH.strPrintableRemarks,
			CH.intAssociationId,				CH.strAssociationName,			CH.intTermId,
			CH.strTerm,							CH.intApprovalBasisId,			CH.strApprovalBasis,
			CH.strApprovalBasisDescription,		CH.intContractBasisId,			CH.strContractBasis,
			CH.strContractBasisDescription,		CH.intPositionId,				CH.strPosition,
			CH.intInsuranceById,				CH.strInsuranceBy,				CH.strInsuranceByDescription,
			CH.intInvoiceTypeId,				CH.strInvoiceType,				CH.strInvoiceTypeDescription,
			CH.dblTolerancePct,					CH.dblProvisionalInvoicePct,	CH.ysnPrepaid,
			CH.ysnSubstituteItem
			,ysnUnlimitedQuantity = CAST(ISNULL(CH.ysnUnlimitedQuantity,0) AS BIT)
			,CH.ysnMaxPrice,			
			CH.intINCOLocationTypeId,			CH.intCountryId,				CH.strCountry,
			CH.ysnMultiplePriceFixation,		CH.strINCOLocation,				CH.ysnLoad,
			CH.strCropYear,						CH.ysnExported,					CH.dtmExported,
			CH.ysnBrokerage,					CH.strCounterPartyName,			CH.strCPContract,
			CD.dblFreightBasisBase,
			CD.dblFreightBasis,
			CD.intFreightBasisBaseUOMId,
			CD.intFreightBasisUOMId,
			strFreightBasisUOM = FBUM.strUnitMeasure,
			strFreightBasisBaseUOM = FBBUM.strUnitMeasure
		
		, CD.strFinanceTradeNo  COLLATE Latin1_General_CI_AS AS strFinanceTradeNo
		, CD.intBankAccountId
		, BA.intBankId
		, strBankName = BN.strBankName
		, strBankAccountNo = BA.strBankAccountNo
		, CD.intBorrowingFacilityId
		, FA.strBorrowingFacilityId
		, CD.intBorrowingFacilityLimitId
		, CD.intBorrowingFacilityLimitDetailId
		, CD.dblLoanAmount
		, FAL.dblLimit
		, FALD.dblLimit AS dblSublimit
		, CD.intBankValuationRuleId
		, BVR.strBankValuationRule
		, FA.strBankReferenceNo
		, FAL.strBorrowingFacilityLimit
		, FALD.strLimitDescription
		, CD.strReferenceNo
		, CD.strComments
		, CD.ysnSubmittedToBank
		, CD.dtmDateSubmitted
		, CD.intApprovalStatusId
		, ASTF.strApprovalStatus
		, CD.dtmDateApproved
		, CD.dblInterestRate
		, CD.dtmPrepaymentDate
		, CD.dblPrepaymentAmount
		, strCostTerm = CostTerm.strFreightTerm
        , CD.intCostTermId
        , CD.dblBudgetPrice
		, CD.dblTotalBudget
		, CH.intSampleTypeId
		, sam.strSampleTypeName
		, CD.intLocalCurrencyId
		, CD.intLocalUOMId
		, CD.dblLocalCashPrice
		, ILU.strUnitMeasure AS strLocalUOM
		, LUC.strCurrency AS strLocalCurrency
		, CD.intAverageUOMId
		, CD.dblAverageQuantity
		, IAU.strUnitMeasure AS strAverageUOM
		, CD.intVendorLocationId
		, CD.ysnApplyDefaultTradeFinance
		, CD.ysnTaxOverride
		, CD.strTaxPoint
		, CD.strTaxLocation
		, CD.intTaxGroupId
		, CD.intTaxLocationId
		, EFT.strAccountNumber
		, CD.dtmEtaPol
		, CD.dtmEtaPod
		, CD.intGardenMarkId
		, CD.intReasonCodeId
		, CD.dblConvertedNetWeight
		, CD.dblConvertedQuantity
		, LL.strName AS strLogisticsLeadName
		, CD.intLogisticsLeadId
		, CD.intItemXrefId
		, strItemXrefProduct = case when CH.intContractTypeId = 1 then vx.strVendorProduct else cx.strCustomerProduct end
	FROM	tblCTContractDetail				CD	CROSS
	JOIN	tblCTCompanyPreference			CP	CROSS
	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	Cross apply (select intDefaultCurrencyId from tblSMCompanyPreference) smcp
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
	JOIN	tblICItemUOM					SM	ON	SM.intItemId				=	CD.intItemId					
												AND	SM.ysnStockUnit				=	1							LEFT
	JOIN	tblICUnitMeasure				U4	ON	U4.intUnitMeasureId			=	SM.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM					WU	ON	WU.intItemUOMId				=	CD.intNetWeightUOMId		LEFT
	JOIN	tblICUnitMeasure				U7	ON	U7.intUnitMeasureId			=	WU.intUnitMeasureId			LEFT	
	
	JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId				LEFT
	JOIN	tblICItemContract				IC	ON	IC.intItemContractId		=	CD.intItemContractId		LEFT
	JOIN	tblSMCountry					CG	ON	CG.intCountryID				=	IC.intCountryId				LEFT
	JOIN	tblICCommodityAttribute			CA1	ON	CA1.intCommodityAttributeId	=	IM.intOriginId				LEFT
	JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId			LEFT
	JOIN	tblSMShipVia					SV	ON	SV.[intEntityId]			=	CD.intShipViaId				LEFT
	JOIN	tblCTContractOptHeader			OH  ON	OH.intContractOptHeaderId	=	CD.intContractOptHeaderId	LEFT
	JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId			=	CD.intFreightRateId			LEFT
	JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId			=	CD.intRailGradeId			LEFT
	JOIN	tblRKFutureMarket				FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		LEFT
	JOIN	tblAPVendor						VR	ON	VR.[intEntityId]			=	CD.intBillTo				LEFT
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
	JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			LEFT
	JOIN	tblSMCurrency					CY	ON	CY.intCurrencyID			=	CU.intMainCurrencyId		LEFT
	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId			LEFT
	JOIN	tblICItemLocation				IL	ON	IL.intItemId				=	IM.intItemId				
												AND	IL.intLocationId			=	CD.intCompanyLocationId		LEFT
	JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId		=	IL.intStorageLocationId		LEFT
	JOIN	tblCTPriceFixation				PF	ON	PF.intContractDetailId		=	CD.intContractDetailId		LEFT
	JOIN	tblSMCity						LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
	JOIN	tblSMCity						DP	ON	DP.intCityId				=	CD.intLoadingPortId			LEFT
	JOIN	tblSMCity						DC	ON	DC.intCityId				=	CD.intDestinationCityId		LEFT
	JOIN	tblEMEntityFarm					EF	ON	EF.intFarmFieldId			=	CD.intFarmFieldId			LEFT
	JOIN	tblEMEntitySplit				ST	ON	ST.intSplitId				=	CD.intSplitId				LEFT
	JOIN	tblGRStorageScheduleRule		SR	ON	SR.intStorageScheduleRuleId	=	CD.intStorageScheduleRuleId	LEFT
	JOIN	tblCTBook						BK	ON	BK.intBookId				=	CD.intBookId				LEFT 
	JOIN	tblCTSubBook					SO	ON	SO.intSubBookId				=	CD.intSubBookId				LEFT
	
	JOIN	tblICItemUOM					FB	ON	FB.intItemUOMId				=	CD.intFreightBasisUOMId		LEFT
	JOIN	tblICUnitMeasure				FBUM	ON FBUM.intUnitMeasureId	=	FB.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM					FBB	ON	FBB.intItemUOMId			=	CD.intFreightBasisBaseUOMId	LEFT
	JOIN	tblICUnitMeasure				FBBUM	ON FBBUM.intUnitMeasureId	=	FBB.intUnitMeasureId		LEFT

	JOIN	(
				SELECT  intItemUOMId AS intStockUOM,strUnitMeasure AS strStockUOM,strUnitType AS strStockUOMType,dblUnitQty AS dblStockUOMCF 
				FROM	tblICItemUOM		IU	LEFT 
				JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId 
				WHERE	ysnStockUnit = 1
			)								SU	ON	SU.intStockUOM				=	IU.intItemUOMId				LEFT
	JOIN	(
				SELECT  intItemUOMId AS intStockUOMId,strUnitMeasure AS strStockUnitMeasure,IU.intItemId,IU.intUnitMeasureId AS intStockUnitMeasureId
				FROM	tblICItemUOM		IU	 
				JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId 
				WHERE	IU.ysnStockUnit = 1
			)								SK	ON	SK.intItemId				=	CD.intItemId				LEFT
	JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	= IL.intSubLocationId 	LEFT
	JOIN	tblTRSupplyPoint				SP	ON	SP.intEntityVendorId		=	IX.intVendorId	AND 
													SP.intEntityLocationId = IX.intVendorLocationId				LEFT
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
			)								SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId		LEFT
	JOIN	tblICUnitMeasure				U5	ON	U5.intUnitMeasureId			=	PA.intAllocationUOMId		LEFT	
	JOIN	tblICUnitMeasure				U6	ON	U6.intUnitMeasureId			=	SA.intAllocationUOMId		LEFT
	JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=	CD.intRateTypeId	 
	LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = CD.intBankAccountId
	LEFT JOIN tblCMBank BN ON BN.intBankId = CD.intBankId
	LEFT JOIN tblCMBorrowingFacility FA ON FA.intBorrowingFacilityId = CD.intBorrowingFacilityId
	LEFT JOIN tblCMBorrowingFacilityLimit FAL ON FAL.intBorrowingFacilityLimitId = CD.intBorrowingFacilityLimitId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail FALD ON FALD.intBorrowingFacilityLimitDetailId = CD.intBorrowingFacilityLimitDetailId
	LEFT JOIN tblCTApprovalStatusTF ASTF on ASTF.intApprovalStatusId = CD.intApprovalStatusId
	LEFT JOIN tblCMBankLoan BL ON BL.intBankLoanId = CD.intLoanLimitId
	LEFT JOIN tblCMBankValuationRule BVR ON BVR.intBankValuationRuleId = CD.intBankValuationRuleId
	LEFT JOIN tblSMFreightTerms CostTerm ON CostTerm.intFreightTermId = CD.intCostTermId
	LEFT JOIN tblQMSampleType sam on sam.intSampleTypeId = CH.intSampleTypeId
	LEFT JOIN tblICItemUOM   LU	ON	LU.intItemUOMId	= CD.intLocalUOMId
	LEFT JOIN tblICUnitMeasure ILU ON ILU.intUnitMeasureId = LU.intUnitMeasureId	--strLocalUOM
	LEFT JOIN tblSMCurrency	LUC	ON LUC.intCurrencyID = CD.intLocalCurrencyId		--strLocalCurrency
	LEFT JOIN tblICItemUOM   AU2	ON	AU2.intItemUOMId	= CD.intAverageUOMId
	LEFT JOIN tblICUnitMeasure IAU ON IAU.intUnitMeasureId = AU2.intUnitMeasureId	--strAverageUOM
	LEFT JOIN [vyuAPEntityEFTInformation] EFT on EFT.intEntityId = CH.intEntityId and isnull(EFT.ysnDefaultAccount,0) = 1 and EFT.intCurrencyId = CD.intCurrencyId
 	LEFT JOIN tblSMCurrency INV ON INV.intCurrencyID = CD.intInvoiceCurrencyId
	LEFT JOIN tblEMEntity LL on LL.intEntityId = CD.intLogisticsLeadId
	LEFT JOIN tblQMGardenMark GM on GM.intGardenMarkId = CD.intGardenMarkId
	left join tblICItemVendorXref vx on vx.intItemVendorXrefId = CD.intItemXrefId
	left join tblICItemCustomerXref cx on cx.intItemCustomerXrefId = CD.intItemXrefId
    cross apply (
     select
     dblHeaderBalance = CH.dblHeaderQuantity - sum(cd.dblQuantity - cd.dblBalance)
     ,dblHeaderAvailable = CH.dblHeaderQuantity - (sum(cd.dblQuantity - cd.dblBalance) + sum(isnull(cd.dblScheduleQty,0)))
	 ,dblHeaderScheduleQty = sum(isnull(cd.dblScheduleQty,0))
     from tblCTContractDetail cd
     where cd.intContractHeaderId = CH.intContractHeaderId
    ) cds
