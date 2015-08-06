CREATE PROCEDURE [dbo].[uspCTReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY
	,@intUserId  INT
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE		@intInventoryReceiptDetailId	INT,
				@intContractDetailId			INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(12,4),
				@dblConvertedQty				NUMERIC(12,4),
				@ErrMsg							NVARCHAR(MAX),
				@strReceiptType					NVARCHAR(50),
				@dblSchQuantityToUpdate			NUMERIC(12,4),
				@intSourceType					INT

	SELECT @strReceiptType = strReceiptType,@intSourceType = intSourceType FROM @ItemsFromInventoryReceipt

	IF(@strReceiptType <> 'Purchase Contract' AND @strReceiptType <> 'Purchase Order')
		RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInventoryReceiptDetailId INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4)	
	)

	IF(@strReceiptType = 'Purchase Contract')
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryReceiptDetailId,intContractDetailId,intItemUOMId,dblQty)
		SELECT 	intInventoryReceiptDetailId,intLineNo,intItemUOMId,	dblQty
		FROM	@ItemsFromInventoryReceipt
	END
	ELSE
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryReceiptDetailId,intContractDetailId,intItemUOMId,dblQty)
		SELECT 	IR.intInventoryReceiptDetailId,PO.intContractDetailId,IR.intItemUOMId,IR.dblQty
		FROM	@ItemsFromInventoryReceipt	IR
		JOIN	tblPOPurchaseDetail			PO	ON	PO.intPurchaseDetailId	=	IR.intLineNo
		WHERE	PO.intContractDetailId		IS	NOT NULL
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInventoryReceiptDetailId	=	NULL

		SELECT	@intContractDetailId			=	intContractDetailId,
				@intFromItemUOMId				=	intItemUOMId,
				@dblQty							=	dblQty,
				@intInventoryReceiptDetailId	=	intInventoryReceiptDetailId
		FROM	@tblToProcess 
		WHERE	intUniqueId						=	 @intUniqueId

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

		EXEC	uspCTUpdateSequenceBalance
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intInventoryReceiptDetailId,
				@strScreenName			=	'Inventory Receipt' 

		SELECT	@dblSchQuantityToUpdate = -@dblConvertedQty

		IF @intSourceType = 3
		BEGIN					
			EXEC	uspCTUpdateScheduleQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblSchQuantityToUpdate
		END

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReceived - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 