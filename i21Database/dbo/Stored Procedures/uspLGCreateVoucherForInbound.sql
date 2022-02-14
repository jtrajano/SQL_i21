CREATE PROCEDURE uspLGCreateVoucherForInbound 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intBillId INT OUTPUT
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
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT
	DECLARE @intCurrencyId INT
	DECLARE @intShipmentStatus INT
	DECLARE @ysnAllowReweighs BIT = 0
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	DECLARE @distinctItem TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intItemId INT)

	SELECT @strLoadNumber = strLoadNumber 
		,@ysnAllowReweighs = ysnAllowReweighs
	FROM tblLGLoad WHERE intLoadId = @intLoadId

	IF OBJECT_ID('tempdb..#tempVoucherId') IS NOT NULL
		DROP TABLE #tempVoucherId

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


	IF (@intShipmentStatus = 4 AND @ysnAllowReweighs = 0)
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
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpInventoryReceipts)
		BEGIN
			SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM #tmpInventoryReceipts
				
			EXEC uspICConvertReceiptToVoucher @intInventoryReceiptId, @intEntityUserSecurityId, @intBillId OUTPUT

			DELETE FROM #tmpInventoryReceipts WHERE intInventoryReceiptId = @intInventoryReceiptId
		END
	END
	ELSE
	BEGIN
	--If Shipment is not yet received, create Voucher normally
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
			,[strComments])
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
			,[dblQuantityToBill] = LD.dblQuantity - ISNULL(B.dblQtyBilled, 0)
			,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intQtyToBillUOMId] = LD.intItemUOMId
			,[dblCost] = (CASE WHEN intPurchaseSale = 3 THEN COALESCE(AD.dblSeqPrice, dbo.fnCTGetSequencePrice(CT.intContractDetailId, NULL), 0) ELSE ISNULL(LD.dblUnitPrice, 0) END)
			,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
			,[intCostUOMId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqPriceUOMId, 0) ELSE ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId) END) 
			,[dblNetWeight] = LD.dblNet - ISNULL(B.dblNetWeight, 0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = ItemWeightUOM.intItemUOMId
			,[intCostCurrencyId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqCurrencyId, 0) ELSE ISNULL(AD.intSeqCurrencyId, LD.intPriceCurrencyId) END)
			,[intFreightTermId] = L.intFreightTermId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = CASE --if contract FX tab is setup
										 WHEN AD.ysnValidFX = 1 THEN 
											CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CT.intInvoiceCurrencyId <> @DefaultCurrencyId) 
													THEN dbo.fnDivide(1, ISNULL(CT.dblRate, 1)) --functional price to foreign FX, use inverted contract FX rate
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
			,[intSubCurrencyCents] = CY.intCent
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intStorageLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
			,[intSubLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
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
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
		JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CT.intContractDetailId
		JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
		LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = CT.intPriceItemUOMId
		OUTER APPLY (SELECT dblQtyBilled = SUM(CASE WHEN (intTransactionType = 3) THEN -dblQtyReceived ELSE dblQtyReceived END)
							,dblNetWeight = SUM(CASE WHEN (intTransactionType = 3) THEN -BD.dblNetWeight ELSE BD.dblNetWeight END)
					FROM tblAPBillDetail BD 
					INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
					INNER JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE B.intTransactionType IN (1, 3) 
						AND BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge'
						AND BD.intLoadId = L.intLoadId AND BD.intLoadDetailId = LD.intLoadDetailId) B
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
					LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
					LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
					WHERE intLoadId = L.intLoadId) LW
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
				,[strComments])
			SELECT
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
			FROM @voucherPayable
			WHERE intEntityVendorId = @intVendorEntityId

			EXEC uspAPCreateVoucher 
				@voucherPayables = @voucherPayableToProcess
				,@voucherPayableTax = DEFAULT
				,@userId = @intEntityUserSecurityId
				,@throwError = 1
				,@error = @strErrorMessage OUTPUT
				,@createdVouchersId = @createVoucherIds OUTPUT

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