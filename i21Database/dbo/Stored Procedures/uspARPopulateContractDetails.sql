CREATE PROCEDURE [dbo].[uspARPopulateContractDetails]
	@Post BIT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @tblToProcess TABLE (
		intUniqueId					INT IDENTITY
	  , intInvoiceDetailId			INT 
	  , intInvoiceId				INT
	  , intOriginalInvoiceId		INT NULL
	  , intOriginalInvoiceDetailId	INT NULL
	  , intContractDetailId			INT 
	  , intContractHeaderId			INT NULL
	  , intItemUOMId				INT NULL
	  , intOrderUOMId				INT NULL
	  , intTicketId					INT NULL
	  , intLoadDetailId				INT NULL
	  , intPurchaseSale				INT NULL
	  , dblQty						NUMERIC(18,6)
	  , dblQtyOrdered				NUMERIC(18,6)
	  , ysnDestWtGrd				BIT
	  , dblShippedQty				NUMERIC(18,6)
	  , intShippedQtyUOMId			INT
	  , ysnFromReturn				BIT
	  , strPricing					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strBatchId					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strInvoiceNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strTransactionType			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strItemNo					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , dtmDate						DATETIME NULL
)

DELETE FROM ##ARItemsForContracts
DELETE FROM @tblToProcess
INSERT INTO @tblToProcess (
	  intInvoiceDetailId
	, intInvoiceId
	, intOriginalInvoiceId
	, intOriginalInvoiceDetailId
	, intContractDetailId
	, intContractHeaderId
	, intItemUOMId
	, intOrderUOMId
	, intTicketId
	, intLoadDetailId
	, intPurchaseSale
	, dblQty
	, dblQtyOrdered
	, ysnDestWtGrd
	, dblShippedQty
	, intShippedQtyUOMId
	, ysnFromReturn
	, strPricing
	, strBatchId
	, strInvoiceNumber
	, strTransactionType
	, strItemNo
	, dtmDate
)
SELECT intInvoiceDetailId			= ID.intInvoiceDetailId
	, intInvoiceId					= ID.intInvoiceId
	, intOriginalInvoiceId			= RI.intInvoiceId
	, intOriginalInvoiceDetailId	= IDD.intOriginalInvoiceDetailId
	, intContractDetailId			= ID.intContractDetailId
	, intContractHeaderId			= ID.intContractHeaderId
	, intItemUOMId					= ID.intItemUOMId
	, intOrderUOMId					= IDD.intOrderUOMId
	, intTicketId					= NULL--ID.intTicketId
	, intLoadDetailId				= ID.intLoadDetailId
	, intPurchaseSale				= LG.intPurchaseSale		
	, dblQty						= CASE WHEN ID.[strTransactionType] = 'Credit Memo' AND ID.[intLoadDetailId] IS NOT NULL AND ISNULL(CH.[ysnLoad], 0) = 1 
											THEN 1 
											ELSE 
												CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL AND ISI.intDestinationGradeId IS NOT NULL AND ISI.intDestinationWeightId IS NOT NULL AND ID.dblQtyShipped > ISNULL(ISI.dblQuantity, 0) AND ISNULL(CD.dblBalance, 0) = 0
														THEN ID.dblQtyShipped - ISNULL(ISI.dblQuantity, 0)
														ELSE ID.dblQtyShipped 
												END
										END * (CASE WHEN ID.[ysnPost] = 0 THEN -1.000000 ELSE 1.000000 END) * (CASE WHEN ID.[ysnIsInvoicePositive] = 0 THEN -1.000000 ELSE 1.000000 END)
	, dblQtyOrdered					= CASE WHEN ID.intSalesOrderDetailId IS NOT NULL OR (ID.intTicketId IS NOT NULL AND ISNULL(T.intTicketType, 0) <> 6 AND ISNULL(T.strInOutFlag, '') <> 'O') THEN IDD.dblQtyOrdered ELSE 0 END
	, ysnDestWtGrd					= CASE WHEN (W.strWhereFinalized = 'Destination' OR G.strWhereFinalized= 'Destination') THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, dblShippedQty					= CAST(0 AS NUMERIC(18, 6))
	, intShippedQtyUOMId			= NULL
	, ysnFromReturn					= CASE WHEN ISNULL(RI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	, strPricing					= IDD.strPricing
	, strBatchId					= ID.strBatchId
	, strInvoiceNumber				= ID.strInvoiceNumber
	, strTransactionType			= ID.strTransactionType
	, strItemNo						= ID.strItemNo
	, dtmDate						= ID.dtmDate
FROM ##ARPostInvoiceDetail ID
INNER JOIN tblARInvoiceDetail IDD ON ID.intInvoiceDetailId = IDD.intInvoiceDetailId
INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblICInventoryShipmentItem ISI ON ID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId
LEFT JOIN tblARInvoice PI ON ID.intOriginalInvoiceId = PI.intInvoiceId AND ID.ysnFromProvisional = 1 AND PI.strType = 'Provisional'
LEFT JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
LEFT JOIN tblCTWeightGrade W ON W.intWeightGradeId = T.intWeightId
LEFT JOIN tblCTWeightGrade G ON G.intWeightGradeId = T.intGradeId
LEFT JOIN (
	SELECT intLoadDetailId
		 , intPurchaseSale 
	FROM tblLGLoadDetail LGD 
	INNER JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
) LG ON ID.intLoadDetailId = LG.intLoadDetailId
OUTER APPLY (
	SELECT TOP 1 intInvoiceId 
	FROM tblARInvoice I
	WHERE I.strTransactionType = 'Invoice'
	  AND I.ysnReturned = 1
	  AND ID.strInvoiceOriginId = I.strInvoiceNumber
	  AND ID.intOriginalInvoiceId = I.intInvoiceId
) RI
WHERE ID.[intInventoryShipmentChargeId] IS NULL
	AND	(
		(ID.strTransactionType NOT IN ('Credit Memo', 'Debit Memo') AND ((ID.[intInventoryShipmentItemId] IS NULL AND (ID.[intLoadDetailId] IS NULL OR (ID.intLoadDetailId IS NOT NULL AND LG.intPurchaseSale = 3)))))
		OR
		(ID.strTransactionType = 'Credit Memo' AND (ID.[intInventoryShipmentItemId] IS NOT NULL OR ID.[intLoadDetailId] IS NOT NULL OR ISNULL(RI.[intInvoiceId], 0) <> 0))
		)
    AND ISNULL(ID.[strItemType], '') <> 'Other Charge'
	AND (ISNULL(RI.[intInvoiceId], 0) = 0 OR (ISNULL(RI.[intInvoiceId], 0) <> 0 AND (ID.intLoadDetailId IS NULL OR ID.[intTicketId] IS NOT NULL)))
	AND ((ID.ysnFromProvisional = 1 AND PI.ysnPosted = 0) OR ID.ysnFromProvisional = 0)
	AND (ISNULL(W.strWhereFinalized, '') <> 'Destination' AND ISNULL(G.strWhereFinalized, '') <> 'Destination')

--DESTINATION WEIGHTS/GRADES
IF NOT EXISTS(SELECT * FROM @tblToProcess)
	BEGIN
		INSERT INTO @tblToProcess (
			  intInvoiceDetailId
			, intInvoiceId
			, intContractDetailId
			, intContractHeaderId
			, intItemUOMId
			, dblQty
			, intTicketId
			, ysnDestWtGrd
			, dblShippedQty
			, intShippedQtyUOMId
			, intOriginalInvoiceId
			, intOriginalInvoiceDetailId
			, ysnFromReturn
			, strPricing
			, strBatchId
			, strInvoiceNumber
			, strTransactionType
			, strItemNo
			, dtmDate
		)
		SELECT intInvoiceDetailId	= MIN(I.intInvoiceDetailId)
			, intInvoiceId			= I.intInvoiceId
			, intContractDetailId	= I.intContractDetailId
			, intContractHeaderId	= I.intContractHeaderId
			, intItemUOMId			= I.intItemUOMId
			, dblQty				= SUM(CASE WHEN I.strTransactionType = 'Credit Memo' AND I.intLoadDetailId IS NOT NULL AND ISNULL(CH.ysnLoad, 0) = 1 
											THEN 1 
											ELSE 
												CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL AND S.intDestinationGradeId IS NOT NULL AND S.intDestinationWeightId IS NOT NULL AND ID.dblQtyShipped > ISNULL(S.dblQuantity, 0) AND ISNULL(CD.dblBalance, 0) = 0
														THEN ID.dblQtyShipped - ISNULL(S.dblQuantity, 0)
														ELSE ID.dblQtyShipped 
												END
										END * (CASE WHEN I.ysnPost = 0 THEN -1.000000 ELSE 1.000000 END) * (CASE WHEN I.ysnIsInvoicePositive = 0 THEN -1.000000 ELSE 1.000000 END))
			, intTicketId			= I.intTicketId
			, ysnDestWtGrd			= CAST(1 AS BIT)
			, dblShippedQty			= AVG(ISNULL(S.dblQuantity, ID.dblQtyShipped))
			, intShippedQtyUOMId	= ISNULL(S.intItemUOMId, ID.intItemUOMId)
			, intOriginalInvoiceId			= RI.intInvoiceId
			, intOriginalInvoiceDetailId	= ID.intOriginalInvoiceDetailId
			, ysnFromReturn			= CASE WHEN ISNULL(RI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
			, strPricing			= ID.strPricing	
			, strBatchId			= I.strBatchId
			, strInvoiceNumber		= I.strInvoiceNumber
			, strTransactionType	= I.strTransactionType
			, strItemNo				= I.strItemNo
			, dtmDate				= I.dtmDate
		FROM ##ARPostInvoiceDetail I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
		INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		INNER JOIN tblSCTicket T ON T.intTicketId = I.intTicketId
		INNER JOIN tblCTWeightGrade W ON W.intWeightGradeId = T.intWeightId
		INNER JOIN tblCTWeightGrade G ON G.intWeightGradeId = T.intGradeId
		LEFT JOIN tblICInventoryShipmentItem S ON S.intSourceId = I.intTicketId
										 AND S.intLineNo IS NOT NULL
										 AND I.intContractDetailId = S.intLineNo
		OUTER APPLY (
			SELECT TOP 1 intInvoiceId 
			FROM tblARInvoice INV
			WHERE INV.strTransactionType = 'Invoice'
			  AND INV.ysnReturned = 1
			  AND I.strInvoiceOriginId = INV.strInvoiceNumber
			  AND I.intOriginalInvoiceId = INV.intInvoiceId
		) RI
		WHERE I.intTicketId IS NOT NULL 
		  AND (W.strWhereFinalized = 'Destination' OR G.strWhereFinalized= 'Destination')
		  AND I.intContractDetailId IS NOT NULL
		  AND ID.intShipmentPurchaseSalesContractId IS NULL
		  AND (I.intLoadDetailId IS NULL OR (I.intLoadDetailId IS NOT NULL AND ID.strPricing = 'Subsystem - Ticket Management'))
		  AND ISNULL(I.[strItemType], '') <> 'Other Charge'
		GROUP BY I.[intInvoiceId], I.[intContractDetailId], I.[intContractHeaderId], I.[intItemUOMId], I.[intTicketId], ISNULL(S.intItemUOMId, ID.intItemUOMId), ID.[strPricing], ID.intInventoryShipmentItemId, I.strBatchId, I.strInvoiceNumber, I.strTransactionType, I.strItemNo,  I.dtmDate, RI.intInvoiceId, ID.intOriginalInvoiceDetailId
	END

DECLARE @intInvoiceDetailId				INT
	  , @intInvoiceId					INT
	  , @intOriginalInvoiceId			INT = NULL
	  , @intOriginalInvoiceDetailId		INT = NULL
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
	  , @strPricing						NVARCHAR(200) = NULL
	  , @strBatchId						NVARCHAR(200) = NULL
	  , @strInvoiceNumber				NVARCHAR(200) = NULL
	  , @strTransactionType				NVARCHAR(200) = NULL
	  , @strItemNo						NVARCHAR(200) = NULL
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
	  , @dtmDate						DATETIME = NULL

SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT @intContractDetailId			= NULL
			 , @intFromItemUOMId			= NULL
			 , @intFromItemOrderedUOMId		= NULL
			 , @dblQty						= NULL
			 , @dblQtyOrdered				= NULL
			 , @dblConvertedQtyOrdered		= NULL
			 , @intInvoiceDetailId			= NULL
			 , @intInvoiceId				= NULL
			 , @intOriginalInvoiceId		= NULL
			 , @intOriginalInvoiceDetailId	= NULL
			 , @intTicketId					= NULL
			 , @intTicketTypeId				= NULL
			 , @intTicketType				= NULL
			 , @strInOutFlag				= NULL
			 , @ysnDestWtGrd				= NULL
			 , @dblShippedQty				= NULL
			 , @intShippedQtyUOMId			= NULL
			 , @dblRemainingSchedQty		= NULL
			 , @intLoadDetailId				= NULL
			 , @intPurchaseSale				= NULL
			 , @ysnFromReturn				= CAST(0 AS BIT)
			 , @ysnLoad						= CAST(0 AS BIT)
			 , @strPricing					= NULL
			 , @strBatchId					= NULL
			 , @strInvoiceNumber			= NULL
			 , @strTransactionType			= NULL
			 , @strItemNo					= NULL
			 , @dtmDate						= NULL

		SELECT @intContractDetailId			= P.intContractDetailId
			 , @intFromItemUOMId			= P.intItemUOMId
			 , @intFromItemOrderedUOMId		= P.intOrderUOMId
			 , @dblQty						= P.dblQty
			 , @dblQtyOrdered				= P.dblQtyOrdered
			 , @intInvoiceDetailId			= P.intInvoiceDetailId
			 , @intInvoiceId				= P.intInvoiceId
			 , @intOriginalInvoiceId		= P.intOriginalInvoiceId
			 , @intOriginalInvoiceDetailId	= P.intOriginalInvoiceDetailId
			 , @ysnDestWtGrd				= P.ysnDestWtGrd
			 , @dblShippedQty				= P.dblShippedQty
			 , @intShippedQtyUOMId			= P.intShippedQtyUOMId
			 , @intLoadDetailId				= P.intLoadDetailId
			 , @intPurchaseSale				= P.intPurchaseSale
			 , @ysnFromReturn				= P.ysnFromReturn
			 , @intTicketId					= T.intTicketId
			 , @intTicketTypeId				= T.intTicketTypeId
			 , @intTicketType				= T.intTicketType
			 , @strInOutFlag				= T.strInOutFlag
			 , @intContractHeaderId			= P.intContractHeaderId
			 , @intItemId					= CD.intItemId
			 , @intCompanyLocationId		= CD.intCompanyLocationId
			 , @intEntityId					= CH.intEntityId
			 , @intPriceItemUOMId			= CD.intPriceItemUOMId
			 , @ysnBestPriceOnly			= CH.ysnBestPriceOnly
			 , @dblCashPrice				= CD.dblCashPrice
			 , @ysnLoad						= ISNULL(CH.ysnLoad, 0)
			 , @strPricing					= P.strPricing
			 , @strBatchId					= P.strBatchId
			 , @strInvoiceNumber			= P.strInvoiceNumber
			 , @strTransactionType			= P.strTransactionType
			 , @strItemNo					= P.strItemNo
			 , @dtmDate						= P.dtmDate
		FROM @tblToProcess P
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId	= P.intContractDetailId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId	= CD.intContractHeaderId
		LEFT JOIN tblSCTicket T	ON T.intTicketId =	P.intTicketId		
		WHERE intUniqueId = @intUniqueId
		
		IF @dblQty < 0
			SET @dblQtyOrdered = -@dblQtyOrdered

		SELECT @intToItemUOMId	= intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty = dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId, @intToItemUOMId, @dblQty)
		SELECT @dblConvertedQtyOrdered = dbo.fnCalculateQtyBetweenUOM(@intFromItemOrderedUOMId, @intToItemUOMId, @dblQtyOrdered)

		SELECT @dblSchQuantityToUpdate = CASE WHEN ABS(@dblQtyOrdered) > 0 AND ABS(@dblQty) > ABS(@dblQtyOrdered) THEN -@dblConvertedQtyOrdered ELSE -@dblConvertedQty END
		SELECT @dblRemainingSchedQty = @dblConvertedQtyOrdered - @dblConvertedQty

		IF	(ISNULL(@ysnDestWtGrd,0) = 0 AND
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
			OR (ISNULL(@ysnDestWtGrd,0) = 1 AND (@strPricing = 'Subsystem - Direct' OR (@intTicketType = 6 AND @intTicketTypeId = 9 AND @strInOutFlag = 'O') ) )
			)
		BEGIN
				IF	@ReduceBalance	=	1
				BEGIN
					INSERT INTO ##ARItemsForContracts (
						  intInvoiceId
						, intInvoiceDetailId
						, intOriginalInvoiceId
						, intOriginalInvoiceDetailId
						, intItemId
						, intContractDetailId
						, intContractHeaderId
						, intEntityId
						, intUserId
						, dtmDate
						, dblQuantity
						, dblBalanceQty
						, dblSheduledQty
						, dblRemainingQty
						, strType
						, strTransactionType
						, strInvoiceNumber
						, strItemNo
						, strBatchId
						, ysnFromReturn
					)
					SELECT intInvoiceId					= @intInvoiceId
						, intInvoiceDetailId			= @intInvoiceDetailId
						, intOriginalInvoiceId			= @intOriginalInvoiceId
						, intOriginalInvoiceDetailId	= @intOriginalInvoiceDetailId
						, intItemId						= @intItemId
						, intContractDetailId			= @intContractDetailId
						, intContractHeaderId			= @intContractHeaderId
						, intEntityId					= @intEntityId
						, intUserId						= @intEntityId
						, dtmDate						= @dtmDate
						, dblQuantity					= @dblConvertedQty
						, dblBalanceQty					= @dblConvertedQty
						, dblSheduledQty				= 0
						, dblRemainingQty				= 0
						, strType						= 'Contract Balance'
						, strTransactionType			= @strTransactionType
						, strInvoiceNumber				= @strInvoiceNumber
						, strItemNo						= @strItemNo
						, strBatchId					= @strBatchId
						, ysnFromReturn					= @ysnFromReturn
				END
				
				IF ISNULL(@ysnFromReturn, 0) = 0 AND (ISNULL(@intLoadDetailId, 0) = 0 OR (ISNULL(@intLoadDetailId, 0) <> 0 AND ISNULL(@intPurchaseSale, 0) = 3))
				BEGIN
					INSERT INTO ##ARItemsForContracts (
						  intInvoiceId
						, intInvoiceDetailId
						, intItemId
						, intContractDetailId
						, intContractHeaderId
						, intEntityId
						, intUserId
						, dtmDate
						, dblQuantity
						, dblBalanceQty
						, dblSheduledQty
						, dblRemainingQty
						, strType
						, strTransactionType
						, strInvoiceNumber
						, strItemNo
						, strBatchId
					)
					SELECT intInvoiceId					= @intInvoiceId
						, intInvoiceDetailId			= @intInvoiceDetailId
						, intItemId						= @intItemId
						, intContractDetailId			= @intContractDetailId
						, intContractHeaderId			= @intContractHeaderId
						, intEntityId					= @intEntityId
						, intUserId						= @intEntityId
						, dtmDate						= @dtmDate
						, dblQuantity					= @dblSchQuantityToUpdate
						, dblBalanceQty					= 0
						, dblSheduledQty				= @dblSchQuantityToUpdate
						, dblRemainingQty				= 0
						, strType						= 'Contract Scheduled'
						, strTransactionType			= @strTransactionType
						, strInvoiceNumber				= @strInvoiceNumber
						, strItemNo						= @strItemNo
						, strBatchId					= @strBatchId
										
					IF ISNULL(@dblRemainingSchedQty, 0) <> 0 AND ISNULL(@dblConvertedQtyOrdered, 0) <> 0 AND (ISNULL(@intLoadDetailId, 0) = 0 OR (ISNULL(@intLoadDetailId, 0) <> 0 AND ISNULL(@intPurchaseSale, 0) = 3)) AND @dblQty <> 0 AND ISNULL(@ysnLoad, 0) = 0
						BEGIN
							DECLARE @dblScheduleQty	NUMERIC(18, 6) = 0

							SELECT @dblScheduleQty = dblScheduleQty 
							FROM tblCTContractDetail 
							WHERE intContractDetailId = @intContractDetailId

							IF @dblRemainingSchedQty > @dblScheduleQty
								SET @dblRemainingSchedQty = @dblScheduleQty

							--IF UNPOST WITH OVERAGE CONTRACT
							SELECT @dblRemainingSchedQty = dblQtyShipped - dblQtyOrdered
							FROM tblARInvoiceDetail
							WHERE intInvoiceDetailId = @intInvoiceDetailId
							  AND intContractDetailId = @intContractDetailId
							  AND intSalesOrderDetailId IS NOT NULL
							  AND dblQtyOrdered <> dblQtyShipped
							  AND @dblQty < 0
							  	
							SET @dblRemainingSchedQty = -@dblRemainingSchedQty

							UPDATE ##ARItemsForContracts
							SET dblQuantity = dblQuantity - CASE WHEN @Post = 1 AND @dblQty > 0 THEN @dblRemainingSchedQty ELSE 0 END
							  , dblSheduledQty = dblSheduledQty - CASE WHEN @Post = 1 AND @dblQty > 0 THEN @dblRemainingSchedQty ELSE 0 END
							WHERE strType = 'Contract Scheduled'
							  AND intInvoiceDetailId = @intInvoiceDetailId
							  AND intContractDetailId = @intContractDetailId
							  AND @dblConvertedQty > @dblConvertedQtyOrdered --IF S.O. Qty is less than net qty
						END
				END
		END

		
		IF ISNULL(@ysnFromReturn, 0) = 1 AND ISNULL(@ysnDestWtGrd,0) = 1
			BEGIN
				INSERT INTO ##ARItemsForContracts (
					  intInvoiceId
					, intInvoiceDetailId
					, intOriginalInvoiceId
					, intOriginalInvoiceDetailId
					, intItemId
					, intContractDetailId
					, intContractHeaderId
					, intEntityId
					, intUserId
					, dtmDate
					, dblQuantity
					, dblBalanceQty
					, dblSheduledQty
					, dblRemainingQty
					, strType
					, strTransactionType
					, strInvoiceNumber
					, strItemNo
					, strBatchId
					, ysnFromReturn
				)
				SELECT intInvoiceId					= @intInvoiceId
					, intInvoiceDetailId			= @intInvoiceDetailId
					, intOriginalInvoiceId			= @intOriginalInvoiceId
					, intOriginalInvoiceDetailId	= @intOriginalInvoiceDetailId
					, intItemId						= @intItemId
					, intContractDetailId			= @intContractDetailId
					, intContractHeaderId			= @intContractHeaderId
					, intEntityId					= @intEntityId
					, intUserId						= @intEntityId
					, dtmDate						= @dtmDate
					, dblQuantity					= @dblConvertedQty
					, dblBalanceQty					= @dblConvertedQty
					, dblSheduledQty				= 0
					, dblRemainingQty				= 0
					, strType						= 'Contract Balance'
					, strTransactionType			= @strTransactionType
					, strInvoiceNumber				= @strInvoiceNumber
					, strItemNo						= @strItemNo
					, strBatchId					= @strBatchId
					, ysnFromReturn					= @ysnFromReturn
			END
	
		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END