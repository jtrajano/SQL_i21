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
		,dblFranchiseAmount DECIMAL(18, 6))

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
		  ,dblFranchiseAmount)
	SELECT WC.intWeightClaimId
		,WC.strReferenceNumber
		,WCD.intWeightClaimDetailId
		,WCD.intPartyEntityId
		,WCD.dblFromNet AS dblNetShippedWeight
		,ABS(WCD.dblWeightLoss) AS dblWeightLoss
		,ABS(WCD.dblWeightLoss) AS dblNetWeight
		,CASE WHEN WCD.dblWeightLoss > 0 THEN 0 ELSE WCD.dblFranchiseWt END AS dblFranchiseWeight
		,(ABS(WCD.dblWeightLoss) - CASE WHEN WCD.dblWeightLoss > 0 THEN 0 ELSE WCD.dblFranchiseWt END) AS dblQtyReceived
		,WCD.dblUnitPrice
		,1 AS dblCostUnitQty
		,1 AS dblWeightUnitQty
		,dblClaimAmount
		,1 AS dblUnitQty
		,(
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			) AS intWeightUOMId
		,(
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			) AS intUOMId
		,WCD.intPriceItemUOMId AS intCostUOMId
		,WCD.intItemId
		,CH.intContractHeaderId
		,NULL AS intInventoryReceiptItemId
		,WCD.intContractDetailId
		,CASE 
		 WHEN CU.ysnSubCurrency = 1
			THEN (dblUnitPrice * dbo.fnCTConvertQuantityToTargetItemUOM(WCD.intItemId, LOAD.intWeightUnitMeasureId, IU.intUnitMeasureId, 1)) * dblFranchiseWt / 100
		 ELSE (dblUnitPrice * dbo.fnCTConvertQuantityToTargetItemUOM(WCD.intItemId, LOAD.intWeightUnitMeasureId, IU.intUnitMeasureId, 1)) * dblFranchiseWt
		 END
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
	WHERE WC.intWeightClaimId = @intWeightClaimId
		AND ISNULL(WCD.ysnNoClaim, 0) = 0
		AND ISNULL(WCD.dblClaimAmount, 0) > 0
	UNION
	SELECT WC.intWeightClaimId
		,WC.strReferenceNumber
		,NULL
		,WCOC.intVendorId
		,WCOC.dblQuantity AS dblNetShippedWeight
		,ABS(0) AS dblWeightLoss
		,ABS(WCOC.dblWeight) AS dblNetWeight
		,0 AS dblFranchiseWeight
		,WCOC.dblQuantity AS dblQtyReceived
		,WCOC.dblRate
		,1 AS dblCostUnitQty
		,1 AS dblWeightUnitQty
		,WCOC.dblAmount
		,1 AS dblUnitQty
		,(
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = WCOC.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			) AS intWeightUOMId
		,(
			SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = WCOC.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
			) AS intUOMId
		,WCOC.intRateUOMId AS intCostUOMId
		,WCOC.intItemId
		,NULL
		,NULL AS intInventoryReceiptItemId
		,NULL
		,0
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimOtherCharges WCOC ON WCOC.intWeightClaimId = WC.intWeightClaimId
	JOIN tblLGLoad LOAD ON LOAD.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WCOC.intRateUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblSMCurrency CU ON CU.intCurrencyID = WCOC.intRateCurrencyId
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

		INSERT INTO @VoucherDetailClaim (
			 dblNetShippedWeight
			,dblWeightLoss
			,dblFranchiseWeight
			,dblQtyReceived
			,dblCost
			,dblCostUnitQty
			,dblWeightUnitQty
			,dblUnitQty
			,intWeightUOMId
			,intUOMId
			,intCostUOMId
			,intItemId
			,intContractHeaderId
			,intInventoryReceiptItemId
			,intContractDetailId
			,dblFranchiseAmount)
		SELECT dblNetShippedWeight
			,dblWeightLoss
			,dblFranchiseWeight
			,(dblWeightLoss-ISNULL(dblFranchiseWeight,0))
			,dblCost
			,dblCostUnitQty
			,dblWeightUnitQty
			,dblUnitQty
			,intWeightUOMId
			,intUOMId
			,intCostUOMId
			,intItemId
			,intContractHeaderId
			,intInventoryReceiptItemId
			,intContractDetailId
			,dblFranchiseAmount
		FROM @voucherDetailData
		WHERE intPartyEntityId = @intVendorEntityId

		EXEC uspAPCreateBillData 
			 @userId = @intEntityUserSecurityId
			,@vendorId = @intVendorEntityId
			,@voucherDetailClaim = @VoucherDetailClaim
			,@type = @intVoucherType
			,@shipTo = @intShipTo
			,@billId = @intBillId OUTPUT
	
		IF (@total = @intCount)
		BEGIN
			UPDATE tblLGWeightClaimDetail
			SET intBillId = @intBillId
			WHERE intWeightClaimId = @intWeightClaimId

			UPDATE tblAPBillDetail
			SET intLoadId = @intLoadId,
				intCurrencyId = @intCurrencyId,
				ysnSubCurrency = @ysnSubCurrency,
				dblClaimAmount = @dblClaimAmount,
				dblTotal = @dblClaimAmount,
				dbl1099 = @dblClaimAmount,
				dblNetWeight = @dblNetWeight
			WHERE intBillId = @intBillId
		END
		ELSE 
		BEGIN
			UPDATE tblLGWeightClaimDetail
			SET intBillId = @intBillId
			WHERE intWeightClaimDetailId = @intWeightClaimDetailId
			
			UPDATE tblAPBillDetail
			SET intLoadId = @intLoadId,
				intCurrencyId = @intCurrencyId,
				ysnSubCurrency = @ysnSubCurrency,
				dblClaimAmount = @dblClaimAmount,
				dblTotal = @dblClaimAmount,
				dbl1099 = @dblClaimAmount,
				dblNetWeight = @dblNetWeight
			WHERE intBillId = @intBillId
		END

		DELETE
		FROM @VoucherDetailClaim

		IF (ISNULL(@intWeightClaimDetailId,0) <> 0)
			SET @strBillId = ISNULL(@strBillId,'') + CONVERT(NVARCHAR,ISNULL(@intBillId,0))

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END

	SELECT @dblTotalForBill = SUM(dblTotal)
		  ,@dblAmountDueForBill = SUM(dblClaimAmount)
	FROM tblAPBillDetail
	WHERE intBillId = @intBillId

	UPDATE tblAPBill
	SET dblTotal = @dblTotalForBill
	   ,dblAmountDue = @dblAmountDueForBill
	WHERE intBillId = @intBillId

	UPDATE BD
	SET intCurrencyId = WCD.intCurrencyId
		,ysnSubCurrency = 1
		,dblClaimAmount = WCD.dblClaimAmount
		,dblTotal = WCD.dblClaimAmount
		,dbl1099 = WCD.dblClaimAmount
		,dblNetWeight = WCD.dblToNet
		,intLoadId = WC.intLoadId
		,intAccountId = (SELECT TOP 1 intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory = 'AP Clearing')
	FROM tblAPBill B
	JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
	JOIN tblLGLoad LD ON LD.intLoadId = BD.intLoadId
	JOIN tblLGWeightClaim WC ON WC.intLoadId = BD.intLoadId
	JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
	WHERE WCD.intContractDetailId = BD.intContractDetailId
		AND WC.intWeightClaimId = @intWeightClaimId 

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH