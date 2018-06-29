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
				@dblQty							NUMERIC(18,6),
				@dblConvertedQty				NUMERIC(18,6),
				@ErrMsg							NVARCHAR(MAX),
				@strReceiptType					NVARCHAR(50),
				@dblSchQuantityToUpdate			NUMERIC(18,6),
				@intSourceType					INT,
				@ysnPO							BIT,
				@ysnLoad						BIT,
				@intPricingTypeId				INT,
				@strScreenName					NVARCHAR(50),
				@intContainerId					INT

	SELECT @strReceiptType = strReceiptType,@intSourceType = intSourceType FROM @ItemsFromInventoryReceipt

	SELECT @strScreenName = CASE WHEN @strReceiptType = 'Inventory Return' THEN 'Receipt Return' ELSE 'Inventory Receipt' END

	IF	@strReceiptType NOT IN ('Purchase Contract','Purchase Order', 'Inventory Return')
		RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInventoryReceiptDetailId INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(18,6),
		intContainerId				INT,
		ysnLoad						BIT
	)

	IF @strReceiptType IN ('Purchase Contract','Inventory Return')
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryReceiptDetailId,intContractDetailId,intItemUOMId,dblQty, intContainerId, ysnLoad)
		SELECT 	intInventoryReceiptDetailId,intLineNo,IR.intItemUOMId,CASE WHEN CH.ysnLoad=1 THEN IR.intLoadReceive ELSE dblQty END, intContainerId, CH.ysnLoad
		FROM	@ItemsFromInventoryReceipt	IR
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	IR.intLineNo
		JOIN	tblCTContractHeader			CH	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	ISNULL(intLineNo,0) > 0
	END
	ELSE IF(@strReceiptType = 'Purchase Order')
	BEGIN
		SELECT	@ysnPO = 1
		INSERT	INTO @tblToProcess (intInventoryReceiptDetailId,intContractDetailId,intItemUOMId,dblQty, ysnLoad)
		SELECT 	IR.intInventoryReceiptDetailId,PO.intContractDetailId,IR.intItemUOMId,CASE WHEN CH.ysnLoad=1 THEN IR.intLoadReceive ELSE IR.dblQty END, CH.ysnLoad
		FROM	@ItemsFromInventoryReceipt	IR
		JOIN	tblPOPurchaseDetail			PO	ON	PO.intPurchaseDetailId	=	IR.intLineNo
		JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId	=	PO.intContractDetailId
		JOIN	tblCTContractHeader			CH	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	PO.intContractDetailId		IS	NOT NULL
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInventoryReceiptDetailId	=	NULL,
				@intContainerId					=	NULL

		SELECT	@intContractDetailId			=	intContractDetailId,
				@intFromItemUOMId				=	intItemUOMId,
				@dblQty							=	dblQty,
				@intInventoryReceiptDetailId	=	intInventoryReceiptDetailId, 
				@intContainerId					=	intContainerId,
				@ysnLoad						=	ysnLoad
		FROM	@tblToProcess 
		WHERE	intUniqueId						=	 @intUniqueId

		SELECT	@intPricingTypeId = intPricingTypeId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	CASE WHEN @ysnLoad=1 THEN @dblQty ELSE dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty) END

		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END

		IF @intSourceType IN (1,5) AND @intPricingTypeId = 5
		BEGIN
			EXEC	uspCTUpdateSequenceQuantity 
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblConvertedQty,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInventoryReceiptDetailId,
					@strScreenName			=	@strScreenName
		END
		ELSE
		BEGIN
			EXEC	uspCTUpdateSequenceBalance
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblConvertedQty,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInventoryReceiptDetailId,
					@strScreenName			=	@strScreenName 

			SELECT	@dblSchQuantityToUpdate = -@dblConvertedQty

			IF ((@intSourceType IN (0,1,2,3,5) OR @ysnPO = 1)AND @strReceiptType <> 'Inventory Return')  OR 
			   (@intSourceType IN (2) AND @strReceiptType = 'Inventory Return')
			BEGIN					
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInventoryReceiptDetailId,
						@strScreenName			=	@strScreenName
			END

			IF(@intSourceType IN (2) AND @strReceiptType = 'Inventory Return')
			BEGIN
				EXEC uspLGRejectContainer @intLoadContainerId = @intContainerId
										 ,@intContractDetailId = @intContractDetailId
										 ,@ysnRejectContainer = 1
										 ,@intEntityUserId = @intUserId
										 ,@strScreenName = 'Inventory Return'
			END
		END
		

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 