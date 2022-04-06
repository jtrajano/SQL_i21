CREATE PROCEDURE [dbo].[uspAPProvisionalFinalize]
	@billId INT,
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

	IF @receiptId > 0
	BEGIN
		EXEC uspICProcessToBill @intReceiptId = @receiptId, @intUserId = @userId, @strType = 'voucher', @intScreenId = 1, @intBillId = @createdVoucher OUT
	END
END