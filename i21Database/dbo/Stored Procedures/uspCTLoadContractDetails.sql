CREATE PROCEDURE [dbo].[uspCTLoadContractDetails]

	@intContractHeaderId INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	DECLARE @tblShipment TABLE 
	(  
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(18,6)
	)

	DECLARE @tblBill TABLE 
	(  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(18,6)
	)

	INSERT INTO @tblShipment(intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT 
		   intContractHeaderId  = ShipmentItem.intOrderId
		  ,intContractDetailId	= ShipmentItem.intLineNo
		  ,dblQuantity			= ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ShipmentItem.intItemUOMId,CD.intItemUOMId,ShipmentItem.dblQuantity)),0)
	
	FROM tblICInventoryShipmentItem ShipmentItem
	JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId AND Shipment.intOrderType = 1
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ShipmentItem.intLineNo AND CD.intContractHeaderId = ShipmentItem.intOrderId
	WHERE Shipment.ysnPosted = 1 AND ShipmentItem.intOrderId = @intContractHeaderId
	GROUP BY ShipmentItem.intOrderId,ShipmentItem.intLineNo

	INSERT INTO @tblBill(intContractDetailId,dblQuantity)
	SELECT 
		   intContractDetailId	= BD.intContractDetailId
		  ,dblQuantity			= ISNULL(SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](BD.intItemId,BD.intUnitOfMeasureId,UOM.intUnitMeasureId,BD.dblQtyOrdered)),0)
	FROM tblAPBillDetail BD
	JOIN tblAPBill B ON B.intBillId = BD.intBillId AND B.ysnPosted = 1 AND BD.dblQtyOrdered > 0 
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = BD.intContractDetailId
	JOIN tblICItemUOM UOM ON UOM.intItemUOMId = CD.intItemUOMId
	WHERE CD.intContractHeaderId = @intContractHeaderId
	GROUP BY BD.intContractDetailId

	;With ContractDetail AS (
	   SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId --1247
    )

	,
	CTE1 AS(
		SELECT	 CD.intContractDetailId
				,AD.intSeqCurrencyId
				,AD.strSeqCurrency
				,AD.ysnSeqSubCurrency
				,AD.intSeqPriceUOMId
				,AD.strSeqPriceUOM
				,AD.dblSeqPrice

				,CAST(ISNULL(LG.intLoadDetailId, 0) AS BIT) AS ysnLoadAvailable

				,CQ.dblBulkQuantity
				,CQ.dblBagQuantity
				,CQ.strContainerType
				,CQ.strContainerUOM --RM.strUnitMeasure strContainerUOM

				,FI.dblQuantityPriceFixed
				,CD.dblQuantity - ISNULL(FI.dblQuantityPriceFixed, 0) AS dblUnpricedQty
				,FI.dblPFQuantityUOMId
				,FI.[dblTotalLots]
				,FI.[dblLotsFixed]
				,CD.dblNoOfLots - ISNULL(FI.[dblLotsFixed], 0) AS dblUnpricedLots
				,FI.intPriceFixationId
				,FI.intPriceContractId
				,FI.ysnSpreadAvailable
				,FI.ysnFixationDetailAvailable
				,FI.ysnMultiPricingDetail

				,QA.strContainerNumber
				,QA.strSampleTypeName
				,QA.strSampleStatus
				,QA.dtmTestingEndDate
				,QA.dblApprovedQty

				,WO.intWashoutId
				,WO.strSourceNumber
				,WO.strWashoutNumber
				,WO.dblSourceCashPrice
				,WO.dblWTCashPrice
				,WO.strBillInvoice
				,WO.intBillInvoiceId
				,WO.strDocType
				,WO.strAdjustmentType

		FROM	ContractDetail CD
		JOIN	tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId

LEFT    JOIN	(
					SELECT ROW_NUMBER() OVER (PARTITION BY ISNULL(intPContractDetailId,intSContractDetailId) ORDER BY intLoadDetailId DESC) intRowNum
					,ISNULL(intPContractDetailId,intSContractDetailId)intContractDetailId
					,intLoadDetailId 
					FROM tblLGLoadDetail
				)LG ON LG.intRowNum = 1 AND LG.intContractDetailId = CD.intContractDetailId
OUTER	APPLY	dbo.fnCTGetSampleDetail(CD.intContractDetailId)						QA
OUTER	APPLY	dbo.fnCTGetSeqPriceFixationInfo(CD.intContractDetailId)				FI
OUTER	APPLY	dbo.fnCTGetSeqContainerInfo(CH.intCommodityId,CD.intContainerTypeId,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin')) CQ
OUTER	APPLY	dbo.fnCTGetSeqWashoutInfo(CD.intContractDetailId)					WO
CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId)	AD
	)

	SELECT	*,
			 dblAppliedLoadQty = CASE 
										WHEN dblShipmentQuantity > 0  THEN dblShipmentQuantity
										WHEN dblBillQty			 > 0  THEN dblBillQty
										ELSE dblAppliedQty * dblQuantityPerLoad
                                 END
	FROM
	(
		SELECT	 CD.*

				,CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty
				,CD.dblBalanceLoad - ISNULL(CD.dblScheduleLoad, 0) dblAvailableLoad
				,CD.intContractStatusId intCurrentContractStatusId
				,dbo.[fnCTGetSeqDisplayField](CD.intMarketZoneId,'tblARMarketZone') strMarketZoneCode--MZ.strMarketZoneCode
				,IM.strItemNo
				,dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId,'tblICItemUOM') strAdjustmentUOM--XM.strUnitMeasure strAdjustmentUOM
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
				,IC.strContractItemName
				,dbo.[fnCTGetSeqDisplayField](CD.intNetWeightUOMId,'tblICItemUOM') strNetWeightUOM--WM.strUnitMeasure strNetWeightUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intPriceItemUOMId,'tblICItemUOM') strPriceUOM--PM.strUnitMeasure strPriceUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin') strOrigin--ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
				,dbo.[fnCTGetSeqDisplayField](CD.intIndexId,'tblCTIndex') strIndex--IX.strIndex
				,CS.strContractStatus
				,MA.strFutMarketName AS strFutureMarket
				,REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ') strFutureMonth
				,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CM.intItemUOMId, 1) AS dblConversionFactor
				,dbo.[fnCTGetSeqDisplayField](CD.intItemUOMId,'tblICItemUOM')strUOM --QM.strUnitMeasure strUOM--ISNULL(QM.strUnitMeasure, YM.strUnitMeasure) AS strUOM -- YM. is not in use
				,CASE 
					WHEN CH.ysnLoad = 1
						THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0)
					ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)
				 END AS dblAppliedQty
				,dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0) AS dblExchangeRate
				,IM.intProductTypeId
				,CAST(1 AS BIT) ysnItemUOMIdExist
				,dbo.[fnCTGetSeqDisplayField](CD.intSubLocationId,'tblSMCompanyLocationSubLocation') strSubLocationName --SB.strSubLocationName
				,dbo.[fnCTGetSeqDisplayField](CD.intStorageLocationId,'tblICStorageLocation') strStorageLocationName --SL.strName AS strStorageLocationName
				,dbo.[fnCTGetSeqDisplayField](CD.intLoadingPortId,'tblSMCity') strLoadingPoint--LP.strCity AS strLoadingPoint
				,dbo.[fnCTGetSeqDisplayField](CD.intDestinationPortId,'tblSMCity') strDestinationPoint--DP.strCity AS strDestinationPoint
				,dbo.[fnCTGetLastApprovalStatus](CD.intContractHeaderId) strApprovalStatus
				,MA.dblContractSize AS dblMarketContractSize
				,MA.intUnitMeasureId AS intMarketUnitMeasureId
				,MA.intCurrencyId AS intMarketCurrencyId
				,MU.strUnitMeasure AS strMarketUnitMeasure
				,dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId,'tblICItemUOMUnitType') strQtyUnitType--XM.strUnitType AS strQtyUnitType
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
				,dbo.[fnCTGetSeqDisplayField](CD.intDestinationCityId,'tblSMCity') strDestinationCity--DY.strCity AS strDestinationCity
				,IY.strCurrency AS strInvoiceCurrency
				,'From ' + FY.strCurrency + ' To ' + TY.strCurrency AS strExchangeRate
				,PG.strName AS strPurchasingGroup
				,dbo.[fnCTGetSeqDisplayField](CD.intFXPriceUOMId,'tblICItemUOM') strFXPriceUOM--FM.strUnitMeasure AS strFXPriceUOM
				,RT.strCurrencyExchangeRateType
				,dbo.[fnCTGetSeqDisplayField](CD.intProducerId,'tblEMEntity') strProducer--PR.strName AS strProducer
				,CU.intCent AS intPriceCurrencyCent
				,MY.strCurrency AS strMarketCurrency
				,BC.strCurrency AS strBasisCurrency
				,BN.strCurrency AS strBasisMainCurrency
				,BC.ysnSubCurrency AS ysnBasisSubCurrency
				,CC.strCurrency AS strConvertedCurrency
				,CC.ysnSubCurrency AS ysnConvertedSubCurrency
				,dbo.[fnCTGetSeqDisplayField](CD.intBasisUOMId,'tblICItemUOM') strBasisUOM --BM.strUnitMeasure AS strBasisUOM
				,dbo.[fnCTGetSeqDisplayField](CD.intConvPriceUOMId,'tblICItemUOM') strConvertedUOM -- VM.strUnitMeasure AS strConvertedUOM
				,[dbo].[fnCTIsMultiAllocationExists](CD.intContractDetailId) ysnMultiAllocation
				,[dbo].[fnCTIsMultiDerivativesExists](CD.intContractDetailId) ysnMultiDerivatives

				,CT.intSeqCurrencyId
				,CT.strSeqCurrency
				,CT.ysnSeqSubCurrency
				,CT.intSeqPriceUOMId
				,CT.strSeqPriceUOM
				,CT.dblSeqPrice

				,CT.ysnLoadAvailable

				,CT.dblBulkQuantity
				,CT.dblBagQuantity
				,CT.strContainerType
				,CT.strContainerUOM --RM.strUnitMeasure strContainerUOM

				,dblQuantityPriceFixed = CASE WHEN CD.intPricingTypeId IN (1,6) THEN CD.dblQuantity ELSE  CT.dblQuantityPriceFixed END
				,dblUnpricedQty		   = CASE WHEN CD.intPricingTypeId IN (1,6) THEN NULL		    ELSE  CT.dblUnpricedQty		   END
				,CT.dblPFQuantityUOMId
				,dblTotalLots			= CASE WHEN CD.intPricingTypeId IN (1,6) THEN CD.dblNoOfLots ELSE  CT.[dblTotalLots]  END 
				,dblLotsFixed			= CASE WHEN CD.intPricingTypeId IN (1,6) THEN CD.dblNoOfLots ELSE  CT.[dblLotsFixed]  END
				,dblUnpricedLots		= CASE WHEN CD.intPricingTypeId IN (1,6) THEN NULL			 ELSE  CT.dblUnpricedLots END
				,CT.intPriceFixationId
				,CT.intPriceContractId
				,CT.ysnSpreadAvailable
				,CT.ysnFixationDetailAvailable
				,CT.ysnMultiPricingDetail

				,CT.strContainerNumber
				,CT.strSampleTypeName
				,CT.strSampleStatus
				,CT.dtmTestingEndDate
				,CT.dblApprovedQty

				,CT.intWashoutId
				,CT.strSourceNumber
				,CT.strWashoutNumber
				,CT.dblSourceCashPrice
				,CT.dblWTCashPrice
				,CT.strBillInvoice
				,CT.intBillInvoiceId
				,CT.strDocType
				,CT.strAdjustmentType
				,dblShipmentQuantity = Shipment.dblQuantity
				,dblBillQty          = Bill.dblQuantity

		FROM			ContractDetail					CD
				JOIN    CTE1							CT	ON CT.intContractDetailId				=		CD.intContractDetailId
				JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
		LEFT    JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId				=		CD.intContractStatusId		--strContractStatus
		LEFT    JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId					=		CD.intPricingTypeId			--strPricingType
		LEFT    JOIN	tblICItem						IM	ON	IM.intItemId						=		CD.intItemId				--strItemNo
		LEFT    JOIN	tblICItemContract				IC	ON	IC.intItemContractId				=		CD.intItemContractId		--strContractItemName

	
		LEFT    JOIN	tblRKFutureMarket				MA	ON	MA.intFutureMarketId				=		CD.intFutureMarketId		--strFutureMarket
		LEFT    JOIN	tblICUnitMeasure				MU	ON	MU.intUnitMeasureId					=		MA.intUnitMeasureId
		LEFT    JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId					=		CD.intFutureMonthId			--strFutureMonth
	
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
		LEFT	JOIN	tblICCommodityUnitMeasure		CO	ON	CO.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
		LEFT    JOIN	tblICItemUOM					CM	ON	CM.intItemId						=		CD.intItemId		
															AND	CM.intUnitMeasureId					=		CO.intUnitMeasureId
		LEFT   JOIN     @tblShipment				Shipment ON Shipment.intContractDetailId        =       CD.intContractDetailId
		LEFT   JOIN     @tblBill						Bill ON Bill.intContractDetailId			=       CD.intContractDetailId
	)t ORDER BY intContractSeq

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH