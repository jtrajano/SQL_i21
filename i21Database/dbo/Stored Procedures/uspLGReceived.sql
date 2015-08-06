CREATE PROCEDURE [dbo].[uspLGReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT 
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg							NVARCHAR(MAX),
				@strReceiptType					NVARCHAR(50),
				@intSourceType					INT,
				@intInventoryReceiptItemId		INT,
				@intSourceId					INT,
				@intContainerId					INT,
				@dblQty							NUMERIC(18,6),
				@dblContractQty					NUMERIC(18,6),
				@dblContainerQty				NUMERIC(18,6)

	SELECT @strReceiptType = strReceiptType, @intSourceType = intSourceType FROM @ItemsFromInventoryReceipt
	IF (@strReceiptType <> 'Purchase Contract' AND @intSourceType <> 2)
		RETURN
	
	SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt
	SELECT @intInventoryReceiptItemId
	WHILE ISNULL(@intInventoryReceiptItemId,0) > 0
	BEGIN
		SELECT	@intSourceId					=	NULL,
				@intContainerId					=	NULL,
				@dblQty							=	NULL

				
		SELECT	@intSourceId					=	intSourceId,
				@intContainerId					=	intContainerId,
				@dblQty							=	dblQty,
				@intInventoryReceiptItemId		=	intInventoryReceiptDetailId
		FROM	@ItemsFromInventoryReceipt 
		WHERE	intInventoryReceiptDetailId		=	 @intInventoryReceiptItemId
		
		IF NOT EXISTS(SELECT * FROM tblLGShipmentContractQty WHERE intShipmentContractQtyId = @intSourceId)
		BEGIN
		SELECT 1, @intSourceId, Cast(@intSourceId as varchar(100))
			SET @ErrMsg = 'Contract for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END

		IF NOT EXISTS(SELECT * FROM tblLGShipmentBLContainerContract WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId)
		BEGIN		
			SET @ErrMsg = 'Container for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END
		
		SELECT @dblContractQty = IsNull(dblReceivedQty, 0) FROM tblLGShipmentContractQty WHERE intShipmentContractQtyId = @intSourceId
		SELECT @dblContainerQty = IsNull(dblReceivedQty, 0) FROM tblLGShipmentBLContainerContract WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId		
		
		IF (@dblContractQty + @dblQty) < 0
		BEGIN		
			SET @ErrMsg = 'Negative contract quantity is not allowed'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF (@dblContainerQty + @dblQty) < 0
		BEGIN		
			SET @ErrMsg = 'Negative container quantity is not allowed'
			RAISERROR(@ErrMsg,16,1)
		END

		UPDATE tblLGShipmentContractQty 		SET dblReceivedQty = (@dblContractQty + @dblQty) WHERE intShipmentContractQtyId = @intSourceId
		UPDATE tblLGShipmentBLContainerContract SET dblReceivedQty = (@dblContainerQty + @dblQty) WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId
		
		SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt WHERE intInventoryReceiptDetailId > @intInventoryReceiptItemId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGReceived - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
