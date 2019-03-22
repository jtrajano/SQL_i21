CREATE PROCEDURE [dbo].[uspLGGetWeightLoss]
	@intInventoryReceiptId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrMsg      NVARCHAR(MAX);

BEGIN TRY

	IF (IsNull(@intInventoryReceiptId, 0) = 0)
	BEGIN
		RAISERROR('Invalid Inventory Receipt Id', 11, 1);
		RETURN;
	END

	SELECT
		CASE WHEN ((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchise)) > 0.0 THEN
				((dblNetShippedWt - dblNetReceivedWt) - (dblNetShippedWt * dblFranchise))
			ELSE
				0.0
			END as dblClaimableWt
	FROM (
		SELECT
		dblFranchise = CASE WHEN Shipment.dblFranchise > 0 THEN
						Shipment.dblFranchise / 100
					ELSE 
						0
					END,
		sum(ReceiptItem.dblOrderQty * Shipment.dblContainerWeightPerQty) as dblNetShippedWt,
		sum(ReceiptItem.dblNet) as dblNetReceivedWt
	FROM tblICInventoryReceiptItem ReceiptItem
	JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
	JOIN vyuLGInboundShipmentView Shipment ON Shipment.intLoadDetailId = ReceiptItem.intSourceId and Shipment.intLoadContainerId = ReceiptItem.intContainerId
	GROUP BY Shipment.intLoadId, Shipment.strTrackingNumber, Shipment.dblFranchise, ReceiptItem.intItemId) t1
	
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
