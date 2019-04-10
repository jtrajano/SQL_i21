CREATE PROCEDURE uspLGCreateVoucherForWarehouseServices 
	 @intLoadWarehouseId INT 
	,@intEntityUserSecurityId INT
	,@intBillId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX);
	DECLARE @total AS INT
	DECLARE @intVendorEntityId AS INT;
	DECLARE @intMinRecord AS INT
	DECLARE @intMinInventoryReceiptId AS INT
	DECLARE @intMinItemRecordId AS INT
	DECLARE @VoucherDetailLoadNonInvAll AS VoucherDetailLoadNonInv
	DECLARE @VoucherDetailLoadNonInv AS VoucherDetailLoadNonInv
	DECLARE @voucherDetailReceipt AS VoucherDetailReceipt
	DECLARE @voucherDetailReceiptCharge AS VoucherDetailReceiptCharge
	DECLARE @voucherPayable AS VoucherPayable
	DECLARE @voucherPayableToProcess AS VoucherPayable
	DECLARE @intItemId INT
	DECLARE @intWarehouseServicesId INT
	DECLARE @strWarehouseName NVARCHAR(100)
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @strDeliveryNo NVARCHAR(100)
	DECLARE @intLoadId INT
	DECLARE @intPurchaseSale INT
	DECLARE @intReceiptCount INT
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT
	DECLARE @intCurrencyId INT
	DECLARE @ysnSubCurrency BIT
	DECLARE @intCents INT

	DECLARE @voucherDetailData TABLE (
		intItemRecordId INT Identity(1, 1)
		,intVendorEntityId INT
		,intLoadId INT
		,intLoadDetailId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,intItemId INT
		,intAccountId INT
		,dblQtyReceived NUMERIC(18, 6)
		,dblCost NUMERIC(18, 6)
		,intCostUOMId INT
		,intWarehouseServicesId INT
		,ysnInventoryCost BIT
		,intItemUOMId INT
		,dblUnitQty DECIMAL(38,20)
		,dblCostUnitQty DECIMAL(38,20)
		,intSubLocationId INT
		,intStorageLocationId INT
		)
	DECLARE @distinctVendor TABLE (
		intRecordId INT Identity(1, 1)
		,intVendorEntityId INT
		)
	DECLARE @distinctItem TABLE (
		intItemRecordId INT Identity(1, 1)
		,intVendorEntityId INT
		,intItemId INT
		)
	DECLARE @receiptData TABLE (
		intReceiptRecordId INT IDENTITY(1, 1)
		,intInventoryReceiptId INT
		,strReceiptNumber NVARCHAR(100)
		,intInventoryReceiptItemId INT
		,intInventoryReceiptType INT
		,dblCost NUMERIC(18, 6)
		)

	SELECT @intLoadId = intLoadId, @strDeliveryNo = strDeliveryNoticeNumber, @strWarehouseName = CLSL.strSubLocationName, 
		   @intCurrencyId = ISNULL(CU.intMainCurrencyId, WRMH.intCurrencyId), @ysnSubCurrency = CASE WHEN (CU.intMainCurrencyId IS NULL) THEN 0 ELSE 1 END,
		   @intCents = CU.intCent
	FROM tblLGLoadWarehouse LW
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WRMH.intCurrencyId 
	WHERE intLoadWarehouseId = @intLoadWarehouseId

	IF NOT EXISTS(
			SELECT TOP 1 1 FROM tblLGLoadWarehouseServices LWS 
				INNER JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId AND LW.intLoadId = @intLoadId
				LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId
				LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
				INNER JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
				INNER JOIN tblAPVendor V ON V.intEntityId = ISNULL(CLSL.intVendorId, WRMH.intVendorEntityId)
			WHERE LWS.intLoadWarehouseId = @intLoadWarehouseId)
	BEGIN
		SET @strErrorMessage = 'Vendor is not specified for ' + @strWarehouseName;
		RAISERROR (@strErrorMessage,16,1);
	END
	
	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @intPurchaseSale = intPurchaseSale
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 1
	BEGIN
		INSERT INTO @receiptData
		SELECT IR.intInventoryReceiptId
			,IR.strReceiptNumber
			,IRI.intInventoryReceiptItemId
			,IR.intSourceType
			,CD.dblSeqPrice
		FROM tblICInventoryReceipt IR
		JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(LD.intPContractDetailId) CD
		WHERE LD.intLoadId = @intLoadId
			AND IR.ysnPosted = 1
			AND IR.intSourceType = 2
	END
	ELSE
	BEGIN
		INSERT INTO @receiptData
		SELECT IRI.intInventoryReceiptId
			,IR.strReceiptNumber
			,IRI.intInventoryReceiptItemId
			,IR.intSourceType
			,CD.dblSeqPrice
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LDL.intLotId
		JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IRIL.intInventoryReceiptItemId
		JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(IRI.intLineNo) CD
		WHERE LD.intLoadId = @intLoadId
			AND IR.ysnPosted = 1
	END

	INSERT INTO @voucherDetailData (
		intVendorEntityId
		,intLoadId
		,intLoadDetailId
		,intContractHeaderId
		,intContractDetailId
		,intItemId
		,intAccountId
		,dblQtyReceived
		,dblCost
		,intCostUOMId
		,intWarehouseServicesId
		,ysnInventoryCost
		,intItemUOMId
		,dblUnitQty
		,dblCostUnitQty
		,intSubLocationId
		,intStorageLocationId
		)
	SELECT intVendorEntityId = ISNULL(SLCL.intVendorId, WRMH.intVendorEntityId)
		,intLoadId = L.intLoadId
		,intLoadDetailId = LD.intLoadDetailId
		,intContractHeaderId = CH.intContractHeaderId
		,intContractDetailId = CD.intContractDetailId
		,intItemId = Item.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = CASE WHEN (WRMD.intCalculateQty = 8) THEN 1 ELSE LWS.dblQuantity END
		,dblCost = LWS.dblUnitRate / CASE WHEN (@ysnSubCurrency = 1) THEN 100 ELSE 1 END
		,intCostUOMId = NULL
		,intWarehouseServicesId = LWS.intLoadWarehouseServicesId
		,ysnInventoryCost = Item.ysnInventoryCost
		,intItemUOMId = LWS.intItemUOMId
		,dblUnitQty = 1
		,dblCostUnitQty = 1 
		,intSubLocationId = LW.intSubLocationId
		,intStorageLocationId = LW.intStorageLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN L.intPurchaseSale = 2
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	LEFT JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
	LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId
	LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
	LEFT JOIN tblICItem Item ON Item.intItemId = LWS.intItemId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LW.intSubLocationId
		AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId 
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = LWS.intItemUOMId 
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
		AND LWS.dblActualAmount > 0
		AND LWS.intBillId IS NULL
	GROUP BY LWS.intLoadWarehouseServicesId
		,WRMH.intVendorEntityId
		,WRMD.intCalculateQty
		,SLCL.intVendorId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,ItemLoc.intItemLocationId
		,LD.dblNet
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,LWS.dblQuantity
		,LWS.dblUnitRate
		,LWS.intItemUOMId
		,Item.ysnInventoryCost
		,LD.intItemUOMId
		,ItemUOM.dblUnitQty
		,CostUOM.dblUnitQty
		,LW.intSubLocationId
		,LW.intStorageLocationId

	SELECT @intVendorEntityId = intVendorEntityId
	FROM @voucherDetailData

	INSERT INTO @distinctItem
	SELECT DISTINCT intVendorEntityId
		,intItemId
	FROM @voucherDetailData

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
	WHERE L.intLoadId = @intLoadId

	IF NOT EXISTS (
			SELECT TOP 1 1 FROM tblLGLoadWarehouseServices LWS 
				INNER JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId AND LW.intLoadId = @intLoadId
				LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId
				LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
				INNER JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
				INNER JOIN tblAPVendor V ON V.intEntityId = ISNULL(CLSL.intVendorId, WRMH.intVendorEntityId)
			WHERE LWS.intLoadWarehouseId = @intLoadWarehouseId
				AND LWS.intBillId IS NULL
			)
	BEGIN
		SET @strErrorMessage = 'Vouchers were already created for all warehouse services ' + CHAR(13) + 'of Delivery No. ' + @strDeliveryNo;

		RAISERROR (@strErrorMessage,16,1);
	END

	SELECT @intAPAccount = ISNULL(intAPAccount, 0)
	FROM tblSMCompanyLocation CL
	JOIN (
		SELECT TOP 1 ISNULL(LD.intPCompanyLocationId, intSCompanyLocationId) intCompanyLocationId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		WHERE L.intLoadId = @intLoadId
		) t ON t.intCompanyLocationId = CL.intCompanyLocationId

	IF @intAPAccount = 0
	BEGIN
		RAISERROR ('Please configure ''AP Account'' for the company location.',16,1)
	END

	SELECT @intAPClearingAccountId = APAccount
	FROM (
		SELECT [dbo].[fnGetItemGLAccount](LWS.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') APAccount
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN L.intPurchaseSale = 2
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
			AND ItemLoc.intLocationId = CD.intCompanyLocationId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
		WHERE L.intLoadId = @intLoadId
		) tb
	WHERE APAccount IS NULL

	IF(ISNULL(@intAPClearingAccountId,0)>0)
	BEGIN
		RAISERROR ('''AP Clearing'' is not configured for one or more item(s).',11,1);
	END

	SELECT @intReceiptCount = COUNT(*)
	FROM @receiptData

	DECLARE @xmlVoucherIds XML
	DECLARE @createVoucherIds NVARCHAR(MAX)
	DECLARE @voucherIds TABLE (intBillId INT)

	IF (@intReceiptCount = 0)
	BEGIN
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
			[intEntityVendorId] = VDD.intVendorEntityId
			,[intTransactionType] = 1
			,[intLocationId] = CD.intCompanyLocationId
			,[intCurrencyId] = @intCurrencyId
			,[dtmDate] = GETDATE()
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(L.strLoadNumber)
			,[intContractHeaderId] = VDD.intContractHeaderId
			,[intContractDetailId] = VDD.intContractDetailId
			,[intContractSeqId] = CD.intContractSeq
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = VDD.intLoadId
			,[intLoadShipmentDetailId] = VDD.intLoadDetailId
			,[intItemId] = VDD.intItemId
			,[strMiscDescription] = I.strDescription
			,[dblOrderQty] = VDD.dblQtyReceived
			,[dblOrderUnitQty] = VDD.dblUnitQty
			,[intOrderUOMId] = VDD.intItemUOMId
			,[dblQuantityToBill] = VDD.dblQtyReceived
			,[dblQtyToBillUnitQty] = VDD.dblUnitQty
			,[intQtyToBillUOMId] = VDD.intItemUOMId
			,[dblCost] = VDD.dblCost
			,[dblCostUnitQty] = VDD.dblCostUnitQty
			,[intCostUOMId] = VDD.intCostUOMId
			,[dblNetWeight] = 0
			,[dblWeightUnitQty] = 1
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = @intCurrencyId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] = @ysnSubCurrency
			,[intSubCurrencyCents] = CASE WHEN @ysnSubCurrency = 1 THEN @intCents ELSE NULL END
			,[intAccountId] = VDD.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[intSubLocationId] = VDD.intSubLocationId
			,[intStorageLocationId] = VDD.intStorageLocationId
		FROM @voucherDetailData VDD
			INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
			INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
			INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
			
		EXEC uspAPCreateVoucher 
			@voucherPayables = @voucherPayableToProcess
			,@voucherPayableTax = DEFAULT
			,@userId = @intEntityUserSecurityId
			,@throwError = 1
			,@error = @strErrorMessage OUTPUT
			,@createdVouchersId = @createVoucherIds OUTPUT

		SET @xmlVoucherIds = CAST('<A>'+ REPLACE(@createVoucherIds, ',', '</A><A>')+ '</A>' AS XML)

		INSERT INTO @voucherIds 
			(intBillId) 
		SELECT 
			RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
		FROM @xmlVoucherIds.nodes('/A') AS X(T) 
		WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

		SELECT TOP 1 @intBillId = intBillId FROM @voucherIds

		UPDATE tblLGLoadWarehouseServices
		SET intBillId = @intBillId
		WHERE intLoadWarehouseServicesId IN (
				SELECT intWarehouseServicesId
				FROM @voucherDetailData)

		DELETE FROM @voucherPayableToProcess
		DELETE FROM @voucherIds
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT TOP 1 1
				FROM @voucherDetailData
				WHERE ysnInventoryCost = 0
				)
		BEGIN
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
				[intEntityVendorId] = VDD.intVendorEntityId
				,[intTransactionType] = 1
				,[intLocationId] = CD.intCompanyLocationId
				,[intCurrencyId] = @intCurrencyId
				,[dtmDate] = GETDATE()
				,[strVendorOrderNumber] = ''
				,[strReference] = ''
				,[strSourceNumber] = LTRIM(L.strLoadNumber)
				,[intContractHeaderId] = VDD.intContractHeaderId
				,[intContractDetailId] = VDD.intContractDetailId
				,[intContractSeqId] = CD.intContractSeq
				,[intInventoryReceiptItemId] = NULL
				,[intLoadShipmentId] = VDD.intLoadId
				,[intLoadShipmentDetailId] = VDD.intLoadDetailId
				,[intItemId] = VDD.intItemId
				,[strMiscDescription] = I.strDescription
				,[dblOrderQty] = VDD.dblQtyReceived
				,[dblOrderUnitQty] = VDD.dblUnitQty
				,[intOrderUOMId] = VDD.intItemUOMId
				,[dblQuantityToBill] = VDD.dblQtyReceived
				,[dblQtyToBillUnitQty] = VDD.dblUnitQty
				,[intQtyToBillUOMId] = VDD.intItemUOMId
				,[dblCost] = VDD.dblCost
				,[dblCostUnitQty] = VDD.dblCostUnitQty
				,[intCostUOMId] = VDD.intCostUOMId
				,[dblNetWeight] = 0
				,[dblWeightUnitQty] = 1
				,[intWeightUOMId] = NULL
				,[intCostCurrencyId] = @intCurrencyId
				,[dblTax] = 0
				,[dblDiscount] = 0
				,[dblExchangeRate] = 1
				,[ysnSubCurrency] = @ysnSubCurrency
				,[intSubCurrencyCents] = CASE WHEN @ysnSubCurrency = 1 THEN @intCents ELSE NULL END
				,[intAccountId] = VDD.intAccountId
				,[strBillOfLading] = L.strBLNumber
				,[ysnReturn] = CAST(0 AS BIT)
				,[intSubLocationId] = VDD.intSubLocationId
				,[intStorageLocationId] = VDD.intStorageLocationId
			FROM @voucherDetailData VDD
				INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
				INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
				INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
			WHERE VDD.ysnInventoryCost = 0
			
			EXEC uspAPCreateVoucher 
				@voucherPayables = @voucherPayableToProcess
				,@voucherPayableTax = DEFAULT
				,@userId = @intEntityUserSecurityId
				,@throwError = 1
				,@error = @strErrorMessage OUTPUT
				,@createdVouchersId = @createVoucherIds OUTPUT

			SET @xmlVoucherIds = CAST('<A>'+ REPLACE(@createVoucherIds, ',', '</A><A>')+ '</A>' AS XML)

			INSERT INTO @voucherIds 
				(intBillId) 
			SELECT 
				RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
			FROM @xmlVoucherIds.nodes('/A') AS X(T) 
			WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

			SELECT TOP 1 @intBillId = intBillId FROM @voucherIds

			UPDATE tblLGLoadWarehouseServices
			SET intBillId = @intBillId
			WHERE intLoadWarehouseServicesId IN (
					SELECT intWarehouseServicesId
					FROM @voucherDetailData
					WHERE ysnInventoryCost = 0)

			DELETE FROM @voucherPayableToProcess
			DELETE FROM @voucherIds
		END

		IF EXISTS (
				SELECT TOP 1 1
				FROM @voucherDetailData
				WHERE ysnInventoryCost = 1
				)
		BEGIN
			SELECT @intMinInventoryReceiptId = MIN(intInventoryReceiptId)
				,@intBillId = NULL
			FROM @receiptData

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
				,[intInventoryReceiptChargeId]
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
				[intEntityVendorId] = VDD.intVendorEntityId
				,[intTransactionType] = 1
				,[intLocationId] = CD.intCompanyLocationId
				,[intCurrencyId] = @intCurrencyId
				,[dtmDate] = GETDATE()
				,[strVendorOrderNumber] = ''
				,[strReference] = ''
				,[strSourceNumber] = LTRIM(L.strLoadNumber)
				,[intContractHeaderId] = VDD.intContractHeaderId
				,[intContractDetailId] = VDD.intContractDetailId
				,[intContractSeqId] = CD.intContractSeq
				,[intInventoryReceiptItemId] = NULL
				,[intInventoryReceiptChargeId] = IRC.intInventoryReceiptChargeId
				,[intLoadShipmentId] = VDD.intLoadId
				,[intLoadShipmentDetailId] = VDD.intLoadDetailId
				,[intItemId] = VDD.intItemId
				,[strMiscDescription] = I.strDescription
				,[dblOrderQty] = VDD.dblQtyReceived
				,[dblOrderUnitQty] = VDD.dblUnitQty
				,[intOrderUOMId] = VDD.intItemUOMId
				,[dblQuantityToBill] = VDD.dblQtyReceived
				,[dblQtyToBillUnitQty] = VDD.dblUnitQty
				,[intQtyToBillUOMId] = VDD.intItemUOMId
				,[dblCost] = VDD.dblCost
				,[dblCostUnitQty] = VDD.dblCostUnitQty
				,[intCostUOMId] = VDD.intCostUOMId
				,[dblNetWeight] = 0
				,[dblWeightUnitQty] = 1
				,[intWeightUOMId] = NULL
				,[intCostCurrencyId] = @intCurrencyId
				,[dblTax] = 0
				,[dblDiscount] = 0
				,[dblExchangeRate] = 1
				,[ysnSubCurrency] = @ysnSubCurrency
				,[intSubCurrencyCents] = CASE WHEN @ysnSubCurrency = 1 THEN @intCents ELSE NULL END
				,[intAccountId] = VDD.intAccountId
				,[strBillOfLading] = L.strBLNumber
				,[ysnReturn] = CAST(0 AS BIT)
				,[intSubLocationId] = VDD.intSubLocationId
				,[intStorageLocationId] = VDD.intStorageLocationId
			FROM @voucherDetailData VDD
				INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
				INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
				INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
				CROSS APPLY (SELECT intInventoryReceiptChargeId
								FROM tblICInventoryReceiptCharge C
								WHERE intInventoryReceiptId = @intMinInventoryReceiptId
									AND ysnInventoryCost = 1
									AND intChargeId = VDD.intItemId) IRC
			WHERE VDD.ysnInventoryCost = 1
			
			EXEC uspAPCreateVoucher 
				@voucherPayables = @voucherPayableToProcess
				,@voucherPayableTax = DEFAULT
				,@userId = @intEntityUserSecurityId
				,@throwError = 1
				,@error = @strErrorMessage OUTPUT
				,@createdVouchersId = @createVoucherIds OUTPUT

			SET @xmlVoucherIds = CAST('<A>'+ REPLACE(@createVoucherIds, ',', '</A><A>')+ '</A>' AS XML)

			INSERT INTO @voucherIds 
				(intBillId) 
			SELECT 
				RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
			FROM @xmlVoucherIds.nodes('/A') AS X(T) 
			WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

			SELECT TOP 1 @intBillId = intBillId FROM @voucherIds

			UPDATE tblLGLoadWarehouseServices
			SET intBillId = @intBillId
			WHERE intLoadWarehouseServicesId IN (
					SELECT intWarehouseServicesId
					FROM @voucherDetailData
					WHERE ysnInventoryCost = 1)

			DELETE FROM @voucherPayableToProcess
			DELETE FROM @voucherIds
		END
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH
