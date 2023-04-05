CREATE PROCEDURE [dbo].[uspAPProvisionalFinalize]
	@billId INT,
	@detailIds NVARCHAR(4000),
	@userId INT,
	@createdVoucher INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	--MAKE SURE PROVISIONAL VOUCHER TYPE ONLY
	IF (SELECT intTransactionType FROM tblAPBill WHERE intBillId = @billId) <> 16
	BEGIN
		RAISERROR('Invalid transaction type for provisional finalize.', 16, 1);
		RETURN;
	END

	--Validate provisional if there is remaining to bill
	IF EXISTS (
			SELECT TOP 1 1 FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			WHERE A.intBillId = @billId
			AND	A.dblProvisionalPercentage = 100
	) 
	BEGIN
		RAISERROR('There is no remaining quanity to bill', 16, 1);
		RETURN;
	END

	--Validate if provisional is already finalize
	IF EXISTS (
			SELECT TOP 1 1 FROM tblAPBill A
				INNER JOIN tblAPBill B ON A.intFinalizeVoucherId IS NOT NULL AND A.intFinalizeVoucherId = B.intBillId
				WHERE A.intBillId = @billId) 
	BEGIN
		RAISERROR('Provisional is already finalized', 16, 1);
		RETURN;
	END

	--CREATE VOUCHER FROM RECEIPT
	DECLARE @receiptId INT = 0;
	SELECT TOP 1 @receiptId = IRI.intInventoryReceiptId
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
	WHERE B.intBillId = @billId

	--CREATE VOUCHER FROM SHIPMENT
	DECLARE @intLoadId INT = 0;
	SELECT TOP 1 @intLoadId = LD.intLoadId
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = BD.intLoadDetailId
	WHERE B.intBillId = @billId

	DECLARE @isBasis INT;
	DECLARE @contractNumber NVARCHAR(50) = NULL;
	DECLARE @itemNo NVARCHAR(50) = NULL;
	DECLARE @allowFinalize BIT = 0;
	DECLARE @excludedVoucherDetailIds Id
	DECLARE @dblProvisionalPercentage AS DECIMAL(18,6)
	DECLARE @dblTotal AS DECIMAL(18,6)

	--Get provisional voucher config
	SELECT TOP 1 @allowFinalize = ysnAllowFinalizeVoucherWithoutReceipt FROM tblAPCompanyPreference

	SELECT TOP 1 
		@contractNumber = CD.strContractNumber
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN dbo.fnGetRowsFromDelimitedValues(@detailIds) IDS ON IDS.intID = BD.intBillDetailId
	INNER JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = BD.intContractDetailId
	INNER JOIN tblCTContractHeader CD ON CTD.intContractHeaderId = CD.intContractHeaderId
	WHERE B.intBillId = @billId AND CTD.intPricingTypeId = 2

	IF @contractNumber IS NOT NULL
	BEGIN
		DECLARE @errMsg NVARCHAR(500);
		SET @errMsg = 'Cannot finalize basis contract ' + @contractNumber + '.'
		RAISERROR(@errMsg, 16, 1);
		RETURN 0;
	END
	ELSE IF NULLIF(@receiptId,0) IS NULL
	AND @allowFinalize = 0 
	BEGIN
		DECLARE @errMsg2 NVARCHAR(500);
		SET @errMsg2 = 'Cannot finalize provisional voucher without receipt.'
		RAISERROR(@errMsg2, 16, 1);
		RETURN 0;
	END

	SELECT @dblTotal = dblProvisionalTotal
				,@dblProvisionalPercentage = dblProvisionalPercentage
	FROM tblAPBill WHERE intBillId = @billId

	--Check if the config is allowed to finalize voucher without Receipt 
	IF (@allowFinalize = 1 AND @intLoadId > 0 AND ISNULL(@receiptId,0) = 0)
	BEGIN
		EXEC uspAPDuplicateBill @billId = @billId, @userId = @userId, @reset = 1, @type = 1,  @billCreatedId = @createdVoucher OUT
		UPDATE B 
		SET B.strReference = 'Final Voucher of ' + B2.strBillId,
			B.dblProvisionalTotal = @dblTotal,
			B.dblProvisionalPercentage = @dblProvisionalPercentage,
			B.dblFinalVoucherTotal = B2.dblTotal - @dblTotal, 
			B.ysnFinalVoucher = 1
		FROM tblAPBill B
		INNER JOIN tblAPBill B2 ON B2.intBillId = @billId
		WHERE B.intBillId = @createdVoucher

		DECLARE @excludedLoadIds Id
		INSERT INTO @excludedLoadIds
		SELECT BD.intLoadDetailId
		FROM tblAPBill B
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		LEFT JOIN dbo.fnGetRowsFromDelimitedValues(@detailIds) IDS ON IDS.intID = BD.intBillDetailId
		WHERE B.intBillId = @billId AND IDS.intID IS NULL

		INSERT INTO @excludedVoucherDetailIds
		SELECT BD.intBillDetailId
		FROM tblAPBill B
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		INNER JOIN @excludedLoadIds IDS ON IDS.intId = BD.intLoadDetailId
		WHERE B.intBillId = @createdVoucher

		EXEC uspAPDeleteVoucherDetail @billDetailIds = @excludedVoucherDetailIds, @userId = @userId, @callerModule = 0

		UPDATE BD
		SET BD.intLotId = BD2.intLotId,
			BD.dblProvisionalCost = BD2.dblCost,
			BD.dblProvisionalWeight = BD2.dblNetWeight * (@dblProvisionalPercentage / 100),
			BD.dblProvisionalTotal = (@dblProvisionalPercentage / 100) * BD2.dblTotal,
			BD.dblProvisionalPercentage = @dblProvisionalPercentage,
			BD.dblFinalVoucherTotal = BD2.dblTotal - ((@dblProvisionalPercentage / 100) * BD2.dblTotal),
			BD.ysnStage = 0
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBillDetail BD2 ON BD2.intLoadDetailId = BD.intLoadDetailId AND BD2.intBillId = @billId
		WHERE BD.intBillId = @createdVoucher
	END
	
	IF @receiptId > 0 AND @contractNumber IS NULL
	BEGIN
		-- EXEC uspICProcessToBill @intReceiptId = @receiptId, @intUserId = @userId, @strType = 'voucher', @intScreenId = 1, @intBillId = @createdVoucher OUT
		EXEC uspAPDuplicateBill @billId = @billId, @userId = @userId, @reset = 1, @type = 1,  @billCreatedId = @createdVoucher OUT

		UPDATE B 
		SET B.strReference = 'Final Voucher of ' + B2.strBillId,
				B.dblProvisionalTotal = @dblTotal,
				B.dblProvisionalPercentage = @dblProvisionalPercentage,
				B.dblFinalVoucherTotal = B2.dblTotal - @dblTotal,
			B.ysnFinalVoucher = 1
		FROM tblAPBill B
		INNER JOIN tblAPBill B2 ON B2.intBillId = @billId
		WHERE B.intBillId = @createdVoucher

		DECLARE @excludedReceiptIds Id
		INSERT INTO @excludedReceiptIds
		SELECT BD.intInventoryReceiptItemId
		FROM tblAPBill B
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		LEFT JOIN dbo.fnGetRowsFromDelimitedValues(@detailIds) IDS ON IDS.intID = BD.intBillDetailId
		WHERE B.intBillId = @billId AND IDS.intID IS NULL

		DECLARE @excludedDetailIds Id
		INSERT INTO @excludedDetailIds
		SELECT BD.intBillDetailId
		FROM tblAPBill B
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		INNER JOIN @excludedReceiptIds IDS ON IDS.intId = BD.intInventoryReceiptItemId
		WHERE B.intBillId = @createdVoucher

		EXEC uspAPDeleteVoucherDetail @billDetailIds = @excludedDetailIds, @userId = @userId, @callerModule = 0

		UPDATE BD
		SET BD.intLotId = BD2.intLotId,
			BD.dblProvisionalCost = BD2.dblCost,
			BD.dblProvisionalWeight = BD2.dblNetWeight * (@dblProvisionalPercentage / 100),
			BD.dblProvisionalTotal = (@dblProvisionalPercentage / 100) * BD2.dblTotal,
			BD.dblProvisionalPercentage = @dblProvisionalPercentage,
			BD.dblFinalVoucherTotal = BD2.dblTotal - ((@dblProvisionalPercentage / 100) * BD2.dblTotal),
			BD.ysnStage = 0
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBillDetail BD2 ON BD2.intInventoryReceiptItemId = BD.intInventoryReceiptItemId AND BD2.intBillId = @billId
		WHERE BD.intBillId = @createdVoucher
	END
	
	UPDATE tblAPBill 
		SET intFinalizeVoucherId = @createdVoucher
				,ysnFinalize = 1
	WHERE intBillId = @billId
END