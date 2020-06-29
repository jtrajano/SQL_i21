CREATE PROCEDURE [dbo].[uspCTInvoicePosted]
	  @ItemsFromInvoice InvoiceItemTableType READONLY
	, @intUserId  INT
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intInvoiceDetailId				INT
		  , @intContractDetailId			INT
		  , @intFromItemUOMId				INT
		  , @intFromItemOrderedUOMId		INT
		  , @intToItemUOMId					INT
		  , @intUniqueId					INT
		  , @intLoadDetailId				INT = NULL
		  , @intTicketId					INT = NULL
		  , @intTicketTypeId				INT = NULL
		  , @intTicketType					INT = NULL
		  , @strInOutFlag					NVARCHAR(MAX) = NULL
		  , @dblQty							NUMERIC(18,6)
		  , @dblQtyOrdered					NUMERIC(18,6)
		  , @dblConvertedQty				NUMERIC(18,6)
		  , @dblConvertedQtyOrdered			NUMERIC(18,6)
		  , @ErrMsg							NVARCHAR(MAX)
		  , @dblSchQuantityToUpdate			NUMERIC(18,6)
		  , @dblRemainingSchedQty			NUMERIC(18,6)
		  , @intContractHeaderId			INT
		  , @intItemId						INT
		  , @intCompanyLocationId			INT
		  , @intEntityId					INT
		  , @intPriceItemUOMId				INT
		  , @ysnBestPriceOnly				BIT
		  , @dblLowestPrice					NUMERIC(18,6)
		  , @dblCashPrice					NUMERIC(18,6)
		  , @ReduceBalance					BIT	=	1
		  , @ysnDestWtGrd					BIT
		  , @dblShippedQty					NUMERIC(18,6)
		  , @intShippedQtyUOMId				INT
		  , @ysnFromReturn					BIT = 0
		  , @ysnLoad						BIT = 0
		  , @intPurchaseSale				INT = NULL

	DECLARE @tblToProcess TABLE (
		  intUniqueId				INT IDENTITY
		, intInvoiceDetailId		INT
		, intContractDetailId		INT
		, intContractHeaderId		INT
		, intItemUOMId				INT
		, intOrderUOMId				INT
		, intTicketId				INT
		, intLoadDetailId			INT
		, dblQty					NUMERIC(18,6)
		, dblQtyOrdered				NUMERIC(18,6)
		, ysnDestWtGrd				BIT
		, dblShippedQty				NUMERIC(18,6)
		, intShippedQtyUOMId		INT
		, ysnFromReturn				BIT	
	)

	INSERT INTO @tblToProcess (
		  [intInvoiceDetailId]
		, [intContractDetailId]
		, [intContractHeaderId]
		, [intItemUOMId]
		, [intOrderUOMId]
		, [dblQty]
		, [dblQtyOrdered]
		, [ysnDestWtGrd]
		, [intTicketId]
		, [intLoadDetailId]
		, [ysnFromReturn]
	)
	SELECT [intInvoiceDetailId] 	= I.[intInvoiceDetailId]
		, [intContractDetailId]		= I.[intContractDetailId]
		, [intContractHeaderId]		= I.[intContractHeaderId]
		, [intItemUOMId]			= I.[intItemUOMId]
		, [intOrderUOMId]			= ID.[intOrderUOMId]
		, [dblQty]					= I.[dblQtyShipped]
		, [dblQtyOrdered]			= CASE WHEN ID.intSalesOrderDetailId IS NOT NULL OR (ID.intTicketId IS NOT NULL AND ISNULL(intTicketType, 0) <> 6 AND ISNULL(strInOutFlag, '') <> 'O') THEN ID.[dblQtyOrdered] ELSE 0 END
		, [ysnDestWtGrd]			= CAST(0 AS BIT)
		, [intTicketId]				= NULL
		, [intLoadDetailId]			= ID.[intLoadDetailId]
		, [ysnFromReturn]			= CASE WHEN ISNULL(RI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
	LEFT JOIN (
		SELECT intLoadDetailId
			, intPurchaseSale 
		FROM tblLGLoadDetail LGD 
		INNER JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
	) LG ON ID.intLoadDetailId = LG.intLoadDetailId
	LEFT JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
	OUTER APPLY (
		SELECT TOP 1 intInvoiceId 
		FROM tblARInvoice I
		WHERE I.strTransactionType = 'Invoice'
		AND I.ysnReturned = 1
		AND INV.strInvoiceOriginId = I.strInvoiceNumber
		AND INV.intOriginalInvoiceId = I.intInvoiceId
	) RI
	WHERE I.intContractDetailId IS NOT NULL
	AND (
		(I.strTransactionType <> 'Credit Memo' AND I.[intInventoryShipmentItemId] IS NULL AND I.[intShipmentPurchaseSalesContractId] IS NULL AND (I.[intLoadDetailId] IS NULL OR (I.intLoadDetailId IS NOT NULL AND ISNULL(LG.intPurchaseSale, 0) = 3)))
		OR
		(I.strTransactionType = 'Credit Memo' AND (I.[intInventoryShipmentItemId] IS NOT NULL OR I.[intShipmentPurchaseSalesContractId] IS NOT NULL OR I.[intLoadDetailId] IS NOT NULL OR ISNULL(RI.[intInvoiceId], 0) <> 0))
	)

	IF NOT EXISTS(SELECT * FROM @tblToProcess)
	BEGIN
		INSERT INTO @tblToProcess (
			  [intInvoiceDetailId]
			, [intContractDetailId]
			, [intContractHeaderId]
			, [intItemUOMId]
			, [dblQty]
			, [intTicketId]
			, [ysnDestWtGrd]
			, [dblShippedQty]
			, [intShippedQtyUOMId]
		)
		SELECT I.[intInvoiceDetailId]
			, I.[intContractDetailId]
			, I.[intContractHeaderId]
			, I.[intItemUOMId]
			, I.[dblQtyShipped]
			, I.[intTicketId]
			, 1
			, S.dblQuantity
			, S.intItemUOMId
		FROM @ItemsFromInvoice	I
		JOIN tblSCTicket T ON T.intTicketId	= I.intTicketId
		JOIN tblCTWeightGrade W	ON W.intWeightGradeId =	T.intWeightId
		JOIN tblCTWeightGrade G	ON G.intWeightGradeId =	T.intGradeId
		JOIN tblICInventoryShipmentItem	S ON S.intSourceId =	I.intTicketId
										 AND S.intLineNo IS NOT NULL
										 AND I.intContractDetailId =	S.intLineNo
		WHERE I.intTicketId IS NOT NULL AND (W.strWhereFinalized	= 'Destination' 
											OR G.strWhereFinalized	= 'Destination')
		AND	I.intContractDetailId IS NOT NULL
		AND	I.[intShipmentPurchaseSalesContractId] IS NULL
		AND	ISNULL(I.[intLoadDetailId],0) = 0
		AND	ISNULL(I.[intTransactionId],0) = 0
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@intFromItemOrderedUOMId		=	NULL,
				@dblQty							=	NULL,
				@dblQtyOrdered					=	NULL,
				@dblConvertedQtyOrdered			=	NULL,
				@intInvoiceDetailId				=	NULL,
				@intTicketId					=   NULL,
				@intTicketTypeId				=	NULL,
				@intTicketType					=   NULL,
				@strInOutFlag					=   NULL,
				@ysnDestWtGrd					=	NULL,
				@dblShippedQty					=	NULL,
				@intShippedQtyUOMId				=	NULL,
				@dblRemainingSchedQty			=	NULL,
				@intLoadDetailId				=	NULL,
				@intPurchaseSale				=	NULL,
				@ysnFromReturn					=	CAST(0 AS BIT),
				@ysnLoad						=	CAST(0 AS BIT)

		SELECT	@intContractDetailId			=	P.[intContractDetailId],
				@intFromItemUOMId				=	P.[intItemUOMId],
				@intFromItemOrderedUOMId		=	P.[intOrderUOMId],
				@dblQty							=	P.[dblQty],
				@dblQtyOrdered					=	P.[dblQtyOrdered],
				@intInvoiceDetailId				=	P.[intInvoiceDetailId],
				@ysnDestWtGrd					=	P.[ysnDestWtGrd],
				@dblShippedQty					=	P.[dblShippedQty],
				@intShippedQtyUOMId				=	P.[intShippedQtyUOMId],
				@intLoadDetailId				=	P.[intLoadDetailId],
				@intPurchaseSale				=	LG.[intPurchaseSale],
				@ysnFromReturn					=	P.[ysnFromReturn],

				@intTicketId					=   T.[intTicketId],
				@intTicketTypeId				=   T.[intTicketTypeId], --SELECT * FROM tblSCListTicketTypes
				@intTicketType					=   T.[intTicketType],
				@strInOutFlag					=   T.[strInOutFlag],

				@intContractHeaderId			=	CD.intContractHeaderId,
				@intItemId						=	CD.intItemId,
				@intCompanyLocationId			=	CD.intCompanyLocationId,
				@intEntityId					=	CH.intEntityId,
				@intPriceItemUOMId				=	CD.intPriceItemUOMId,
				@ysnBestPriceOnly				=	CH.ysnBestPriceOnly,
				@dblCashPrice					=	CD.dblCashPrice,
				@ysnLoad						=	ISNULL(CH.ysnLoad, 0)

		FROM	@tblToProcess P
		JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	P.intContractDetailId
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
   LEFT JOIN	tblSCTicket			T	ON	T.intTicketId			=	P.intTicketId
   LEFT JOIN 	(
					SELECT intLoadDetailId
						 , intPurchaseSale 
					FROM tblLGLoadDetail LGD 
					INNER JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
				) LG ON P.intLoadDetailId = LG.intLoadDetailId
		WHERE	[intUniqueId]		=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		IF @dblQty < 0
			SET @dblQtyOrdered = -@dblQtyOrdered

		SELECT @intToItemUOMId	= intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty = dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId, @intToItemUOMId, @dblQty)
		SELECT @dblConvertedQtyOrdered = dbo.fnCalculateQtyBetweenUOM(@intFromItemOrderedUOMId, @intToItemUOMId, @dblQtyOrdered)

		IF @ysnBestPriceOnly = 1
		BEGIN
			EXEC uspARGetBestItemPrice @intItemId, @intCompanyLocationId, @intEntityId, @intPriceItemUOMId, @dblLowestPrice OUTPUT

			IF	ISNULL(@dblLowestPrice,0) <> 0 AND @dblLowestPrice < @dblCashPrice
				SET	@ReduceBalance	=	0
				
		END

		SELECT @dblSchQuantityToUpdate = CASE WHEN ABS(@dblQtyOrdered) > 0 AND ABS(@dblQty) > ABS(@dblQtyOrdered) THEN -@dblConvertedQtyOrdered ELSE -@dblConvertedQty END
		SELECT @dblRemainingSchedQty = @dblConvertedQtyOrdered - @dblConvertedQty

		IF	ISNULL(@ysnDestWtGrd,0) = 0 AND
			(
				(
					ISNULL(@intTicketTypeId, 0) <> 9 AND 
					(ISNULL(@intTicketType, 0) <> 6 AND ISNULL(@strInOutFlag, '') <> 'O')
				) OR 
				(
					ISNULL(@intTicketTypeId, 0) = 2 AND 
					(ISNULL(@intTicketType, 0) =1 AND ISNULL(@strInOutFlag, '') = 'O')
				)
			)
		BEGIN
				IF	@ReduceBalance	=	1
				BEGIN
					EXEC	uspCTUpdateSequenceBalance
							@intContractDetailId	=	@intContractDetailId,
							@dblQuantityToUpdate	=	@dblConvertedQty,
							@intUserId				=	@intUserId,
							@intExternalId			=	@intInvoiceDetailId,
							@strScreenName			=	'Invoice',
							@ysnFromInvoice 		= 	1  	 
				END
				
				IF ISNULL(@ysnFromReturn, 0) = 0 AND (ISNULL(@intLoadDetailId, 0) = 0 OR (ISNULL(@intLoadDetailId, 0) <> 0 AND ISNULL(@intPurchaseSale, 0) = 3))
				BEGIN
					EXEC	uspCTUpdateScheduleQuantity
							@intContractDetailId	=	@intContractDetailId,
							@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
							@intUserId				=	@intUserId,
							@intExternalId			=	@intInvoiceDetailId,
							@strScreenName			=	'Invoice' 
				
					IF ISNULL(@dblRemainingSchedQty, 0) <> 0 AND ISNULL(@dblConvertedQtyOrdered, 0) <> 0 AND (ISNULL(@intLoadDetailId, 0) = 0 OR (ISNULL(@intLoadDetailId, 0) <> 0 AND ISNULL(@intPurchaseSale, 0) = 3)) AND @dblQty <> 0 AND ISNULL(@ysnLoad, 0) = 0
						BEGIN
							DECLARE @dblScheduleQty	NUMERIC(18, 6) = 0

							SELECT @dblScheduleQty = dblScheduleQty 
							FROM tblCTContractDetail 
							WHERE intContractDetailId = @intContractDetailId

							IF @dblRemainingSchedQty > @dblScheduleQty
								SET @dblRemainingSchedQty = @dblScheduleQty
								
							SET @dblRemainingSchedQty = -@dblRemainingSchedQty

							EXEC uspCTUpdateScheduleQuantity @intContractDetailId	= @intContractDetailId
														, @dblQuantityToUpdate		= @dblRemainingSchedQty
														, @intUserId				= @intUserId
														, @intExternalId			= @intInvoiceDetailId
														, @strScreenName			= 'Invoice' 
						END
				END
		END

		IF @ysnDestWtGrd = 1
		BEGIN
			IF @dblQty > 0 -- Post
			BEGIN
				SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intShippedQtyUOMId,@intToItemUOMId,@dblShippedQty) * -1	

				EXEC	uspCTUpdateSequenceBalance
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblConvertedQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice',
						@ysnFromInvoice 		= 	1  	 

				SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)

				EXEC	uspCTUpdateSequenceBalance
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblConvertedQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice',
						@ysnFromInvoice 		= 	1  	
			END
			ELSE --Unpost
			BEGIN
				SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)

				EXEC	uspCTUpdateSequenceBalance
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblConvertedQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice',
						@ysnFromInvoice 		= 	1  	
						
				SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intShippedQtyUOMId,@intToItemUOMId,@dblShippedQty) 	

				EXEC	uspCTUpdateSequenceBalance
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblConvertedQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice',
						@ysnFromInvoice 		= 	1  	
			END
		END

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
 
