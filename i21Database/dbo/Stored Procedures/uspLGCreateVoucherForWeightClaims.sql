CREATE PROCEDURE uspLGCreateVoucherForWeightClaims
	 @intWeightClaimId INT
	,@intEntityUserSecurityId INT
	,@strBillId NVARCHAR(100) = '' OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(4000);
	DECLARE @intErrorSeverity INT;
	DECLARE @intErrorState INT;
	DECLARE @total AS INT
	DECLARE @intVendorEntityId AS INT;
	DECLARE @intMinRecord AS INT
	DECLARE @voucherPayableToProcess AS VoucherPayable
	DECLARE @intAPAccount INT
	DECLARE @strWeightClaimNo NVARCHAR(100)
	DECLARE @intWeightClaimDetailId INT
	DECLARE @intCount INT
	DECLARE @intLoadId INT
	DECLARE @dblClaimAmount NUMERIC(18,6)
	DECLARE @dblNetWeight NUMERIC(18,6)
	DECLARE @intBillId INT
	DECLARE @intVoucherType INT

	DECLARE @voucherDetailData TABLE 
		(intWeightClaimRecordId INT Identity(1, 1)
		,intWeightClaimId INT
		,strReferenceNumber NVARCHAR(MAX)
		,intWeightClaimDetailId INT
		,intPartyEntityId INT
		,dblNetShippedWeight DECIMAL(18, 6)
		,dblWeightLoss DECIMAL(18, 6)
		,dblNetWeight DECIMAL(18, 6) 
		,dblFranchiseWeight DECIMAL(18, 6)
		,dblQtyReceived DECIMAL(18, 6)
		,dblCost DECIMAL(18, 6)
		,dblCostUnitQty DECIMAL(18, 6)
		,intCostCurrencyId INT
		,dblWeightUnitQty DECIMAL(18, 6)
		,dblClaimAmount DECIMAL(18, 6)
		,dblUnitQty DECIMAL(18, 6)
		,intWeightUOMId INT
		,intUOMId INT
		,intCostUOMId INT
		,intItemId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,intCompanyLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		,dblFranchiseAmount DECIMAL(18, 6)
		,intCurrencyId INT
		,ysnSubCurrency BIT
		,intSubCurrencyCents INT)

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	IF EXISTS (SELECT TOP 1 1
			   FROM tblAPBill AB
			   JOIN tblLGWeightClaimDetail WCD ON WCD.intBillId = AB.intBillId
			   WHERE WCD.intWeightClaimId = @intWeightClaimId)
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(250)
		SELECT @ErrorMessage = 'Voucher was already created for ' + strReferenceNumber
		FROM tblLGWeightClaim
		WHERE intWeightClaimId = @intWeightClaimId

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

	SELECT TOP 1 @intAPAccount = (ISNULL(intAPAccount,0))
	FROM tblLGWeightClaim WC 
	JOIN (
		SELECT ISNULL(LD.intPCompanyLocationId, intSCompanyLocationId) intCompanyLocationId, L.intLoadId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		) t ON t.intLoadId = WC.intLoadId
	JOIN tblSMCompanyLocation CL ON t.intCompanyLocationId = CL.intCompanyLocationId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	IF @intAPAccount = 0
	BEGIN
		RAISERROR('Please configure ''AP Account'' for the company location.',16,1)
	END

	INSERT INTO @voucherDetailData (
		   intWeightClaimId
		  ,strReferenceNumber
		  ,intWeightClaimDetailId
		  ,intPartyEntityId
		  ,dblNetShippedWeight
		  ,dblWeightLoss
		  ,dblNetWeight
		  ,dblFranchiseWeight
		  ,dblQtyReceived
		  ,dblCost
		  ,dblCostUnitQty
		  ,intCostCurrencyId
		  ,dblWeightUnitQty
		  ,dblClaimAmount
		  ,dblUnitQty
		  ,intWeightUOMId
		  ,intUOMId
		  ,intCostUOMId
		  ,intItemId
		  ,intContractHeaderId
		  ,intContractDetailId
		  ,intCompanyLocationId
		  ,intSubLocationId
		  ,intStorageLocationId
		  ,dblFranchiseAmount
		  ,intCurrencyId
		  ,ysnSubCurrency
		  ,intSubCurrencyCents)
	/* Weight Claim Details */
	SELECT intWeightClaimId = WC.intWeightClaimId
		,strReferenceNumber = WC.strReferenceNumber
		,intWeightClaimDetailId = WCD.intWeightClaimDetailId
		,intPartyEntityId = WCD.intPartyEntityId
		,dblNetShippedWeight = WCD.dblFromNet
		,dblWeightLoss = ABS(WCD.dblWeightLoss)
		,dblNetWeight = WCD.dblToNet
		,dblFranchiseWeight = CASE WHEN WCD.dblWeightLoss > 0 THEN 0 ELSE WCD.dblFranchiseWt END
		,dblQtyReceived = (ABS(WCD.dblWeightLoss) - CASE WHEN WCD.dblWeightLoss > 0 THEN 0 ELSE WCD.dblFranchiseWt END)
		,dblCost = WCD.dblUnitPrice
		,dblCostUnitQty = ISNULL(IU.dblUnitQty,1)
		,intCostCurrencyId = CU.intCurrencyID
		,dblWeightUnitQty = ISNULL(ItemUOM.dblUnitQty,1)
		,dblClaimAmount
		,dblUnitQty = ISNULL(ItemUOM.dblUnitQty,1)
		,intWeightUOMId = ItemUOM.intItemUOMId
		,intUOMId = ItemUOM.intItemUOMId
		,intCostUOMId = WCD.intPriceItemUOMId
		,intItemId = WCD.intItemId
		,intContractHeaderId = CH.intContractHeaderId
		,intContractDetailId = WCD.intContractDetailId
		,intCompanyLocationId = CD.intCompanyLocationId
		,intSubLocationId = CD.intSubLocationId
		,intStorageLocationId = CD.intStorageLocationId
		,dblFranchiseAmount = ROUND(
			(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM.intItemUOMId, WCD.intPriceItemUOMId, dblUnitPrice) * dblFranchiseWt)
			/ CASE WHEN (CU.ysnSubCurrency = 1) THEN 100 ELSE 1 END, 2)
		,intCurrencyId = ISNULL(CU.intMainCurrencyId, CU.intCurrencyID)
		,ysnSubCurrency = CU.ysnSubCurrency
		,intSubCurrencyCents = CU.intCent
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
	JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
	OUTER APPLY (SELECT TOP 1 
					intItemUOMId = IU.intItemUOMId
					,dblUnitQty = IU.dblUnitQty
				FROM tblICItemUOM IU
				WHERE IU.intItemId = WCD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) ItemUOM
	WHERE WC.intWeightClaimId = @intWeightClaimId
		AND ISNULL(WCD.ysnNoClaim, 0) = 0
		AND ISNULL(WCD.dblClaimAmount, 0) > 0
	UNION
	/* Missing/Damaged/Reconditioned */
	SELECT intWeightClaimId = WC.intWeightClaimId
		,strReferenceNumber = WC.strReferenceNumber
		,intWeightClaimDetailId = NULL
		,intPartyEntityId = WCOC.intVendorId
		,dblNetShippedWeight = ROUND(WCOC.dblWeight,2)
		,dblWeightLoss = ROUND(ABS(WCOC.dblWeight),2)
		,dblNetWeight = ROUND(ABS(WCOC.dblWeight),2)
		,dblFranchiseWeight = 0
		,dblQtyReceived = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN WCOC.dblQuantity ELSE 1 END
		,dblCost = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN WCOC.dblRate ELSE WCOC.dblAmount END
		,dblCostUnitQty = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN ISNULL(CostUOM.dblUnitQty,1) ELSE 1 END
		,intCostCurrencyId = CU.intCurrencyID
		,dblWeightUnitQty = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN ISNULL(DamageWeightUOM.dblUnitQty,1) ELSE 1 END
		,dblClaimAmount = WCOC.dblAmount
		,dblUnitQty = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN ISNULL(ItemUOM.dblUnitQty,1) ELSE 1 END
		,intWeightUOMId = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN DamageWeightUOM.intItemUOMId ELSE NULL END
		,intUOMId = WCOC.intItemUOMId 
		,intCostUOMId = CASE WHEN (WCOC.strCostMethod = 'Per Unit') THEN WCOC.intRateUOMId ELSE WCD.intDamageToPriceItemUOMId END
		,intItemId = WCOC.intItemId
		,intContractHeaderId = NULL
		,intContractDetailId = NULL
		,intCompanyLocationId = WCD.intCompanyLocationId
		,intSubLocationId = NULL
		,intStorageLocationId = NULL
		,dblFranchiseAmount = 0
		,intCurrencyId = ISNULL(CU.intMainCurrencyId, CU.intCurrencyID)
		,ysnSubCurrency = CU.ysnSubCurrency
		,intSubCurrencyCents = CU.intCent
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimOtherCharges WCOC ON WCOC.intWeightClaimId = WC.intWeightClaimId
	JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = WCOC.intRateUOMId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCOC.intRateCurrencyId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = WCOC.intItemUOMId
	OUTER APPLY (SELECT TOP 1 
					intItemUOMId = IU.intItemUOMId
					,dblUnitQty = IU.dblUnitQty
				FROM tblICItemUOM IU
				WHERE IU.intItemId = WCOC.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) DamageWeightUOM
	OUTER APPLY (SELECT TOP 1
					intCompanyLocationId = CD.intCompanyLocationId
					,intPriceItemUOMId = WCD.intPriceItemUOMId
					,intDamageToPriceItemUOMId = IU2.intItemUOMId
				FROM tblLGWeightClaimDetail WCD
					INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
					INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
					INNER JOIN tblICItemUOM IU2 ON IU.intUnitMeasureId = IU.intUnitMeasureId AND IU2.intItemId = WCOC.intItemId
				WHERE WCD.intWeightClaimId = WC.intWeightClaimId
					AND ISNULL(WCD.dblClaimAmount, 0) <> 0) WCD
	WHERE WC.intWeightClaimId = @intWeightClaimId

	SELECT @intVoucherType = CASE 
							 WHEN WCD.dblWeightLoss < 0
								THEN 11
							 ELSE 1 END
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	INSERT INTO @distinctVendor
	SELECT DISTINCT intPartyEntityId
	FROM @voucherDetailData

	SELECT @total = COUNT(*)
	FROM @voucherDetailData;

	IF (@total = 0)
	BEGIN
		RAISERROR ('Voucher cannot be created if claim amount is zero or ''No Claim'' is ticked.',11,1);
		RETURN;
	END

	SELECT @intMinRecord = MIN(intRecordId) FROM @distinctVendor

	DECLARE @xmlVoucherIds XML
	DECLARE @createVoucherIds NVARCHAR(MAX)
	DECLARE @voucherIds AS Id

	WHILE ISNULL(@intMinRecord, 0) <> 0
	BEGIN
		SET @intVendorEntityId = NULL
		SET @intWeightClaimDetailId = NULL
		SET @dblClaimAmount = NULL

		SELECT @intVendorEntityId = intVendorEntityId
		FROM @distinctVendor
		WHERE intRecordId = @intMinRecord

		SELECT @intCount = COUNT(*) FROM @voucherDetailData WHERE intPartyEntityId = @intVendorEntityId

		SELECT @intWeightClaimDetailId = intWeightClaimDetailId,
			   @dblClaimAmount = dblClaimAmount,
			   @dblNetWeight = dblNetWeight
		FROM @voucherDetailData 
		WHERE intPartyEntityId = @intVendorEntityId

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
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
			,[strLoadShipmentNumber]
			,[strBillOfLading]
			,[intWeightClaimId]
			,[intWeightClaimDetailId]
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
			,[dblNetShippedWeight]
			,[dblWeightLoss]		
			,[dblFranchiseWeight]
			,[dblFranchiseAmount]	
			,[dblWeightUnitQty]
			,[intWeightUOMId]
			,[intCostCurrencyId]
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[ysnReturn]
			,[ysnStage]
			,[intSubLocationId]
			,[intStorageLocationId])
		SELECT
			[intEntityVendorId] = VDD.intPartyEntityId
			,[intTransactionType] = @intVoucherType
			,[intLocationId] = VDD.intCompanyLocationId
			,[intCurrencyId] = VDD.intCurrencyId
			,[dtmDate] = GETDATE()
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(WC.strReferenceNumber)
			,[intContractHeaderId] = VDD.intContractHeaderId
			,[intContractDetailId] = VDD.intContractDetailId
			,[intContractSeqId] = CD.intContractSeq
			,[intLoadShipmentId] = WC.intLoadId
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[strLoadShipmentNumber] = LTRIM(L.strLoadNumber)
			,[strBillOfLading] = L.strBLNumber
			,[intWeightClaimId] = VDD.intWeightClaimId
			,[intWeightClaimDetailId] = VDD.intWeightClaimDetailId
			,[intItemId] = VDD.intItemId
			,[strMiscDescription] = I.strDescription
			,[dblOrderQty] = VDD.dblQtyReceived
			,[dblOrderUnitQty] = VDD.dblUnitQty
			,[intOrderUOMId] = VDD.intUOMId
			,[dblQuantityToBill] = VDD.dblQtyReceived
			,[dblQtyToBillUnitQty] = VDD.dblUnitQty
			,[intQtyToBillUOMId] = VDD.intUOMId
			,[dblCost] = VDD.dblCost
			,[dblCostUnitQty] = VDD.dblCostUnitQty
			,[intCostUOMId] = VDD.intCostUOMId
			,[dblNetWeight] = VDD.dblNetWeight
			,[dblNetShippedWeight] = VDD.dblNetShippedWeight
			,[dblWeightLoss] = VDD.dblWeightLoss
			,[dblFranchiseWeight] = VDD.dblFranchiseWeight
			,[dblFranchiseAmount] = VDD.dblFranchiseAmount
			,[dblWeightUnitQty] = VDD.dblWeightUnitQty
			,[intWeightUOMId] = VDD.intWeightUOMId
			,[intCostCurrencyId] = VDD.intCostCurrencyId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] = VDD.ysnSubCurrency
			,[intSubCurrencyCents] = VDD.intSubCurrencyCents
			,[intAccountId] = CASE WHEN (VDD.intContractDetailId IS NULL) 
								THEN (SELECT TOP 1 intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory = 'AP Clearing') 
								ELSE V.intGLAccountExpenseId END
			,[ysnReturn] = CAST(CASE WHEN (@intVoucherType = 11) THEN 1 ELSE 0 END AS BIT)
			,[ysnStage] = CAST(0 AS BIT)
			,[intSubLocationId] = VDD.intSubLocationId
			,[intStorageLocationId] = VDD.intStorageLocationId
		FROM @voucherDetailData VDD
			INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
			LEFT JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = VDD.intWeightClaimId
			LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimDetailId = VDD.intWeightClaimDetailId
			LEFT JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
			LEFT JOIN tblAPVendor V ON VDD.intPartyEntityId = V.intEntityId
			OUTER APPLY (SELECT TOP 1 ld.intLoadDetailId FROM tblLGLoadDetail ld 
						 LEFT JOIN tblLGLoadDetailContainerLink ldcl on ldcl.intLoadDetailId = ld.intLoadDetailId
						 WHERE ld.intLoadId = L.intLoadId 
							AND (WCD.intLoadContainerId IS NULL 
							 OR (WCD.intLoadContainerId IS NOT NULL AND WCD.intLoadContainerId = ldcl.intLoadContainerId))) LD
		WHERE VDD.intPartyEntityId = @intVendorEntityId

		EXEC uspAPCreateVoucher 
			@voucherPayables = @voucherPayableToProcess
			,@voucherPayableTax = DEFAULT
			,@userId = @intEntityUserSecurityId
			,@throwError = 1
			,@error = @strErrorMessage OUTPUT
			,@createdVouchersId = @createVoucherIds OUTPUT
	
		SET @xmlVoucherIds = CAST('<A>'+ REPLACE(@createVoucherIds, ',', '</A><A>')+ '</A>' AS XML)

		INSERT INTO @voucherIds 
			(intId) 
		SELECT 
			RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
		FROM @xmlVoucherIds.nodes('/A') AS X(T) 
		WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

		SELECT TOP 1 @intBillId = intId FROM @voucherIds

		IF (@total = @intCount)
		BEGIN
			UPDATE tblLGWeightClaimDetail
			SET intBillId = @intBillId
			WHERE intWeightClaimId = @intWeightClaimId AND intContractDetailId IS NOT NULL
		END
		ELSE 
		BEGIN
			UPDATE tblLGWeightClaimDetail
			SET intBillId = @intBillId
			WHERE intWeightClaimDetailId = @intWeightClaimDetailId
		END

		EXEC uspAPUpdateVoucherTotal @voucherIds

		IF (ISNULL(@intWeightClaimDetailId,0) <> 0)
			SET @strBillId = ISNULL(@strBillId,'') + CONVERT(NVARCHAR,ISNULL(@intBillId,0))

		DELETE FROM @voucherPayableToProcess
		DELETE FROM @voucherIds

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH