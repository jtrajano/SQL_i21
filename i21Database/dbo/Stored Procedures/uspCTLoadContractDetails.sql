CREATE PROCEDURE [dbo].[uspCTLoadContractDetails]

	@intContractHeaderId INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	;With ContractDetail AS (
	   SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId --1247
    )

	SELECT	*,
			dblAppliedQty * dblQuantityPerLoad		AS	dblAppliedLoadQty
	FROM
	(
		SELECT	 CD.*

				,CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty
				,CD.dblBalanceLoad - ISNULL(CD.dblScheduleLoad, 0) dblAvailableLoad
				,CD.intContractStatusId intCurrentContractStatusId
				,dbo.[fnCTGetSeqDisplayField](CD.intMarketZoneId,'tblARMarketZone') strMarketZoneCode--MZ.strMarketZoneCode
				,IM.strItemNo
				,XM.strUnitMeasure strAdjustmentUOM
				,CL.strLocationName
				,FT.strFreightTerm
				,dbo.[fnCTGetSeqDisplayField](CD.intShipViaId,'tblEMEntity') strShipVia--SV.strName AS strShipVia
				,CU.strCurrency
				,CY.strCurrency strMainCurrency
				,CU.intMainCurrencyId
				,CU.ysnSubCurrency
				,dbo.[fnCTGetSeqDisplayField](CD.intFreightRateId,'tblCTFreightRate') strOriginDest--FR.strOrigin + FR.strDest strOriginDest
				,dbo.[fnCTGetSeqDisplayField](CD.intRailGradeId,'tblCTRailGrade') strRailGrade--RG.strRailGrade
				,PT.strPricingType
				,NULL AS strContractOptDesc --Screen not in use
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountTypeId,'tblCTDiscountType') strDiscountType
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountId,'tblGRDiscountId') strDiscountId
				,FI.dblQuantityPriceFixed
				,CD.dblQuantity - ISNULL(FI.dblQuantityPriceFixed, 0) AS dblUnpricedQty
				,FI.dblPFQuantityUOMId
				,FI.[dblTotalLots]
				,FI.[dblLotsFixed]
				,CD.dblNoOfLots - ISNULL(FI.[dblLotsFixed], 0) AS dblUnpricedLots
				,IC.strContractItemName
				,WM.strUnitMeasure strNetWeightUOM
				,PM.strUnitMeasure strPriceUOM
				,ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
				,dbo.[fnCTGetSeqDisplayField](CD.intIndexId,'tblCTIndex') strIndex--IX.strIndex
				,CS.strContractStatus
				,FI.intPriceFixationId
				,FI.intPriceContractId
				,QA.strContainerNumber
				,QA.strSampleTypeName
				,QA.strSampleStatus
				,QA.dtmTestingEndDate
				,QA.dblApprovedQty
				,MA.strFutMarketName AS strFutureMarket
				,REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ') strFutureMonth
				,FI.ysnSpreadAvailable
				,FI.ysnFixationDetailAvailable
				,FI.ysnMultiPricingDetail
				--,CASE 
				--	WHEN	 CH.ysnCategory = 1
				--		 THEN dbo.fnCTConvertQtyToTargetCategoryUOM(CD.intCategoryUOMId, GU.intCategoryUOMId, 1)
				--	ELSE	 dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CM.intItemUOMId, 1)
				--  END	 AS dblConversionFactor
				,QU.dblUnitQty/ CM.dblUnitQty AS dblConversionFactor
				,QM.strUnitMeasure strUOM--ISNULL(QM.strUnitMeasure, YM.strUnitMeasure) AS strUOM -- YM. is not in use
				,CASE 
					WHEN CH.ysnLoad = 1
						THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0)
					ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)
				 END AS dblAppliedQty
				,dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0) AS dblExchangeRate
				,IM.intProductTypeId
				,CQ.dblBulkQuantity
				,CQ.dblBagQuantity
				,CAST(1 AS BIT) ysnItemUOMIdExist
				,CQ.strContainerUOM --RM.strUnitMeasure strContainerUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intSubLocationId,'tblSMCompanyLocationSubLocation') strSubLocationName --SB.strSubLocationName
				,dbo.[fnCTGetSeqDisplayField](CD.intStorageLocationId,'tblICStorageLocation') strStorageLocationName --SL.strName AS strStorageLocationName
				,LP.strCity AS strLoadingPoint
				,DP.strCity AS strDestinationPoint
				,dbo.[fnCTGetLastApprovalStatus](CD.intContractHeaderId) strApprovalStatus
				,MA.dblContractSize AS dblMarketContractSize
				,MA.intUnitMeasureId AS intMarketUnitMeasureId
				,MA.intCurrencyId AS intMarketCurrencyId
				,MU.strUnitMeasure AS strMarketUnitMeasure
				,XM.strUnitType AS strQtyUnitType
				,CAST(ISNULL(LG.intLoadDetailId, 0) AS BIT) AS ysnLoadAvailable
				,dbo.[fnCTGetSeqDisplayField](CD.intBookId,'tblCTBook') strBook --BK.strBook
				,dbo.[fnCTGetSeqDisplayField](CD.intSubBookId,'tblCTSubBook') strSubBook --SK.strSubBook
				,dbo.[fnCTGetSeqDisplayField](CD.intBillTo,'tblEMEntity') strBillTo --BT.strName AS strBillTo
				,dbo.[fnCTGetSeqDisplayField](CD.intShipperId,'tblEMEntity') strShipper--SH.strName AS strShipper
				,dbo.[fnCTGetSeqDisplayField](CD.intShippingLineId,'tblEMEntity') strShippingLine--SN.strName AS strShippingLine
				,dbo.[fnCTGetSeqDisplayField](CD.intFarmFieldId,'tblEMEntityLocation') strFarmNumber --EF.strLocationName AS strFarmNumber
				,dbo.[fnCTGetSeqDisplayField](CD.intSplitId,'tblEMEntitySplit') strSplitNumber --ES.strSplitNumber
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleId,'tblGRDiscountSchedule') strDiscountDescription--DS.strDiscountDescription
				,dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleCodeId,'tblGRDiscountScheduleCode') strScheduleCode--,SI.strDescription AS strScheduleCode
				,dbo.[fnCTGetSeqDisplayField](CD.intStorageScheduleRuleId,'tblGRStorageScheduleRule') strScheduleDescription--,SR.strScheduleDescription
				,NULL AS strCategoryCode--CG.strCategoryCode --CG. is not in use
				,CQ.strContainerType
				,DY.strCity AS strDestinationCity
				,IY.strCurrency AS strInvoiceCurrency
				,'From ' + FY.strCurrency + ' To ' + TY.strCurrency AS strExchangeRate
				,PG.strName AS strPurchasingGroup
				,FM.strUnitMeasure AS strFXPriceUOM
				,RT.strCurrencyExchangeRateType
				,dbo.[fnCTGetSeqDisplayField](CD.intProducerId,'tblEMEntity') strProducer--PR.strName AS strProducer
				,CU.intCent AS intPriceCurrencyCent
				,MY.strCurrency AS strMarketCurrency
				,BC.strCurrency AS strBasisCurrency
				,BN.strCurrency AS strBasisMainCurrency
				,BC.ysnSubCurrency AS ysnBasisSubCurrency
				,CC.strCurrency AS strConvertedCurrency
				,CC.ysnSubCurrency AS ysnConvertedSubCurrency
				,BM.strUnitMeasure AS strBasisUOM
				,VM.strUnitMeasure AS strConvertedUOM
				,[dbo].[fnCTIsMultiAllocationExists](CD.intContractDetailId) ysnMultiAllocation
				,[dbo].[fnCTIsMultiDerivativesExists](CD.intContractDetailId) ysnMultiDerivatives
				,AD.intSeqCurrencyId
				,AD.strSeqCurrency
				,AD.ysnSeqSubCurrency
				,AD.intSeqPriceUOMId
				,AD.strSeqPriceUOM
				,AD.dblSeqPrice
				,WO.intWashoutId
				,WO.strSourceNumber
				,WO.strWashoutNumber
				,WO.dblSourceCashPrice
				,WO.dblWTCashPrice
				,WO.strBillInvoice
				,WO.intBillInvoiceId
				,WO.strDocType
				,WO.strAdjustmentType


		FROM			ContractDetail					CD
				JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
															--AND CD.intContractHeaderId				=		@intContractHeaderId
	  --LEFT	JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId					=		CD.intMarketZoneId			--strMarketZoneCode
	  --LEFT	JOIN	tblCTBook						BK	ON	BK.intBookId						=		CD.intBookId				--strBook
	  --LEFT    JOIN	tblCTContractOptHeader			OH	ON	OH.intContractOptHeaderId			=		CD.intContractOptHeaderId	--strContractOptDesc
		LEFT    JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId				=		CD.intContractStatusId		--strContractStatus
	  --LEFT    JOIN	tblCTDiscountType				DT	ON	DT.intDiscountTypeId				=		CD.intDiscountTypeId		--strDiscountType
	  --LEFT    JOIN	tblCTFreightRate				FR	ON	FR.intFreightRateId					=		CD.intFreightRateId			--strOriginDest
      --LEFT    JOIN	tblCTIndex						IX	ON	IX.intIndexId						=		CD.intIndexId				--strIndex
		LEFT    JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId					=		CD.intPricingTypeId			--strPricingType
	  --LEFT    JOIN	tblCTRailGrade					RG	ON	RG.intRailGradeId					=		CD.intRailGradeId
	  --LEFT	JOIN	tblCTSubBook					SK	ON	SK.intSubBookId						=		CD.intSubBookId				--strSubBook
	
	  --LEFT	JOIN	tblEMEntity						BT	ON	BT.intEntityId						=		CD.intBillTo				--strBillTo
	  --LEFT	JOIN	tblEMEntity						SH	ON	SH.intEntityId						=		CD.intShipperId				--strShipper
	  --LEFT	JOIN	tblEMEntity						SN	ON	SN.intEntityId						=		CD.intShippingLineId		--strShippingLine
	  --LEFT    JOIN	tblEMEntity						SV	ON	SV.intEntityId						=		CD.intShipViaId				--strShipVia
	  --LEFT    JOIN	tblEMEntity						PR	ON	PR.intEntityId						=		CD.intProducerId			--strProducer
	  --LEFT	JOIN	tblEMEntityLocation				EF	ON	EF.intEntityLocationId				=		CD.intFarmFieldId			--strFarmNumber
	  --LEFT	JOIN	tblEMEntitySplit				ES	ON	ES.intSplitId						=		CD.intSplitId				--strSplitNumber
	
	  --LEFT    JOIN	tblGRDiscountId					DC	ON	DC.intDiscountId					=		CD.intDiscountId			--strDiscountId
	  --LEFT    JOIN	tblGRDiscountSchedule			DS	ON	DS.intDiscountScheduleId			=		CD.intDiscountScheduleId	--strDiscountDescription
	  --LEFT    JOIN	tblGRDiscountScheduleCode		SC	ON	SC.intDiscountScheduleCodeId		=		CD.intDiscountScheduleCodeId	
	  --LEFT	JOIN	tblICItem						SI	ON	SI.intItemId						=		SC.intItemId				--strScheduleCode
	  --LEFT    JOIN	tblGRStorageScheduleRule		SR	ON	SR.intStorageScheduleRuleId			=		CD.intStorageScheduleRuleId	--strScheduleDescription
	
	  --LEFT    JOIN	tblICCategory					CG	ON	CG.intCategoryId					=		CD.intCategoryId			--strCategoryCode
	  --LEFT    JOIN	tblICCategoryUOM				YU	ON	YU.intCategoryUOMId					=		CD.intCategoryUOMId	
	  --LEFT    JOIN	tblICUnitMeasure				YM	ON	YM.intUnitMeasureId					=		YU.intUnitMeasureId			--strUOM
		LEFT    JOIN	tblICItem						IM	ON	IM.intItemId						=		CD.intItemId				--strItemNo
		LEFT    JOIN	tblICItemContract				IC	ON	IC.intItemContractId				=		CD.intItemContractId		--strContractItemName
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
	  --LEFT    JOIN	tblICStorageLocation			SL	ON	SL.intStorageLocationId				=		CD.intStorageLocationId		--strStorageLocationName
	
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
		LEFT    JOIN	tblSMCurrency					BN	ON	BN.intCurrencyID					=		BC.intMainCurrencyId		--strBasisMainCurrency
		LEFT    JOIN	tblSMCurrency					CC	ON	CC.intCurrencyID					=		CD.intConvPriceCurrencyId	--strConvertedCurrency

		LEFT    JOIN	tblSMCurrency					IY	ON	IY.intCurrencyID					=		CD.intInvoiceCurrencyId		--strInvoiceCurrency
		LEFT    JOIN	tblSMCurrency					MY	ON	MY.intCurrencyID					=		MA.intCurrencyId			--strMarketCurrency
		LEFT    JOIN	tblSMCurrencyExchangeRate		ER	ON	ER.intCurrencyExchangeRateId		=		CD.intCurrencyExchangeRateId--strExchangeRate
		LEFT    JOIN	tblSMCurrency					FY	ON	FY.intCurrencyID					=		ER.intFromCurrencyId			
		LEFT    JOIN	tblSMCurrency					TY	ON	TY.intCurrencyID					=		ER.intToCurrencyId	
		LEFT    JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CD.intRateTypeId
		LEFT    JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId					=		CD.intFreightTermId			--strFreightTerm
		LEFT	JOIN	tblSMPurchasingGroup			PG	ON	PG.intPurchasingGroupId				=		CD.intPurchasingGroupId		--strPurchasingGroup
	  --LEFT    JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	=		CD.intSubLocationId 		--strLocationName
	
		LEFT    JOIN	tblSMCountry					RY	ON	RY.intCountryID						=		IC.intCountryId
		LEFT    JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId			=		IM.intOriginId												
															AND	CA.strType							=		'Origin'			
		LEFT    JOIN	tblSMCountry					OG	ON	OG.intCountryID						=		CA.intCountryID	
		LEFT	JOIN	tblICCommodityUnitMeasure		CO	ON	CO.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
		LEFT    JOIN	tblICItemUOM					CM	ON	CM.intItemId						=		CD.intItemId		
															AND	CM.intUnitMeasureId					=		CO.intUnitMeasureId		
	  --LEFT    JOIN	tblICCategoryUOM				GU	ON	GU.intCategoryId					=		CD.intCategoryId																	
		--													AND	GU.intUnitMeasureId					=		CH.intCategoryUnitMeasureId				
	  --LEFT	JOIN	tblCTWashout					WO	ON	WO.intSourceDetailId				=		CD.intContractDetailId
		--													OR	WO.intWashoutDetailId				=		CD.intContractDetailId
		--LEFT    JOIN	(
		--					SELECT	CQ.intContainerTypeId,
		--							CQ.intCommodityAttributeId,
		--							CQ.intUnitMeasureId,
		--							CQ.dblBulkQuantity ,
		--							CQ.dblQuantity AS dblBagQuantity,
		--							CQ.intCommodityId,
		--							CA.intCountryID AS intCountryId,
		--							CT.strContainerType
		--					FROM	tblLGContainerTypeCommodityQty	CQ	
		--					JOIN	tblLGContainerType				CT	ON	CT.intContainerTypeId		=	CQ.intContainerTypeId
		--					JOIN	tblICCommodityAttribute			CA	ON	CQ.intCommodityAttributeId	=	CA.intCommodityAttributeId
		--				)								CQ	ON	CQ.intCommodityId					=		CH.intCommodityId 
		--													AND CQ.intContainerTypeId				=		CD.intContainerTypeId 
		--													AND CQ.intCountryId						=		ISNULL(IC.intCountryId,CA.intCountryID)
		--LEFT    JOIN	tblICUnitMeasure				RM	ON	RM.intUnitMeasureId					=		CQ.intUnitMeasureId	
		LEFT    JOIN	(
						SELECT ROW_NUMBER() OVER (PARTITION BY ISNULL(intPContractDetailId,intSContractDetailId) ORDER BY intLoadDetailId DESC) intRowNum,ISNULL(intPContractDetailId,intSContractDetailId)intContractDetailId,intLoadDetailId 
						FROM tblLGLoadDetail
					)LG ON LG.intRowNum = 1 AND LG.intContractDetailId = CD.intContractDetailId
		OUTER APPLY dbo.fnCTGetSampleDetail(CD.intContractDetailId)	QA
		OUTER APPLY dbo.fnCTGetSeqPriceFixationInfo(CD.intContractDetailId) FI
		OUTER APPLY dbo.fnCTGetSeqWashoutInfo(CD.intContractDetailId) WO
		OUTER APPLY dbo.fnCTGetSeqContainerInfo(CH.intCommodityId,CD.intContainerTypeId,ISNULL(IC.intCountryId,CA.intCountryID)) CQ
		CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		
	)t ORDER BY intContractSeq

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH