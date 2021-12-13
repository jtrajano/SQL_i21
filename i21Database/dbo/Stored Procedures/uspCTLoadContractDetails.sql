CREATE PROCEDURE [dbo].[uspCTLoadContractDetails]
	@intContractHeaderId INT

AS

BEGIN TRY

 
	DECLARE
		@ErrMsg NVARCHAR(MAX)
		,@intContractTypeId int;


	DECLARE @tblShipment TABLE (
		intContractHeaderId INT
		, intContractDetailId INT
		, dblQuantity NUMERIC(18, 6)
		, dblDestinationQuantity NUMERIC(18, 6)
	);

	DECLARE @tblInvoice TABLE (  
		intContractDetailId  INT,        
		dblQuantity    NUMERIC(18,6)
	); 

	DECLARE @tblBill TABLE (
		intContractDetailId INT
		, dblQuantity NUMERIC(18, 6)
	);

	DECLARE @OpenLoad TABLE (
		intContractDetailId INT
		, ysnOpenLoad BIT
	);

	select top 1 @intContractTypeId = intContractTypeId from tblCTContractHeader where intContractHeaderId = @intContractHeaderId
	
	SELECT
		*
	INTO
		#tmpContractDetail
	FROM
		tblCTContractDetail WITH (NOLOCK)
	WHERE
		intContractHeaderId = @intContractHeaderId;

	if (@intContractTypeId = 1)
	begin
		INSERT INTO @tblBill (
			intContractDetailId
			, dblQuantity
		)
		SELECT
			intContractDetailId = ReceiptItem.intLineNo
			, dblQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ReceiptItem.intUnitMeasureId, CD.intItemUOMId, ReceiptItem.dblReceived)), 0)
		FROM
			tblICInventoryReceiptItem ReceiptItem WITH (NOLOCK)
			JOIN tblICInventoryReceipt Receipt WITH (NOLOCK)
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				AND Receipt.strReceiptType = 'Purchase Contract'
			JOIN #tmpContractDetail CD
				ON CD.intContractDetailId = ReceiptItem.intLineNo
				AND CD.intContractHeaderId = ReceiptItem.intOrderId
		WHERE
			CD.intContractHeaderId = @intContractHeaderId
		GROUP BY
			ReceiptItem.intLineNo
	end
	else
	begin
		INSERT INTO @tblInvoice (
			intContractDetailId
			,dblQuantity
		)
		SELECT
			CD.intContractDetailId
			,dblQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(InvoiceDetail.intItemUOMId,CD.intItemUOMId,InvoiceDetail.dblQtyShipped)),0) - ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(InvoiceDetail.intItemUOMId,CD.intItemUOMId,CM.dblQtyShipped)),0)
		FROM
			tblARInvoiceDetail InvoiceDetail
			JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId AND Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
			JOIN tblCTContractDetail CD ON CD.intContractHeaderId = InvoiceDetail.intContractHeaderId AND CD.intContractDetailId = InvoiceDetail.intContractDetailId
			LEFT JOIN 
			(
				SELECT
					dblQtyShipped = SUM(ID.dblQtyShipped)
					,ID.intOriginalInvoiceDetailId
				FROM
					tblARInvoice IV
					INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
				WHERE
					IV.strTransactionType = 'Credit Memo'
					AND  IV.ysnPosted = 1
				GROUP BY
					ID.intOriginalInvoiceDetailId
			) CM ON CM.intOriginalInvoiceDetailId = InvoiceDetail.intInvoiceDetailId
		WHERE Invoice.ysnPosted = 1
			AND Invoice.strTransactionType = 'Invoice'
			AND CD.intContractHeaderId = @intContractHeaderId
		GROUP BY
				CD.intContractDetailId
	
		INSERT INTO @tblShipment (
			intContractHeaderId
			, intContractDetailId
			, dblQuantity
			, dblDestinationQuantity
		)
		SELECT intContractHeaderId = ShipmentItem.intOrderId
			, intContractDetailId = ShipmentItem.intLineNo
			, dblQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ShipmentItem.intItemUOMId, CD.intItemUOMId, CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN ShipmentItem.dblQuantity ELSE 0 END)), 0)
			, dblDestinationQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ShipmentItem.intItemUOMId, CD.intItemUOMId, CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN ISNULL(ShipmentItem.dblDestinationNet, ShipmentItem.dblQuantity) ELSE 0 END )), 0)
		FROM
			tblICInventoryShipmentItem ShipmentItem WITH (NOLOCK)
			JOIN tblICInventoryShipment Shipment WITH (NOLOCK)
				ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId 
				AND Shipment.intOrderType = 1
			JOIN #tmpContractDetail CD 
				ON CD.intContractDetailId = ShipmentItem.intLineNo 
				AND CD.intContractHeaderId = ShipmentItem.intOrderId
			LEFT JOIN (
				SELECT DISTINCT
					ID.intInventoryShipmentItemId
					, IV.ysnPosted
				FROM
					tblARInvoice IV WITH (NOLOCK)
					INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK)
						ON IV.intInvoiceId = ID.intInvoiceId
				WHERE
					IV.strTransactionType = 'Invoice'
					AND IV.ysnPosted = 1
			) INV
				ON INV.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN (
				SELECT DISTINCT
					ID.intInventoryShipmentItemId
				FROM
					tblARInvoice IV WITH (NOLOCK)
					INNER JOIN tblARInvoiceDetail ID WITH (NOLOCK) 
						ON IV.intInvoiceId = ID.intInvoiceId
				WHERE
					IV.strTransactionType = 'Credit Memo'
					AND IV.ysnPosted = 1
			) CM
				ON CM.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
		WHERE
			Shipment.ysnPosted = 1
			AND ShipmentItem.intOrderId = @intContractHeaderId
		GROUP BY
			ShipmentItem.intOrderId
			, ShipmentItem.intLineNo
	end

	INSERT INTO
		@OpenLoad
	SELECT
		intContractDetailId = ISNULL(LD.intSContractDetailId, LD.intPContractDetailId)
		, ysnOpenLoad = CAST(LD.intLoadDetailId AS BIT)
	FROM
		tblLGLoad LO
		JOIN tblLGLoadDetail LD
			ON LD.intLoadId = LO.intLoadId
		JOIN #tmpContractDetail CD
			ON CD.intContractDetailId = ISNULL(LD.intSContractDetailId, LD.intPContractDetailId)
	WHERE
		intTicketId IS NULL
		AND LO.intShipmentStatus NOT IN(4, 10)
		AND LO.intShipmentType <> 2
		AND CD.intContractHeaderId = @intContractHeaderId;
	
	WITH CTE1 AS (
		SELECT CD.intContractDetailId
			, AD.intSeqCurrencyId
			, AD.strSeqCurrency
			, AD.ysnSeqSubCurrency
			, AD.intSeqPriceUOMId
			, AD.strSeqPriceUOM
			, AD.dblSeqPrice
			, ysnLoadAvailable = CAST(ISNULL(LG.ysnOpenLoad, 0) AS BIT)
			, CQ.dblBulkQuantity
			, CQ.dblBagQuantity
			, CQ.strContainerType
			, CQ.strContainerUOM
			, FI.dblQuantityPriceFixed
			, dblUnpricedQty = CD.dblQuantity - ISNULL(FI.dblQuantityPriceFixed, 0)
			, FI.dblPFQuantityUOMId
			, FI.[dblTotalLots]
			, FI.[dblLotsFixed]
			, dblUnpricedLots = CD.dblNoOfLots - ISNULL(FI.[dblLotsFixed], 0)
			, FI.intPriceFixationId
			, FI.intPriceContractId
			, FI.ysnSpreadAvailable
			, FI.ysnFixationDetailAvailable
			, FI.ysnMultiPricingDetail
			, QA.strContainerNumber
			, QA.strSampleTypeName
			, QA.strSampleStatus
			, QA.dtmTestingEndDate
			, QA.dblApprovedQty
			, WO.intWashoutId
			, WO.strSourceNumber
			, WO.strWashoutNumber
			, WO.dblSourceCashPrice
			, WO.dblWTCashPrice
			, WO.strBillInvoice
			, WO.intBillInvoiceId
			, WO.strDocType
			, WO.strAdjustmentType
			, intHeaderPricingTypeId = CH.intPricingTypeId
			, CH.intCommodityId
			, CH.intContractTypeId
			, CH.ysnLoad
			, CH.intCommodityUOMId			
			, CH.ysnMultiplePriceFixation
		FROM
			#tmpContractDetail CD
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			left join @OpenLoad LG on LG.intContractDetailId = CD.intContractDetailId
			OUTER APPLY dbo.fnCTGetSampleDetail(CD.intContractDetailId) QA
			OUTER APPLY dbo.fnCTGetSeqPriceFixationInfo(CD.intContractDetailId) FI
			OUTER APPLY dbo.fnCTGetSeqContainerInfo(CH.intCommodityId, CD.intContainerTypeId, dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId, 'Origin')) CQ
			OUTER APPLY dbo.fnCTGetSeqWashoutInfo(CD.intContractDetailId) WO
			CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	)
	
	SELECT DISTINCT CD.intContractDetailId
		, CD.intSplitFromId
		, CD.intParentDetailId
		, CD.ysnSlice
		, CD.intConcurrencyId
		, CD.intContractHeaderId
		, CD.intContractStatusId
		, CD.intContractSeq
		, CD.intCompanyLocationId
		, CD.intShipToId
		, CD.dtmStartDate
		, CD.dtmEndDate
		, CD.ysnCashFlowOverride
		, CD.dtmCashFlowDate
		, CD.intFreightTermId
		, CD.intShipViaId
		, CD.intItemContractId
		, CD.intItemBundleId
		, CD.intItemId
		, CD.strItemSpecification
		, CD.intCategoryId
		, CD.dblQuantity
		, CD.intItemUOMId
		, CD.dblOriginalQty
		, CD.dblBalance
		, CD.dblIntransitQty
		, CD.dblScheduleQty
		, CD.dblBalanceLoad
		, CD.dblScheduleLoad
		, CD.dblShippingInstructionQty
		, CD.dblNetWeight
		, CD.intNetWeightUOMId
		, CD.intUnitMeasureId
		, CD.intCategoryUOMId
		, CD.intNoOfLoad
		, CD.dblQuantityPerLoad
		, CD.intIndexId
		, CD.dblAdjustment
		, CD.intAdjItemUOMId
		, CD.intFutureMarketId
		, CD.intFutureMonthId
		, intPricingTypeId = CASE WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval') THEN CD.intPricingTypeId
								WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval') THEN CT.intHeaderPricingTypeId
								ELSE CD.intPricingTypeId END
		, dblFutures = CASE WHEN CD.intPricingTypeId IN (1, 3) THEN CD.dblFutures
							WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval') THEN CD.dblFutures
							WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval') THEN NULL
							ELSE CD.dblFutures END
		, strPricingType = CASE WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval') THEN PT.strPricingType
								WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval') THEN PTH.strPricingType
								ELSE PT.strPricingType END
		, CD.dblBasis
		, CD.dblOriginalBasis
		, CD.dblConvertedBasis
		, CD.intBasisCurrencyId
		, CD.intBasisUOMId
		, CD.dblFreightBasisBase
		, CD.intFreightBasisBaseUOMId
		, CD.dblFreightBasis
		, CD.intFreightBasisUOMId
		, CD.dblRatio
		, CD.dblCashPrice
		, CD.dblTotalCost
		, CD.intCurrencyId
		, CD.intPriceItemUOMId
		, CD.dblNoOfLots
		, CD.dtmLCDate
		, CD.dtmLastPricingDate
		, CD.dblConvertedPrice
		, CD.intConvPriceCurrencyId
		, CD.intConvPriceUOMId
		, CD.intMarketZoneId
		, CD.intDiscountTypeId
		, CD.intDiscountId
		, CD.intDiscountScheduleId
		, CD.intDiscountScheduleCodeId
		, CD.intStorageScheduleRuleId
		, CD.intContractOptHeaderId
		, CD.strBuyerSeller
		, CD.intBillTo
		, CD.intFreightRateId
		, CD.strFobBasis
		, CD.intRailGradeId
		, CD.strRailRemark
		, CD.strLoadingPointType
		, CD.intLoadingPortId
		, CD.strDestinationPointType
		, CD.intDestinationPortId
		, CD.strShippingTerm
		, CD.intShippingLineId
		, CD.strVessel
		, CD.intDestinationCityId
		, CD.intShipperId
		, CD.strRemark
		, CD.intSubLocationId
		, CD.intStorageLocationId
		, CD.intPurchasingGroupId
		, CD.intFarmFieldId
		, CD.intSplitId
		, CD.strGrade
		, CD.strGarden
		, CD.strVendorLotID
		, CD.strInvoiceNo
		, CD.strReference
		, CD.strERPPONumber
		, CD.strERPItemNumber
		, CD.strERPBatchNumber
		, CD.intUnitsPerLayer
		, CD.intLayersPerPallet
		, CD.dtmEventStartDate
		, CD.dtmPlannedAvailabilityDate
		, CD.dtmUpdatedAvailabilityDate
		, CD.dtmM2MDate
		, CD.intBookId
		, CD.intSubBookId
		, CD.intContainerTypeId
		, CD.intNumberOfContainers
		, CD.intInvoiceCurrencyId
		, CD.dtmFXValidFrom
		, CD.dtmFXValidTo
		, CD.dblRate
		, CD.dblFXPrice
		, CD.ysnUseFXPrice
		, CD.intFXPriceUOMId
		, CD.strFXRemarks
		, CD.dblAssumedFX
		, CD.strFixationBy
		, CD.strPackingDescription
		, CD.dblYield
		, CD.intCurrencyExchangeRateId
		, CD.intRateTypeId
		, CD.intCreatedById
		, CD.dtmCreated
		, CD.intLastModifiedById
		, CD.dtmLastModified
		, CD.ysnInvoice
		, CD.ysnProvisionalInvoice
		, CD.ysnQuantityFinal
		, CD.intProducerId
		, CD.ysnClaimsToProducer
		, CD.ysnRiskToProducer
		, CD.ysnBackToBack
		, CD.dblAllocatedQty
		, CD.dblReservedQty
		, CD.dblAllocationAdjQty
		, CD.dblInvoicedQty
		, CD.ysnPriceChanged
		, CD.intContractDetailRefId
		, CD.ysnStockSale
		, CD.strCertifications
		, CD.ysnSplit
		, CD.ysnProvisionalPNL
		, CD.ysnFinalPNL
		, CD.dtmProvisionalPNL
		, CD.dtmFinalPNL
		, dblAvailableQty = CD.dblBalance - ISNULL(CD.dblScheduleQty, 0)
		, dblAvailableLoad = CD.dblBalanceLoad - ISNULL(CD.dblScheduleLoad, 0)
		, intCurrentContractStatusId = CD.intContractStatusId
		, strMarketZoneCode = dbo.[fnCTGetSeqDisplayField](CD.intMarketZoneId, 'tblARMarketZone')
		, IM.strItemNo
		, strAdjustmentUOM = dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId, 'tblICItemUOM')
		, CL.strLocationName
		, FT.strFreightTerm
		, strShipVia = dbo.[fnCTGetSeqDisplayField](CD.intShipViaId, 'tblEMEntity')
		, strShipTo = dbo.[fnCTGetSeqDisplayField](CD.intShipToId, 'tblEMEntityLocation')
		, CU.strCurrency
		, strMainCurrency = CY.strCurrency
		, CU.intMainCurrencyId
		, CU.ysnSubCurrency
		, strOriginDest = dbo.[fnCTGetSeqDisplayField](CD.intFreightRateId, 'tblCTFreightRate')
		, strRailGrade = dbo.[fnCTGetSeqDisplayField](CD.intRailGradeId, 'tblCTRailGrade')
		, strContractOptDesc = NULL
		, strDiscountType = dbo.[fnCTGetSeqDisplayField](CD.intDiscountTypeId, 'tblCTDiscountType')
		, strDiscountId = dbo.[fnCTGetSeqDisplayField](CD.intDiscountId, 'tblGRDiscountId')
		, IC.strContractItemName
		, strBundleItemNo = IB.strItemNo
		, strNetWeightUOM = dbo.[fnCTGetSeqDisplayField](CD.intNetWeightUOMId, 'tblICItemUOM')
		, strPriceUOM = dbo.[fnCTGetSeqDisplayField](CD.intPriceItemUOMId, 'tblICItemUOM')
		, strOrigin = dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId, 'Origin')
		, strIndex = dbo.[fnCTGetSeqDisplayField](CD.intIndexId, 'tblCTIndex')
		, CS.strContractStatus
		, strShipmentStatus = ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open')
		, strFinancialStatus = CASE WHEN CT.intContractTypeId = 1 THEN CASE WHEN CD.ysnFinalPNL = 1 THEN 'Final P&L Created'
														WHEN CD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
														ELSE CASE WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' END END
				ELSE CD.strFinancialStatus END
		, strFutureMarket = MA.strFutMarketName
		, strFutureMonth = REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ')
		, dblConversionFactor = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CM.intItemUOMId, 1)
		, strUOM = dbo.[fnCTGetSeqDisplayField](CD.intItemUOMId, 'tblICItemUOM')
		, dblAppliedQty = CASE WHEN CT.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END
	    , dblAppliedLoadQty = CASE WHEN CT.ysnLoad = 1
									THEN CASE WHEN Bill.dblQuantity > 0 THEN Bill.dblQuantity
											WHEN Invoice.dblQuantity > 0 THEN Invoice.dblQuantity
											WHEN Shipment.dblQuantity > 0 THEN Shipment.dblDestinationQuantity
											ELSE (ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ) * CD.dblQuantityPerLoad END
								ELSE CASE WHEN Bill.dblQuantity > 0 THEN Bill.dblQuantity
										WHEN Invoice.dblQuantity > 0  THEN Invoice.dblQuantity
										WHEN Shipment.dblQuantity > 0 THEN Shipment.dblDestinationQuantity
										ELSE (ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)) END END
		, dblExchangeRate = dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0)
		, IM.intProductTypeId
		, ysnItemUOMIdExist = CAST(1 AS BIT)
		, strSubLocationName = dbo.[fnCTGetSeqDisplayField](CD.intSubLocationId, 'tblSMCompanyLocationSubLocation')
		, strStorageLocationName = dbo.[fnCTGetSeqDisplayField](CD.intStorageLocationId, 'tblICStorageLocation')
		, strLoadingPoint = LoadingPort.strCity
		, strDestinationPoint = DestinationPort.strCity
		, dblMarketContractSize = MA.dblContractSize
		, intMarketUnitMeasureId = MA.intUnitMeasureId
		, intMarketCurrencyId = MA.intCurrencyId
		, strMarketUnitMeasure = MU.strUnitMeasure
		, strQtyUnitType = dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId, 'tblICItemUOMUnitType')
		, strBook = dbo.[fnCTGetSeqDisplayField](CD.intBookId, 'tblCTBook')
		, strSubBook = dbo.[fnCTGetSeqDisplayField](CD.intSubBookId, 'tblCTSubBook')
		, strBillTo = dbo.[fnCTGetSeqDisplayField](CD.intBillTo, 'tblEMEntity')
		, strShipper = dbo.[fnCTGetSeqDisplayField](CD.intShipperId, 'tblEMEntity')
		, strShippingLine = dbo.[fnCTGetSeqDisplayField](CD.intShippingLineId, 'tblEMEntity')
		, strFarmNumber = dbo.[fnCTGetSeqDisplayField](CD.intFarmFieldId, 'tblEMEntityLocation')
		, strSplitNumber = dbo.[fnCTGetSeqDisplayField](CD.intSplitId, 'tblEMEntitySplit')
		, strDiscountDescription = dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleId, 'tblGRDiscountSchedule')
		, strScheduleCode = dbo.[fnCTGetSeqDisplayField](CD.intDiscountScheduleCodeId, 'tblGRDiscountScheduleCode')
		, strScheduleDescription = dbo.[fnCTGetSeqDisplayField](CD.intStorageScheduleRuleId, 'tblGRStorageScheduleRule')
		, strCategoryCode = NULL
		, strDestinationCity = dbo.[fnCTGetSeqDisplayField](CD.intDestinationCityId, 'tblSMCity')
		, strInvoiceCurrency = IY.strCurrency
		, strExchangeRate = dbo.[fnCTGetSeqDisplayField](CD.intCurrencyExchangeRateId, 'tblSMCurrencyExchangeRate')
		, strPurchasingGroup = PG.strName
		, strFXPriceUOM = dbo.[fnCTGetSeqDisplayField](CD.intFXPriceUOMId, 'tblICItemUOM')
		, RT.strCurrencyExchangeRateType
		, strProducer = dbo.[fnCTGetSeqDisplayField](CD.intProducerId, 'tblEMEntity')
		, intPriceCurrencyCent = CU.intCent
		, strMarketCurrency = MY.strCurrency
		, strBasisCurrency = BC.strCurrency
		, strBasisMainCurrency = BN.strCurrency
		, ysnBasisSubCurrency = BC.ysnSubCurrency
		, strConvertedCurrency = CC.strCurrency
		, ysnConvertedSubCurrency = CC.ysnSubCurrency
		, strBasisUOM = dbo.[fnCTGetSeqDisplayField](CD.intBasisUOMId, 'tblICItemUOM')
		, strConvertedUOM = dbo.[fnCTGetSeqDisplayField](CD.intConvPriceUOMId, 'tblICItemUOM')
		, ysnMultiAllocation = [dbo].[fnCTIsMultiAllocationExists](CD.intContractDetailId)
		, ysnMultiDerivatives = [dbo].[fnCTIsMultiDerivativesExists](CD.intContractDetailId)
		, CT.intSeqCurrencyId
		, CT.strSeqCurrency
		, CT.ysnSeqSubCurrency
		, CT.intSeqPriceUOMId
		, CT.strSeqPriceUOM
		, CT.dblSeqPrice
		, CT.ysnLoadAvailable
		, CT.dblBulkQuantity
		, CT.dblBagQuantity
		, CT.strContainerType
		, CT.strContainerUOM
		, dblQuantityPriceFixed = CASE WHEN CD.intPricingTypeId IN(1, 6) THEN CD.dblQuantity
										ELSE CT.dblQuantityPriceFixed END
		, dblUnpricedQty = CASE WHEN CD.intPricingTypeId IN(1, 6) THEN NULL
								ELSE CT.dblUnpricedQty END
		, CT.dblPFQuantityUOMId
		, dblTotalLots = CASE WHEN CD.intPricingTypeId IN(1, 6) THEN CD.dblNoOfLots
								ELSE CT.[dblTotalLots] END
		, dblLotsFixed = CASE WHEN CD.intPricingTypeId IN(1, 6) THEN CD.dblNoOfLots
								ELSE CT.[dblLotsFixed] END
		, dblUnpricedLots = CASE WHEN CD.intPricingTypeId IN(1, 6) THEN NULL
								ELSE CT.dblUnpricedLots END
		, CT.intPriceFixationId
		, CT.intPriceContractId
		, CT.ysnSpreadAvailable
		, CT.ysnFixationDetailAvailable
		, CT.ysnMultiPricingDetail
		, CT.strContainerNumber
		, CT.strSampleTypeName
		, CT.strSampleStatus
		, CT.dtmTestingEndDate
		, CT.dblApprovedQty
		, CT.intWashoutId
		, CT.strSourceNumber
		, CT.strWashoutNumber
		, CT.dblSourceCashPrice
		, CT.dblWTCashPrice
		, CT.strBillInvoice
		, CT.intBillInvoiceId
		, CT.strDocType
		, CT.strAdjustmentType
		, dblShipmentQuantity = Shipment.dblQuantity
		, dblBillQty = Bill.dblQuantity
		, ysnOpenLoad = ISNULL(OL.ysnOpenLoad, 0)
        , ysnContractAllocated = CAST(CASE WHEN isnull(AD.dblAllocatedQty,0) > 0 THEN 1 ELSE 0 END AS BIT)
		, strFreightBasisUOM = FBUM.strUnitMeasure
		, strFreightBasisBaseUOM = FBBUM.strUnitMeasure
		, CD.intRefFuturesMarketId
		, CD.intRefFuturesMonthId
		, CD.intRefFuturesItemUOMId
		, CD.intRefFuturesCurrencyId
		, CD.dblRefFuturesQty
		, RefFuturesMarket.strFutMarketName  strRefFuturesMarket
		, REPLACE(RefFuturesMonth.strFutureMonth, ' ', '(' + RefFuturesMonth.strSymbol + ') ') strRefFuturesMonth
		, RefFuturesCurrency.strCurrency strRefFuturesCurrency
		, RefFturesUnitMeasure.strUnitMeasure strRefFuturesUnitMeasure
		, ysnWithPriceFix = case when isnull(CT.intPriceContractId,0) = 0 then convert(bit,0) else convert(bit,1) end
        , dblAllocatedQty = AD.dblAllocatedQty
		, ysnCalculateUpdatedAvailability = CASE WHEN CT.intContractTypeId = 1 THEN Pref.ysnUpdatedAvailabilityPurchase ELSE Pref.ysnUpdatedAvailabilitySales END
		, ysnCalculatePlannedAvailability = CASE WHEN CT.intContractTypeId = 1 THEN Pref.ysnCalculatePlannedAvailabilityPurchase ELSE Pref.ysnCalculatePlannedAvailabilitySale END
		, intLoadingLeadTime = ISNULL(LoadingPort.intLeadTime, 0)
		, intLoadingLeadTimeSource = ISNULL(LoadingPort.intLeadTimeAtSource, 0)
		, intDestinationLeadTime = ISNULL(DestinationPort.intLeadTime, 0)
		, intDestinationLeadTimeSource = ISNULL(DestinationPort.intLeadTimeAtSource, 0)
		, intFreightRateMatrixLeadTime = ISNULL(FRM.intLeadTime, 0)
		, CD.strFinanceTradeNo
		, CD.intBankAccountId
		, BA.intBankId
		, strBankName = BK.strBankName
		, strBankAccountNo = BA.strBankAccountNo
		, CD.intFacilityId
		, strFacility = FA.strBorrowingFacilityId
		, CD.intLoanLimitId
		, strLoanLimit = BL.strBankLoanId
		, strLoanReferenceNo = BL.strLimitDescription
		, CD.dblLoanAmount
		, intOverrideFacilityId
		, strOverrideFacility = BVR.strBankValuationRule
		, CD.strBankReferenceNo
		, CD.dblQualityPremium
		, CD.dblOptionalityPremium
	FROM #tmpContractDetail CD
	JOIN CTE1 CT ON CT.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	LEFT JOIN tblCTPricingType PTH ON PTH.intPricingTypeId = CT.intHeaderPricingTypeId
	LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
	LEFT JOIN tblICItem IB ON IB.intItemId = CD.intItemBundleId
	LEFT JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblICUnitMeasure MU ON MU.intUnitMeasureId = MA.intUnitMeasureId
	LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	-- Trade Finance
	LEFT JOIN tblCMBankAccount BA ON BA.intBankAccountId = CD.intBankAccountId
	LEFT JOIN tblCMBank BK ON BK.intBankId = BA.intBankId
	LEFT JOIN tblCMBorrowingFacility FA ON FA.intBorrowingFacilityId = CD.intFacilityId
	LEFT JOIN tblCMBankLoan BL ON BL.intBankLoanId = CD.intLoanLimitId
	LEFT JOIN tblCMBankValuationRule BVR ON BVR.intBankValuationRuleId = CD.intOverrideFacilityId

	--SELECT * FROM tblCMBankLoan

	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CU.intMainCurrencyId
	LEFT JOIN tblSMCurrency BC ON BC.intCurrencyID = CD.intBasisCurrencyId
	LEFT JOIN tblSMCurrency BN ON BN.intCurrencyID = BC.intMainCurrencyId
	LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = CD.intConvPriceCurrencyId
	LEFT JOIN tblSMCurrency IY ON IY.intCurrencyID = CD.intInvoiceCurrencyId
	LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = MA.intCurrencyId
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DestinationPort ON DestinationPort.intCityId = CD.intDestinationPortId
	LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	LEFT JOIN tblICCommodityUnitMeasure CO ON CO.intCommodityUnitMeasureId =  CT.intCommodityUOMId
	LEFT JOIN tblICItemUOM CM ON CM.intItemId = CD.intItemId AND CM.intUnitMeasureId = CO.intUnitMeasureId
	LEFT JOIN @tblShipment Shipment ON Shipment.intContractDetailId = CD.intContractDetailId
	LEFT JOIN @tblBill Bill ON Bill.intContractDetailId = CD.intContractDetailId
	LEFT JOIN @OpenLoad OL ON OL.intContractDetailId = CD.intContractDetailId
	LEFT JOIN @tblInvoice Invoice ON Invoice.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGFreightRateMatrix FRM ON FRM.strOriginPort = LoadingPort.strCity
		AND FRM.strDestinationCity = DestinationPort.strCity
		AND FRM.intType = 2 -- General type
	OUTER APPLY dbo.fnCTGetShipmentStatus(CD.intContractDetailId) LD
	LEFT JOIN tblAPBillDetail BD ON BD.intContractDetailId = CD.intContractDetailId
    outer apply (
        select dblAllocatedQty = sum(lga.dblSAllocatedQty) from tblLGAllocationDetail lga where lga.intSContractDetailId = CD.intContractDetailId
    ) AD
	LEFT JOIN tblICItemUOM FB ON FB.intItemUOMId = CD.intFreightBasisUOMId
	LEFT JOIN tblICUnitMeasure FBUM ON FBUM.intUnitMeasureId = FB.intUnitMeasureId
	LEFT JOIN tblICItemUOM FBB ON FBB.intItemUOMId = CD.intFreightBasisBaseUOMId
	LEFT JOIN tblICUnitMeasure FBBUM ON FBBUM.intUnitMeasureId = FBB.intUnitMeasureId
	-- Reference Pricing
	LEFT JOIN tblRKFutureMarket RefFuturesMarket ON RefFuturesMarket.intFutureMarketId = CD.intRefFuturesMarketId
	LEFT JOIN tblRKFuturesMonth RefFuturesMonth ON RefFuturesMonth.intFutureMonthId = CD.intRefFuturesMonthId
	LEFT JOIN tblSMCurrency RefFuturesCurrency ON RefFuturesCurrency.intCurrencyID = CD.intRefFuturesCurrencyId
	LEFT JOIN tblICItemUOM RefFuturesItemUOMId ON RefFuturesItemUOMId.intItemUOMId = CD.intRefFuturesItemUOMId
	LEFT JOIN tblICUnitMeasure RefFturesUnitMeasure ON RefFturesUnitMeasure.intUnitMeasureId = RefFuturesItemUOMId.intUnitMeasureId
	CROSS APPLY (SELECT TOP 1 * FROM tblCTCompanyPreference) Pref
	OUTER APPLY (
		SELECT TOP 1 a.intContractHeaderId
			, a.intContractDetailId
			, c.strApprovalStatus
		FROM tblCTPriceFixation a
		LEFT JOIN tblSMTransaction c ON c.intRecordId = a.intPriceContractId AND c.strApprovalStatus IS NOT NULL
		LEFT JOIN tblSMScreen d ON d.strNamespace = 'ContractManagement.view.PriceContracts' AND d.intScreenId = c.intScreenId AND d.ysnApproval = 1
		WHERE a.intContractHeaderId = @intContractHeaderId
			AND ISNULL(a.intContractDetailId, 0) = CASE WHEN CT.ysnMultiplePriceFixation = 1 THEN ISNULL(a.intContractDetailId, 0) ELSE ISNULL(CD.intContractDetailId, 0) END
		ORDER BY c.intTransactionId DESC
	) AP
	ORDER BY CD.intContractSeq

	DROP TABLE #tmpContractDetail
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 18, 1, 'WITH NOWAIT')
END CATCH
