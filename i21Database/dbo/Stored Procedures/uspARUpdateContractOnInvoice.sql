CREATE PROCEDURE [dbo].[uspARUpdateContractOnInvoice]  
	  @TransactionId	INT   
	, @ForDelete		BIT = 0
	, @UserId			INT = NULL	
	, @InvoiceIds		InvoiceId	READONLY	
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Get the details from the invoice 
BEGIN TRY
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice 	
	EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @TransactionId
                                      , @InvoiceIds   = @InvoiceIds


	DECLARE		@intInvoiceDetailId				INT,
				@intTicketId					INT,
				@intInventoryShipmentItemId		INT,
				@strPricing						NVARCHAR(200),
				@intContractDetailId			INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(12,4),
				@ErrMsg							NVARCHAR(MAX),
				@dblSchQuantityToUpdate			NUMERIC(12,4),
				@intLoadDetailId				INT

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInvoiceDetailId			INT,
		intContractDetailId			INT,
		intTicketId					INT,
		intInventoryShipmentItemId	INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(12,4),
		intLoadDetailId				INT
	)

	INSERT INTO @tblToProcess(
		 [intInvoiceDetailId]
		,[intContractDetailId]
		,[intTicketId]
		,[intInventoryShipmentItemId]
		,[intItemUOMId]
		,[dblQty]
		,[intLoadDetailId])

	--Quantity/UOM Changed
	SELECT
		 I.[intInvoiceDetailId]
		,D.[intContractDetailId]
		,D.[intTicketId]
		,D.[intInventoryShipmentItemId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], (CASE WHEN @ForDelete = 1 THEN D.[dblQtyShipped] ELSE (D.dblQtyShipped - TD.dblQtyShipped) END))
		, I.intLoadDetailId
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblICItem ITEM
			ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]			
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId = TD.intContractDetailId		
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.[intItemId] = TD.[intItemId]
		AND (D.intItemUOMId <> TD.intItemUOMId OR D.dblQtyShipped <> TD.dblQtyShipped)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(D.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL

	--New Contract Selected
	SELECT
		 I.[intInvoiceDetailId]
		,D.[intContractDetailId]
		,D.[intTicketId]
		,D.[intInventoryShipmentItemId]
		,D.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], D.[dblQtyShipped])
		,I.[intLoadDetailId]
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblICItem ITEM
			ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> ISNULL(TD.intContractDetailId, 0)
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(D.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL

	--Replaced Contract
	SELECT
		 I.[intInvoiceDetailId]
		,TD.[intContractDetailId]
		,D.[intTicketId]
		,D.[intInventoryShipmentItemId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		,I.[intLoadDetailId]
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblICItem ITEM
			ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> ISNULL(TD.intContractDetailId, 0)
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(D.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL
		
	--Removed Contract
	SELECT
		 I.[intInvoiceDetailId]
		,TD.[intContractDetailId]
		,D.[intTicketId]
		,D.[intInventoryShipmentItemId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		,I.[intLoadDetailId]
	FROM
		@ItemsFromInvoice I
	INNER JOIN
		tblARInvoiceDetail D
			ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN
		tblICItem ITEM
			ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice H
			ON	D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN
		tblARTransactionDetail TD
			ON D.intInvoiceDetailId = TD.intTransactionDetailId 
			AND D.intInvoiceId = TD.intTransactionId 
			AND TD.strTransactionType = 'Invoice'
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NULL
		AND TD.intContractDetailId IS NOT NULL
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(D.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL	

	--Deleted Item
	SELECT
		 TD.intTransactionDetailId
		,TD.[intContractDetailId]
		,TD.[intTicketId]
		,TD.[intInventoryShipmentItemId]
		,TD.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		,TD.[intLoadDetailId]
	FROM
		tblARTransactionDetail TD
	INNER JOIN
		tblICItem ITEM
			ON TD.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice H
			ON	TD.[intTransactionId] = H.[intInvoiceId]		
	INNER JOIN
		tblCTContractDetail CD
			ON TD.intContractDetailId = CD.intContractDetailId
	WHERE
		TD.intTransactionId = @TransactionId 
		AND TD.strTransactionType = 'Invoice'
		AND TD.intContractDetailId IS NOT NULL
		AND TD.[intInventoryShipmentItemId] IS NULL
		AND TD.[intSalesOrderDetailId] IS NULL
		-- AND TD.[intLoadDetailId] IS NULL FOR AR-8652
		AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @TransactionId)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(H.intLoadId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL
		
	--Added Item
	SELECT
		 Detail.intInvoiceDetailId
		,Detail.[intContractDetailId]
		,Detail.[intTicketId]
		,Detail.[intInventoryShipmentItemId]
		,Detail.[intItemUOMId]
		,dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyShipped])
		,Detail.[intLoadDetailId]
	FROM
		tblARInvoiceDetail Detail
	INNER JOIN
		tblICItem ITEM
			ON Detail.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN
		tblARInvoice Header
			ON Detail.intInvoiceId = Header.intInvoiceId 
	INNER JOIN
		tblCTContractDetail CD
			ON Detail.intContractDetailId = CD.intContractDetailId
	WHERE
		Detail.intInvoiceId = @TransactionId 
		AND Header.strTransactionType = 'Invoice'
		AND Detail.intContractDetailId IS NOT NULL
		AND (Detail.[intInventoryShipmentItemId] IS NULL OR (Detail.[intInventoryShipmentItemId] IS NOT NULL AND Detail.strPricing = 'Subsystem - Direct'))
		AND Detail.[intSalesOrderDetailId] IS NULL
		AND Detail.[intShipmentPurchaseSalesContractId] IS NULL 
		AND Detail.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId)
		AND (ISNULL(Header.intDistributionHeaderId, 0) = 0 AND ISNULL(Header.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(Detail.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(Header.intTransactionId, 0) = 0
		AND Header.ysnFromProvisional = 0

	UNION ALL

    --Added Item From Batch Invoice
    SELECT
         Detail.intInvoiceDetailId
        ,Detail.[intContractDetailId]
        ,Detail.[intTicketId]
        ,Detail.[intInventoryShipmentItemId]
        ,Detail.[intItemUOMId]
        ,dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyShipped]) * CASE WHEN ISNULL(IDS.ysnForDelete, 0) = 0 THEN 1 ELSE -1 END
        ,Detail.[intLoadDetailId]
    FROM tblARInvoiceDetail Detail
    INNER JOIN @InvoiceIds IDS ON Detail.intInvoiceId = IDS.intHeaderId
    INNER JOIN tblICItem ITEM ON Detail.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
    INNER JOIN tblARInvoice Header ON Detail.intInvoiceId = Header.intInvoiceId 
    INNER JOIN tblCTContractDetail CD ON Detail.intContractDetailId = CD.intContractDetailId
    WHERE Header.strTransactionType = 'Invoice'
      AND Detail.intContractDetailId IS NOT NULL
      AND Detail.[intInventoryShipmentItemId] IS NULL
      AND Detail.[intSalesOrderDetailId] IS NULL
      AND Detail.[intShipmentPurchaseSalesContractId] IS NULL 
      AND (ISNULL(Header.intDistributionHeaderId, 0) = 0 AND ISNULL(Header.intLoadDistributionHeaderId, 0) = 0)    
      AND ISNULL(Header.intTransactionId, 0) = 0
      AND @TransactionId IS NULL

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInvoiceDetailId				=	NULL,
				@intTicketId					=	NULL,
				@intInventoryShipmentItemId		=	NULL,
				@strPricing						=	NULL,
				@intLoadDetailId				=	NULL

		SELECT	@intContractDetailId			=	P.[intContractDetailId],
				@intFromItemUOMId				=	P.[intItemUOMId],
				@dblQty							=	P.[dblQty] * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END),
				@intInvoiceDetailId				=	P.[intInvoiceDetailId],
				@intTicketId					=   P.[intTicketId],
				@intInventoryShipmentItemId		=   P.[intInventoryShipmentItemId],
				@strPricing						=	ID.[strPricing],
				@intLoadDetailId				=	P.[intLoadDetailId]
		FROM	@tblToProcess P
		LEFT JOIN tblARInvoiceDetail ID ON P.intInvoiceDetailId = ID.intInvoiceDetailId

		WHERE	[intUniqueId]					=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SET @dblQty = ISNULL(@dblQty,0)

		DECLARE @intTicketTypeId	INT = NULL
			  , @intTicketType		INT = NULL
			  , @strInOutFlag		NVARCHAR(MAX) = NULL

		IF ISNULL(@intTicketId, 0) <> 0
			BEGIN
				SELECT @intTicketTypeId = intTicketTypeId
					 , @intTicketType	= intTicketType
					 , @strInOutFlag	= strInOutFlag
				FROM tblSCTicket WHERE intTicketId = @intTicketId
			END		
		IF (ISNULL(@intTicketId, 0) = 0 AND ISNULL(@intTicketTypeId, 0) <> 9 AND (ISNULL(@intTicketType, 0) <> 6 AND ISNULL(@strInOutFlag, '') <> 'O')) AND (ISNULL(@intInventoryShipmentItemId, 0) = 0) AND ISNULL(@intLoadDetailId,0) = 0 OR (@intInventoryShipmentItemId IS NOT NULL AND @strPricing = 'Subsystem - Direct')
			BEGIN
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@UserId,
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