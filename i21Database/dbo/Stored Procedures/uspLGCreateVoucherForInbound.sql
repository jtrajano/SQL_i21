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
		WHERE intBillId IS NOT NULL
	
		UNION
	
		SELECT intBillId
		FROM tblLGLoadWarehouseServices
		WHERE intBillId IS NOT NULL
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
		,[intInventoryReceiptItemId]
		,[intLoadShipmentId]
		,[intLoadShipmentDetailId]
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
		,[dblTax]
		,[dblDiscount]
		,[dblExchangeRate]
		,[ysnSubCurrency]
		,[intSubCurrencyCents]
		,[intAccountId]
		,[strBillOfLading]
		,[ysnReturn]
		,[intSubLocationId]
		,[intStorageLocationId])
	SELECT
		[intEntityVendorId] = intVendorEntityId
		,[intTransactionType] = 1
		,[intLocationId] = L.intCompanyLocationId
		,[intCurrencyId] = L.intCurrencyId
		,[dtmDate] = GETDATE()
		,[strVendorOrderNumber] = ''
		,[strReference] = ''
		,[strSourceNumber] = LTRIM(L.strLoadNumber)
		,[intContractHeaderId] = CH.intContractHeaderId
		,[intContractDetailId] = CD.intContractDetailId
		,[intContractSeqId] = CD.intContractSeq
		,[intInventoryReceiptItemId] = NULL
		,[intLoadShipmentId] = L.intLoadId
		,[intLoadShipmentDetailId] = LD.intLoadDetailId
		,[intItemId] = LD.intItemId
		,[strMiscDescription] = I.strDescription
		,[dblOrderQty] = LD.dblQuantity
		,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intOrderUOMId] = LD.intItemUOMId
		,[dblQuantityToBill] = LD.dblQuantity
		,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intQtyToBillUOMId] = LD.intItemUOMId
		,[dblCost] = ISNULL(AD.dblSeqPrice, 0)
		,[dblCostUnitQty] = CAST(ISNULL(CostUOM.dblUnitQty,1) AS DECIMAL(38,20))
		,[intCostUOMId] = AD.intSeqPriceUOMId
		,[dblNetWeight] = ISNULL(LD.dblNet,0)
		,[dblWeightUnitQty] = ISNULL(WeightUOM.dblUnitQty,1)
		,[intWeightUOMId] = LD.intWeightItemUOMId
		,[intCostCurrencyId] = AD.intSeqCurrencyId
		,[dblTax] = 0
		,[dblDiscount] = 0
		,[dblExchangeRate] = 1
		,[ysnSubCurrency] =	AD.ysnSeqSubCurrency
		,[intSubCurrencyCents] = AD.ysnSeqSubCurrency
		,[intAccountId] = [dbo].[fnGetItemGLAccount](LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strBillOfLading] = L.strBLNumber
		,[ysnReturn] = CAST(0 AS BIT)
		,[intSubLocationId] = ISNULL(LW.intSubLocationId, CD.intSubLocationId)
		,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, CD.intStorageLocationId)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation SMCL ON LD.intPCompanyLocationId = SMCL.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
	LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemUOMId = LD.intWeightItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = CD.intPriceItemUOMId
	OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, 
			strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
			WHERE intLoadId = L.intLoadId) LW
	WHERE L.intLoadId = @intLoadId
	GROUP BY LD.intVendorEntityId
		,L.intCompanyLocationId
		,L.intCurrencyId
		,L.strBLNumber
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,LD.intItemId
		,LD.dblQuantity
		,LD.intItemUOMId
		,LD.dblNet
		,LD.intWeightItemUOMId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,CD.intContractSeq
		,I.strDescription
		,ItemLoc.intItemLocationId
		,AD.ysnSeqSubCurrency
		,AD.dblQtyToPriceUOMConvFactor
		,AD.dblSeqPrice
		,AD.intSeqPriceUOMId
		,AD.intSeqCurrencyId
		,ItemUOM.dblUnitQty
		,CostUOM.dblUnitQty
		,WeightUOM.dblUnitQty
		,ISNULL(LW.intSubLocationId, CD.intSubLocationId)
		,ISNULL(LW.intStorageLocationId, CD.intStorageLocationId)

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
		RAISERROR ('Bill process failure #1',11,1);
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
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
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
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
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
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
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
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
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