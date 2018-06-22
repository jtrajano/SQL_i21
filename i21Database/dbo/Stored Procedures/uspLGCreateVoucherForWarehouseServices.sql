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
	DECLARE @intItemId INT
	DECLARE @intWarehouseServicesId INT
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intLoadId INT
	DECLARE @intPurchaseSale INT
	DECLARE @intReceiptCount INT
	DECLARE @intAPClearingAccountId INT

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

	SELECT @intLoadId = intLoadId
	FROM tblLGLoadWarehouse
	WHERE intLoadWarehouseId = @intLoadWarehouseId

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
		)
	SELECT ISNULL(SLCL.intVendorId, WRMH.intVendorEntityId)
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
		,LD.intItemUOMId
		,LWS.intLoadWarehouseServicesId
		,Item.ysnInventoryCost
		,LD.intItemUOMId
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
	LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
	LEFT JOIN tblICItem Item ON Item.intItemId = LWS.intItemId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = LW.intSubLocationId
		AND ItemLoc.intLocationId = SLCL.intCompanyLocationId
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
		AND LWS.dblActualAmount > 0
	GROUP BY LWS.intLoadWarehouseServicesId
		,WRMH.intVendorEntityId
		,SLCL.intVendorId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,Item.intItemId
		,ItemLoc.intItemLocationId
		,LD.dblNet
		,L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,Item.ysnInventoryCost
		,LD.intItemUOMId

	SELECT @intVendorEntityId = intVendorEntityId
	FROM @voucherDetailData

	INSERT INTO @distinctItem
	SELECT DISTINCT intVendorEntityId
		,intItemId
	FROM @voucherDetailData

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblAPBillDetail BD
			JOIN tblLGLoadWarehouseServices LWS ON LWS.intBillId = BD.intBillId
			JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
			WHERE LW.intLoadId = @intLoadId
			)
	BEGIN
		SET @strErrorMessage = 'Voucher was already created for warehouse services of ' + @strLoadNumber;

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

	IF (@intReceiptCount = 0)
	BEGIN
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
			)
		SELECT intContractHeaderId
			,intContractDetailId
			,intItemId
			,ISNULL(intAccountId, 0)
			,intLoadDetailId
			,dblQtyReceived
			,dblCost
			,intCostUOMId
			,intItemUOMId
		FROM @voucherDetailData

		EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
			,@vendorId = @intVendorEntityId
			,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
			,@billId = @intBillId OUTPUT

		UPDATE tblLGLoadWarehouseServices
		SET intBillId = @intBillId
		WHERE intLoadWarehouseServicesId IN (
				SELECT intWarehouseServicesId
				FROM @voucherDetailData
				)

		UPDATE tblAPBillDetail
		SET intLoadId = @intLoadId
		WHERE intBillId = @intBillId
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT TOP 1 1
				FROM @voucherDetailData
				WHERE ysnInventoryCost = 0
				)
		BEGIN
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
				)
			SELECT intContractHeaderId
				,intContractDetailId
				,intItemId
				,ISNULL(intAccountId, 0)
				,intLoadDetailId
				,dblQtyReceived
				,dblCost
				,intCostUOMId
				,intItemUOMId
			FROM @voucherDetailData
			WHERE ysnInventoryCost = 0

			EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
				,@vendorId = @intVendorEntityId
				,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
				,@billId = @intBillId OUTPUT

			UPDATE tblLGLoadWarehouseServices
			SET intBillId = @intBillId
			WHERE intLoadWarehouseServicesId IN (
					SELECT intWarehouseServicesId
					FROM @voucherDetailData
					WHERE ysnInventoryCost = 0)

			UPDATE tblAPBillDetail
			SET intLoadId = @intLoadId
			WHERE intBillId = @intBillId
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

			INSERT INTO @voucherDetailReceiptCharge (intInventoryReceiptChargeId)
			SELECT intInventoryReceiptChargeId
			FROM tblICInventoryReceiptCharge C
			WHERE intInventoryReceiptId = @intMinInventoryReceiptId
				AND ysnInventoryCost = 1
				AND intChargeId IN (SELECT DISTINCT intItemId FROM @voucherDetailData WHERE ysnInventoryCost = 1)

			EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
				,@vendorId = @intVendorEntityId
				,@voucherDetailReceiptCharge = @voucherDetailReceiptCharge
				,@billId = @intBillId OUTPUT
				
			UPDATE tblLGLoadWarehouseServices
			SET intBillId = @intBillId
			WHERE intLoadWarehouseServicesId IN (
					SELECT intWarehouseServicesId
					FROM @voucherDetailData
					WHERE ysnInventoryCost = 1)
		END
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH
