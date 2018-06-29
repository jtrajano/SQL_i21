CREATE PROCEDURE [dbo].[uspLGProcessToBill]
	@intWarehouseInstructionHeaderId AS INT
	,@intUserId AS INT
	,@intBillId int OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @voucherDetailNonInvContract AS VoucherDetailNonInvContract,
		@total as INT,
		@intVendorEntityId as INT;
BEGIN TRY

	SELECT @intVendorEntityId = WM.intVendorEntityId FROM tblLGWarehouseRateMatrixHeader WM
		INNER JOIN tblLGWarehouseInstructionHeader WH ON WH.intWarehouseRateMatrixHeaderId = WM.intWarehouseRateMatrixHeaderId

     INSERT into @voucherDetailNonInvContract(
	     intContractHeaderId
		 ,intContractDetailId
		 ,intItemId
		 ,intAccountId
	 	,dblQtyReceived
	 	,dblCost
	 )	
		SELECT
				CTHeader.intContractHeaderId,
				CTDetail.intContractDetailId,
				Item.intItemId,
				intAccountId = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing'),
				dblQtyReceived = 1,
				dblCost = (Sum(WHD.dblActualAmount) * Receipt.dblNet / dblSumNet.dblSum)

		FROM tblICInventoryReceiptItem Receipt
			LEFT JOIN (SELECT SUM(dblNet) dblSum, intInventoryReceiptId FROM tblICInventoryReceiptItem GROUP BY intInventoryReceiptId) dblSumNet ON dblSumNet.intInventoryReceiptId = Receipt.intInventoryReceiptId
		   LEFT JOIN tblLGShipmentContractQty SCQ ON SCQ.intShipmentContractQtyId = Receipt.intSourceId
		   LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = SCQ.intContractDetailId
		   LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = CTDetail.intContractHeaderId
		   LEFT JOIN tblLGShipment S ON S.intShipmentId = SCQ.intShipmentId
		   LEFT JOIN tblLGWarehouseInstructionHeader WH ON WH.intShipmentId = S.intShipmentId
		   LEFT JOIN tblLGWarehouseInstructionDetail WHD ON WHD.intWarehouseInstructionHeaderId = WH.intWarehouseInstructionHeaderId
		   LEFT JOIN tblICItem Item ON Item.intItemId = WHD.intItemId
		   LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = Item.intItemId and ItemLoc.intLocationId = WH.intCompanyLocationId
		   WHERE WH.intWarehouseInstructionHeaderId = @intWarehouseInstructionHeaderId
		   GROUP BY CTHeader.intContractHeaderId, CTDetail.intContractDetailId, Item.intItemId, ItemLoc.intItemLocationId, Receipt.dblNet, dblSumNet.dblSum
		   
    select @total = count(*) from @voucherDetailNonInvContract;
    IF (@total = 0)
	BEGIN
		RAISERROR('Bill process failure #1', 11, 1);
		RETURN;
	END

	EXEC uspAPCreateBillData @userId = @intUserId, @vendorId = @intVendorEntityId, @voucherDetailNonInvContract = @voucherDetailNonInvContract, @billId=@intBillId OUTPUT

	UPDATE tblLGWarehouseInstructionHeader SET intBillId = @intBillId WHERE intWarehouseInstructionHeaderId=@intWarehouseInstructionHeaderId

	Select @intBillId


END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
