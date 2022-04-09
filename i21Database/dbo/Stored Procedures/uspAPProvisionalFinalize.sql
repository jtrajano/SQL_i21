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

	--CREATE VOUCHER FROM RECEIPT
	DECLARE @receiptId INT = 0;
	SELECT TOP 1 @receiptId = IRI.intInventoryReceiptId
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
	WHERE B.intBillId = @billId

	DECLARE @isBasis INT;
	DECLARE @contractNumber NVARCHAR(50) = NULL;
	DECLARE @itemNo NVARCHAR(50) = NULL;

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

	IF @receiptId > 0 AND NULLIF(@contractNumber,'') = NULL
	BEGIN
		EXEC uspICProcessToBill @intReceiptId = @receiptId, @intUserId = @userId, @strType = 'voucher', @intScreenId = 1, @intBillId = @createdVoucher OUT

		UPDATE B 
		SET B.strReference = 'Final Voucher of ' + B2.strBillId,
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
			BD.ysnStage = 0
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBillDetail BD2 ON BD2.intInventoryReceiptItemId = BD.intInventoryReceiptItemId AND BD2.intBillId = @billId
		WHERE BD.intBillId = @createdVoucher
	END
END