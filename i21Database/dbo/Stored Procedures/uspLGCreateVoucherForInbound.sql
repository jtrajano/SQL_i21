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
	DECLARE @VoucherDetailLoadNonInv AS VoucherDetailLoadNonInv
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT

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
		,dblCost NUMERIC(18, 6)
		,intCostUOMId INT
		,intItemUOMId INT
		,dblUnitQty DECIMAL(38,20)
		,dblCostUnitQty DECIMAL(38,20))

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
		,intItemUOMId
		,dblUnitQty
		,dblCostUnitQty
		)
	SELECT LD.intVendorEntityId
		,L.intLoadId
		,LD.intLoadDetailId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,LD.intItemId
		,intAccountId = [dbo].[fnGetItemGLAccount](LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
		,dblQtyReceived = LD.dblQuantity
		,dblCost = CASE 
			WHEN AD.ysnSeqSubCurrency = 1
				THEN ISNULL(AD.dblSeqPrice, 0) / 100
			ELSE ISNULL(AD.dblSeqPrice, 0)
			END
		,AD.intSeqPriceUOMId
		,LD.intItemUOMId
		,ISNULL(ItemUOM.dblUnitQty,1)
		,ISNULL(CostUOM.dblUnitQty,1)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LD.intPSubLocationId
		AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = CD.intPriceItemUOMId
	WHERE L.intLoadId = @intLoadId
	GROUP BY LD.intVendorEntityId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,LD.intItemId
		,ItemLoc.intItemLocationId
		,LD.dblNet
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,AD.ysnSeqSubCurrency
		,AD.dblQtyToPriceUOMConvFactor
		,AD.dblSeqPrice
		,LD.dblQuantity
		,LD.intItemUOMId
		,AD.intSeqPriceUOMId
		,ItemUOM.dblUnitQty
		,CostUOM.dblUnitQty

	INSERT INTO @distinctVendor
	SELECT DISTINCT intVendorEntityId
	FROM @voucherDetailData

	INSERT INTO @distinctItem
	SELECT DISTINCT intItemId
	FROM @voucherDetailData

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
			,intCostUOMId
			,intItemUOMId
			,dblUnitQty
			,dblCostUnitQty
			)
		SELECT intContractHeaderId
			,intContractDetailId
			,intItemId
			,intAccountId
			,intLoadDetailId
			,dblQtyReceived
			,dblCost
			,intCostUOMId
			,intItemUOMId
			,dblUnitQty
			,dblCostUnitQty
		FROM @voucherDetailData
		WHERE intVendorEntityId = @intVendorEntityId

		EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
			,@vendorId = @intVendorEntityId
			,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
			,@shipTo = @intShipTo
			,@billId = @intBillId OUTPUT

		DELETE
		FROM @VoucherDetailLoadNonInv

		UPDATE tblAPBillDetail SET intLoadId = @intLoadId WHERE intBillId = @intBillId

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE(),@intErrorSeverity = ERROR_SEVERITY(),@intErrorState = ERROR_STATE();
	RAISERROR (@strErrorMessage,@intErrorSeverity,@intErrorState)
END CATCH