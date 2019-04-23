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
	DECLARE @VoucherDetailClaim AS VoucherDetailClaim
	DECLARE @voucherPayableToProcess AS VoucherPayable
	DECLARE @intAPAccount INT
	DECLARE @strWeightClaimNo NVARCHAR(100)
	DECLARE @intWeightClaimDetailId INT
	DECLARE @intCount INT
	DECLARE @intLoadId INT
	DECLARE @intCurrencyId INT
	DECLARE @ysnSubCurrency BIT
	DECLARE @dblClaimAmount NUMERIC(18,6)
	DECLARE @dblNetWeight NUMERIC(18,6)
	DECLARE @dblTotalForBill NUMERIC(18,6)
	DECLARE @dblAmountDueForBill NUMERIC(18,6)
	DECLARE @intBillId INT
	DECLARE @intVoucherType INT
	DECLARE @intShipTo INT

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
		,dblWeightUnitQty DECIMAL(18, 6)
		,dblClaimAmount DECIMAL(18, 6)
		,dblUnitQty DECIMAL(18, 6)
		,intWeightUOMId INT
		,intUOMId INT
		,intCostUOMId INT
		,intItemId INT
		,intContractHeaderId INT
		,intInventoryReceiptItemId INT
		,intContractDetailId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		,dblFranchiseAmount DECIMAL(18, 6)
		,intCurrencyId INT)

	DECLARE @distinctVendor TABLE 
		(intRecordId INT Identity(1, 1)
		,intVendorEntityId INT)

	DECLARE @distinctItem TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intItemId INT)

	SELECT @strWeightClaimNo = strReferenceNumber
		,@intLoadId = intLoadId
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @intCurrencyId = intCurrencyId
	FROM tblLGWeightClaimDetail
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @ysnSubCurrency = ISNULL(ysnSubCurrency, 0)
	FROM tblSMCurrency
	WHERE intCurrencyID = @intCurrencyId

	IF EXISTS (SELECT TOP 1 1
			   FROM tblAPBill AB
			   JOIN tblLGWeightClaimDetail WCD ON WCD.intBillId = AB.intBillId
			   WHERE WCD.intWeightClaimId = @intWeightClaimId)
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = 'Voucher was already created for ' + @strWeightClaimNo;

		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END

	SELECT TOP 1 @intShipTo = CD.intCompanyLocationId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = ISNULL(LD.intPContractDetailId,LD.intSContractDetailId)
	WHERE L.intLoadId = @intLoadId

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
		  ,dblWeightUnitQty
		  ,dblClaimAmount
		  ,dblUnitQty
		  ,intWeightUOMId
		  ,intUOMId
		  ,intCostUOMId
		  ,intItemId
		  ,intContractHeaderId
		  ,intInventoryReceiptItemId
		  ,intContractDetailId
		  ,intSubLocationId
		  ,intStorageLocationId
		  ,dblFranchiseAmount
		  ,intCurrencyId)
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
		,dblWeightUnitQty = ISNULL(WeightItemUOM.dblUnitQty,1)
		,dblClaimAmount
		,dblUnitQty = ISNULL(WeightItemUOM.dblUnitQty,1)
		,intWeightUOMId = (
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			)
		,intUOMId = (
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			)
		,intCostUOMId = WCD.intPriceItemUOMId
		,intItemId = WCD.intItemId
		,intContractHeaderId = CH.intContractHeaderId
		,intInventoryReceiptItemId = NULL
		,intContractDetailId = WCD.intContractDetailId
		,intSubLocationId = CD.intSubLocationId
		,intStorageLocationId = CD.intStorageLocationId
		,dblFranchiseAmount = ROUND(CASE 
				 WHEN CU.ysnSubCurrency = 1
					THEN (dbo.fnCTConvertQtyToTargetItemUOM(
						(SELECT Top(1) IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId=CD.intItemId AND IU.intUnitMeasureId=WUOM.intUnitMeasureId),
						WCD.intPriceItemUOMId, dblUnitPrice)) * dblFranchiseWt / 100
				 ELSE (dbo.fnCTConvertQtyToTargetItemUOM(
						(SELECT Top(1) IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId=CD.intItemId AND IU.intUnitMeasureId=WUOM.intUnitMeasureId), 
						WCD.intPriceItemUOMId, dblUnitPrice)) * dblFranchiseWt
			   END, 2)
		,intCurrencyId = WCD.intCurrencyId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblLGLoad LOAD ON LOAD.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblSMCurrency CU ON CU.intCurrencyID = WCD.intCurrencyId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = WCD.intItemId AND ItemUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = CD.intNetWeightUOMId
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
		,dblQtyReceived = WCOC.dblQuantity
		,dblCost = WCOC.dblRate
		,dblCostUnitQty = ISNULL(IU.dblUnitQty,1)
		,dblWeightUnitQty = ISNULL(WeightItemUOM.dblUnitQty,1)
		,dblClaimAmount = WCOC.dblAmount
		,dblUnitQty = ISNULL(ItemUOM.dblUnitQty,1)
		,intWeightUOMId = (
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = WCOC.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			)
		,intUOMId = (
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = WCOC.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			)
		,intCostUOMId = WCOC.intRateUOMId
		,intItemId = WCOC.intItemId
		,intContractHeaderId = NULL
		,intInventoryReceiptItemId = NULL 
		,intContractDetailId = NULL
		,intSubLocationId = NULL
		,intStorageLocationId = NULL
		,dblFranchiseAmount = 0
		,intCurrencyId = WCOC.intRateCurrencyId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimOtherCharges WCOC ON WCOC.intWeightClaimId = WC.intWeightClaimId
	JOIN tblLGLoad LOAD ON LOAD.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = WCOC.intRateUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = WCOC.intRateCurrencyId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = WCOC.intItemUOMId
	LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = WCOC.intWeightUOMId
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

	INSERT INTO @distinctItem
	SELECT DISTINCT intItemId
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
	DECLARE @voucherIds TABLE (intBillId INT)

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
			,[intSubLocationId]
			,[intStorageLocationId])
		SELECT
			[intEntityVendorId] = VDD.intPartyEntityId
			,[intTransactionType] = @intVoucherType
			,[intLocationId] = CD.intCompanyLocationId
			,[intCurrencyId] = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)
			,[dtmDate] = GETDATE()
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(WC.strReferenceNumber)
			,[intContractHeaderId] = VDD.intContractHeaderId
			,[intContractDetailId] = VDD.intContractDetailId
			,[intContractSeqId] = CD.intContractSeq
			,[intLoadShipmentId] = WC.intLoadId
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
			,[intCostCurrencyId] = VDD.intCurrencyId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] = CUR.ysnSubCurrency
			,[intSubCurrencyCents] = CUR.intCent
			,[intAccountId] = CASE WHEN (VDD.intContractDetailId IS NULL) 
								THEN (SELECT TOP 1 intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory = 'AP Clearing') 
								ELSE V.intGLAccountExpenseId END
			,[ysnReturn] = CAST(0 AS BIT)
			,[intSubLocationId] = VDD.intSubLocationId
			,[intStorageLocationId] = VDD.intStorageLocationId
		FROM @voucherDetailData VDD
			INNER JOIN tblCTContractDetail CD ON VDD.intContractDetailId = CD.intContractDetailId
			INNER JOIN tblICItem I ON I.intItemId = VDD.intItemId
			LEFT JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = VDD.intWeightClaimId
			LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimDetailId = VDD.intWeightClaimDetailId
			LEFT JOIN tblSMCurrency CUR ON VDD.intCurrencyId = CUR.intCurrencyID
			LEFT JOIN tblAPVendor V ON VDD.intPartyEntityId = V.intEntityId
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
			(intBillId) 
		SELECT 
			RTRIM(LTRIM(T.value('.', 'INT'))) AS intBillId
		FROM @xmlVoucherIds.nodes('/A') AS X(T) 
		WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

		SELECT TOP 1 @intBillId = intBillId FROM @voucherIds

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