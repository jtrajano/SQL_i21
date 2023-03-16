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
				@dblQtyOrdered					NUMERIC(12,4),
				@ErrMsg							NVARCHAR(MAX),
				@dblSchQuantityToUpdate			NUMERIC(12,4),
				@intLoadDetailId				INT

	DECLARE @tblToProcess TABLE (
		  intUniqueId					INT IDENTITY
		, intInvoiceDetailId			INT
		, intContractDetailId			INT
		, intTicketId					INT
		, intInventoryShipmentItemId	INT
		, intItemUOMId					INT
		, dblQty						NUMERIC(12,4)
		, intLoadDetailId				INT
		, intDispatchId					INT NULL
		, ysnMobileBilling				BIT NOT NULL DEFAULT (0)
	)

	INSERT INTO @tblToProcess (
		  [intInvoiceDetailId]
		, [intContractDetailId]
		, [intTicketId]
		, [intInventoryShipmentItemId]
		, [intItemUOMId]
		, [dblQty]
		, [intLoadDetailId]
		, [intDispatchId]
		, [ysnMobileBilling]
	)
	--Quantity/UOM Changed
	SELECT [intInvoiceDetailId]			= I.[intInvoiceDetailId]
		, [intContractDetailId]			= D.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= D.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], (CASE WHEN @ForDelete = 1 THEN D.[dblQtyShipped] ELSE (D.dblQtyShipped - TD.dblQtyShipped) END))
		, [intLoadDetailId]				= I.[intLoadDetailId]
		, [intDispatchId]				= D.[intDispatchId]
		, [ysnMobileBilling]		    = 0
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail D ON I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN tblICItem ITEM ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice H ON D.[intInvoiceId] = H.[intInvoiceId]			
	INNER JOIN tblARTransactionDetail TD ON D.intInvoiceDetailId = TD.intTransactionDetailId 
										AND D.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN tblCTContractDetail CD ON D.intContractDetailId = CD.intContractDetailId
	WHERE D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId = TD.intContractDetailId		
		AND D.[intInventoryShipmentItemId] IS NULL
		AND (D.[intSalesOrderDetailId] IS NULL OR D.strPricing = 'MANUAL OVERRIDE')
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.[intItemId] = TD.[intItemId]
		AND (D.intItemUOMId <> TD.intItemUOMId OR D.dblQtyShipped <> TD.dblQtyShipped)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)		
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL

	--New Contract Selected
	SELECT [intInvoiceDetailId]			= I.[intInvoiceDetailId]
		, [intContractDetailId]			= D.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= D.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], D.[dblQtyShipped])
		, [intLoadDetailId]				= I.[intLoadDetailId]
		, [intDispatchId]				= D.[intDispatchId]
		, [ysnMobileBilling]		    = 0
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail D ON I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN tblICItem ITEM ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice H ON D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN tblARTransactionDetail TD ON D.intInvoiceDetailId = TD.intTransactionDetailId 
										AND D.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN tblCTContractDetail CD ON D.intContractDetailId = CD.intContractDetailId
	WHERE D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> ISNULL(TD.intContractDetailId, 0)
		AND D.[intInventoryShipmentItemId] IS NULL
		AND (D.[intSalesOrderDetailId] IS NULL OR D.strPricing = 'MANUAL OVERRIDE')
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL

	--Replaced Contract
	SELECT [intInvoiceDetailId]			= I.[intInvoiceDetailId]
		, [intContractDetailId]			= TD.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= TD.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		, [intLoadDetailId]				= I.[intLoadDetailId]
		, [intDispatchId]				= D.[intDispatchId]
		, [ysnMobileBilling]		    = 0
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail D ON I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN tblICItem ITEM ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice H ON D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN tblARTransactionDetail TD ON D.intInvoiceDetailId = TD.intTransactionDetailId 
										AND D.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN tblCTContractDetail CD ON TD.intContractDetailId = CD.intContractDetailId
	WHERE D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> ISNULL(TD.intContractDetailId, 0)
		AND D.[intInventoryShipmentItemId] IS NULL
		AND (D.[intSalesOrderDetailId] IS NULL OR D.strPricing = 'MANUAL OVERRIDE')
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId = TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL
		
	--Removed Contract
	SELECT [intInvoiceDetailId]			= I.[intInvoiceDetailId]
		, [intContractDetailId]			= TD.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= TD.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		, [intLoadDetailId]				= I.[intLoadDetailId]
		, [intDispatchId]				= D.[intDispatchId]
		, [ysnMobileBilling]		    = 0
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail D ON I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN tblICItem ITEM ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice H ON D.[intInvoiceId] = H.[intInvoiceId]				
	INNER JOIN tblARTransactionDetail TD ON D.intInvoiceDetailId = TD.intTransactionDetailId 
										AND D.intInvoiceId = TD.intTransactionId 
										AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN tblCTContractDetail CD ON TD.intContractDetailId = CD.intContractDetailId
	WHERE D.intContractDetailId IS NULL
		AND TD.intContractDetailId IS NOT NULL
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL	

	--Replaced existing Item with new Item with Contract
	SELECT
		  [intInvoiceDetailId]			= D.intInvoiceDetailId
		, [intContractDetailId]			= D.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= D.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], D.[dblQtyShipped])
		, [intLoadDetailId]				= D.[intLoadDetailId]
		, [intDispatchId]				= TD.intDispatchId
		, [ysnMobileBilling]		    = 0
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
			AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN
		tblCTContractDetail CD
			ON D.intContractDetailId = CD.intContractDetailId
	WHERE
		D.intContractDetailId IS NOT NULL
		AND D.intContractDetailId <> ISNULL(TD.intContractDetailId, 0)
		AND D.[intInventoryShipmentItemId] IS NULL
		AND (D.[intSalesOrderDetailId] IS NULL OR D.strPricing = 'MANUAL OVERRIDE')
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND D.intItemId <> TD.intItemId
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		-- AND ISNULL(D.intLoadDetailId, 0) = 0 FOR AR-8652
		AND ISNULL(H.intTransactionId, 0) = 0

	UNION ALL	

	--Deleted Item
	SELECT [intInvoiceDetailId]			= TD.intTransactionDetailId
		, [intContractDetailId]			= TD.[intContractDetailId]
		, [intTicketId]					= TD.[intTicketId]
		, [intInventoryShipmentItemId]	= TD.[intInventoryShipmentItemId]
		, [intItemUOMId]				= TD.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(TD.[intItemUOMId], CD.[intItemUOMId], (TD.[dblQtyShipped] * -1))
		, [intLoadDetailId]				= TD.[intLoadDetailId]
		, [intDispatchId]				= TD.intDispatchId
		, [ysnMobileBilling]		    = 0
	FROM tblARTransactionDetail TD
	INNER JOIN tblICItem ITEM ON TD.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice H ON TD.[intTransactionId] = H.[intInvoiceId]		
	INNER JOIN tblCTContractDetail CD ON TD.intContractDetailId = CD.intContractDetailId
	WHERE TD.intTransactionId = @TransactionId 
		AND TD.strTransactionType IN ('Cash', 'Invoice')
		AND TD.intContractDetailId IS NOT NULL
		AND TD.[intInventoryShipmentItemId] IS NULL
		AND TD.[intSalesOrderDetailId] IS NULL
		AND TD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @TransactionId)
		AND (ISNULL(H.intDistributionHeaderId, 0) = 0 AND ISNULL(H.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(H.intTransactionId, 0) = 0
		
	UNION ALL
		
	--Added Item
	SELECT [intInvoiceDetailId]			= Detail.intInvoiceDetailId
		, [intContractDetailId]			= Detail.[intContractDetailId]
		, [intTicketId]					= Detail.[intTicketId]
		, [intInventoryShipmentItemId]	= Detail.[intInventoryShipmentItemId]
		, [intItemUOMId]				= Detail.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyShipped])
		, [intLoadDetailId]				= Detail.[intLoadDetailId]
		, [intDispatchId]					= Detail.[intDispatchId]
		, [ysnMobileBilling]		    = CASE WHEN  ISNULL(MBIL.strInvoiceNo, '') = ''   THEN 0 ELSE 1 END
	FROM tblARInvoiceDetail Detail
	INNER JOIN tblICItem ITEM ON Detail.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblARInvoice Header ON Detail.intInvoiceId = Header.intInvoiceId 
	INNER JOIN tblCTContractDetail CD ON Detail.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblMBILInvoice MBIL ON Header.strInvoiceNumber = MBIL.strInvoiceNo
	WHERE Detail.intInvoiceId = @TransactionId 
		AND Header.strTransactionType IN ('Cash', 'Invoice')
		AND Detail.intContractDetailId IS NOT NULL
		AND (Detail.[intInventoryShipmentItemId] IS NULL OR (Detail.[intInventoryShipmentItemId] IS NOT NULL AND Detail.strPricing = 'Subsystem - Direct'))
		AND (Detail.intSalesOrderDetailId IS NULL OR (Detail.intSalesOrderDetailId IS NOT NULL AND Detail.strPricing = 'Subsystem - Direct'))
		AND Detail.[intShipmentPurchaseSalesContractId] IS NULL 
		AND Detail.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId)
		AND (ISNULL(Header.intDistributionHeaderId, 0) = 0 AND ISNULL(Header.intLoadDistributionHeaderId, 0) = 0)
		AND ISNULL(Header.intTransactionId, 0) = 0
		AND Header.ysnFromProvisional = 0

	UNION ALL

    --Added Item From Batch Invoice
    SELECT [intInvoiceDetailId]			= Detail.intInvoiceDetailId
		, [intContractDetailId]			= Detail.[intContractDetailId]
		, [intTicketId]					= Detail.[intTicketId]
		, [intInventoryShipmentItemId]	= Detail.[intInventoryShipmentItemId]
		, [intItemUOMId]				= Detail.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(Detail.[intItemUOMId], CD.[intItemUOMId], Detail.[dblQtyShipped]) * CASE WHEN ISNULL(IDS.ysnForDelete, 0) = 0 THEN 1 ELSE -1 END
		, [intLoadDetailId]				= Detail.[intLoadDetailId]
		, [intDispatchId]					= Detail.[intDispatchId]
		, [ysnMobileBilling]		    = CASE WHEN  ISNULL(MBIL.strInvoiceNo, '') = ''   THEN 0 ELSE 1 END
    FROM tblARInvoiceDetail Detail
    INNER JOIN @InvoiceIds IDS ON Detail.intInvoiceId = IDS.intHeaderId
    INNER JOIN tblICItem ITEM ON Detail.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
    INNER JOIN tblARInvoice Header ON Detail.intInvoiceId = Header.intInvoiceId 
    INNER JOIN tblCTContractDetail CD ON Detail.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblMBILInvoice MBIL ON Header.strInvoiceNumber = MBIL.strInvoiceNo
    WHERE Header.strTransactionType IN ('Cash', 'Invoice')
      AND Detail.intContractDetailId IS NOT NULL
      AND Detail.[intInventoryShipmentItemId] IS NULL
      AND Detail.[intSalesOrderDetailId] IS NULL
      AND Detail.[intShipmentPurchaseSalesContractId] IS NULL 
      AND (ISNULL(Header.intDistributionHeaderId, 0) = 0 AND ISNULL(Header.intLoadDistributionHeaderId, 0) = 0)    
      AND ISNULL(Header.intTransactionId, 0) = 0
      AND @TransactionId IS NULL

	UNION ALL

	SELECT [intInvoiceDetailId]			= I.[intInvoiceDetailId]
		, [intContractDetailId]			= D.[intContractDetailId]
		, [intTicketId]					= D.[intTicketId]
		, [intInventoryShipmentItemId]	= D.[intInventoryShipmentItemId]
		, [intItemUOMId]				= D.[intItemUOMId]
		, [dblQty]						= dbo.fnCalculateQtyBetweenUOM(D.[intItemUOMId], CD.[intItemUOMId], (CASE WHEN @ForDelete = 1 THEN D.[dblQtyShipped] ELSE -D.dblQtyShipped END))
		, [intLoadDetailId]				= I.intLoadDetailId
		, [intDispatchId]					= D.[intDispatchId]
		, [ysnMobileBilling]		    = CASE WHEN  ISNULL(MBIL.strInvoiceNo, '') = ''   THEN 0 ELSE 1 END
	FROM @ItemsFromInvoice I
	INNER JOIN tblARInvoiceDetail D ON	I.[intInvoiceDetailId] = D.[intInvoiceDetailId]
	INNER JOIN tblARInvoice Header ON D.intInvoiceId = Header.intInvoiceId 
	INNER JOIN tblICItem ITEM ON D.intItemId = ITEM.intItemId AND ITEM.strType <> 'Other Charge'
	INNER JOIN tblSCTicket T ON D.intTicketId = T.intTicketId
	LEFT JOIN tblMBILInvoice MBIL ON Header.strInvoiceNumber = MBIL.strInvoiceNo
	LEFT JOIN tblARTransactionDetail TD ON D.intInvoiceDetailId = TD.intTransactionDetailId 
									   AND D.intInvoiceId = TD.intTransactionId 
									   AND TD.strTransactionType IN ('Cash', 'Invoice')
	INNER JOIN tblCTContractDetail CD ON D.intContractDetailId = CD.intContractDetailId
	WHERE D.intContractDetailId IS NOT NULL
		AND D.[intInventoryShipmentItemId] IS NULL
		AND D.[intSalesOrderDetailId] IS NOT NULL
		AND D.[intShipmentPurchaseSalesContractId] IS NULL 
		AND TD.intId IS NULL
		AND T.strDistributionOption = 'SO'
		AND I.strTransactionType IN ('Cash', 'Invoice')
			
	--UPDATE TM QTY
	INSERT INTO @tblToProcess (
		  intInvoiceDetailId
		, intContractDetailId
		, intTicketId
		, intInventoryShipmentItemId
		, intItemUOMId
		, dblQty
		, intLoadDetailId
	)
	SELECT intInvoiceDetailId			= P.intInvoiceDetailId
		, intContractDetailId			= P.intContractDetailId
		, intTicketId					= P.intTicketId
		, intInventoryShipmentItemId	= P.intInventoryShipmentItemId
		, intItemUOMId					= P.intItemUOMId
		, dblQty						= (CASE WHEN TRD.intTransactionDetailId IS NULL
													THEN 
														CASE WHEN ABS(P.dblQty) > TMO.dblQuantity
																THEN (ABS(P.dblQty) - TMO.dblQuantity)
															 WHEN ABS(P.dblQty) < TMO.dblQuantity
																THEN -(TMO.dblQuantity - ABS(P.dblQty))
														END 
												ELSE 
													P.dblQty * CASE WHEN ID.dblQtyShipped < TMO.dblQuantity AND P.dblQty > TMO.dblQuantity THEN -1 ELSE 1 END
											END)
		, intLoadDetailId				= P.intLoadDetailId
	FROM @tblToProcess P
	LEFT JOIN tblARInvoiceDetail ID ON P.intInvoiceDetailId = ID.intInvoiceDetailId AND ID.intDispatchId IS NOT NULL
	CROSS APPLY ( 
		SELECT TOP 1 
			 dblQuantity
			,intContractDetailId
		FROM tblTMOrder
		WHERE intDispatchId = P.intDispatchId
		  AND intContractDetailId = P.intContractDetailId
		ORDER BY dtmTransactionDate DESC
	) TMO
	OUTER APPLY (
		SELECT TOP 1 TD.intTransactionDetailId
		FROM tblARTransactionDetail TD 
		WHERE P.intInvoiceDetailId = TD.intTransactionDetailId 
	      AND TD.strTransactionType IN ('Cash', 'Invoice')
	) TRD
	WHERE TMO.intContractDetailId IS NOT NULL
	  AND P.intDispatchId IS NOT NULL
	  AND (ABS(P.dblQty) <> TMO.dblQuantity OR (ABS(P.dblQty) = TMO.dblQuantity AND TRD.intTransactionDetailId IS NOT NULL))
	  AND P.ysnMobileBilling = 0
	  
	DELETE P 
	FROM @tblToProcess P
	CROSS APPLY ( 
		SELECT TOP 1 *
		FROM tblTMOrder
		WHERE intDispatchId = P.intDispatchId
		  AND intContractDetailId = P.intContractDetailId
		ORDER BY dtmTransactionDate DESC
	) TMO 
	WHERE P.intDispatchId IS NOT NULL
	  AND P.ysnMobileBilling = 0

	--SCENARIO AR-16406
	DELETE P 
	FROM @tblToProcess P
	CROSS APPLY ( 
		SELECT TOP 1 TMO.*
		FROM tblTMOrder TMO 
		INNER JOIN tblTMDispatch D ON TMO.intSiteId = D.intSiteID
		WHERE TMO.intSiteId = P.intSiteId
		  AND TMO.intContractDetailId = P.intContractDetailId
		ORDER BY TMO.dtmTransactionDate DESC
	) TMO 
	WHERE P.intSiteId IS NOT NULL
	  AND P.ysnMobileBilling = 1
	  AND P.dblQty = TMO.dblQuantity

	--FROM MBIL WHERE MBIL QTY <> TMO QTY
    UPDATE P
    SET dblQty = CASE WHEN P.dblQty > TMO.dblQuantity
                      THEN P.dblQty - TMO.dblQuantity
                      ELSE -(TMO.dblQuantity - P.dblQty)
                 END
    FROM @tblToProcess P
    INNER JOIN tblCTContractDetail CD ON P.intContractDetailId = CD.intContractDetailId
    CROSS APPLY ( 
        SELECT TOP 1 TMO.*
        FROM tblTMOrder TMO 
        INNER JOIN tblTMDispatch D ON TMO.intSiteId = D.intSiteID
        WHERE TMO.intSiteId = P.intSiteId
          AND TMO.intContractDetailId = P.intContractDetailId
        ORDER BY TMO.dtmTransactionDate DESC
    ) TMO 
    WHERE P.intSiteId IS NOT NULL
      AND P.ysnMobileBilling = 1
      AND P.dblQty <> TMO.dblQuantity
	
	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@dblQtyOrdered					=	NULL,
				@intInvoiceDetailId				=	NULL,
				@intTicketId					=	NULL,
				@intInventoryShipmentItemId		=	NULL,
				@strPricing						=	NULL,
				@intLoadDetailId				=	NULL

		SELECT	@intContractDetailId			=	P.[intContractDetailId],
				@intFromItemUOMId				=	P.[intItemUOMId],
				@dblQty							=	P.[dblQty] * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END),
				@dblQtyOrdered					=	ID.[dblQtyOrdered],
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

		DECLARE @intTicketTypeId		INT = NULL
			  , @intTicketType			INT = NULL
			  , @strInOutFlag			NVARCHAR(MAX) = NULL
			  , @strDistributionOption	NVARCHAR(MAX) = NULL

		IF ISNULL(@intTicketId, 0) <> 0
			BEGIN
				SELECT @intTicketTypeId 		= intTicketTypeId
					 , @intTicketType			= intTicketType
					 , @strInOutFlag			= strInOutFlag
					 , @strDistributionOption	= strDistributionOption
				FROM tblSCTicket WHERE intTicketId = @intTicketId
			END

		IF (@dblQty <> 0 OR @ForDelete = 1)
		BEGIN
			
		IF ((ISNULL(@intTicketId, 0) = 0 AND ISNULL(@intTicketTypeId, 0) <> 9 AND (ISNULL(@intTicketType, 0) <> 6 AND ISNULL(@strInOutFlag, '') <> 'O')) AND (ISNULL(@intInventoryShipmentItemId, 0) = 0) AND ISNULL(@intLoadDetailId,0) = 0) OR @strPricing IN ('Subsystem - Direct', 'MANUAL OVERRIDE')	
			BEGIN
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@UserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice'
			END

		--SCHEDULE QTY DIFFERENCE IF FROM SALES ORDER
		IF ISNULL(@intTicketId, 0) <> 0 AND ISNULL(@strInOutFlag, '') = 'O' AND @strDistributionOption = 'SO' AND @dblQtyOrdered <> @dblQty AND @strPricing = 'Contracts'	
			BEGIN
				DECLARE @dblQtyDifference	NUMERIC(18, 6) = 0
				SET @dblQtyDifference 		= -(@dblQtyOrdered + @dblQty)

				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQtyDifference,
						@intUserId				=	@UserId,
						@intExternalId			=	@intInvoiceDetailId,
						@strScreenName			=	'Invoice'
			END

		END

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH