CREATE PROCEDURE [dbo].[uspCTLoadContractDetails]

	@intContractHeaderId INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX)

	DECLARE @tblShipment TABLE 
	(  
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(18,6),
			dblDestinationQuantity	NUMERIC(18,6)
	)

	DECLARE @tblBill TABLE 
	(  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(18,6)
	)
	
	DECLARE @tblInvoice TABLE 
	(  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(18,6)
	)	

	DECLARE @OpenLoad TABLE 
	(  
			intContractDetailId		INT,        
			ysnOpenLoad				BIT
	)

	IF EXISTS (SELECT TOP 1 1 FROM vyuCTCompanyPreference WHERE ysnAutoCompleteDPDeliveryDate = 1)
	BEGIN
		UPDATE CD SET intContractStatusId = 5
		FROM tblCTContractDetail CD
		WHERE dblBalance = 0
		AND intPricingTypeId = 5
		AND intContractStatusId = 1
		AND intContractHeaderId = @intContractHeaderId
		AND GETDATE() > dtmEndDate
	END

	INSERT INTO @tblShipment(intContractHeaderId,intContractDetailId,dblQuantity,dblDestinationQuantity)
	SELECT intContractHeaderId  = ShipmentItem.intOrderId  
		,intContractDetailId = ShipmentItem.intLineNo  
		,dblQuantity   = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ShipmentItem.intItemUOMId,CD.intItemUOMId,
							CASE
								WHEN CM.intInventoryShipmentItemId IS NULL THEN ShipmentItem.dblQuantity
								ELSE 0
							END)),0)
		,dblDestinationQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ShipmentItem.intItemUOMId,CD.intItemUOMId, 
		CASE
			WHEN CM.intInventoryShipmentItemId IS NULL THEN
			ISNULL(ShipmentItem.dblDestinationNet,ShipmentItem.dblQuantity)
				-- (CASE			
				-- 	WHEN ISNULL(INV.ysnPosted,0) = 1 THEN ISNULL(ShipmentItem.dblDestinationNet,ShipmentItem.dblQuantity) 
				-- 	ELSE ShipmentItem.dblQuantity 
				-- END)
			ELSE 0
		END)),0)
	FROM tblICInventoryShipmentItem ShipmentItem  
	JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId AND Shipment.intOrderType = 1  
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ShipmentItem.intLineNo AND CD.intContractHeaderId = ShipmentItem.intOrderId  
	LEFT JOIN 
	(
		SELECT DISTINCT ID.intInventoryShipmentItemId, IV.ysnPosted
		FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
		WHERE IV.strTransactionType = 'Invoice'
		AND  IV.ysnPosted = 1
	) INV ON INV.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId    
	LEFT JOIN 
	(
		SELECT DISTINCT ID.intInventoryShipmentItemId
		FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
		WHERE IV.strTransactionType = 'Credit Memo'
		AND  IV.ysnPosted = 1
	) CM ON CM.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId    
	WHERE Shipment.ysnPosted = 1 AND ShipmentItem.intOrderId = @intContractHeaderId
	GROUP BY ShipmentItem.intOrderId,ShipmentItem.intLineNo 

	INSERT INTO @tblBill(intContractDetailId,dblQuantity)
	SELECT 
		   intContractDetailId	= ReceiptItem.intLineNo
		  ,dblQuantity			= ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(ReceiptItem.intUnitMeasureId,CD.intItemUOMId,ReceiptItem.dblReceived)),0)
	FROM tblICInventoryReceiptItem ReceiptItem
	JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId AND Receipt.strReceiptType = 'Purchase Contract'
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ReceiptItem.intLineNo AND CD.intContractHeaderId = ReceiptItem.intOrderId
	WHERE CD.intContractHeaderId = @intContractHeaderId
	GROUP BY ReceiptItem.intLineNo

	INSERT  INTO @OpenLoad
	SELECT	ISNULL(LD.intSContractDetailId,LD.intPContractDetailId) AS intContractDetailId, CAST(LD.intLoadDetailId AS BIT) ysnOpenLoad 
	FROM	tblLGLoad		LO
	JOIN	tblLGLoadDetail LD	ON LD.intLoadId = LO.intLoadId
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	ISNULL(LD.intSContractDetailId,LD.intPContractDetailId)
	WHERE	intTicketId IS NULL 
	AND		LO.intShipmentStatus NOT IN (4, 10)
	AND		LO.intShipmentType <> 2
	AND		CD.intContractHeaderId	=	@intContractHeaderId

	INSERT INTO @tblInvoice (intContractDetailId, dblQuantity)
	SELECT CD.intContractDetailId, dblQuantity = ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(InvoiceDetail.intItemUOMId,CD.intItemUOMId,InvoiceDetail.dblQtyShipped)),0) - ISNULL(SUM([dbo].fnCTConvertQtyToTargetItemUOM(InvoiceDetail.intItemUOMId,CD.intItemUOMId,CM.dblQtyShipped)),0)
	FROM tblARInvoiceDetail InvoiceDetail
	JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
	AND Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
	JOIN tblCTContractDetail CD ON CD.intContractHeaderId = InvoiceDetail.intContractHeaderId AND CD.intContractDetailId = InvoiceDetail.intContractDetailId
	LEFT JOIN 
	(
		SELECT dblQtyShipped = SUM(ID.dblQtyShipped), ID.intOriginalInvoiceDetailId
		FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
		WHERE IV.strTransactionType = 'Credit Memo'
		AND  IV.ysnPosted = 1
		GROUP BY ID.intOriginalInvoiceDetailId
	) CM ON CM.intOriginalInvoiceDetailId = InvoiceDetail.intInvoiceDetailId
	WHERE InvoiceDetail.strPricing = 'Contracts'
	AND Invoice.ysnPosted = 1
	AND CD.intContractHeaderId = @intContractHeaderId
	GROUP BY CD.intContractDetailId

	;With ContractDetail AS (
	   SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId --1247
    ),
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
		OUTER APPLY 
		(
			SELECT TOP 1 intLoadDetailId
			FROM tblLGLoadDetail
			WHERE CD.intContractDetailId = CASE WHEN CH.intContractTypeId = 1 THEN intPContractDetailId ELSE intSContractDetailId END
			ORDER BY intLoadDetailId DESC
		) LG
		OUTER	APPLY	dbo.fnCTGetSampleDetail(CD.intContractDetailId)						QA
		OUTER	APPLY	dbo.fnCTGetSeqPriceFixationInfo(CD.intContractDetailId)				FI
		OUTER	APPLY	dbo.fnCTGetSeqContainerInfo(CH.intCommodityId,CD.intContainerTypeId,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin')) CQ
		OUTER	APPLY	dbo.fnCTGetSeqWashoutInfo(CD.intContractDetailId)					WO
		CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId)	AD
	)

	SELECT DISTINCT
		CD.intContractDetailId
		,CD.intSplitFromId
		,CD.intParentDetailId
		,CD.ysnSlice
		,CD.intConcurrencyId
		,CD.intContractHeaderId
		,CD.intContractStatusId
		,CD.intContractSeq
		,CD.intCompanyLocationId
		,CD.intShipToId
		,CD.dtmStartDate
		,CD.dtmEndDate
		,CD.intFreightTermId
		,CD.intShipViaId
		,CD.intItemContractId
		,CD.intItemBundleId
		,CD.intItemId
		,CD.strItemSpecification
		,CD.intCategoryId
		,CD.dblQuantity
		,CD.intItemUOMId
		,CD.dblOriginalQty
		,CD.dblBalance
		,CD.dblIntransitQty
		,CD.dblScheduleQty
		,CD.dblBalanceLoad
		,CD.dblScheduleLoad
		,CD.dblShippingInstructionQty
		,CD.dblNetWeight
		,CD.intNetWeightUOMId
		,CD.intUnitMeasureId
		,CD.intCategoryUOMId
		,CD.intNoOfLoad
		,CD.dblQuantityPerLoad
		,CD.intIndexId
		,CD.dblAdjustment
		,CD.intAdjItemUOMId
		,CD.intFutureMarketId
		,CD.intFutureMonthId
		,intPricingTypeId =  CASE 
								WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval')
									THEN CD.intPricingTypeId	
								WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval')
									THEN CH.intPricingTypeId
								ELSE CD.intPricingTypeId
							END
		,dblFutures = CASE 
						WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval')
							THEN CD.dblFutures	
						WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval')
							THEN NULL
						ELSE CD.dblFutures
					END
		,strPricingType = CASE 
							WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus = 'Approved' OR AP.strApprovalStatus = 'No Need for Approval')
								THEN PT.strPricingType
							WHEN AP.intContractHeaderId IS NOT NULL AND (AP.strApprovalStatus <> 'Approved' AND AP.strApprovalStatus <> 'No Need for Approval')
								THEN PTH.strPricingType
							ELSE PT.strPricingType
						END
		,CD.dblBasis
		,CD.dblOriginalBasis
		,CD.dblConvertedBasis
		,CD.intBasisCurrencyId
		,CD.intBasisUOMId
		,CD.dblFreightBasisBase
		,CD.intFreightBasisBaseUOMId
		,CD.dblFreightBasis
		,CD.intFreightBasisUOMId
		,CD.dblRatio
		,CD.dblCashPrice
		,CD.dblTotalCost
		,CD.intCurrencyId
		,CD.intPriceItemUOMId
		,CD.dblNoOfLots
		,CD.dtmLCDate
		,CD.dtmLastPricingDate
		,CD.dblConvertedPrice
		,CD.intConvPriceCurrencyId
		,CD.intConvPriceUOMId
		,CD.intMarketZoneId
		,CD.intDiscountTypeId
		,CD.intDiscountId
		,CD.intDiscountScheduleId
		,CD.intDiscountScheduleCodeId
		,CD.intStorageScheduleRuleId
		,CD.intContractOptHeaderId
		,CD.strBuyerSeller
		,CD.intBillTo
		,CD.intFreightRateId
		,CD.strFobBasis
		,CD.intRailGradeId
		,CD.strRailRemark
		,CD.strLoadingPointType
		,CD.intLoadingPortId
		,CD.strDestinationPointType
		,CD.intDestinationPortId
		,CD.strShippingTerm
		,CD.intShippingLineId
		,CD.strVessel
		,CD.intDestinationCityId
		,CD.intShipperId
		,CD.strRemark
		,CD.intSubLocationId
		,CD.intStorageLocationId
		,CD.intPurchasingGroupId
		,CD.intFarmFieldId
		,CD.intSplitId
		,CD.strGrade
		,CD.strGarden
		,CD.strVendorLotID
		,CD.strInvoiceNo
		,CD.strReference
		,CD.strERPPONumber
		,CD.strERPItemNumber
		,CD.strERPBatchNumber
		,CD.intUnitsPerLayer
		,CD.intLayersPerPallet
		,CD.dtmEventStartDate
		,CD.dtmPlannedAvailabilityDate
		,CD.dtmUpdatedAvailabilityDate
		,CD.dtmM2MDate
		,CD.intBookId
		,CD.intSubBookId
		,CD.intContainerTypeId
		,CD.intNumberOfContainers
		,CD.intInvoiceCurrencyId
		,CD.dtmFXValidFrom
		,CD.dtmFXValidTo
		,CD.dblRate
		,CD.dblFXPrice
		,CD.ysnUseFXPrice
		,CD.intFXPriceUOMId
		,CD.strFXRemarks
		,CD.dblAssumedFX
		,CD.strFixationBy
		,CD.strPackingDescription
		,CD.dblYield
		,CD.intCurrencyExchangeRateId
		,CD.intRateTypeId
		,CD.intCreatedById
		,CD.dtmCreated
		,CD.intLastModifiedById
		,CD.dtmLastModified
		,CD.ysnInvoice
		,CD.ysnProvisionalInvoice
		,CD.ysnQuantityFinal
		,CD.intProducerId
		,CD.ysnClaimsToProducer
		,CD.ysnRiskToProducer
		,CD.ysnBackToBack
		,CD.dblAllocatedQty
		,CD.dblReservedQty
		,CD.dblAllocationAdjQty
		,CD.dblInvoicedQty
		,CD.ysnPriceChanged
		,CD.intContractDetailRefId
		,CD.ysnStockSale
		,CD.strCertifications
		,CD.ysnSplit
		,CD.ysnProvisionalPNL
		,CD.ysnFinalPNL
		,CD.dtmProvisionalPNL
		,CD.dtmFinalPNL

		,CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) dblAvailableQty
		,CD.dblBalanceLoad - ISNULL(CD.dblScheduleLoad, 0) dblAvailableLoad
		,CD.intContractStatusId intCurrentContractStatusId
		,dbo.[fnCTGetSeqDisplayField](CD.intMarketZoneId,'tblARMarketZone') strMarketZoneCode--MZ.strMarketZoneCode
		,IM.strItemNo
		,dbo.[fnCTGetSeqDisplayField](CD.intAdjItemUOMId,'tblICItemUOM') strAdjustmentUOM--XM.strUnitMeasure strAdjustmentUOM
		,CL.strLocationName
		,FT.strFreightTerm
		,dbo.[fnCTGetSeqDisplayField](CD.intShipViaId,'tblEMEntity') strShipVia--SV.strName AS strShipVia
		,dbo.[fnCTGetSeqDisplayField](CD.intShipToId,'tblEMEntityLocation') strShipTo--SV.strName AS strShipVia
		,CU.strCurrency
		,CY.strCurrency strMainCurrency
		,CU.intMainCurrencyId
		,CU.ysnSubCurrency
		,dbo.[fnCTGetSeqDisplayField](CD.intFreightRateId,'tblCTFreightRate') strOriginDest--FR.strOrigin + FR.strDest strOriginDest
		,dbo.[fnCTGetSeqDisplayField](CD.intRailGradeId,'tblCTRailGrade') strRailGrade--RG.strRailGrade
		,NULL AS strContractOptDesc --Screen not in use
		,dbo.[fnCTGetSeqDisplayField](CD.intDiscountTypeId,'tblCTDiscountType') strDiscountType
		,dbo.[fnCTGetSeqDisplayField](CD.intDiscountId,'tblGRDiscountId') strDiscountId
		,IC.strContractItemName
		,IB.strItemNo as strBundleItemNo
		,dbo.[fnCTGetSeqDisplayField](CD.intNetWeightUOMId,'tblICItemUOM') strNetWeightUOM--WM.strUnitMeasure strNetWeightUOM
		,dbo.[fnCTGetSeqDisplayField](CD.intPriceItemUOMId,'tblICItemUOM') strPriceUOM--PM.strUnitMeasure strPriceUOM
		,dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId,'Origin') strOrigin--ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
		,dbo.[fnCTGetSeqDisplayField](CD.intIndexId,'tblCTIndex') strIndex--IX.strIndex
		,CS.strContractStatus
		,ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') AS strShipmentStatus
		,CASE 
			WHEN CH.intContractTypeId = 1 THEN
				CASE 
					WHEN CD.ysnFinalPNL = 1 THEN 'Final P&L Created'
					WHEN CD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
					ELSE CASE WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' END
				END
			ELSE CD.strFinancialStatus --FS.strFinancialStatus
		END AS strFinancialStatus
		,MA.strFutMarketName AS strFutureMarket
		,REPLACE(MO.strFutureMonth, ' ', '(' + MO.strSymbol + ') ') strFutureMonth
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CM.intItemUOMId, 1) AS dblConversionFactor
		,dbo.[fnCTGetSeqDisplayField](CD.intItemUOMId,'tblICItemUOM')strUOM --QM.strUnitMeasure strUOM--ISNULL(QM.strUnitMeasure, YM.strUnitMeasure) AS strUOM -- YM. is not in use
		,CASE 
			WHEN CH.ysnLoad = 1
				THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0)
			ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)
		END AS dblAppliedQty
		,dblAppliedLoadQty = 
		CASE 
			WHEN Shipment.dblQuantity > 0  THEN Shipment.dblDestinationQuantity + ISNULL(Invoice.dblQuantity,0)
			WHEN Bill.dblQuantity > 0  THEN Bill.dblQuantity
			WHEN Invoice.dblQuantity > 0  THEN Invoice.dblQuantity
			ELSE -- dblAppliedQty
				CASE 
					WHEN CH.ysnLoad = 1
					THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0)
					ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0)
				END * CD.dblQuantityPerLoad
		END
		,dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId, 0) AS dblExchangeRate
		,IM.intProductTypeId
		,CAST(1 AS BIT) ysnItemUOMIdExist
		,dbo.[fnCTGetSeqDisplayField](CD.intSubLocationId,'tblSMCompanyLocationSubLocation') strSubLocationName --SB.strSubLocationName
		,dbo.[fnCTGetSeqDisplayField](CD.intStorageLocationId,'tblICStorageLocation') strStorageLocationName --SL.strName AS strStorageLocationName
		,dbo.[fnCTGetSeqDisplayField](CD.intLoadingPortId,'tblSMCity') strLoadingPoint--LP.strCity AS strLoadingPoint
		,dbo.[fnCTGetSeqDisplayField](CD.intDestinationPortId,'tblSMCity') strDestinationPoint--DP.strCity AS strDestinationPoint
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
		,dbo.[fnCTGetSeqDisplayField](CD.intCurrencyExchangeRateId,'tblSMCurrencyExchangeRate') AS strExchangeRate
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
		,ISNULL(OL.ysnOpenLoad,0)	AS ysnOpenLoad
		,CAST(CASE WHEN AD.intAllocationDetailId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnContractAllocated
		,strFreightBasisUOM = FBUM.strUnitMeasure
		,strFreightBasisBaseUOM = FBBUM.strUnitMeasure

	FROM			ContractDetail					CD
			JOIN    CTE1							CT	ON CT.intContractDetailId				=		CD.intContractDetailId
			JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
	LEFT    JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId				=		CD.intContractStatusId		--strContractStatus
	LEFT    JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId					=		CD.intPricingTypeId			--strPricingType
	LEFT    JOIN	tblCTPricingType				PTH ON	PTH.intPricingTypeId				=		CH.intPricingTypeId   --strPricingType  
	LEFT    JOIN	tblICItem						IM	ON	IM.intItemId						=		CD.intItemId				--strItemNo
	LEFT    JOIN	tblICItemContract				IC	ON	IC.intItemContractId				=		CD.intItemContractId		--strContractItemName
	LEFT    JOIN	tblICItem						IB	ON	IB.intItemId						=		CD.intItemBundleId			--strBundleItemNo

	
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
	--LEFT    JOIN	tblSMCurrencyExchangeRate		ER	ON	ER.intCurrencyExchangeRateId		=		CD.intCurrencyExchangeRateId--strExchangeRate
	--LEFT    JOIN	tblSMCurrency					FY	ON	FY.intCurrencyID					=		ER.intFromCurrencyId			
	--LEFT    JOIN	tblSMCurrency					TY	ON	TY.intCurrencyID					=		ER.intToCurrencyId	
	LEFT    JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CD.intRateTypeId
	LEFT    JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId					=		CD.intFreightTermId			--strFreightTerm
	LEFT	JOIN	tblSMPurchasingGroup			PG	ON	PG.intPurchasingGroupId				=		CD.intPurchasingGroupId		--strPurchasingGroup
	LEFT	JOIN	tblICCommodityUnitMeasure		CO	ON	CO.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
	LEFT    JOIN	tblICItemUOM					CM	ON	CM.intItemId						=		CD.intItemId		
														AND	CM.intUnitMeasureId					=		CO.intUnitMeasureId
	LEFT   JOIN     @tblShipment				Shipment ON Shipment.intContractDetailId        =       CD.intContractDetailId
	LEFT   JOIN     @tblBill						Bill ON Bill.intContractDetailId			=       CD.intContractDetailId
	LEFT   JOIN     @tblInvoice						Invoice ON Invoice.intContractDetailId		=       CD.intContractDetailId
	LEFT   JOIN     @OpenLoad						OL	ON OL.intContractDetailId				=       CD.intContractDetailId
	OUTER	APPLY	dbo.fnCTGetShipmentStatus(CD.intContractDetailId) LD
	--OUTER	APPLY	dbo.fnCTGetFinancialStatus(CD.intContractDetailId) FS
	LEFT	JOIN	tblAPBillDetail					BD	ON	BD.intContractDetailId				=		CD.intContractDetailId
	LEFT	JOIN	tblLGAllocationDetail			AD	ON AD.intSContractDetailId = CD.intContractDetailId	
	
	LEFT	JOIN	tblICItemUOM					FB	ON	FB.intItemUOMId				=	CD.intFreightBasisUOMId		
	LEFT	JOIN	tblICUnitMeasure				FBUM	ON FBUM.intUnitMeasureId	=	FB.intUnitMeasureId			
	LEFT	JOIN	tblICItemUOM					FBB	ON	FBB.intItemUOMId			=	CD.intFreightBasisBaseUOMId	
	LEFT	JOIN	tblICUnitMeasure				FBBUM	ON FBBUM.intUnitMeasureId	=	FBB.intUnitMeasureId
	OUTER APPLY 
	(
		SELECT TOP 1 a.intContractHeaderId, a.intContractDetailId, c.strApprovalStatus
		FROM tblCTPriceFixation a
		INNER JOIN tblCTContractHeader b ON a.intContractHeaderId = b.intContractHeaderId
		LEFT JOIN tblSMTransaction c ON c.intRecordId = a.intPriceContractId AND c.strApprovalStatus IS NOT NULL
		LEFT JOIN tblSMScreen d ON d.strNamespace = 'ContractManagement.view.PriceContracts' AND d.intScreenId = c.intScreenId AND d.ysnApproval = 1
		WHERE a.intContractHeaderId  = CD.intContractHeaderId
		AND CD.intContractDetailId = CASE WHEN b.ysnMultiplePriceFixation = 1 THEN CD.intContractDetailId ELSE a.intContractDetailId END
		ORDER BY c.intTransactionId DESC
	) AP
	ORDER BY CD.intContractSeq

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH