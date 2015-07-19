CREATE PROCEDURE [dbo].[uspCTReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY ,
	@intUserId  INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE		@intInventoryReceiptDetailId INT,
				@intContractDetailId INT,
				@intFromItemUOMId		INT,
				@intToItemUOMId		INT,
				@dblQty				NUMERIC(12,4),
				@dblConvertedQty				NUMERIC(12,4)

	SELECT @intInventoryReceiptDetailId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt

	WHILE ISNULL(@intInventoryReceiptDetailId,0) > 0
	BEGIN
		SELECT	@intContractDetailId	=	NULL,
				@intFromItemUOMId		=	NULL,
				@dblQty					=	NULL

		SELECT	@intContractDetailId	=	intLineNo,
				@intFromItemUOMId		=	intItemUOMId,
				@dblQty					=	dblQty
		FROM	@ItemsFromInventoryReceipt WHERE intInventoryReceiptDetailId = @intInventoryReceiptDetailId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)

		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END

		EXEC uspCTUpdateSequenceBalance @intContractDetailId,@dblConvertedQty,@intUserId,@intInventoryReceiptDetailId

		SELECT @intInventoryReceiptDetailId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt WHERE intInventoryReceiptDetailId > @intInventoryReceiptDetailId
	END

END 