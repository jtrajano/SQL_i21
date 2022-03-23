CREATE PROCEDURE [dbo].[uspARUpdateInTransit]
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblItemsToUpdate InTransitTableType
	DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
		
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
		, intItemLocationId					= ID.intItemLocationId
		, intItemUOMId						= ID.intItemUOMId
		, intLotId							= ID.intLotId
		, intCompanyLocationSubLocationId	= ID.intSubLocationId
		, intStorageLocationId				= ID.intStorageLocationId
		, dblQty							= (CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL 
												THEN ROUND(ID.dblQtyShipped/ CASE WHEN ICSI.ysnDestinationWeightsAndGrades = 1 THEN ISNULL(ICSI.[dblDestinationQuantity], ICSI.[dblQuantity]) ELSE ICSI.[dblQuantity] END, 2) * ICSI.[dblQuantity]
												ELSE ID.dblQtyShipped
											END) * CASE WHEN ID.ysnPost = 1 THEN -1 ELSE 0 END
		, intInvoiceId						= ID.intInvoiceId
		, strInvoiceNumber					= ID.strInvoiceNumber
		, intTransactionTypeId				= @INVENTORY_INVOICE_TYPE
		, intFOBPointId						= FP.intFobPointId
		, dtmTransactionDate				= ISNULL(ID.dtmPostDate, ID.dtmShipDate)
	FROM ##ARPostInvoiceDetail ID
	LEFT JOIN tblICInventoryShipmentItem ICSI ON ICSI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
	LEFT JOIN tblSMFreightTerms FT ON ID.intFreightTermId = FT.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
	LEFT JOIN tblSCTicket TICKET ON TICKET.intTicketId = ID.intTicketId
	OUTER APPLY (
		SELECT TOP 1 intInvoiceId 
		FROM tblARInvoice R
		WHERE R.strTransactionType = 'Invoice'
		AND R.ysnReturned = 1
		AND ID.strInvoiceOriginId = R.strInvoiceNumber
		AND ID.intOriginalInvoiceId = R.intInvoiceId
	) RI
	WHERE (ID.intInventoryShipmentItemId IS NOT NULL OR ID.intLoadDetailId IS NOT NULL)
	AND (ID.intTicketId IS NULL OR (ID.intTicketId IS NOT NULL AND TICKET.strInOutFlag = 'O'))
	AND RI.[intInvoiceId] IS NULL
	AND (
			(ID.[strType] <> 'Provisional' AND ID.[ysnProvisionalWithGL] = 0)
		OR
			(ID.[strType] = 'Provisional' AND ID.[ysnProvisionalWithGL] = 1)
		)

	DECLARE @TransactionDate DATE
	DECLARE @tblItemsToUpdateByDate InTransitTableType

	DECLARE MY_CURSOR CURSOR 
	  LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR 
	SELECT DISTINCT @TransactionDate 
	FROM @tblItemsToUpdate

	OPEN MY_CURSOR
	FETCH NEXT FROM MY_CURSOR INTO @TransactionDate
	WHILE @@FETCH_STATUS = 0
	BEGIN 

		 INSERT INTO @tblItemsToUpdateByDate 
			( [intItemId]
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
			, [dtmTransactionDate] )
		 SELECT [intItemId]
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
		 FROM @tblItemsToUpdate ItemsToUpdate
		 WHERE dtmTransactionDate = @TransactionDate

		 EXEC dbo.uspICIncreaseInTransitOutBoundQty @tblItemsToUpdateByDate

		 DELETE FROM @tblItemsToUpdateByDate 
		 WHERE dtmTransactionDate = @TransactionDate

		 FETCH NEXT FROM MY_CURSOR INTO @TransactionDate
	END
	CLOSE MY_CURSOR
	DEALLOCATE MY_CURSOR

END