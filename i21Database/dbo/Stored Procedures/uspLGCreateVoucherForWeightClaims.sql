CREATE PROCEDURE uspLGCreateVoucherForWeightClaims
	 @intWeightClaimId INT
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
	DECLARE @VoucherDetailClaim AS VoucherDetailClaim
	DECLARE @intAPAccount INT
	DECLARE @strWeightClaimNo NVARCHAR(100)
	DECLARE @intWeightClaimDetailId INT
	DECLARE @intCount INT

	DECLARE @voucherDetailData TABLE 
		(intWeightClaimRecordId INT Identity(1, 1)
		,intWeightClaimId INT
		,strReferenceNumber NVARCHAR(MAX)
		,intWeightClaimDetailId INT
		,intPartyEntityId INT
		,dblNetShippedWeight DECIMAL(18, 6)
		,dblWeightLoss DECIMAL(18, 6)
		,dblFranchiseWeight DECIMAL(18, 6)
		,dblQtyReceived DECIMAL(18, 6)
		,dblCost DECIMAL(18, 6)
		,dblCostUnitQty DECIMAL(18, 6)
		,dblWeightUnitQty DECIMAL(18, 6)
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

	SELECT @strWeightClaimNo = strReferenceNumber FROM tblLGWeightClaim WHERE intWeightClaimId = @intWeightClaimId

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
	SELECT WC.intWeightClaimId
 		  ,WC.strReferenceNumber
		  ,WCD.intWeightClaimDetailId
		  ,WCD.intPartyEntityId
		  ,WCD.dblFromNet AS dblNetShippedWeight
		  ,WCD.dblWeightLoss AS dblWeightLoss
		  ,WCD.dblFranchiseWt AS dblFranchiseWeight
		  ,(WCD.dblWeightLoss-WCD.dblFranchiseWt) AS dblQtyReceived
		  ,WCD.dblUnitPrice AS dblCost
		  ,1 AS dblCostUnitQty
		  ,1 AS dblWeightUnitQty
		  ,1 AS dblUnitQty
		  ,WCD.intPriceItemUOMId AS intWeightUOMId
		  ,UM.intUnitMeasureId AS intUOMId
		  ,WCD.intPriceItemUOMId AS intCostUOMId
		  ,WCD.intItemId
		  ,CH.intContractHeaderId
		  ,NULL as intInventoryReceiptItemId
		  ,WCD.intContractDetailId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WCD.intPriceItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	INSERT INTO @distinctVendor
	SELECT DISTINCT intPartyEntityId
	FROM @voucherDetailData

	INSERT INTO @distinctItem
	SELECT DISTINCT intItemId
	FROM @voucherDetailData

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
	FROM @voucherDetailData;

	IF (@total = 0)
	BEGIN
		RAISERROR ('Bill process failure #1',11,1);
		RETURN;
	END

	SELECT @intMinRecord = MIN(intRecordId) FROM @distinctVendor

	WHILE ISNULL(@intMinRecord, 0) <> 0
	BEGIN
		SET @intVendorEntityId = NULL
		SET @intWeightClaimDetailId = NULL

		SELECT @intVendorEntityId = intVendorEntityId
		FROM @distinctVendor
		WHERE intRecordId = @intMinRecord

		SELECT @intCount = COUNT(*) FROM @voucherDetailData WHERE intPartyEntityId = @intVendorEntityId

		SELECT @intWeightClaimDetailId = intWeightClaimDetailId FROM @voucherDetailData WHERE intPartyEntityId = @intVendorEntityId

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
		END
		ELSE 
		BEGIN
			UPDATE tblLGWeightClaimDetail
			SET intBillId = @intBillId
			WHERE intWeightClaimDetailId = @intWeightClaimDetailId
		END

		DELETE
		FROM @VoucherDetailClaim

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH