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

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	--IF EXISTS (
	--		SELECT TOP 1 1
	--		FROM tblAPBillDetail BD
	--		JOIN tblLGLoadDetail LD ON BD.intLoadDetailId = LD.intLoadDetailId
	--		WHERE LD.intLoadId = @intLoadId
	--		)
	--BEGIN
	--	DECLARE @ErrorMessage NVARCHAR(250)

	--	SET @ErrorMessage = 'Voucher was already created for ' + @strLoadNumber;

	--	RAISERROR (@ErrorMessage,16,1);

	--	RETURN 0;
	--END

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
						FROM vyuLGLoadCostForVendor VN
						WHERE VN.intLoadId = V.intLoadId
						))
				)
			) * CONVERT(NUMERIC(18, 6), V.dblNet)
		,V.intLoadCostId
	FROM vyuLGLoadCostForVendor V
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN ISNULL(LD.intPContractDetailId, 0) = 0
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId AND ItemLoc.intLocationId = CD.intCompanyLocationId
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

	INSERT INTO @distinctVendor
	SELECT DISTINCT intVendorEntityId
	FROM @voucherDetailData

	INSERT INTO @distinctItem
	SELECT DISTINCT intVendorEntityId
		,intItemId
	FROM @voucherDetailData

	IF EXISTS (
			SELECT 1
			FROM tblICItem I
			LEFT JOIN tblICItemAccount IA ON IA.intItemId = I.intItemId
			LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = IA.intAccountCategoryId
			WHERE strAccountCategory IS NULL
				AND I.intItemId IN (
					SELECT intItemId
					FROM @distinctItem
					)
			)
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

	SELECT @intMinRecord = MIN(intRecordId)
	FROM @distinctVendor

	WHILE ISNULL(@intMinRecord, 0) <> 0
	BEGIN
		SET @intVendorEntityId = NULL
		SET @intItemId = NULL
		SET @ysnInventoryCost = NULL

		SELECT @intVendorEntityId = intVendorEntityId
		FROM @distinctVendor
		WHERE intRecordId = @intMinRecord

		INSERT INTO @VoucherDetailLoadNonInvAll (
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
			,ISNULL(intAccountId,0)
			,intLoadDetailId
			,dblQtyReceived
			,dblCost
		FROM @voucherDetailData
		WHERE intVendorEntityId = @intVendorEntityId

		SELECT @intMinItemRecordId = MIN(intItemRecordId)
		FROM @distinctItem
		WHERE intVendorEntityId = @intVendorEntityId

		WHILE ISNULL(@intMinItemRecordId, 0) > 0
		BEGIN
			SET @intItemId = NULL
			SET @ysnInventoryCost = NULL

			SELECT @intItemId = intItemId
			FROM @distinctItem
			WHERE intItemRecordId = @intMinItemRecordId

			SELECT @ysnInventoryCost = ISNULL(ysnInventoryCost, 0)
			FROM tblICItem
			WHERE intItemId = @intItemId

			IF (@ysnInventoryCost = 1)
			BEGIN
				SELECT @intMinInventoryReceiptId = MIN(intInventoryReceiptId)
				FROM @receiptData

				WHILE ISNULL(@intMinInventoryReceiptId, 0) > 0
				BEGIN
					INSERT INTO @voucherDetailReceipt (
						intInventoryReceiptType
						,intInventoryReceiptItemId
						,dblCost
						)
					SELECT intInventoryReceiptType = 2
						,intInventoryReceiptItemId = intInventoryReceiptItemId
						,dblCost = dblCost
					FROM @receiptData
					WHERE intInventoryReceiptId = @intMinInventoryReceiptId

					INSERT INTO @voucherDetailReceiptCharge (intInventoryReceiptChargeId)
					SELECT intInventoryReceiptChargeId
					FROM tblICInventoryReceiptCharge
					WHERE intInventoryReceiptId = @intMinInventoryReceiptId

					INSERT INTO @VoucherDetailLoadNonInv
					SELECT * FROM @VoucherDetailLoadNonInvAll WHERE intItemId = @intItemId
					
					--SELECT * FROM @voucherDetailReceipt
					--SELECT * FROM @voucherDetailReceiptCharge
					--SELECT * FROM @VoucherDetailLoadNonInv


					EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
						,@vendorId = @intVendorEntityId
						,@voucherDetailReceipt = @voucherDetailReceipt
						--,@voucherDetailReceiptCharge = @voucherDetailReceiptCharge
						,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
						,@billId = @intBillId OUTPUT

					UPDATE tblLGLoadCost
					SET intBillId = @intBillId
					WHERE intLoadCostId IN (
							SELECT intLoadCostId
							FROM @voucherDetailData)

					DELETE
					FROM @VoucherDetailLoadNonInv

					SELECT @intMinInventoryReceiptId = MIN(intInventoryReceiptId)
					FROM @receiptData WHERE intInventoryReceiptId > @intMinInventoryReceiptId
				END
			END
			ELSE
			BEGIN
				INSERT INTO @VoucherDetailLoadNonInv
				SELECT * FROM @VoucherDetailLoadNonInvAll WHERE intItemId = @intItemId

				--SELECT * FROM @VoucherDetailLoadNonInv

				EXEC uspAPCreateBillData @userId = @intEntityUserSecurityId
					,@vendorId = @intVendorEntityId
					,@voucherDetailLoadNonInv = @VoucherDetailLoadNonInv
					,@billId = @intBillId OUTPUT

				UPDATE tblLGLoadCost
				SET intBillId = @intBillId
				WHERE intLoadCostId IN (
						SELECT intLoadCostId
						FROM @voucherDetailData)

				DELETE
				FROM @VoucherDetailLoadNonInv
			END

			SELECT @intMinItemRecordId = MIN(intItemRecordId)
			FROM @distinctItem
			WHERE intVendorEntityId = @intVendorEntityId
			AND intItemRecordId > @intMinItemRecordId
		END

		SELECT @intMinRecord = MIN(intRecordId)
		FROM @distinctVendor
		WHERE intRecordId > @intMinRecord
	END
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH