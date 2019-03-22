CREATE PROCEDURE [dbo].[uspAPProcessToBill]
	@intRecordId int,
	@receiptChargeId int,
	@intUserId int,
	@intBillId int OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @voucherCreated NVARCHAR(MAX);
DECLARE @billId INT;
DECLARE @intVendorEntityId INT;
DECLARE @shipToId INT;
DECLARE @voucherOtherCharges AS VoucherDetailReceiptCharge;
	
CREATE TABLE #tmpBillIds (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryRecordId] [INT],
	[intEntityVendorId] INT,
	[intCurrencyId] INT
)
-- EXEC dbo.[uspAPCreateBillFromIR] 
-- 	@intRecordId,
-- 	@intUserId
IF (@receiptChargeId > 0)
BEGIN 
	BEGIN
			INSERT INTO @voucherOtherCharges (
					[intInventoryReceiptChargeId]
					,[dblQtyReceived]
					,[dblCost]
					,[intTaxGroupId]
			)
			SELECT	
					[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
					,[dblQtyReceived] = 
						CASE 
							WHEN rc.ysnPrice = 1 THEN 
								rc.dblQuantity - ISNULL(-rc.dblQuantityPriced, 0) 
							ELSE 
								rc.dblQuantity - ISNULL(rc.dblQuantityBilled, 0) 
						END 

					,[dblCost] = 
						CASE 
							WHEN rc.strCostMethod = 'Per Unit' THEN rc.dblRate
							WHEN rc.strCostMethod = 'Gross Unit' THEN rc.dblRate
							ELSE rc.dblAmount
						END 
					,[intTaxGroupId] = rc.intTaxGroupId
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
						ON r.intInventoryReceiptId = rc.intInventoryReceiptId
			WHERE	r.ysnPosted = 1
					AND r.intInventoryReceiptId = @intRecordId 
					AND 
					(
						(
							rc.ysnPrice = 1
							AND ISNULL(-rc.dblAmountPriced, 0) < rc.dblAmount
							AND rc.intInventoryReceiptChargeId = @receiptChargeId
						)
						OR (
							rc.ysnAccrue = 1 
							AND rc.intInventoryReceiptChargeId = @receiptChargeId
							AND ISNULL(rc.dblAmountBilled, 0) < rc.dblAmount
						)
					)
		END 

		BEGIN
		SET @intVendorEntityId = (SELECT intEntityVendorId FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptChargeId = @receiptChargeId)
		SET @shipToId = (SELECT intLocationId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intRecordId)
				EXEC uspAPCreateBillData @userId = @intUserId
				,@vendorId = @intVendorEntityId
				,@voucherDetailReceiptCharge = @voucherOtherCharges
				,@shipTo = @shipToId 
				,@billId = @billId OUTPUT
		
		SET @intBillId = @billId;
		SET @strBillIds = (SELECT strBillId FROM tblAPBill WHERE intBillId = @billId)
		END
END
ELSE
	BEGIN
		EXEC [dbo].[uspICProcessToBill]
			@intReceiptId = @intRecordId,
			@intUserId = @intUserId,
			@intBillId = @billId OUTPUT,
			@strBillIds = @voucherCreated OUTPUT

			SET @intBillId = @billId;
			SET @strBillIds = @voucherCreated;
	END


-- SELECT TOP 1 @intBillId = intBillId FROM #tmpBillIds

-- SELECT @strBillIds = 
-- 	LTRIM(
-- 		STUFF(
-- 				' ' + (
-- 					SELECT  CONVERT(NVARCHAR(50), intBillId) + '|^|'
-- 					FROM	#tmpBillIds
-- 					ORDER BY intBillId
-- 					FOR xml path('')
-- 				)
-- 			, 1
-- 			, 1
-- 			, ''
-- 		)
-- 	)

DROP TABLE #tmpBillIds
GO