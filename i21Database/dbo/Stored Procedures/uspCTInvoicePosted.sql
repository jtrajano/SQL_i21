CREATE PROCEDURE [dbo].[uspCTInvoicePosted]
	@ItemsFromInvoice InvoiceItemTableType READONLY
	,@intUserId  INT
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE		@intInvoiceDetailId				INT,
				@intContractDetailId			INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(18,6),
				@dblConvertedQty				NUMERIC(18,6),
				@ErrMsg							NVARCHAR(MAX),
				@dblSchQuantityToUpdate			NUMERIC(18,6)

	--SELECT @strReceiptType = strReceiptType FROM @ItemsFromInvoice

	--IF(@strReceiptType <> 'Purchase Contract' AND @strReceiptType <> 'Purchase Order')
	--	RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInvoiceDetailId			INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(18,6)	
	)

	INSERT INTO @tblToProcess(
		 [intInvoiceDetailId]
		,[intContractDetailId]
		,[intItemUOMId]
		,[dblQty])
	SELECT
		 I.[intInvoiceDetailId]
		,I.[intContractDetailId]
		,I.[intItemUOMId]
		,I.[dblQtyShipped]
	FROM
		@ItemsFromInvoice I
	WHERE
		I.intContractDetailId IS NOT NULL
		AND I.[intInventoryShipmentItemId] IS NULL
		AND I.[intShipmentPurchaseSalesContractId] IS NULL
		AND ISNULL(I.[intLoadDetailId],0) = 0


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInvoiceDetailId	=	NULL

		SELECT	@intContractDetailId			=	[intContractDetailId],
				@intFromItemUOMId				=	[intItemUOMId],
				@dblQty							=	[dblQty],
				@intInvoiceDetailId				=	[intInvoiceDetailId]
		FROM	@tblToProcess 
		WHERE	[intUniqueId]					=	 @intUniqueId

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
				@intExternalId			=	@intInvoiceDetailId,
				@strScreenName			=	'Invoice' 

		SELECT	@dblSchQuantityToUpdate = - @dblConvertedQty
					
		EXEC	uspCTUpdateScheduleQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intInvoiceDetailId,
				@strScreenName			=	'Invoice' 

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 