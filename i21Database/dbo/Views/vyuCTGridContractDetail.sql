CREATE VIEW dbo.vyuCTGridContractDetail
AS
	SELECT	DISTINCT
			--CD.*,
			CD.intContractDetailId,
			CD.intSplitFromId,
			CD.intParentDetailId,
			CD.ysnSlice,
			CD.intConcurrencyId,
			CD.intContractHeaderId,
			CD.intContractStatusId,
			CD.intContractSeq,
			CD.intCompanyLocationId,
			CD.intShipToId,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.intFreightTermId,
			CD.intShipViaId,
			CD.intItemContractId,
			CD.intItemBundleId,
			CD.intItemId,
			CD.strItemSpecification,
			CD.intCategoryId,
			CD.dblQuantity,
			CD.intItemUOMId,
			CD.dblOriginalQty,
			CD.dblBalance,
			CD.dblIntransitQty,
			CD.dblScheduleQty,
			CD.dblBalanceLoad,
			CD.dblScheduleLoad,
			CD.dblShippingInstructionQty,
			CD.dblNetWeight,
			CD.intNetWeightUOMId,
			CD.intUnitMeasureId,
			CD.intCategoryUOMId,
			CD.intNoOfLoad,
			CD.dblQuantityPerLoad,
			CD.intIndexId,
			CD.dblAdjustment,
			CD.intAdjItemUOMId,
			CD.intPricingTypeId,
			CD.intFutureMarketId,
			CD.intFutureMonthId,
			CD.dblFutures,
			CD.dblBasis,
			CD.dblOriginalBasis,
			CD.dblConvertedBasis,
			CD.intBasisCurrencyId,
			CD.intBasisUOMId,
			CD.dblFreightBasisBase,
			CD.intFreightBasisBaseUOMId,
			CD.dblFreightBasis,
			CD.intFreightBasisUOMId,
			CD.dblRatio,
			CD.dblCashPrice,
			CD.dblTotalCost,
			CD.intCurrencyId,
			CD.intPriceItemUOMId,
			CD.dblNoOfLots,
			CD.dtmLCDate,
			CD.dtmLastPricingDate,
			CD.dblConvertedPrice,
			CD.intConvPriceCurrencyId,
			CD.intConvPriceUOMId,
			CD.intMarketZoneId,
			CD.intDiscountTypeId,
			CD.intDiscountId,
			CD.intDiscountScheduleId,
			CD.intDiscountScheduleCodeId,
			CD.intStorageScheduleRuleId,
			CD.intContractOptHeaderId,
			CD.strBuyerSeller,
			CD.intBillTo,
			CD.intFreightRateId,
			CD.strFobBasis,
			CD.intRailGradeId,
			CD.strRailRemark,
			CD.strLoadingPointType,
			CD.intLoadingPortId,
			CD.strDestinationPointType,
			CD.intDestinationPortId,
			CD.strShippingTerm,
			CD.intShippingLineId,
			CD.strVessel,
			CD.intDestinationCityId,
			CD.intShipperId,
			CD.strRemark,
			CD.intSubLocationId,
			CD.intStorageLocationId,
			CD.intPurchasingGroupId,
			CD.intFarmFieldId,
			CD.intSplitId,
			CD.strGrade,
			CD.strGarden,
			CD.strVendorLotID,
			CD.strInvoiceNo,
			CD.strReference,
			CD.strERPPONumber,
			CD.strERPItemNumber,
			CD.strERPBatchNumber,
			CD.intUnitsPerLayer,
			CD.intLayersPerPallet,
			CD.dtmEventStartDate,
			CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate,
			CD.dtmM2MDate,
			CD.intBookId,
			CD.intSubBookId,
			CD.intContainerTypeId,
			CD.intNumberOfContainers,
			CD.intInvoiceCurrencyId,
			CD.dtmFXValidFrom,
			CD.dtmFXValidTo,
			CD.dblRate,
			CD.dblFXPrice,
			CD.ysnUseFXPrice,
			CD.intFXPriceUOMId,
			CD.strFXRemarks,
			CD.dblAssumedFX,
			CD.strFixationBy,
			CD.strPackingDescription,
			CD.dblYield,
			CD.intCurrencyExchangeRateId,
			CD.intRateTypeId,
			CD.intCreatedById,
			CD.dtmCreated,
			CD.intLastModifiedById,
			CD.dtmLastModified,
			CD.ysnInvoice,
			CD.ysnProvisionalInvoice,
			CD.ysnQuantityFinal,
			CD.intProducerId,
			CD.ysnClaimsToProducer,
			CD.ysnRiskToProducer,
			CD.ysnBackToBack,
			CD.dblAllocatedQty,
			CD.dblReservedQty,
			CD.dblAllocationAdjQty,
			CD.dblInvoicedQty,
			CD.ysnPriceChanged,
			CD.intContractDetailRefId,
			CD.ysnStockSale,
			CD.strCertifications,
			CD.ysnSplit,
			CD.ysnProvisionalPNL,
			CD.ysnFinalPNL,
			CD.dtmProvisionalPNL,
			CD.dtmFinalPNL,

			CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty,
			CD.intContractStatusId intCurrentContractStatusId,
			MZ.strMarketZoneCode,
			IM.strItemNo,
			XM.strUnitMeasure strAdjustmentUOM,
			CL.strLocationName,
			FT.strFreightTerm,
			SV.strName AS strShipVia,
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
			PF.[dblTotalLots],
			PF.[dblLotsFixed],
			IC.strContractItemName,
			IB.strItemNo AS strBundleItemNo,
			WM.strUnitMeasure strNetWeightUOM,
			PM.strUnitMeasure strPriceUOM,
			ISNULL(RY.strCountry,OG.strCountry) AS strOrigin,
			IX.strIndex,
			CS.strContractStatus,
			PF.intPriceFixationId, 
			PF.intPriceContractId, 
			QA.strContainerNumber,
			QA.strSampleTypeName,
			QA.strSampleStatus,
			QA.dtmTestingEndDate,
			QA.dblApprovedQty,
			MA.strFutMarketName AS strFutureMarket,
			REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ') strFutureMonth,
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
						THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalanceLoad,0)
						ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
			END		AS	dblAppliedQty,
			dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)	AS	dblExchangeRate,
			IM.intProductTypeId,
			CQ.dblBulkQuantity ,
			CQ.dblBagQuantity,
			CAST(1 AS BIT) ysnItemUOMIdExist,
			RM.strUnitMeasure strContainerUOM,
			SB.strSubLocationName,
			SL.strName						AS	strStorageLocationName,		
			LP.strCity						AS	strLoadingPoint,
			DP.strCity						AS	strDestinationPoint,
			AP.strApprovalStatus,
			MA.dblContractSize				AS dblMarketContractSize,
			MA.intUnitMeasureId				AS intMarketUnitMeasureId,
			MA.intCurrencyId				AS intMarketCurrencyId,
			MU.strUnitMeasure				AS strMarketUnitMeasure,
			XM.strUnitType					AS strQtyUnitType,
			CAST(ISNULL(LG.intLoadDetailId,0) AS BIT) AS ysnLoadAvailable,

			
			BK.strBook,
			SK.strSubBook,
			BT.strName						AS	strBillTo,
			SH.strName						AS	strShipper,
			SN.strName						AS	strShippingLine,
			EF.strFarmNumber,
			ES.strSplitNumber,
			DS.strDiscountDescription,
			SI.strDescription				AS	strScheduleCode,
			SR.strScheduleDescription,
			CG.strCategoryCode,
			CQ.strContainerType,
			DY.strCity						AS	strDestinationCity,
			IY.strCurrency AS strInvoiceCurrency,
			FY.strCurrency + '/' + TY.strCurrency AS strExchangeRate,
			PG.strName						AS	strPurchasingGroup,
			FM.strUnitMeasure				AS	strFXPriceUOM,
			RT.strCurrencyExchangeRateType,
			PR.strName						AS	strProducer,
			CU.intCent						AS	intPriceCurrencyCent,
			MY.strCurrency					AS	strMarketCurrency,
			BC.strCurrency					AS	strBasisCurrency,
			BC.ysnSubCurrency				AS	ysnBasisSubCurrency,
			CC.strCurrency					AS	strConvertedCurrency,
			CC.ysnSubCurrency				AS	ysnConvertedSubCurrency,
			BM.strUnitMeasure				AS	strBasisUOM,
			VM.strUnitMeasure				AS	strConvertedUOM,
			CH.ysnLoad						AS	ysnLoad,
			CASE WHEN AD.intAllocationDetailId IS NOT NULL THEN 1 ELSE 0 END AS ysnContractAllocated,
			ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') AS strShipmentStatus,
			CASE 
				WHEN CH.intContractTypeId = 1 THEN
					CASE 
						WHEN CD.ysnFinalPNL = 1 THEN 'Final P&L Created'
						WHEN CD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
						ELSE CASE WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' END
					END
				ELSE CD.strFinancialStatus --FS.strFinancialStatus
			END AS strFinancialStatus,
			strFreightBasisUOM = FBUM.strUnitMeasure,
			strFreightBasisBaseUOM = FBBUM.strUnitMeasure,
			CD.intRefFuturesMarketId,
			CD.intRefFuturesMonthId,
			CD.intRefFuturesItemUOMId,
			CD.intRefFuturesCurrencyId,
			CD.dblRefFuturesQty,
			RefFuturesMarket.strFutMarketName  strRefFuturesMarket,
			REPLACE(RefFuturesMonth.strFutureMonth, ' ', '(' + RefFuturesMonth.strSymbol + ') ') strRefFuturesMonth,
			RefFuturesCurrency.strCurrency strRefFuturesCurrency,
			RefFturesUnitMeasure.strUnitMeasure strRefFuturesUnitMeasure,
			ysnWithPriceFix = convert(bit, isnull(PF.intPriceFixationId,0))
	FROM			tblCTContractDetail				CD
			JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
	LEFT	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId					=		CD.intMarketZoneId			--strMarketZoneCode
	LEFT	JOIN	tblCTBook						BK	ON	BK.intBookId						=		CD.intBookId				--strBook
	LEFT    JOIN	tblCTContractOptHeader			OH	ON	OH.intContractOptHeaderId			=		CD.intContractOptHeaderId	--strContractOptDesc
	LEFT    JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId				=		CD.intContractStatusId		--strContractStatus
	LEFT    JOIN	tblCTDiscountType				DT	ON	DT.intDiscountTypeId				=		CD.intDiscountTypeId		--strDiscountType
	LEFT    JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId					=		CD.intFreightRateId			--strOriginDest
	LEFT    JOIN	tblCTIndex						IX	ON	IX.intIndexId						=		CD.intIndexId				--strIndex
	LEFT    JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId					=		CD.intPricingTypeId			--strPricingType
	LEFT    JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId					=		CD.intRailGradeId
	LEFT	JOIN	tblCTSubBook					SK	ON	SK.intSubBookId						=		CD.intSubBookId				--strSubBook

	-- Reference Pricing
	LEFT JOIN tblRKFutureMarket RefFuturesMarket ON RefFuturesMarket.intFutureMarketId = CD.intRefFuturesMarketId
	LEFT JOIN tblRKFuturesMonth RefFuturesMonth ON RefFuturesMonth.intFutureMonthId = CD.intRefFuturesMonthId
	LEFT JOIN tblSMCurrency RefFuturesCurrency ON RefFuturesCurrency.intCurrencyID = CD.intRefFuturesCurrencyId
	LEFT JOIN tblICItemUOM RefFuturesItemUOMId ON RefFuturesItemUOMId.intItemUOMId = CD.intRefFuturesItemUOMId
	LEFT JOIN tblICUnitMeasure RefFturesUnitMeasure ON RefFturesUnitMeasure.intUnitMeasureId = RefFuturesItemUOMId.intUnitMeasureId
	
	LEFT	JOIN	tblEMEntity						BT	ON	BT.intEntityId						=		CD.intBillTo				--strBillTo
	LEFT	JOIN	tblEMEntity						SH	ON	SH.intEntityId						=		CD.intShipperId				--strShipper
	LEFT	JOIN	tblEMEntity						SN	ON	SN.intEntityId						=		CD.intShippingLineId		--strShippingLine
	LEFT    JOIN	tblEMEntity						SV	ON	SV.intEntityId						=		CD.intShipViaId				--strShipVia
	LEFT    JOIN	tblEMEntity						PR	ON	PR.intEntityId						=		CD.intProducerId			--strProducer
	LEFT	JOIN	tblEMEntityFarm					EF	ON	EF.intFarmFieldId					=		CD.intFarmFieldId			--strFarmNumber
	LEFT	JOIN	tblEMEntitySplit				ES	ON	ES.intSplitId						=		CD.intSplitId				--strSplitNumber
	
	LEFT    JOIN	tblGRDiscountId					DC	ON	DC.intDiscountId					=		CD.intDiscountId			--strDiscountId
	LEFT    JOIN	tblGRDiscountSchedule			DS	ON	DS.intDiscountScheduleId			=		CD.intDiscountScheduleId	--strDiscountDescription
	LEFT    JOIN	tblGRDiscountScheduleCode		SC	ON	SC.intDiscountScheduleCodeId		=		CD.intDiscountScheduleCodeId	
	LEFT	JOIN	tblICItem						SI	ON	SI.intItemId						=		SC.intItemId				--strScheduleCode
	LEFT    JOIN	tblGRStorageScheduleRule		SR	ON	SR.intStorageScheduleRuleId			=		CD.intStorageScheduleRuleId	--strScheduleDescription
	
	LEFT    JOIN	tblICCategory					CG	ON	CG.intCategoryId					=		CD.intCategoryId			--strCategoryCode
	LEFT    JOIN	tblICCategoryUOM				YU	ON	YU.intCategoryUOMId					=		CD.intCategoryUOMId	
	LEFT    JOIN	tblICUnitMeasure				YM	ON	YM.intUnitMeasureId					=		YU.intUnitMeasureId			--strUOM
	LEFT    JOIN	tblICItem						IM	ON	IM.intItemId						=		CD.intItemId				--strItemNo
	LEFT    JOIN	tblICItemContract				IC	ON	IC.intItemContractId				=		CD.intItemContractId		--strContractItemName
	LEFT    JOIN	tblICItem						IB	ON	IB.intItemId						=		CD.intItemBundleId			--strBundleItemNo
	LEFT    JOIN	tblICItemUOM					QU	ON	QU.intItemUOMId						=		CD.intItemUOMId				
	LEFT    JOIN	tblICUnitMeasure				QM	ON	QM.intUnitMeasureId					=		QU.intUnitMeasureId			--strUOM
	LEFT    JOIN	tblICItemUOM					WU	ON	WU.intItemUOMId						=		CD.intNetWeightUOMId		
	LEFT    JOIN	tblICUnitMeasure				WM	ON	WM.intUnitMeasureId					=		WU.intUnitMeasureId			--strNetWeightUOM
	LEFT    JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId						=		CD.intPriceItemUOMId		
	LEFT    JOIN	tblICUnitMeasure				PM	ON	PM.intUnitMeasureId					=		PU.intUnitMeasureId			--strPriceUOM
	LEFT    JOIN	tblICItemUOM					XU	ON	XU.intItemUOMId						=		CD.intAdjItemUOMId
	LEFT    JOIN	tblICUnitMeasure				XM	ON	XM.intUnitMeasureId					=		XU.intUnitMeasureId			--strAdjustmentUOM
	LEFT    JOIN	tblICItemUOM					FU	ON	FU.intItemUOMId						=		CD.intFXPriceUOMId
	LEFT    JOIN	tblICUnitMeasure				FM	ON	FM.intUnitMeasureId					=		FU.intUnitMeasureId			--strFXPriceUOM
	LEFT    JOIN	tblICItemUOM					BU	ON	BU.intItemUOMId						=		CD.intBasisUOMId
	LEFT    JOIN	tblICUnitMeasure				BM	ON	BM.intUnitMeasureId					=		BU.intUnitMeasureId			--strBasisUOM
	LEFT    JOIN	tblICItemUOM					VU	ON	VU.intItemUOMId						=		CD.intConvPriceUOMId
	LEFT    JOIN	tblICUnitMeasure				VM	ON	VM.intUnitMeasureId					=		VU.intUnitMeasureId			--strConvertedUOM
	LEFT    JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId				=		CD.intStorageLocationId		--strStorageLocationName
	
	LEFT    JOIN	tblRKFutureMarket				MA	ON	MA.intFutureMarketId				=		CD.intFutureMarketId		--strFutureMarket
	LEFT    JOIN	tblICUnitMeasure				MU	ON	MU.intUnitMeasureId					=		MA.intUnitMeasureId
	LEFT    JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId					=		CD.intFutureMonthId			--strFutureMonth
	
	LEFT    JOIN	tblSMCity						DY	ON	DY.intCityId						=		CD.intDestinationCityId		--strDestinationCity
	LEFT    JOIN	tblSMCity						DP	ON	DP.intCityId						=		CD.intDestinationPortId		--strDestinationPort
	LEFT    JOIN	tblSMCity						LP	ON	LP.intCityId						=		CD.intLoadingPortId			--strLoadingPort
	LEFT    JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId				=		CD.intCompanyLocationId		--strLocationName
	LEFT    JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID					=		CD.intCurrencyId			--strCurrency
	LEFT    JOIN	tblSMCurrency					CY	ON	CY.intCurrencyID					=		CU.intMainCurrencyId
	LEFT    JOIN	tblSMCurrency					BC	ON	BC.intCurrencyID					=		CD.intBasisCurrencyId		--strBasisCurrency
	LEFT    JOIN	tblSMCurrency					CC	ON	CC.intCurrencyID					=		CD.intConvPriceCurrencyId	--strConvertedCurrency

	LEFT    JOIN	tblSMCurrency					IY	ON	IY.intCurrencyID					=		CD.intInvoiceCurrencyId		--strInvoiceCurrency
	LEFT    JOIN	tblSMCurrency					MY	ON	MY.intCurrencyID					=		MA.intCurrencyId			--strMarketCurrency
	LEFT    JOIN	tblSMCurrencyExchangeRate		ER	ON	ER.intCurrencyExchangeRateId		=		CD.intCurrencyExchangeRateId--strExchangeRate
	LEFT    JOIN	tblSMCurrency					FY	ON	FY.intCurrencyID					=		ER.intFromCurrencyId			
	LEFT    JOIN	tblSMCurrency					TY	ON	TY.intCurrencyID					=		ER.intToCurrencyId	
	LEFT    JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CD.intRateTypeId
	LEFT    JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId					=		CD.intFreightTermId			--strFreightTerm
	LEFT	JOIN	tblSMPurchasingGroup			PG	ON	PG.intPurchasingGroupId				=		CD.intPurchasingGroupId		--strPurchasingGroup
	LEFT    JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	=		CD.intSubLocationId 		--strLocationName
	
	LEFT    JOIN	tblSMCountry					RY	ON	RY.intCountryID						=		IC.intCountryId
	LEFT    JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId			=		IM.intOriginId												
														AND	CA.strType							=		'Origin'			
	LEFT    JOIN	tblSMCountry					OG	ON	OG.intCountryID						=		CA.intCountryID	
	LEFT	JOIN	tblICCommodityUnitMeasure		CO	ON	CO.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
	LEFT    JOIN	tblICItemUOM					CM	ON	CM.intItemId						=		CD.intItemId		
														AND	CM.intUnitMeasureId					=		CO.intUnitMeasureId		
	LEFT    JOIN	tblICCategoryUOM				GU	ON	GU.intCategoryId					=		CD.intCategoryId																	
														AND	GU.intUnitMeasureId					=		CH.intCategoryUnitMeasureId		
	LEFT    JOIN	tblCTPriceFixation				PF	ON	CD.intContractDetailId				=		PF.intContractDetailId		
	
	LEFT	JOIN	tblICItemUOM					FB	ON	FB.intItemUOMId				=	CD.intFreightBasisUOMId		
	LEFT	JOIN	tblICUnitMeasure				FBUM	ON FBUM.intUnitMeasureId	=	FB.intUnitMeasureId			
	LEFT	JOIN	tblICItemUOM					FBB	ON	FBB.intItemUOMId			=	CD.intFreightBasisBaseUOMId	
	LEFT	JOIN	tblICUnitMeasure				FBBUM	ON FBBUM.intUnitMeasureId	=	FBB.intUnitMeasureId		

	LEFT    JOIN	(
						SELECT	 intPriceFixationId,
								 COUNT(intPriceFixationDetailId) intPFDCount,
								 SUM(dblQuantity) dblQuantityPriceFixed,
								 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
						FROM	 tblCTPriceFixationDetail
						GROUP BY intPriceFixationId
					)								PD	ON	PD.intPriceFixationId				=		PF.intPriceFixationId
	LEFT    JOIN	(
						SELECT	CQ.intContainerTypeId,
								CQ.intCommodityAttributeId,
								CQ.intUnitMeasureId,
								CQ.dblBulkQuantity ,
								CQ.dblQuantity AS dblBagQuantity,
								CQ.intCommodityId,
								CA.intCountryID AS intCountryId,
								CT.strContainerType
						FROM	tblLGContainerTypeCommodityQty	CQ	
						JOIN	tblLGContainerType				CT	ON	CT.intContainerTypeId		=	CQ.intContainerTypeId
						JOIN	tblICCommodityAttribute			CA	ON	CQ.intCommodityAttributeId	=	CA.intCommodityAttributeId
					)								CQ	ON	CQ.intCommodityId					=		CH.intCommodityId 
														AND CQ.intContainerTypeId				=		CD.intContainerTypeId 
														AND CQ.intCountryId						=		ISNULL(IC.intCountryId,CA.intCountryID)
	LEFT    JOIN	tblICUnitMeasure				RM	ON	RM.intUnitMeasureId					=		CQ.intUnitMeasureId
	LEFT    JOIN	(
						SELECT * FROM 
						(
							SELECT	ROW_NUMBER() OVER (PARTITION BY TR.intRecordId ORDER BY AP.intApprovalId DESC) intRowNum,
									TR.intRecordId, AP.strStatus AS strApprovalStatus 
							FROM	tblSMApproval		AP
							JOIN	tblSMTransaction	TR	ON	TR.intTransactionId =	AP.intTransactionId
							JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
							WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
														'ContractManagement.view.Amendments')
						) t
						WHERE intRowNum = 1
					)								AP	ON	AP.intRecordId						=		CD.intContractHeaderId		
	LEFT    JOIN	(
					SELECT ROW_NUMBER() OVER (PARTITION BY ISNULL(intPContractDetailId,intSContractDetailId) ORDER BY intLoadDetailId DESC) intRowNum,ISNULL(intPContractDetailId,intSContractDetailId)intContractDetailId,intLoadDetailId 
					FROM tblLGLoadDetail
				)LG ON LG.intRowNum = 1 AND LG.intContractDetailId = CD.intContractDetailId
	OUTER	APPLY	dbo.fnCTGetSampleDetail(CD.intContractDetailId)	QA
	OUTER	APPLY	dbo.fnCTGetShipmentStatus(CD.intContractDetailId) LD
	--OUTER	APPLY	dbo.fnCTGetFinancialStatus(CD.intContractDetailId) FS
	LEFT	JOIN	tblAPBillDetail						BD ON	BD.intContractDetailId = CD.intContractDetailId
	LEFT	JOIN	tblLGAllocationDetail		AD		ON AD.intPContractDetailId = CD.intContractDetailId