CREATE PROCEDURE [dbo].[uspARUpdateInTransit]
	 @TransactionId		INT
	,@Negate			BIT	= 0
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblItemsToUpdate InTransitTableType
	DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
	DECLARE @ysnImposeReversalTransaction BIT = 0

	SELECT TOP 1 @ysnImposeReversalTransaction  = ISNULL(ysnImposeReversalTransaction, 0)
	FROM tblRKCompanyPreference
	
	INSERT INTO @tblItemsToUpdate (
		  [intItemId]
		, [intItemLocationId]
		, [intItemUOMId]
		, [intLotId]
		, [intSubLocationId]
		, [intStorageLocationId]
		, [dblQty]
		, [intTransactionId]
		, [strTransactionId]
		, [intTransactionTypeId]
		, [intFOBPointId]
		, [dtmTransactionDate]
	) 
	SELECT intItemId						= ID.intItemId
		 , intItemLocationId				= IL.intItemLocationId
		 , intItemUOMId						= ID.intItemUOMId
		 , intLotId							= ID.intLotId
		 , intCompanyLocationSubLocationId	= ID.intCompanyLocationSubLocationId
		 , intStorageLocationId				= ID.intStorageLocationId
		 , dblQty							= CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL 
												   THEN ROUND(ID.dblQtyShipped/ CASE WHEN ICSI.ysnDestinationWeightsAndGrades = 1 THEN ISNULL(ICSI.[dblDestinationQuantity], ICSI.[dblQuantity]) ELSE ICSI.[dblQuantity] END, 2) * ICSI.[dblQuantity]
												   ELSE ID.dblQtyShipped
											  END * (CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END)
		 , intInvoiceId						= I.intInvoiceId
		 , strInvoiceNumber					= I.strInvoiceNumber
		 , intTransactionTypeId				= @INVENTORY_INVOICE_TYPE
		 , intFOBPointId					= FP.intFobPointId
		 , dtmTransactionDate				= ISNULL(I.dtmPostDate, I.dtmShipDate)
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN tblICItemLocation IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
	INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
	LEFT JOIN tblICInventoryShipmentItem ICSI ON ICSI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
	LEFT JOIN tblLGLoadDetail LGD ON ID.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblSMFreightTerms FT ON I.intFreightTermId = FT.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
	LEFT JOIN tblSCTicket TICKET ON TICKET.intTicketId = ID.intTicketId
	OUTER APPLY (
		SELECT TOP 1 intInvoiceId 
		FROM tblARInvoice R
		WHERE R.strTransactionType = 'Invoice'
			AND R.ysnReturned = 1
			AND I.strInvoiceOriginId = R.strInvoiceNumber
			AND I.intOriginalInvoiceId = R.intInvoiceId
	) RI
	WHERE ID.intInvoiceId = @TransactionId 
	  AND (ID.intInventoryShipmentItemId IS NOT NULL OR ID.intLoadDetailId IS NOT NULL)
	  AND (ID.intTicketId IS NULL OR (ID.intTicketId IS NOT NULL AND ISNULL(TICKET.strInOutFlag, '') = 'O'))
	  AND (RI.[intInvoiceId] IS NULL OR (I.ysnReversal = 1 AND I.strTransactionType = 'Credit Memo'))
	  AND ITEM.strType <> 'Other Charge'
	  AND (
			(I.[strType] <> 'Provisional' AND I.[ysnProvisionalWithGL] = 0)
		OR
			(I.[strType] = 'Provisional' AND I.[ysnProvisionalWithGL] = 1)
		)	  
		
	UPDATE @tblItemsToUpdate
	SET dblQty = (CASE WHEN @Negate = 0 THEN dblQty ELSE -dblQty END)

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @tblItemsToUpdate
END

GO