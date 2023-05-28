CREATE PROCEDURE uspLGCreateVoucherForInbound 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intBillId INT OUTPUT
	,@intType INT = 1
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(4000);
	DECLARE @intErrorSeverity INT;
	DECLARE @intErrorState INT;
	DECLARE @total AS INT
	DECLARE @intVendorEntityId AS INT;
	DECLARE @intMinRecord AS INT
	DECLARE @voucherPayable AS VoucherPayable
	DECLARE @voucherPayableToProcess AS VoucherPayable
	DECLARE @voucherPayableTax AS VoucherDetailTax
	DECLARE @intTaxGroupId INT
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intPurchaseSale INT
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT
	DECLARE @intCurrencyId INT
	DECLARE @intShipmentStatus INT
	DECLARE @ysnAllowReweighs BIT = 0
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @strFOBPoint NVARCHAR(50)

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	DECLARE @distinctItem TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intItemId INT)

	SELECT @strLoadNumber = L.strLoadNumber 
		,@intPurchaseSale = intPurchaseSale
		,@ysnAllowReweighs = L.ysnAllowReweighs
		,@strFOBPoint = FT.strFobPoint
	FROM tblLGLoad L
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId 
	WHERE intLoadId = @intLoadId

	IF OBJECT_ID('tempdb..#tempVoucherId') IS NOT NULL
		DROP TABLE #tempVoucherId

	--Update LS Unit Cost for Unpriced Contracts
	UPDATE LD 
	SET dblUnitPrice = dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
		,dblAmount = dbo.fnCalculateCostBetweenUOM(
							LD.intPriceUOMId
							, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
							,(dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) / CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END)
						) * CASE WHEN (LD.intWeightItemUOMId IS NOT NULL) THEN LD.dblNet ELSE LD.dblQuantity END		
	FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
		LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
	WHERE ISNULL(LD.dblUnitPrice, 0) = 0 AND LD.intLoadId = @intLoadId

	--Check if any Purchase Basis Contract price is not fully priced
	IF EXISTS (SELECT TOP 1 1 FROM 
					tblCTContractDetail CD
					JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
					JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
					WHERE L.intLoadId = @intLoadId AND CD.intPricingTypeId NOT IN (1, 6))
	BEGIN
		DECLARE @strContractNumber NVARCHAR(100)
		DECLARE @ErrorMessageNotPriced NVARCHAR(250)

		SELECT TOP 1 
			@strContractNumber = CH.strContractNumber + '/' + CAST(CD.intContractSeq AS nvarchar(10))
		FROM 
		tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
		OUTER APPLY fnCTGetSeqPriceFixationInfo(CD.intContractDetailId) PF
		WHERE L.intLoadId = @intLoadId AND CD.intPricingTypeId NOT IN (1, 6)
			AND (PF.dblTotalLots IS NULL OR (ISNULL(PF.dblTotalLots,0) > 0 AND (ISNULL(PF.dblTotalLots,0) <> ISNULL(PF.dblLotsFixed,0))))

		SET @ErrorMessageNotPriced = 'Contract No. ' + @strContractNumber + ' is not fully priced. Unable to create Voucher.' 
		RAISERROR(@ErrorMessageNotPriced, 16, 1);
		RETURN 0;
	END

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
				,@intCurrencyId = CASE WHEN CD.ysnUseFXPrice = 1 THEN ISNULL(AD.intSeqCurrencyId, L.intCurrencyId) ELSE L.intCurrencyId END
				,@intShipmentStatus = L.intShipmentStatus
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
	JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
	WHERE L.intLoadId = @intLoadId

	SELECT @intAPAccount = ISNULL(intAPAccount,0)
	FROM tblSMCompanyLocation CL
	JOIN (
		SELECT TOP 1 ISNULL(LD.intPCompanyLocationId, intSCompanyLocationId) intCompanyLocationId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		WHERE L.intLoadId = @intLoadId
		) t ON t.intCompanyLocationId = CL.intCompanyLocationId

	IF @intAPAccount = 0
	BEGIN
		RAISERROR('Please configure ''AP Account'' for the company location.',16,1)
	END


	IF (@intShipmentStatus = 4 AND ISNULL(@ysnAllowReweighs, 0) = 0)
	BEGIN
		--If Shipment is already received, call the IR to Voucher procedure
		SELECT DISTINCT 
			receipt.intInventoryReceiptId 
		INTO
			#tmpInventoryReceipts
		FROM 
			tblICInventoryReceipt receipt 
			INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = receiptItem.intSourceId
		WHERE LD.intLoadId = @intLoadId
			AND receipt.intSourceType = 2
			AND receipt.intSourceInventoryReceiptId IS NULL 
			AND receipt.intInventoryReceiptId NOT IN (SELECT intSourceInventoryReceiptId FROM tblICInventoryReceipt WHERE intSourceInventoryReceiptId IS NOT NULL AND strDataSource = 'Reverse')

		--Delete the Payables created by LS to allow IR to regenerate the payables
		DELETE FROM tblAPVoucherPayable WHERE intLoadShipmentId = @intLoadId AND intLoadShipmentCostId IS NULL

		DECLARE @intInventoryReceiptId INT = NULL
		DECLARE @strVoucherType NVARCHAR(100)
		SELECT @strVoucherType = CASE WHEN @intType = 2 THEN 'provisional voucher' ELSE '' END

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpInventoryReceipts)
		BEGIN
			SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM #tmpInventoryReceipts
				
			EXEC uspICConvertReceiptToVoucher @intInventoryReceiptId, @intEntityUserSecurityId, @strVoucherType, @intBillId OUTPUT

			DELETE FROM #tmpInventoryReceipts WHERE intInventoryReceiptId = @intInventoryReceiptId
		END
	END
	ELSE
	BEGIN
	--If Shipment is not yet received, create Voucher normally
		IF (@strFOBPoint = 'Destination' AND @intShipmentStatus <> 4)
		BEGIN
			RAISERROR('Load/Shipment has FOB Point of ''Destination''. Create and post Inventory Receipt first before creating Voucher.',16,1)
		END

		-- Get tax group
		SELECT TOP 1
			@intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
				LD.intVendorEntityId	-- @VendorId
				,ISNULL(L.intCompanyLocationId, CD.intCompanyLocationId)		--,@CompanyLocationId
				,NULL				--,@ItemId
				,EL.intEntityLocationId		--,@VendorLocationId
				,L.intFreightTermId	--,@FreightTermId
				,default --,@FOB
			)
		FROM tblLGLoad L
		INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		INNER JOIN tblAPVendor V ON V.intEntityId = LD.intVendorEntityId
		INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1	
		WHERE L.intLoadId = @intLoadId

		INSERT INTO @voucherPayable(
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intCurrencyId]
			,[dtmDate]
			,[strVendorOrderNumber]
			,[strReference]
			,[strSourceNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intContractCostId]
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[strLoadShipmentNumber]
			,[intLoadShipmentDetailId]
			,[intLoadShipmentCostId]
			,[intItemId]
			,[strMiscDescription]
			,[dblOrderQty]
			,[dblOrderUnitQty]
			,[intOrderUOMId]
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]
			,[intQtyToBillUOMId]
			,[dblCost]
			,[dblOptionalityPremium]
			,[dblQualityPremium]
			,[dblCostUnitQty]
			,[intCostUOMId]
			,[dblNetWeight]
			,[dblWeightUnitQty]
			,[intWeightUOMId]
			,[intCostCurrencyId]
			,[intFreightTermId]
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
			,[ysnStage]
			,[intSubLocationId]
			,[intStorageLocationId]
			/*Payment Info*/
			,[intPayFromBankAccountId]
			,[strFinancingSourcedFrom]
			,[strFinancingTransactionNumber]
			/* Trade Finance */
			,[strFinanceTradeNo]
			,[intBankId]
			,[intBankAccountId]
			,[intBorrowingFacilityId]
			,[strBankReferenceNo]
			,[intBorrowingFacilityLimitId]
			,[intBorrowingFacilityLimitDetailId]
			,[strReferenceNo]
			,[intBankValuationRuleId]
			,[strComments]
			,[intPurchaseTaxGroupId]
			,[strTaxPoint]
			,[intTaxLocationId]
			,[ysnOverrideTaxGroup])
		SELECT
			[intEntityVendorId] = D1.intEntityId
			,[intTransactionType] = 1
			,[intLocationId] = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
			,[intCurrencyId] = COALESCE(CY.intMainCurrencyId, CY.intCurrencyID, L.intCurrencyId)
			,[dtmDate] = L.dtmPostedDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(L.strLoadNumber)
			,[intContractHeaderId] = CH.intContractHeaderId
			,[intContractDetailId] = LD.intPContractDetailId
			,[intContractSeqId] = CT.intContractSeq
			,[intContractCostId] = NULL
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = L.intLoadId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[intLoadShipmentCostId] = NULL
			,[intItemId] = LD.intItemId
			,[strMiscDescription] = item.strDescription
			,[dblOrderQty] = LD.dblQuantity - ISNULL(B.dblQtyBilled, 0)
			,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intOrderUOMId] = LD.intItemUOMId
			,[dblQuantityToBill] = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) 
						THEN ISNULL(LDCL.dblQuantity, LD.dblQuantity) 
						ELSE LD.dblQuantity - ISNULL(LD.dblDeliveredQuantity,0) END - ISNULL(B.dblQtyBilled, 0)
			,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intQtyToBillUOMId] = LD.intItemUOMId
			,[dblCost] = COALESCE(LD.dblUnitPrice, dbo.fnCTGetSequencePrice(CT.intContractDetailId, NULL), 0)
			,[dblOptionalityPremium] = LD.dblOptionalityPremium
			,[dblQualityPremium] = LD.dblQualityPremium
			,[dblCostUnitQty] = CAST(ISNULL(AD.dblCostUnitQty,1) AS DECIMAL(38,20))
			,[intCostUOMId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqPriceUOMId, 0) ELSE ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId) END) 
			,[dblNetWeight] = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) 
							THEN ISNULL(LDCL.dblLinkNetWt, LD.dblNet)
							ELSE LD.dblNet -ISNULL(LD.dblDeliveredNet,0) END - ISNULL(B.dblNetWeight, 0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = ItemWeightUOM.intItemUOMId
			,[intCostCurrencyId] = SC.intCurrencyID
			,[intFreightTermId] = L.intFreightTermId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = CASE --if contract FX tab is setup
									WHEN CT.dblHistoricalRate IS NOT NULL THEN CT.dblHistoricalRate
									WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CT.intInvoiceCurrencyId <> @DefaultCurrencyId) 
											THEN CT.dblRate --functional price to foreign FX, use contract FX rate
										WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CT.intInvoiceCurrencyId = @DefaultCurrencyId)
											THEN 1 --foreign price to functional FX, use 1
										WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CT.intInvoiceCurrencyId <> @DefaultCurrencyId)
											THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
										ELSE ISNULL(LD.dblForexRate,1) END
									ELSE  --if contract FX tab is not setup
									CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
										THEN ISNULL(FX.dblFXRate, 1)
										ELSE ISNULL(LD.dblForexRate,1) END
									END
			,[ysnSubCurrency] =	AD.ysnSeqSubCurrency
			,[intSubCurrencyCents] = SC.intCent
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intStorageLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
			,[intSubLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
			/*Payment Info*/
			,[intPayFromBankAccountId] = BA.intBankAccountId
			,[strFinancingSourcedFrom] = CASE WHEN (BA.intBankAccountId IS NOT NULL) THEN 'Logistics' ELSE '' END
			,[strFinancingTransactionNumber] = CASE WHEN (BA.intBankAccountId IS NOT NULL) THEN L.strLoadNumber ELSE '' END
			/* Trade Finance */
			,[strFinanceTradeNo] = L.strTradeFinanceNo
			,[intBankId] = BA.intBankId
			,[intBankAccountId] = BA.intBankAccountId
			,[intBorrowingFacilityId] = L.intBorrowingFacilityId 
			,[strBankReferenceNo] = L.strBankReferenceNo
			,[intBorrowingFacilityLimitId] = L.intBorrowingFacilityLimitId
			,[intBorrowingFacilityLimitDetailId] = L.intBorrowingFacilityLimitDetailId
			,[strReferenceNo] = L.strTradeFinanceReferenceNo
			,[intBankValuationRuleId] = L.intBankValuationRuleId
			,[strComments] = L.strTradeFinanceComments
			,[intPurchaseTaxGroupId] = CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END
			,[strTaxPoint] = L.strTaxPoint
			,[intTaxLocationId] = L.intTaxLocationId
			,[ysnOverrideTaxGroup] = LD.ysnTaxGroupOverride
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CT.intContractDetailId) AD
		JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
		LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqPriceUOMId, 0) ELSE ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId) END)
		OUTER APPLY (SELECT dblQtyBilled = SUM(CASE WHEN (intTransactionType = 3) THEN -dblQtyReceived ELSE dblQtyReceived END)
							,dblNetWeight = SUM(CASE WHEN (intTransactionType = 3) THEN -BD.dblNetWeight ELSE BD.dblNetWeight END)
					FROM tblAPBillDetail BD 
					INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
					INNER JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE B.intTransactionType IN (1, 3) 
						AND BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge'
						AND BD.intLoadId = L.intLoadId AND BD.intLoadDetailId = LD.intLoadDetailId) B
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		LEFT JOIN (
			SELECT 
				W.intLoadId,
				W.intLoadWarehouseId,
				W.intSubLocationId,
				W.intStorageLocationId,
				strSubLocation = CLSL.strSubLocationName,
				strStorageLocation = SL.strName
			FROM tblLGLoadWarehouse W
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
			) LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadWarehouseId = LW.intLoadWarehouseId
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CT.intCurrencyId
			OUTER APPLY (SELECT	TOP 1  
							intForexRateTypeId = RD.intRateTypeId
							,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
										THEN 1/RD.[dblRate] 
										ELSE RD.[dblRate] END 
							FROM tblSMCurrencyExchangeRate ER
							JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
							WHERE @DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
								AND ((ER.intFromCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
									OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)))
							ORDER BY RD.dtmValidFromDate DESC) FX
		LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
		LEFT JOIN tblCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId AND ISNULL(LC.ysnRejected, 0) = 0 AND LC.intLoadContainerId = LWC.intLoadContainerId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		WHERE L.intLoadId = @intLoadId
			AND (LD.dblQuantity - ISNULL(B.dblQtyBilled, 0)) > 0

		INSERT INTO @distinctVendor
		SELECT DISTINCT intEntityVendorId
		FROM @voucherPayable

		INSERT INTO @distinctItem
		SELECT DISTINCT intItemId
		FROM @voucherPayable

		SELECT @intAPClearingAccountId = APAccount
		FROM (
			SELECT [dbo].[fnGetItemGLAccount](LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') APAccount
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
					WHEN L.intPurchaseSale = 2
						THEN LD.intSContractDetailId
					ELSE LD.intPContractDetailId
					END
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
				AND ItemLoc.intLocationId = CD.intCompanyLocationId
			WHERE L.intLoadId = @intLoadId
			) tb
		WHERE APAccount IS NULL

		IF(ISNULL(@intAPClearingAccountId,0)>0)
		BEGIN
			RAISERROR ('''AP Clearing'' is not configured for one or more item(s).',11,1);
		END

		SELECT @total = COUNT(*)
		FROM @voucherPayable;

		IF (@total = 0)
		BEGIN
			DECLARE @ErrorMessage NVARCHAR(250)
			SET @ErrorMessage = 'Voucher(s) are already created for the Total Quantity of this Load/Shipment';

			RAISERROR (@ErrorMessage,11,1);
			RETURN;
		END

		SELECT @intMinRecord = MIN(intRecordId) FROM @distinctVendor

		DECLARE @xmlVoucherIds XML
		DECLARE @createVoucherIds NVARCHAR(MAX)
		DECLARE @voucherIds Id

		WHILE ISNULL(@intMinRecord, 0) <> 0
		BEGIN
			SET @intVendorEntityId = NULL

			SELECT @intVendorEntityId = intVendorEntityId
			FROM @distinctVendor
			WHERE intRecordId = @intMinRecord

			INSERT INTO @voucherPayableToProcess(
				[intEntityVendorId]
				,[intTransactionType]
				,[intLocationId]
				,[intCurrencyId]
				,[dtmDate]
				,[strVendorOrderNumber]
				,[strReference]
				,[strSourceNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intContractSeqId]
				,[intContractCostId]
				,[intInventoryReceiptItemId]
				,[intLoadShipmentId]
				,[strLoadShipmentNumber]
				,[intLoadShipmentDetailId]
				,[intLoadShipmentCostId]
				,[intItemId]
				,[strMiscDescription]
				,[dblOrderQty]
				,[dblOrderUnitQty]
				,[intOrderUOMId]
				,[dblQuantityToBill]
				,[dblQtyToBillUnitQty]
				,[intQtyToBillUOMId]
				,[dblCost]
				,[dblOptionalityPremium]
				,[dblQualityPremium]
				,[dblCostUnitQty]
				,[intCostUOMId]
				,[dblNetWeight]
				,[dblWeightUnitQty]
				,[intWeightUOMId]
				,[intCostCurrencyId]
				,[intFreightTermId]
				,[dblTax]
				,[dblDiscount]
				,[dblExchangeRate]
				,[ysnSubCurrency]
				,[intSubCurrencyCents]
				,[intAccountId]
				,[strBillOfLading]
				,[ysnReturn]
				,[ysnStage]
				,[intSubLocationId]
				,[intStorageLocationId]
				/*Payment Info*/
				,[intPayFromBankAccountId]
				,[strFinancingSourcedFrom]
				,[strFinancingTransactionNumber]
				/* Trade Finance */
				,[strFinanceTradeNo]
				,[intBankId]
				,[intBankAccountId]
				,[intBorrowingFacilityId]
				,[strBankReferenceNo]
				,[intBorrowingFacilityLimitId]
				,[intBorrowingFacilityLimitDetailId]
				,[strReferenceNo]
				,[intBankValuationRuleId]
				,[strComments]
				,[intPurchaseTaxGroupId]
				,[strTaxPoint]
				,[intTaxLocationId]
				,[ysnOverrideTaxGroup])
			SELECT
				[intEntityVendorId]
				,[intTransactionType] = CASE WHEN @intType = 1 THEN 1 WHEN @intType = 2 THEN 16 END
				,[intLocationId]
				,[intCurrencyId]
				,[dtmDate]
				,[strVendorOrderNumber]
				,[strReference]
				,[strSourceNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intContractSeqId]
				,[intContractCostId]
				,[intInventoryReceiptItemId]
				,[intLoadShipmentId]
				,[strLoadShipmentNumber]
				,[intLoadShipmentDetailId]
				,[intLoadShipmentCostId]
				,[intItemId]
				,[strMiscDescription]
				,[dblOrderQty]
				,[dblOrderUnitQty]
				,[intOrderUOMId]
				,[dblQuantityToBill]
				,[dblQtyToBillUnitQty]
				,[intQtyToBillUOMId]
				,[dblCost]
				,[dblOptionalityPremium]
				,[dblQualityPremium]
				,[dblCostUnitQty]
				,[intCostUOMId]
				,[dblNetWeight]
				,[dblWeightUnitQty]
				,[intWeightUOMId]
				,[intCostCurrencyId]
				,[intFreightTermId]
				,[dblTax]
				,[dblDiscount]
				,[dblExchangeRate]
				,[ysnSubCurrency]
				,[intSubCurrencyCents]
				,[intAccountId]
				,[strBillOfLading]
				,[ysnReturn]
				,[ysnStage]
				,[intSubLocationId]
				,[intStorageLocationId]
				/*Payment Info*/
				,[intPayFromBankAccountId]
				,[strFinancingSourcedFrom]
				,[strFinancingTransactionNumber]
				/* Trade Finance */
				,[strFinanceTradeNo]
				,[intBankId]
				,[intBankAccountId]
				,[intBorrowingFacilityId]
				,[strBankReferenceNo]
				,[intBorrowingFacilityLimitId]
				,[intBorrowingFacilityLimitDetailId]
				,[strReferenceNo]
				,[intBankValuationRuleId]
				,[strComments]
				,[intPurchaseTaxGroupId]
				,[strTaxPoint]
				,[intTaxLocationId]
				,[ysnOverrideTaxGroup]
			FROM @voucherPayable
			WHERE intEntityVendorId = @intVendorEntityId

			-- Assemble Item Taxes
			BEGIN
				INSERT INTO @voucherPayableTax (
					[intVoucherPayableId]
					,[intTaxGroupId]				
					,[intTaxCodeId]				
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[intAccountId]				
					,[dblTax]					
					,[dblAdjustedTax]			
					,[ysnTaxAdjusted]			
					,[ysnSeparateOnBill]			
					,[ysnCheckOffTax]		
					,[ysnTaxExempt]	
					,[ysnTaxOnly]
				)
				SELECT 
					[intVoucherPayableId]			= payables.intVoucherPayableId
					,[intTaxGroupId]				= CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END
					,[intTaxCodeId]					= vendorTax.[intTaxCodeId]
					,[intTaxClassId]				= vendorTax.[intTaxClassId]
					,[strTaxableByOtherTaxes]		= vendorTax.[strTaxableByOtherTaxes]
					,[strCalculationMethod]			= vendorTax.[strCalculationMethod]
					,[dblRate]						= vendorTax.[dblRate]
					,[intAccountId]					= vendorTax.[intTaxAccountId]
					,[dblTax]						=	CASE 
															WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
																vendorTax.[dblTax] 
															ELSE 
																CASE 
																	WHEN payables.dblExchangeRate <> 0 THEN 
																		ROUND(
																			dbo.fnDivide(
																				-- Convert the tax to the transaction currency. 
																				vendorTax.[dblTax] 
																				, payables.dblExchangeRate
																			)
																		, 2) 
																	ELSE 
																		vendorTax.[dblTax] 
																END 
														END 
					,[dblAdjustedTax]				= 
														CASE 
															WHEN vendorTax.[ysnTaxAdjusted] = 1 THEN 
																vendorTax.[dblAdjustedTax]
															WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
																vendorTax.[dblTax] 
															ELSE 
																CASE 
																	WHEN payables.dblExchangeRate <> 0 THEN 
																		ROUND(
																			dbo.fnDivide(
																				-- Convert the tax to the transaction currency. 
																				vendorTax.[dblTax] 
																				, payables.dblExchangeRate
																			)
																		, 2) 
																	ELSE 
																		vendorTax.[dblTax] 
																END 
														END
					,[ysnTaxAdjusted]				= vendorTax.[ysnTaxAdjusted]
					,[ysnSeparateOnBill]			= vendorTax.[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]				= vendorTax.[ysnCheckoffTax]
					,[ysnTaxExempt]					= vendorTax.[ysnTaxExempt]
					,[ysnTaxOnly]					= 0
				FROM @voucherPayableToProcess payables
				INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = payables.intLoadShipmentDetailId
				INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND payables.intLoadShipmentId = L.intLoadId
				INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				INNER JOIN tblAPVendor V ON V.intEntityId = LD.intVendorEntityId
				INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.ysnDefaultLocation = 1
				INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
				OUTER APPLY [dbo].[fnGetItemTaxComputationForVendor](
						payables.intItemId,
						payables.intEntityVendorId,
						GETDATE(),
						-- Cost
						CASE WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN
							dbo.fnCalculateCostBetweenUOM(
								COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
								, payables.intWeightUOMId
								, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
										dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
									ELSE
										payables.dblCost
								END
							)
						ELSE 
							dbo.fnCalculateCostBetweenUOM(
								COALESCE(payables.intCostUOMId, payables.intOrderUOMId)
								, LD.intItemUOMId
								, CASE WHEN payables.ysnSubCurrency = 1 AND ISNULL(payables.intSubCurrencyCents, 0) <> 0 THEN 
										dbo.fnDivide(payables.dblCost, payables.intSubCurrencyCents) 
									ELSE
										payables.dblCost
								END
							)
						END,
						-- Qty
						CASE
							WHEN payables.intWeightUOMId IS NOT NULL AND I.intComputeItemTotalOption = 0 THEN 
								payables.dblNetWeight
							ELSE 
								payables.dblOrderQty 
						END,
						CASE WHEN ISNULL(LD.intTaxGroupId, '') = '' THEN @intTaxGroupId ELSE LD.intTaxGroupId END,
						CL.intCompanyLocationId,
						EL.intEntityLocationId,
						1,
						0,
						L.intFreightTermId,
						0,
						ISNULL(payables.intWeightUOMId, payables.intOrderUOMId),
						NULL,
						NULL,
						NULL
					) vendorTax
				WHERE vendorTax.intTaxGroupId IS NOT NULL
			END


			IF (@intType = 1)
			BEGIN
				EXEC uspAPCreateVoucher 
					@voucherPayables = @voucherPayableToProcess
					,@voucherPayableTax = @voucherPayableTax
					,@userId = @intEntityUserSecurityId
					,@throwError = 1
					,@error = @strErrorMessage OUTPUT
					,@createdVouchersId = @createVoucherIds OUTPUT
			END
			ELSE
			BEGIN
				EXEC uspAPCreateProvisional
					@voucherPayables = @voucherPayableToProcess
					,@voucherPayableTax = @voucherPayableTax
					,@userId = @intEntityUserSecurityId
					,@throwError = 1
					,@error = @strErrorMessage OUTPUT
					,@createdVouchersId = @createVoucherIds OUTPUT
			END

			DELETE FROM @voucherPayableToProcess

			SET @xmlVoucherIds = CAST('<A>'+ REPLACE(@createVoucherIds, ',', '</A><A>')+ '</A>' AS XML)

			INSERT INTO @voucherIds 
				(intId) 
			SELECT 
				RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
			FROM @xmlVoucherIds.nodes('/A') AS X(T) 
			WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

			SELECT TOP 1 @intBillId = intId FROM @voucherIds

			SELECT @intMinRecord = MIN(intRecordId)
			FROM @distinctVendor
			WHERE intRecordId > @intMinRecord
		END
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH

GO