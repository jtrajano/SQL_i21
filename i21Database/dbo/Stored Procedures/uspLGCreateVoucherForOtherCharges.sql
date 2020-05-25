CREATE PROCEDURE uspLGCreateVoucherForOtherCharges 
	 @intLoadId INT
	,@strLoadCostIds NVARCHAR(MAX)
	,@intEntityUserSecurityId INT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX);
	DECLARE @total AS INT
	DECLARE @intVendorEntityId AS INT;
	DECLARE @intMinRecord AS INT
	DECLARE @intMinInventoryReceiptId AS INT
	DECLARE @intMinItemRecordId AS INT
	DECLARE @intBillId AS INT
	DECLARE @VoucherDetailLoadNonInvAll AS VoucherDetailLoadNonInv
	DECLARE @VoucherDetailLoadNonInv AS VoucherDetailLoadNonInv
	DECLARE @voucherDetailReceipt AS VoucherDetailReceipt
	DECLARE @voucherDetailReceiptCharge AS VoucherDetailReceiptCharge
	DECLARE @voucherPayable AS VoucherPayable
	DECLARE @voucherPayableToProcess AS VoucherPayable
	DECLARE @intItemId INT
	DECLARE @ysnInventoryCost BIT
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intMinVendorRecordId INT
	DECLARE @intReceiptCount INT
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT
	DECLARE @xmlLoadCosts XML

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
		,intLoadCostId INT
		,ysnInventoryCost BIT
		,intItemUOMId INT
		,dblUnitQty DECIMAL(38,20)
		,dblCostUnitQty DECIMAL(38,20)
		,intCurrencyId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		)
	DECLARE @loadCosts TABLE (
		intRecordId INT Identity(1, 1)
		,intLoadCostId INT
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
		,intEntityVendorId INT
		)

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @xmlLoadCosts = CAST('<A>'+ REPLACE(@strLoadCostIds, ',', '</A><A>')+ '</A>' AS XML)

	INSERT @loadCosts (intLoadCostId)
	SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intLoadCostId
	FROM @xmlLoadCosts.nodes('/A') AS X(T) 
	WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0 
	OPTION (OPTIMIZE FOR ( @xmlLoadCosts = NULL ))

	INSERT INTO @receiptData
	SELECT IR.intInventoryReceiptId
		,IR.strReceiptNumber
		,IRI.intInventoryReceiptItemId
		,IR.intSourceType
		,CD.dblSeqPrice
		,IR.intEntityVendorId
	FROM tblICInventoryReceipt IR
	JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId
	JOIN vyuLGAdditionalColumnForContractDetailView CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblICInventoryReceiptCharge IRC ON IR.intInventoryReceiptId = IRC.intInventoryReceiptId AND IRC.intContractDetailId = CD.intContractDetailId
	JOIN tblLGLoadCost LC ON LC.intItemId = IRC.intChargeId AND LC.intLoadId = @intLoadId
	WHERE LD.intLoadId = @intLoadId
		AND IR.ysnPosted = 1
		AND IR.intSourceType = 2

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblLGLoadCost WHERE intLoadId = @intLoadId AND intBillId IS NULL 
			AND (intLoadCostId IN (SELECT intLoadCostId FROM @loadCosts) OR NOT EXISTS (SELECT TOP 1 1 FROM @loadCosts)))
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = CASE WHEN EXISTS(SELECT TOP 1 1 FROM @loadCosts) THEN
								'Vouchers were already created for the selected other charges.'
								ELSE 
								'Vouchers were already created for all other charges in ' + @strLoadNumber
							END;

		RAISERROR (@ErrorMessage,16,1);
	END

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
	WHERE L.intLoadId = @intLoadId

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

	EXEC uspLGRecalculateLoadCosts @intLoadId, @intEntityUserSecurityId

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
		,intLoadCostId
		,ysnInventoryCost
		,intItemUOMId
		,dblUnitQty
		,dblCostUnitQty
		,intCurrencyId
		,intSubLocationId
		,intStorageLocationId
		)
	SELECT 
		intVendorEntityId = V.intEntityVendorId
		,intLoadId = LD.intLoadId
		,intLoadDetailId = LD.intLoadDetailId
		,intContractHeaderId = CH.intContractHeaderId
		,intContractDetailId = CD.intContractDetailId
		,intItemId = V.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](V.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
		,dblCost = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN ISNULL(V.dblTotal, V.dblPrice) ELSE ISNULL(V.dblPrice, V.dblTotal) END 
		,intCostUOMId = V.intPriceItemUOMId
		,intLoadCostId = V.intLoadCostId
		,ysnInventoryCost = I.ysnInventoryCost
		,intItemUOMId = V.intItemUOMId
		,dblUnitQty = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
		,dblCostUnitQty = CASE WHEN V.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(CostUOM.dblUnitQty,1) END
		,intCurrencyId = V.intCurrencyId
		,intSubLocationId = NULL
		,intStorageLocationId = NULL
	FROM vyuLGLoadCostForVendor V
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN ISNULL(LD.intPContractDetailId, 0) = 0
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	JOIN tblICItem I ON I.intItemId = V.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = V.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = V.intPriceItemUOMId
	WHERE V.intLoadId = @intLoadId AND V.intBillId IS NULL
		AND ((V.intLoadCostId IN (SELECT intLoadCostId FROM @loadCosts)) OR (NOT EXISTS (SELECT TOP 1 1 FROM @loadCosts))) 
	GROUP BY V.intEntityVendorId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,ItemLoc.intItemLocationId
		,V.intItemId
		,V.intLoadId
		,V.strLoadNumber
		,V.dblNet
		,LD.intLoadId
		,LD.intLoadDetailId
		,V.intLoadCostId
		,I.ysnInventoryCost
		,V.intItemUOMId
		,V.intPriceItemUOMId
		,ItemUOM.dblUnitQty
		,CostUOM.dblUnitQty
		,LD.dblQuantity
		,V.strCostMethod
		,V.dblPrice
		,V.dblTotal
		,V.intCurrencyId
		,V.intSubLocationId
		,V.intStorageLocationId

	INSERT INTO @distinctVendor
	SELECT DISTINCT intVendorEntityId
	FROM @voucherDetailData

	SELECT @intAPClearingAccountId = APAccount
	FROM (
		SELECT [dbo].[fnGetItemGLAccount](LC.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') APAccount
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN L.intPurchaseSale = 2
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
			AND ItemLoc.intLocationId = CD.intCompanyLocationId
		LEFT JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId
		WHERE L.intLoadId = @intLoadId
		) tb
	WHERE APAccount IS NULL

	IF(ISNULL(@intAPClearingAccountId,0)>0)
	BEGIN
		RAISERROR ('''AP Clearing'' is not configured for one or more item(s).',11,1);
	END

	SELECT @intReceiptCount = COUNT(*) FROM @receiptData 

	DECLARE @xmlVoucherIds XML
	DECLARE @createVoucherIds NVARCHAR(MAX)
	DECLARE @voucherIds TABLE (intBillId INT)

	IF(@intReceiptCount = 0)
	BEGIN
		-- LOOP THROUGH EACH VENDOR AVAILABLE IN THE OTHER CHARGES
		SELECT @intMinVendorRecordId = MIN(intRecordId)
		FROM @distinctVendor

		WHILE (ISNULL(@intMinVendorRecordId, 0) > 0)
		BEGIN
			SET @intVendorEntityId = NULL
			DELETE FROM @VoucherDetailLoadNonInv

			SELECT @intVendorEntityId = intVendorEntityId
			FROM @distinctVendor
			WHERE intRecordId = @intMinVendorRecordId

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
				[intEntityVendorId] = VDD.intVendorEntityId
				,[intTransactionType] = 1
				,[intLocationId] = CD.intCompanyLocationId
				,[intCurrencyId] = VDD.intCurrencyId
				,[dtmDate] = GETDATE()
				,[strVendorOrderNumber] = ''
				,[strReference] = ''
				,[strSourceNumber] = LTRIM(L.strLoadNumber)
				,[intContractHeaderId] = VDD.intContractHeaderId
				,[intContractDetailId] = VDD.intContractDetailId
				,[intContractSeqId] = CD.intContractSeq
				,[intContractCostId] = CTC.intContractCostId
				,[intInventoryReceiptItemId] = NULL
				,[intLoadShipmentId] = VDD.intLoadId
				,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
				,[intLoadShipmentDetailId] = VDD.intLoadDetailId
				,[intLoadShipmentCostId] = VDD.intLoadCostId
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
				,[intCostCurrencyId] = VDD.intCurrencyId
				,[dblTax] = 0
				,[dblDiscount] = 0
				,[dblExchangeRate] = 1
				,[ysnSubCurrency] = CUR.ysnSubCurrency
				,[intSubCurrencyCents] = CUR.intCent
				,[intAccountId] = VDD.intAccountId
				,[strBillOfLading] = L.strBLNumber
				,[ysnReturn] = CAST(0 AS BIT)
				,[ysnStage] = CAST(CASE WHEN (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL) THEN 0 ELSE 1 END AS BIT)
				,[intSubLocationId] = VDD.intSubLocationId
				,[intStorageLocationId] = VDD.intStorageLocationId
			FROM @voucherDetailData VDD
				INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
				INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
				INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
				LEFT JOIN tblSMCurrency CUR ON VDD.intCurrencyId = CUR.intCurrencyID
				OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC
				OUTER APPLY (SELECT TOP 1 CTC.intContractCostId FROM tblCTContractCost CTC
						WHERE CD.intContractDetailId = CTC.intContractDetailId
							AND VDD.intItemId = CTC.intItemId
							AND VDD.intVendorEntityId = CTC.intVendorId
						) CTC
			WHERE VDD.intVendorEntityId = @intVendorEntityId

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

			UPDATE tblLGLoadCost
			SET intBillId = @intBillId
			WHERE intLoadCostId IN (
					SELECT intLoadCostId
					FROM @voucherDetailData
					WHERE intVendorEntityId = @intVendorEntityId)

			SELECT @intMinVendorRecordId = MIN(intRecordId)
			FROM @distinctVendor
			WHERE intRecordId > @intMinVendorRecordId

			DELETE FROM @voucherPayableToProcess
			DELETE FROM @voucherIds
		END
	END
	ELSE 
	BEGIN
		-- LOOP THROUGH EACH VENDOR AVAILABLE IN THE OTHER CHARGES
		SELECT @intMinVendorRecordId = MIN(intRecordId)
		FROM @distinctVendor

		WHILE (ISNULL(@intMinVendorRecordId, 0) > 0)
		BEGIN
			SET @intVendorEntityId = NULL
			SET @ysnInventoryCost = NULL

			DELETE FROM @VoucherDetailLoadNonInv
			DELETE FROM @voucherDetailReceiptCharge

			SELECT @intVendorEntityId = intVendorEntityId
			FROM @distinctVendor
			WHERE intRecordId = @intMinVendorRecordId
			
			IF EXISTS (SELECT TOP 1 1
					FROM @voucherDetailData
					WHERE intVendorEntityId = @intVendorEntityId
						AND ysnInventoryCost = 0)
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
					[intEntityVendorId] = VDD.intVendorEntityId
					,[intTransactionType] = 1
					,[intLocationId] = CD.intCompanyLocationId
					,[intCurrencyId] = VDD.intCurrencyId
					,[dtmDate] = GETDATE()
					,[strVendorOrderNumber] = ''
					,[strReference] = ''
					,[strSourceNumber] = LTRIM(L.strLoadNumber)
					,[intContractHeaderId] = VDD.intContractHeaderId
					,[intContractDetailId] = VDD.intContractDetailId
					,[intContractSeqId] = CD.intContractSeq
					,[intContractCostId] = CTC.intContractCostId
					,[intInventoryReceiptItemId] = NULL
					,[intLoadShipmentId] = VDD.intLoadId
					,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
					,[intLoadShipmentDetailId] = VDD.intLoadDetailId
					,[intLoadShipmentCostId] = VDD.intLoadCostId
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
					,[intCostCurrencyId] = VDD.intCurrencyId
					,[dblTax] = 0
					,[dblDiscount] = 0
					,[dblExchangeRate] = 1
					,[ysnSubCurrency] = CUR.ysnSubCurrency
					,[intSubCurrencyCents] = CUR.intCent
					,[intAccountId] = VDD.intAccountId
					,[strBillOfLading] = L.strBLNumber
					,[ysnReturn] = CAST(0 AS BIT)
					,[ysnStage] = CAST(CASE WHEN (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL) THEN 0 ELSE 1 END AS BIT)
					,[intSubLocationId] = VDD.intSubLocationId
					,[intStorageLocationId] = VDD.intStorageLocationId
				FROM @voucherDetailData VDD
					INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
					INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
					INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
					LEFT JOIN tblSMCurrency CUR ON VDD.intCurrencyId = CUR.intCurrencyID
					OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC
					OUTER APPLY (SELECT TOP 1 CTC.intContractCostId FROM tblCTContractCost CTC
						WHERE CD.intContractDetailId = CTC.intContractDetailId
							AND VDD.intItemId = CTC.intItemId
							AND VDD.intVendorEntityId = CTC.intVendorId
						) CTC
				WHERE VDD.intVendorEntityId = @intVendorEntityId AND VDD.ysnInventoryCost = 0
			
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

				UPDATE tblLGLoadCost
				SET intBillId = @intBillId
				WHERE intLoadCostId IN (
						SELECT intLoadCostId
						FROM @voucherDetailData
						WHERE intVendorEntityId = @intVendorEntityId
							AND ysnInventoryCost = 0)

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
					,[intContractCostId]
					,[intInventoryReceiptItemId]
					,[intInventoryReceiptChargeId]
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
					[intEntityVendorId] = VDD.intVendorEntityId
					,[intTransactionType] = 1
					,[intLocationId] = CD.intCompanyLocationId
					,[intCurrencyId] = VDD.intCurrencyId
					,[dtmDate] = GETDATE()
					,[strVendorOrderNumber] = ''
					,[strReference] = ''
					,[strSourceNumber] = LTRIM(L.strLoadNumber)
					,[intContractHeaderId] = VDD.intContractHeaderId
					,[intContractDetailId] = VDD.intContractDetailId
					,[intContractSeqId] = CD.intContractSeq
					,[intContractCostId] = CTC.intContractCostId
					,[intInventoryReceiptItemId] = NULL
					,[intInventoryReceiptChargeId] = IRC.intInventoryReceiptChargeId
					,[intLoadShipmentId] = VDD.intLoadId
					,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
					,[intLoadShipmentDetailId] = VDD.intLoadDetailId
					,[intLoadShipmentCostId] = VDD.intLoadCostId
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
					,[intCostCurrencyId] = VDD.intCurrencyId
					,[dblTax] = 0
					,[dblDiscount] = 0
					,[dblExchangeRate] = 1
					,[ysnSubCurrency] = CUR.ysnSubCurrency
					,[intSubCurrencyCents] = CUR.intCent
					,[intAccountId] = VDD.intAccountId
					,[strBillOfLading] = L.strBLNumber
					,[ysnReturn] = CAST(0 AS BIT)
					,[ysnStage] = CAST(CASE WHEN (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL) THEN 0 ELSE 1 END AS BIT)
					,[intSubLocationId] = VDD.intSubLocationId
					,[intStorageLocationId] = VDD.intStorageLocationId
				FROM @voucherDetailData VDD
					INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
					INNER JOIN tblLGLoad L on VDD.intLoadId = L.intLoadId
					INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
					LEFT JOIN tblSMCurrency CUR ON VDD.intCurrencyId = CUR.intCurrencyID
					CROSS APPLY (SELECT intInventoryReceiptChargeId, dblQuantity
									FROM tblICInventoryReceiptCharge C
									WHERE intInventoryReceiptId = @intMinInventoryReceiptId
										AND ysnInventoryCost = 1
										AND intChargeId = VDD.intItemId) IRC
					OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC
					OUTER APPLY (SELECT TOP 1 CTC.intContractCostId FROM tblCTContractCost CTC
						WHERE CD.intContractDetailId = CTC.intContractDetailId
							AND VDD.intItemId = CTC.intItemId
							AND VDD.intVendorEntityId = CTC.intVendorId
						) CTC
				WHERE VDD.intVendorEntityId = @intVendorEntityId AND VDD.ysnInventoryCost = 1
			
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

				UPDATE tblLGLoadCost
				SET intBillId = @intBillId
				WHERE intLoadCostId IN (
						SELECT intLoadCostId
						FROM @voucherDetailData
						WHERE intVendorEntityId = @intVendorEntityId
							AND ysnInventoryCost = 1)

				DELETE FROM @voucherPayableToProcess
				DELETE FROM @voucherIds
			END

			SELECT @intMinVendorRecordId = MIN(intRecordId)
			FROM @distinctVendor
			WHERE intRecordId > @intMinVendorRecordId						
		END
	END

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH