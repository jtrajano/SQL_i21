CREATE PROCEDURE uspLGCreateVoucherForOtherCharges 
	 @intLoadId INT
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
	DECLARE @ysnInventoryCost BIT
	DECLARE @intAPAccount INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intMinVendorRecordId INT
	DECLARE @intReceiptCount INT
	DECLARE @intAPClearingAccountId INT
	DECLARE @intShipTo INT

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
		,intLoadCostId INT
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
		,intEntityVendorId INT
		)

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
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(LD.intPContractDetailId) CD
	WHERE LD.intLoadId = @intLoadId
		AND IR.ysnPosted = 1
		AND IR.intSourceType = 2

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblAPBillDetail BD
			JOIN tblLGLoadCost LC ON LC.intBillId = BD.intBillId
			WHERE LC.intLoadId = @intLoadId
			)
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(250)

		SET @ErrorMessage = 'Voucher was already created for other charges in ' + @strLoadNumber;

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
		,intLoadCostId
		,ysnInventoryCost
		,intItemUOMId
		)
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
						FROM tblLGLoadDetail VN
						WHERE VN.intLoadId = V.intLoadId
						))
				)
			) * CONVERT(NUMERIC(18, 6), V.dblNet)
		,V.intLoadCostId
		,I.ysnInventoryCost
		,LD.intItemUOMId
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
	WHERE V.intLoadId = @intLoadId
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
		,LD.intItemUOMId

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

			INSERT INTO @VoucherDetailLoadNonInv (
				intContractHeaderId
				,intContractDetailId
				,intItemId
				,intAccountId
				,intLoadDetailId
				,dblQtyReceived
				,dblCost
				,intItemUOMId
				)
			SELECT intContractHeaderId
				,intContractDetailId
				,intItemId
				,ISNULL(intAccountId, 0)
				,intLoadDetailId
				,dblQtyReceived
				,dblCost
				,intItemUOMId
			FROM @voucherDetailData
			WHERE intVendorEntityId = @intVendorEntityId

			EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
				,@vendorId = @intVendorEntityId
				,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
				,@shipTo = @intShipTo
				,@billId = @intBillId OUTPUT

			UPDATE tblLGLoadCost
			SET intBillId = @intBillId
			WHERE intLoadCostId IN (
					SELECT intLoadCostId
					FROM @voucherDetailData)

			UPDATE tblAPBillDetail 
			SET intLoadId = @intLoadId 
			WHERE intBillId = @intBillId
		
			SELECT * FROM tblAPBill WHERE intBillId = @intBillId
			SELECT * FROM tblAPBillDetail WHERE intBillId = @intBillId

			SELECT @intMinVendorRecordId = MIN(intRecordId)
			FROM @distinctVendor
			WHERE intRecordId > @intMinVendorRecordId
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
				INSERT INTO @VoucherDetailLoadNonInv (
					intContractHeaderId
					,intContractDetailId
					,intItemId
					,intAccountId
					,intLoadDetailId
					,dblQtyReceived
					,dblCost
					,intItemUOMId
					)
				SELECT intContractHeaderId
					,intContractDetailId
					,intItemId
					,ISNULL(intAccountId, 0)
					,intLoadDetailId
					,dblQtyReceived
					,dblCost
					,intItemUOMId
				FROM @voucherDetailData
				WHERE intVendorEntityId = @intVendorEntityId
					AND ysnInventoryCost = 0

				EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
					,@vendorId = @intVendorEntityId
					,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
					,@shipTo = @intShipTo
					,@billId = @intBillId OUTPUT

				UPDATE tblLGLoadCost
				SET intBillId = @intBillId
				WHERE intLoadCostId IN (
						SELECT intLoadCostId
						FROM @voucherDetailData
						WHERE intVendorEntityId = @intVendorEntityId
							AND ysnInventoryCost = 0)

				UPDATE tblAPBillDetail 
				SET intLoadId = @intLoadId 
				WHERE intBillId = @intBillId
			END

			
			IF EXISTS (SELECT TOP 1 1
					FROM @voucherDetailData
					WHERE intVendorEntityId = @intVendorEntityId
						AND ysnInventoryCost = 1)
			BEGIN
				SELECT @intMinInventoryReceiptId = MIN(intInventoryReceiptId), @intBillId = NULL
				FROM @receiptData

				INSERT INTO @voucherDetailReceiptCharge (intInventoryReceiptChargeId,dblQtyReceived,dblCost)
				SELECT intInventoryReceiptChargeId
					,1
					,LC.dblAmount / (
						SELECT SUM(LO.dblQuantity)
						FROM tblLGLoadDetail LO
						WHERE LO.intLoadId = LC.intLoadId
						) * LD.dblQuantity
				FROM tblICInventoryReceiptCharge C
				JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = C.intContractDetailId
				JOIN tblLGLoadCost LC ON LC.intLoadId = LD.intLoadId
					AND C.intChargeId = LC.intItemId
					AND LC.intVendorId = C.intEntityVendorId
				WHERE C.ysnInventoryCost = 1
					AND LD.intLoadId = @intLoadId
					AND  C.intEntityVendorId = @intVendorEntityId 
				GROUP BY intInventoryReceiptChargeId
					,LC.dblAmount
					,LD.dblQuantity
					,LC.intLoadId

				--SELECT intInventoryReceiptChargeId
				--FROM tblICInventoryReceiptCharge C
				--WHERE intInventoryReceiptId = @intMinInventoryReceiptId AND intEntityVendorId = @intVendorEntityId AND ysnInventoryCost = 1
				
				EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
					,@vendorId = @intVendorEntityId
					,@voucherDetailReceiptCharge = @voucherDetailReceiptCharge
					,@shipTo = @intShipTo
					,@billId = @intBillId OUTPUT

				UPDATE tblLGLoadCost
				SET intBillId = @intBillId
				WHERE intLoadCostId IN (
						SELECT intLoadCostId
						FROM @voucherDetailData
						WHERE intVendorEntityId = @intVendorEntityId
							AND ysnInventoryCost = 1)

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