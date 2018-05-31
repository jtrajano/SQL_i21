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
				@intTicketId					INT = NULL,
				@intTicketTypeId				INT = NULL,
			    @intTicketType					INT = NULL,
			    @strInOutFlag					NVARCHAR(MAX) = NULL,
				@dblQty							NUMERIC(18,6),
				@dblConvertedQty				NUMERIC(18,6),
				@ErrMsg							NVARCHAR(MAX),
				@dblSchQuantityToUpdate			NUMERIC(18,6),
				@intContractHeaderId			INT,
				@intItemId						INT,
				@intCompanyLocationId			INT,
				@intEntityId					INT,
				@intPriceItemUOMId				INT,
				@ysnBestPriceOnly					BIT,
				@dblLowestPrice					NUMERIC(18,6),
				@dblCashPrice					NUMERIC(18,6),
				@ReduceBalance					BIT	=	1

	--SELECT @strReceiptType = strReceiptType FROM @ItemsFromInvoice

	--IF(@strReceiptType <> 'Purchase Contract' AND @strReceiptType <> 'Purchase Order')
	--	RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInvoiceDetailId			INT,
		intContractDetailId			INT,
		intContractHeaderId			INT,
		intItemUOMId				INT,
		intTicketId					INT,
		dblQty						NUMERIC(18,6)	
	)

	INSERT INTO @tblToProcess(
		 [intInvoiceDetailId]
		,[intContractDetailId]
		,[intContractHeaderId]
		,[intItemUOMId]
		,[dblQty]
		,[intTicketId])
	SELECT
		 I.[intInvoiceDetailId]
		,I.[intContractDetailId]
		,I.[intContractHeaderId]
		,I.[intItemUOMId]
		,I.[dblQtyShipped]
		,I.[intTicketId]
	FROM
		@ItemsFromInvoice I
	WHERE
		I.intContractDetailId IS NOT NULL
		AND I.[intInventoryShipmentItemId] IS NULL
		AND I.[intShipmentPurchaseSalesContractId] IS NULL
		AND ISNULL(I.[intLoadDetailId],0) = 0
		AND ISNULL(I.[intTransactionId],0) = 0


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInvoiceDetailId				=	NULL,
				@intTicketId					=   NULL,
				@intTicketTypeId				=	NULL,
				@intTicketType					=   NULL,
				@strInOutFlag					=   NULL

		SELECT	@intContractDetailId			=	P.[intContractDetailId],
				@intFromItemUOMId				=	P.[intItemUOMId],
				@dblQty							=	P.[dblQty],
				@intInvoiceDetailId				=	P.[intInvoiceDetailId],
				@intTicketId					=   T.[intTicketId],
				@intTicketTypeId				=   T.[intTicketTypeId],
				@intTicketType					=   T.[intTicketType],
				@strInOutFlag					=   T.[strInOutFlag],

				@intContractHeaderId			=	CD.intContractHeaderId,
				@intItemId						=	CD.intItemId,
				@intCompanyLocationId			=	CD.intCompanyLocationId,
				@intEntityId					=	CH.intEntityId,
				@intPriceItemUOMId				=	CD.intPriceItemUOMId,
				@ysnBestPriceOnly					=	CH.ysnBestPriceOnly,
				@dblCashPrice					=	CD.dblCashPrice

		FROM	@tblToProcess P
		JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	P.intContractDetailId
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		LEFT JOIN  tblSCTicket T ON T.intTicketId = P.intTicketId
		WHERE	[intUniqueId]					=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)

		IF @ysnBestPriceOnly = 1
		BEGIN
			EXEC uspARGetBestItemPrice @intItemId, @intCompanyLocationId, @intEntityId, @intPriceItemUOMId, @dblLowestPrice OUTPUT

			IF	ISNULL(@dblLowestPrice,0) <> 0 AND @dblLowestPrice < @dblCashPrice
				SET	@ReduceBalance	=	0
				
		END
		-- IF ISNULL(@dblConvertedQty,0) = 0
		-- BEGIN
		-- 	RAISERROR('UOM does not exist.',16,1)
		-- END
		IF	@ReduceBalance	=	1
		BEGIN
			EXEC	uspCTUpdateSequenceBalance
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblConvertedQty,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInvoiceDetailId,
					@strScreenName			=	'Invoice' 
		END

		SELECT	@dblSchQuantityToUpdate = - @dblConvertedQty
					
		IF (ISNULL(@intTicketTypeId, 0) <> 9 AND (ISNULL(@intTicketType, 0) <> 6 AND ISNULL(@strInOutFlag, '') <> 'O'))
			BEGIN
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice' 
			END

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 