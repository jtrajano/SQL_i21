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
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	DECLARE @distinctItem TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intItemId INT)

	SELECT @strLoadNumber = strLoadNumber FROM tblLGLoad WHERE intLoadId = @intLoadId

	IF OBJECT_ID('tempdb..#tempVoucherId') IS NOT NULL
		DROP TABLE #tempVoucherId

	SELECT *
	INTO #tempVoucherId
	FROM (
		SELECT intBillId
		FROM tblLGLoadCost
		WHERE intLoadId = @intLoadId
			AND intBillId IS NOT NULL
			AND intBillId NOT IN (SELECT intBillId FROM tblAPBillDetail BD 
									JOIN tblLGLoadDetail LD ON BD.intLoadDetailId = LD.intLoadDetailId
									WHERE BD.intLoadShipmentCostId IS NULL)

		UNION
	
		SELECT intBillId
		FROM tblLGLoadWarehouseServices
		WHERE intLoadWarehouseId IN (SELECT intLoadWarehouseId FROM tblLGLoadWarehouse WHERE intLoadId = @intLoadId)
			AND intBillId IS NOT NULL
		) tbl

	IF EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail BD 
	JOIN tblLGLoadDetail LD ON BD.intLoadDetailId = LD.intLoadDetailId
	WHERE LD.intLoadId = @intLoadId AND BD.intBillId NOT IN (SELECT intBillId FROM #tempVoucherId))
	BEGIN

		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = 'Voucher was already created for ' + @strLoadNumber;

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
				,@intCurrencyId = CASE WHEN CD.ysnUseFXPrice = 1 THEN ISNULL(AD.intSeqCurrencyId, L.intCurrencyId) ELSE L.intCurrencyId END
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
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
		,[intStorageLocationId])
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
		,[intInventoryReceiptItemId] = receiptItem.intInventoryReceiptItemId
		,[intLoadShipmentId] = L.intLoadId
		,[intLoadShipmentDetailId] = LD.intLoadDetailId
		,[intLoadShipmentCostId] = NULL
		,[intItemId] = LD.intItemId
		,[strMiscDescription] = item.strDescription
		,[dblOrderQty] = LD.dblQuantity
		,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intOrderUOMId] = LD.intItemUOMId
		,[dblQuantityToBill] = LD.dblQuantity
		,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intQtyToBillUOMId] = LD.intItemUOMId
		,[dblCost] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.dblSeqPrice, 0) ELSE ISNULL(LD.dblUnitPrice, 0) END)
		,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
		,[intCostUOMId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqPriceUOMId, 0) ELSE ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId) END) 
		,[dblNetWeight] = ISNULL(LD.dblNet,0)
		,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
		,[intWeightUOMId] = ItemWeightUOM.intItemUOMId
		,[intCostCurrencyId] = (CASE WHEN intPurchaseSale = 3 THEN ISNULL(AD.intSeqCurrencyId, 0) ELSE ISNULL(AD.intSeqCurrencyId, LD.intPriceCurrencyId) END)
		,[intFreightTermId] = L.intFreightTermId
		,[dblTax] = ISNULL(receiptItem.dblTax, 0)
		,[dblDiscount] = 0
		,[dblExchangeRate] = CASE WHEN (COALESCE(CY.intMainCurrencyId, CY.intCurrencyID, L.intCurrencyId) <> @DefaultCurrencyId) THEN ISNULL(LD.dblForexRate, 0) ELSE 1 END
		,[ysnSubCurrency] =	AD.ysnSeqSubCurrency
		,[intSubCurrencyCents] = CY.intCent
		,[intAccountId] = apClearing.intAccountId
		,[strBillOfLading] = L.strBLNumber
		,[ysnReturn] = CAST(0 AS BIT)
		,[ysnStage] = CAST(1 AS BIT)
		,[intStorageLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
		,[intSubLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CT.intContractDetailId) AD
	JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = AD.intSeqCurrencyId
	LEFT JOIN (tblICInventoryReceipt receipt 
				INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
				ON LD.intLoadDetailId = receiptItem.intSourceId AND receipt.intSourceType = 2
	LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = CT.intPriceItemUOMId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
	OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
				LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
				LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
				WHERE intLoadId = L.intLoadId) LW
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	WHERE L.intLoadId = @intLoadId
		AND LD.intLoadDetailId NOT IN (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
										WHERE BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge')

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
		SET @ErrorMessage = 'Voucher was already created for ' + @strLoadNumber;

		RAISERROR (@ErrorMessage,11,1);
		RETURN;
	END

	SELECT @intMinRecord = MIN(intRecordId) FROM @distinctVendor

	DECLARE @xmlVoucherIds XML
	DECLARE @createVoucherIds NVARCHAR(MAX)
	DECLARE @voucherIds TABLE (intBillId INT)

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
			,[intStorageLocationId])
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
			(intBillId) 
		SELECT 
			RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
		FROM @xmlVoucherIds.nodes('/A') AS X(T) 
		WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

		SELECT TOP 1 @intBillId = intBillId FROM @voucherIds

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH

GO