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
	-- Check if the item is "Basis" priced and futures price is not blank. 
	BEGIN 

		SELECT	TOP 1
				@invalidItemNo = i.strItemNo
				,@invalidItemId = i.intItemId 
		FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN tblCTContractDetail cd
					ON cd.intContractDetailId = ri.intLineNo
					AND cd.intContractHeaderId = ri.intOrderId
					AND cd.intItemId = ri.intItemId
				INNER JOIN tblICItem i
					ON i.intItemId = ri.intItemId
		WHERE	r.strReceiptType = 'Purchase Contract'
				AND r.intInventoryReceiptId = @intReceiptId
				AND cd.intPricingTypeId = 2 -- 2 is Basis. 
				AND ISNULL(cd.dblFutures, 0) = 0
				AND ISNULL(ri.ysnAllowVoucher, 1) = 1

		IF @invalidItemId IS NOT NULL 
		BEGIN 
			-- 'Pricing type for {Item No} is a Basis and its Futures needs a price. Please add it at Contract Management -> Price Contract.'
			EXEC uspICRaiseError 80218, @invalidItemNo; 		
			SET @intReturnValue = -80218;
			GOTO Post_Exit;
		END 
	END 

	EXEC @intReturnValue = uspICConvertReceiptToVoucher
		@intReceiptId 
		,@intUserId 
		,@intBillId OUTPUT
		,@strBillIds OUTPUT
		,@intScreenId
END 

Post_Exit: 
RETURN @intReturnValue