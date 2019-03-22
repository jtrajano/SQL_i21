CREATE PROCEDURE uspLGCreateVoucherForOutbound 
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
	DECLARE @intShipTo INT
	DECLARE @intCurrencyId INT

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	DECLARE @distinctItem TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intItemId INT)
	
	SELECT @strLoadNumber = strLoadNumber FROM tblLGLoad WHERE intLoadId = @intLoadId

	IF EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail BD 
	JOIN tblLGLoadDetail LD ON BD.intLoadDetailId = LD.intLoadDetailId
	WHERE LD.intLoadId = @intLoadId)
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = 'Voucher was already created for ' + @strLoadNumber;

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
				,@intCurrencyId = L.intCurrencyId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
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
		,[ysnReturn])
	SELECT
		[intEntityVendorId] = ISNULL(SLCL.intVendorId,WRMH.intVendorEntityId)
		,[intTransactionType] = 1
		,[intLocationId] = L.intCompanyLocationId
		,[intCurrencyId] = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)
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
		,[intItemId] = Item.intItemId
		,[strMiscDescription] = Item.strDescription
		,[dblOrderQty] = 1
		,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intOrderUOMId] = LD.intItemUOMId
		,[dblQuantityToBill] = 1
		,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
		,[intQtyToBillUOMId] = LD.intItemUOMId
		,[dblCost] = (CONVERT(NUMERIC(18, 6), Sum(LWS.dblActualAmount)) / (
						CONVERT(NUMERIC(18, 6), (
								SELECT SUM(dblNet)
								FROM tblLGLoadDetail D
								WHERE L.intLoadId = D.intLoadId
								))
						) * CONVERT(NUMERIC(18, 6), SUM(LD.dblNet))
					)
		,[dblCostUnitQty] = CAST(ISNULL(CostUOM.dblUnitQty,1) AS DECIMAL(38,20))
		,[intCostUOMId] = CostUOM.intItemUOMId
		,[dblNetWeight] = ISNULL(LD.dblNet,0)
		,[dblWeightUnitQty] = ISNULL(WeightUOM.dblUnitQty,1)
		,[intWeightUOMId] = LD.intWeightItemUOMId
		,[intCostCurrencyId] = CUR.intCurrencyID
		,[dblTax] = 0
		,[dblDiscount] = 0
		,[dblExchangeRate] = 1
		,[ysnSubCurrency] = ISNULL(CUR.ysnSubCurrency, 0)
		,[intSubCurrencyCents] = ISNULL(CUR.intCent, 0) 
		,[intAccountId] = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,[strBillOfLading] = L.strBLNumber
		,[ysnReturn] = CAST(0 AS BIT)
	FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
		LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
		LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId
		LEFT JOIN tblICItem Item ON Item.intItemId = LWS.intItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = LWS.intItemUOMId
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId
		LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LW.intSubLocationId
			AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
		LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = WRMH.intCurrencyId
	WHERE L.intLoadId = @intLoadId
		AND LWS.dblActualAmount > 0
	GROUP BY 
		LWS.intLoadWarehouseServicesId
		,WRMH.intVendorEntityId
		,SLCL.intVendorId
		,L.intCompanyLocationId
		,L.intCurrencyId
		,L.strBLNumber
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,Item.intItemId
		,LD.dblQuantity
		,LD.intItemUOMId
		,LD.dblNet
		,LD.intWeightItemUOMId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,CD.intContractSeq
		,Item.strDescription
		,ItemLoc.intItemLocationId
		,ItemUOM.dblUnitQty
		,CostUOM.intItemUOMId
		,CostUOM.dblUnitQty
		,WeightUOM.dblUnitQty
		,CUR.intMainCurrencyId
		,CUR.intCurrencyID
		,CUR.ysnSubCurrency
		,CUR.intCent
	UNION ALL
	SELECT
		[intEntityVendorId] = A.intEntityVendorId
		,[intTransactionType] = 1
		,[intLocationId] = A.intCompanyLocationId
		,[intCurrencyId] = A.intCurrencyId
		,[dtmDate] = A.dtmProcessDate
		,[strVendorOrderNumber] = ''
		,[strReference] = ''
		,[strSourceNumber] = LTRIM(A.strLoadNumber)
		,[intContractHeaderId] = A.intContractHeaderId
		,[intContractDetailId] = A.intContractDetailId
		,[intContractSeqId] = A.intContractSeq
		,[intInventoryReceiptItemId] = NULL
		,[intLoadShipmentId] = A.intLoadId
		,[intLoadShipmentDetailId] = A.intLoadDetailId
		,[intItemId] = A.intItemId
		,[strMiscDescription] = A.strItemDescription
		,[dblOrderQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
		,[dblOrderUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
		,[intOrderUOMId] = A.intItemUOMId
		,[dblQuantityToBill] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
		,[dblQtyToBillUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
		,[intQtyToBillUOMId] = A.intItemUOMId
		,[dblCost] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN ISNULL(A.dblTotal, A.dblPrice) ELSE ISNULL(A.dblPrice, A.dblTotal) END 
		,[dblCostUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
		,[intCostUOMId] = A.intPriceItemUOMId
		,[dblNetWeight] = ISNULL(A.dblNet,0)
		,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
		,[intWeightUOMId] = A.intWeightItemUOMId
		,[intCostCurrencyId] = A.intCurrencyId
		,[dblTax] = 0
		,[dblDiscount] = 0
		,[dblExchangeRate] = 1
		,[ysnSubCurrency] =	CASE WHEN ISNULL(CC.intMainCurrencyId, CC.intCurrencyID) > 0 THEN 1 ELSE 0 END
		,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
		,[intAccountId] = apClearing.intAccountId
		,[strBillOfLading] = L.strBLNumber
		,[ysnReturn] = CAST(0 AS BIT)
	FROM vyuLGLoadCostForVendor A
		JOIN tblLGLoad L ON L.intLoadId = A.intLoadId
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
		LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = A.intCurrencyId
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
		WHERE A.intLoadId = @intLoadId
			AND A.intLoadDetailId NOT IN 
			(SELECT IsNull(BD.intLoadDetailId, 0) 
				FROM tblAPBillDetail BD 
			JOIN tblICItem Item ON Item.intItemId = BD.intItemId
			WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1)

	INSERT INTO @distinctVendor
	SELECT DISTINCT intEntityVendorId
	FROM @voucherPayable

	INSERT INTO @distinctItem
	SELECT DISTINCT intItemId
	FROM @voucherPayable

	IF EXISTS (SELECT 1 
		   FROM tblICItem I
		   LEFT JOIN tblICItemAccount IA ON IA.intItemId = I.intItemId
		   LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = IA.intAccountCategoryId
		   WHERE strAccountCategory IS NULL
			  AND I.intItemId IN (SELECT intItemId FROM @distinctItem))
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
			,[ysnReturn])
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