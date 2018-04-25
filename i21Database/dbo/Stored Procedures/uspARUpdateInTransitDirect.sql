CREATE PROCEDURE [dbo].[uspARUpdateInTransitDirect]
	 @TransactionId		INT
	,@Negate			BIT	= 0
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ItemsToIncreaseInTransitDirect InTransitTableType

	INSERT INTO @ItemsToIncreaseInTransitDirect (
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
	) 
	SELECT ID.intItemId
		, IL.intItemLocationId
		, ID.intItemUOMId
		, ID.intLotId
		, ID.intCompanyLocationSubLocationId
		, ID.[intStorageLocationId]
		, ID.dblQtyShipped
		, I.intInvoiceId
		, I.strInvoiceNumber
		, 6
		, fp.intFobPointId
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN tblICItemLocation IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
	INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId AND T.intTicketTypeId = 6
	LEFT JOIN tblSMFreightTerms ft
		ON I.intFreightTermId = ft.intFreightTermId
	LEFT JOIN tblICFobPoint fp
		ON fp.strFobPoint = ft.strFobPoint
	WHERE ID.intInvoiceId = @TransactionId
	AND ISNULL(ID.intInventoryShipmentItemId, 0) <> 0 
					
	UPDATE @ItemsToIncreaseInTransitDirect
	SET dblQty = CASE WHEN @Negate = 0 THEN dblQty ELSE -dblQty END

	EXEC dbo.uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect
END

GO