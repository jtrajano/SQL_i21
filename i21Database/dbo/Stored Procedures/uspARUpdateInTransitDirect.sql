CREATE PROCEDURE [dbo].[uspARUpdateInTransitDirect]
	@strSessionId		NVARCHAR(50) = NULL
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ItemsToIncreaseInTransitDirect InTransitTableType

	INSERT INTO @ItemsToIncreaseInTransitDirect (
		  intItemId
		, intItemLocationId
		, intItemUOMId
		, intLotId
		, intSubLocationId
		, intStorageLocationId
		, dblQty
		, intTransactionId
		, strTransactionId
		, intTransactionTypeId
		, intFOBPointId
	) 
	SELECT intItemId						= ID.intItemId
		, intItemLocationId					= ID.intItemLocationId
		, intItemUOMId						= ID.intItemUOMId
		, intLotId							= ID.intLotId
		, intCompanyLocationSubLocationId	= ID.intSubLocationId
		, intStorageLocationId				= ID.intStorageLocationId
		, dblQty							= ID.dblQtyShipped * CASE WHEN ID.ysnPost = 1 THEN -1 ELSE 0 END
		, intInvoiceId						= ID.intInvoiceId
		, strInvoiceNumber					= ID.strInvoiceNumber
		, intTransactionTypeId				= 6
		, intFOBPointId						= FP.intFobPointId
	FROM tblARPostInvoiceDetail ID
	INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
	LEFT JOIN tblSMFreightTerms FT ON ID.intFreightTermId = FT.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
	WHERE (T.intTicketTypeId = 9 OR (T.intTicketType = 6 AND T.strInOutFlag = 'O'))
	  AND ID.intTicketId IS NOT NULL
	  AND ID.strSessionId = @strSessionId
					
	IF EXISTS(SELECT TOP 1 NULL FROM @ItemsToIncreaseInTransitDirect)
		EXEC dbo.uspICIncreaseInTransitDirectQty @ItemsToIncreaseInTransitDirect
END