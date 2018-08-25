CREATE PROCEDURE [dbo].[uspARInvoiceUpdateSequenceBalance]
	 @post			BIT = 0  
	,@TransactionId	INT = NULL   
	,@UserId		INT = NULL    
AS
BEGIN
		DECLARE InvoiceTickets CURSOR
		FOR SELECT intInvoiceId,intInvoiceDetailId,intTicketId,intInventoryShipmentItemId,intContractHeaderId,intContractDetailId,dblQtyShipped FROM tblARInvoiceDetail WHERE intInvoiceId = @TransactionId AND intTicketId IS NOT NULL and (intContractDetailId IS NOT NULL AND intContractHeaderId IS NOT NULL)
		OPEN InvoiceTickets
		DECLARE @intInvoiceId INT,
				@intInvoiceDetailId INT,
				@intTicketId INT,
				@intInventoryShipmentItemId INT,
				@intContractHeaderId INT,
				@intContractDetailId INT,
				@dblQty NUMERIC(18,6)
		FETCH NEXT FROM InvoiceTickets
		INTO @intInvoiceId,@intInvoiceDetailId,@intTicketId,@intInventoryShipmentItemId,@intContractHeaderId,@intContractDetailId,@dblQty
		WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE   @intTicketTypeId	INT = NULL
						, @intTicketType		INT = NULL
						, @strInOutFlag		NVARCHAR(MAX) = NULL

				IF ISNULL(@intTicketId, 0) <> 0
					BEGIN
						SELECT @intTicketTypeId = intTicketTypeId
								, @intTicketType	= intTicketType
								, @strInOutFlag	= strInOutFlag
						FROM tblSCTicket WHERE intTicketId = @intTicketId
					END		
				IF @post = 0
					BEGIN
						SET @dblQty = @dblQty * (-1)
					END

				IF (ISNULL(@intTicketTypeId, 0) <> 9 AND (ISNULL(@intTicketType, 0) <> 6)) AND ISNULL(@intInventoryShipmentItemId, 0) = 0
					BEGIN
							EXEC uspCTUpdateSequenceBalance 
								 @intContractDetailId = @intContractDetailId
								,@dblQuantityToUpdate = @dblQty
								,@intUserId = @UserId
								,@intExternalId = @intInvoiceId
								,@strScreenName = 'Invoice'
					END
				FETCH NEXT FROM InvoiceTickets
				INTO @intInvoiceId,@intInvoiceDetailId,@intTicketId,@intInventoryShipmentItemId,@intContractHeaderId,@intContractDetailId,@dblQty
			END
		CLOSE InvoiceTickets
		DEALLOCATE InvoiceTickets
END
