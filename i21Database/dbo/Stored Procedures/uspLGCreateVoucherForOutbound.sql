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
	DECLARE @VoucherDetailLoadNonInv AS VoucherDetailLoadNonInv
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)

	DECLARE @voucherDetailData TABLE 
		(intItemRecordId INT Identity(1, 1)
		,intVendorEntityId INT
		,intLoadId INT
		,intLoadDetailId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,intItemId INT
		,intAccountId INT
		,dblQtyReceived NUMERIC(18, 6)
		,dblCost NUMERIC(18, 6))

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
		)
	SELECT WRMH.intVendorEntityId
		,L.intLoadId
		,LD.intLoadDetailId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = 1
		,dblCost = (
			CONVERT(NUMERIC(18, 6), Sum(LWS.dblActualAmount)) / (
				CONVERT(NUMERIC(18, 6), (
						SELECT SUM(dblNet)
						FROM tblLGLoadDetail D
						WHERE L.intLoadId = D.intLoadId
						))
				) * CONVERT(NUMERIC(18, 6), SUM(LD.dblNet))
			)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
	JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
	JOIN tblICItem Item ON Item.intItemId = LWS.intItemId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LW.intSubLocationId
		AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
	WHERE L.intLoadId = @intLoadId
		AND LWS.dblActualAmount > 0
	GROUP BY LWS.intLoadWarehouseServicesId
		,WRMH.intVendorEntityId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,ItemLoc.intItemLocationId
		,LD.dblNet
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId

	UNION ALL

	SELECT V.intEntityVendorId
		,LD.intLoadId
		,LD.intLoadDetailId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,V.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](V.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = 1
		,dblCost = (
			CONVERT(NUMERIC(18, 6), Sum(V.dblPrice)) / (
				CONVERT(NUMERIC(18, 6), (
						SELECT SUM(dblNet)
						FROM vyuLGLoadCostForVendor VN
						WHERE VN.intLoadId = V.intLoadId
						))
				)
			) * CONVERT(NUMERIC(18, 6), V.dblNet)
	FROM vyuLGLoadCostForVendor V
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN ISNULL(LD.intPContractDetailId, 0) = 0
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = V.intItemId
	WHERE V.intLoadId = @intLoadId
	GROUP BY V.intEntityVendorId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,V.intItemId
		,ItemLoc.intItemLocationId
		,V.intLoadId
		,V.strLoadNumber
		,V.dblNet
		,LD.intLoadId
		,LD.intLoadDetailId

	INSERT INTO @distinctVendor
	SELECT DISTINCT intVendorEntityId
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
		RAISERROR ('Voucher cannot be created if claim amount is zero.',11,1);
		RETURN;
	END

	SELECT @intMinRecord = MIN(intRecordId) FROM @distinctVendor
	WHILE ISNULL(@intMinRecord, 0) <> 0
	BEGIN
		SET @intVendorEntityId = NULL

		SELECT @intVendorEntityId = intVendorEntityId
		FROM @distinctVendor
		WHERE intRecordId = @intMinRecord

		INSERT INTO @VoucherDetailLoadNonInv (
			intContractHeaderId
			,intContractDetailId
			,intItemId
			,intAccountId
			,intLoadDetailId
			,dblQtyReceived
			,dblCost
			)
		SELECT intContractHeaderId
			,intContractDetailId
			,intItemId
			,intAccountId
			,intLoadDetailId
			,dblQtyReceived
			,dblCost
		FROM @voucherDetailData
		WHERE intVendorEntityId = @intVendorEntityId

		EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
			,@vendorId = @intVendorEntityId
			,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
			,@billId = @intBillId OUTPUT

		DELETE
		FROM @VoucherDetailLoadNonInv

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH