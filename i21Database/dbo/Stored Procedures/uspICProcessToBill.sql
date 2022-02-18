CREATE PROCEDURE [dbo].[uspICProcessToBill]
	@intReceiptId int,
	@intUserId int,
	@intBillId int OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT,
	@intScreenId int = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @receiptType AS NVARCHAR(50) 
DECLARE	 @invalidItemNo AS NVARCHAR(50) 
		,@invalidItemId AS INT
		,@intReturnValue AS INT 

SELECT	@receiptType = r.strReceiptType
FROM	tblICInventoryReceipt r
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId

IF @receiptType = 'Inventory Return'
BEGIN 
	EXEC @intReturnValue = uspICConvertReturnToVoucher
		@intReceiptId 
		,@intUserId 
		,@intBillId OUTPUT
		,@strBillIds OUTPUT
END 
ELSE IF @receiptType <> 'Transfer Order'
BEGIN 

	EXEC @intReturnValue = uspICConvertReceiptToVoucher
		@intReceiptId 
		,@intUserId 
		,@intBillId OUTPUT
		,@strBillIds OUTPUT
		,@intScreenId
END 

BEGIN 
			
	DECLARE @TransactionLinks udtICTransactionLinks
	DELETE FROM @TransactionLinks
	
	IF EXISTS (SELECT intDestinationId FROM dbo.vyuICGetReceiptItemVoucherDestination WHERE intInventoryReceiptId = @intReceiptId AND intDestinationId IS NOT NULL)
	BEGIN
	
		INSERT INTO @TransactionLinks (
			strOperation, -- Operation
			intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType, -- Source Transaction
			intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType	-- Destination Transaction
		)
		SELECT 'Create',
			@intReceiptId, Voucher.strReceiptNumber, 'Inventory', 'Inventory Receipt',
			Voucher.intDestinationId, 
			COALESCE(Voucher.strDestinationNo, 'Missing Transaction No'), 
			'Purchasing', 
			'Voucher'
		FROM dbo.vyuICGetReceiptItemVoucherDestination Voucher
		WHERE intInventoryReceiptId = @intReceiptId AND Voucher.intDestinationId = @intBillId

		EXEC dbo.uspICAddTransactionLinks @TransactionLinks

	END
END

Post_Exit: 
RETURN @intReturnValue