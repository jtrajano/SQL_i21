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
		,intContractDetailId INT)

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

	SELECT @intAPAccount = ISNULL(intAPAccount,0)
	FROM tblLGWeightClaim WC 
	JOIN (
		SELECT TOP 1 ISNULL(LD.intPCompanyLocationId, intSCompanyLocationId) intCompanyLocationId, L.intLoadId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		) t ON t.intLoadId = WC.intLoadId
	JOIN tblSMCompanyLocation CL ON t.intCompanyLocationId = CL.intCompanyLocationId
	WHERE WC.intWeightClaimId = 1

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
		  ,intContractDetailId)
	SELECT WC.intWeightClaimId
		,WC.strReferenceNumber
		,WCD.intWeightClaimDetailId
		,WCD.intPartyEntityId
		,WCD.dblFromNet AS dblNetShippedWeight
		,WCD.dblWeightLoss AS dblWeightLoss
		,WCD.dblWeightLoss AS dblNetWeight
		,WCD.dblFranchiseWt AS dblFranchiseWeight
		,(WCD.dblWeightLoss - WCD.dblFranchiseWt) AS dblQtyReceived
		--,CASE 
		--	WHEN AD.ysnSeqSubCurrency = 1
		--		THEN dbo.fnCTConvertQtyToTargetItemUOM((
		--					SELECT TOP (1) IU.intItemUOMId
		--					FROM tblICItemUOM IU
		--					WHERE IU.intItemId = CD.intItemId
		--						AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
		--					), AD.intSeqPriceUOMId, AD.dblSeqPrice) / 100
		--	ELSE dbo.fnCTConvertQtyToTargetItemUOM((
		--				SELECT TOP (1) IU.intItemUOMId
		--				FROM tblICItemUOM IU
		--				WHERE IU.intItemId = CD.intItemId
		--					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
		--				), AD.intSeqPriceUOMId, AD.dblSeqPrice)
		--	END AS dblCost
		,AD.dblSeqPrice
		,1 AS dblCostUnitQty
		,1 AS dblWeightUnitQty
		,dblClaimAmount 
		,1 AS dblUnitQty
		,(SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
		 ) AS intWeightUOMId
		,(SELECT TOP (1) IU.intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = CD.intItemId
				AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
		 ) AS intUOMId
		,WCD.intPriceItemUOMId AS intCostUOMId
		,WCD.intItemId
		,CH.intContractHeaderId
		,NULL AS intInventoryReceiptItemId
		,WCD.intContractDetailId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblLGLoad LOAD ON LOAD.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE WC.intWeightClaimId = @intWeightClaimId
		AND ISNULL(WCD.ysnNoClaim, 0) = 0
		AND ISNULL(WCD.dblClaimAmount,0) > 0

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
			,intContractDetailId)
		SELECT dblNetShippedWeight
			,dblWeightLoss
			,dblFranchiseWeight
			,(dblWeightLoss-dblFranchiseWeight)
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
		FROM @voucherDetailData
		WHERE intPartyEntityId = @intVendorEntityId

		EXEC uspAPCreateBillData 
			 @userId = @intEntityUserSecurityId
			,@vendorId = @intVendorEntityId
			,@voucherDetailClaim = @VoucherDetailClaim
			,@type = 11
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
		,intAccountId = IA.intAccountId
	FROM tblAPBill B
	JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
	JOIN tblLGLoad LD ON LD.intLoadId = BD.intLoadId
	JOIN tblLGWeightClaim WC ON WC.intLoadId = BD.intLoadId
	JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
	LEFT JOIN tblICItemAccount IA ON IA.intItemId = WCD.intItemId AND IA.intAccountCategoryId = 27
	WHERE WCD.intContractDetailId = BD.intContractDetailId
		AND WC.intWeightClaimId = @intWeightClaimId 

END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH