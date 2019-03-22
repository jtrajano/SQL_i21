CREATE PROCEDURE [dbo].[uspARInvoiceUpdateSequenceBalance]
	 @ysnDelete			BIT = 0  
	,@TransactionId	INT = NULL   
	,@UserId		INT = NULL    
AS
BEGIN
		DECLARE InvoiceTickets CURSOR
		FOR SELECT intInvoiceId,intInvoiceDetailId,intTicketId,intInventoryShipmentItemId,intContractHeaderId,intContractDetailId,dblQtyShipped,dblQtyOrdered,intLoadDetailId 
		FROM tblARInvoiceDetail ID
		INNER JOIN tblICItem I ON ID.intItemId = I.intItemId 
		WHERE intInvoiceId = @TransactionId 
		  AND intTicketId IS NOT NULL 
		  AND intContractDetailId IS NOT NULL 
		  AND intContractHeaderId IS NOT NULL
		  AND I.strType <> 'Other Charge'
		OPEN InvoiceTickets
		DECLARE @intInvoiceId INT,
				@intInvoiceDetailId INT,
				@intTicketId INT,
				@intInventoryShipmentItemId INT,
				@intContractHeaderId INT,
				@intContractDetailId INT,
				@dblQty NUMERIC(18,6),
				@dblQtyOrdered NUMERIC(18,6),
				@intLoadDetailId INT
		FETCH NEXT FROM InvoiceTickets
		INTO @intInvoiceId,@intInvoiceDetailId,@intTicketId,@intInventoryShipmentItemId,@intContractHeaderId,@intContractDetailId,@dblQty,@dblQtyOrdered, @intLoadDetailId
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
				IF @ysnDelete = 1
					BEGIN
						SET @dblQty = @dblQty * (-1)
					END

				IF (ISNULL(@intTicketTypeId, 0) <> 9 AND (ISNULL(@intTicketType, 0) <> 6)) AND ISNULL(@intInventoryShipmentItemId, 0) = 0 AND ISNULL(@intLoadDetailId,0) = 0
					BEGIN
							IF(@ysnDelete = 1)
							BEGIN 
								EXEC uspCTUpdateSequenceBalance 
									 @intContractDetailId = @intContractDetailId
									,@dblQuantityToUpdate = @dblQty
									,@intUserId = @UserId
									,@intExternalId = @intInvoiceDetailId
									,@strScreenName = 'Invoice'		

								EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblQtyOrdered,
									@intUserId				=	@UserId,
									@intExternalId			=	@intInvoiceDetailId,
									@strScreenName			=	'Invoice'		

						
							END
						ELSE
							BEGIN
								SET @dblQtyOrdered = @dblQtyOrdered * (-1)
								EXEC uspCTUpdateScheduleQuantity
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblQtyOrdered,
									@intUserId				=	@UserId,
									@intExternalId			=	@intInvoiceDetailId,
									@strScreenName			=	'Invoice'		

								EXEC uspCTUpdateSequenceBalance 
									 @intContractDetailId = @intContractDetailId
									,@dblQuantityToUpdate = @dblQty
									,@intUserId = @UserId
									,@intExternalId = @intInvoiceDetailId
									,@strScreenName = 'Invoice'
							END
					END
				FETCH NEXT FROM InvoiceTickets
				INTO @intInvoiceId,@intInvoiceDetailId,@intTicketId,@intInventoryShipmentItemId,@intContractHeaderId,@intContractDetailId,@dblQty,@dblQtyOrdered, @intLoadDetailId
			END
		CLOSE InvoiceTickets
		DEALLOCATE InvoiceTickets
END