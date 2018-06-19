﻿CREATE PROCEDURE [dbo].[uspARUpdateInvoiceTransactionHistory]
	 @InvoiceIds	InvoiceId	READONLY,
	 @Post		BIT = NULL,
	 @Payment	BIT = 0

AS

	IF @Payment = 0
	begin
		IF @Post IS NULL
		BEGIN

			IF NOT EXISTS (SELECT TOP 1 1 FROM tblARTransactionDetail a
								join @InvoiceIds b
									ON a.intTransactionId = b.intHeaderId)
			BEGIN
				INSERT INTO tblARInvoiceTransactionHistory
				(
					intInvoiceId
					,intInvoiceDetailId
					,dblQtyReceived
					,dblPrice
					,dblAmountDue
					,intItemId
					,intItemUOMId
					,intCompanyLocationId
					,intTicketId
					,dtmTicketDate
					,dtmTransactionDate
					,intCurrencyId
					,intCommodityId
					,dblCost
				)			
				SELECT
					ARID.intInvoiceId,
					ARID.intInvoiceDetailId,
					ARID.dblQtyShipped,
					ARID.dblPrice,
					ARID.dblTotal,
					ARID.intItemId,
					ARID.intItemUOMId,
					ARI.intCompanyLocationId,
					ARID.intTicketId,
					ST.dtmTicketDateTime,
					GETDATE(),
					ARID.intSubCurrencyId,
					ITM.intCommodityId,
					ICT.dblCost
				FROM
					tblARInvoiceDetail ARID
				INNER JOIN
					(SELECT [intInvoiceId], [intCompanyLocationId], [intCurrencyId], dtmDate FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@InvoiceIds II
						ON ARI.[intInvoiceId] = II.[intHeaderId]
				LEFT JOIN (select intItemId, intCommodityId from tblICItem with(nolock)) ITM
					on ITM.intItemId = ARID.intItemId
				left join tblICInventoryTransaction ICT
					on ARID.intInvoiceDetailId = ICT.intTransactionId
				left join (select intTicketId, dtmTicketDateTime from tblSCTicket) ST
					on ST.intTicketId = ARID.intTicketId

			END
			ELSE
			BEGIN

				INSERT INTO tblARInvoiceTransactionHistory
				(
					intInvoiceId
					,intInvoiceDetailId
					,dblQtyReceived
					,dblPrice
					,dblAmountDue
					,intItemId
					,intItemUOMId
					,intCompanyLocationId
					,intTicketId
					,dtmTicketDate
					,dtmTransactionDate
					,intCurrencyId
					,intCommodityId
					,dblCost
				)
				SELECT
					ARID.intInvoiceId,
					ARID.intInvoiceDetailId,
					ATD.dblQtyShipped,
					ATD.dblPrice,
					ATD.dblAmountDue,
					ATD.intItemId,
					ATD.intItemUOMId,
					ATD.intCompanyLocationId,
					ATD.intTicketId,
					ST.dtmTicketDateTime,
					GETDATE(),
					ATD.intCurrencyId,
					CASE WHEN ATD.intItemId IS NOT NULL THEN ITM.intCommodityId ELSE NULL END,
					CASE WHEN ATD.dblPrice IS NOT NULL THEN ICT.dblCost ELSE NULL END
				FROM
					tblARInvoiceDetail ARID
				INNER JOIN
					(SELECT [intInvoiceId], [intCompanyLocationId], [intCurrencyId] FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN tblARTransactionDetail ATD
					ON ATD.intTransactionDetailId = ARID.intInvoiceDetailId
				INNER JOIN
					@InvoiceIds II
						ON ARI.[intInvoiceId] = II.[intHeaderId]
				LEFT JOIN (select intItemId, intCommodityId from tblICItem with(nolock)) ITM
					on ITM.intItemId = ARID.intItemId
				left join tblICInventoryTransaction ICT
					on ARID.intInvoiceDetailId = ICT.intTransactionId
				left join (select intTicketId, dtmTicketDateTime from tblSCTicket) ST
					on ST.intTicketId = ARID.intTicketId
				WHERE ATD.dblQtyShipped				<> ARID.dblQtyShipped OR
					ATD.dblPrice					<> ARID.dblPrice OR
					ATD.intItemId					<> ARID.intItemId OR
					ATD.intItemUOMId				<> ARID.intItemUOMId OR
					ATD.intCompanyLocationId		<> ARI.intCompanyLocationId OR
					ATD.intCurrencyId				<> ARI.intCurrencyId OR
					ATD.intTicketId					<> ARID.intTicketId
			END
		END
		ELSE
			INSERT INTO tblARInvoiceTransactionHistory
				(
					intInvoiceId
					,intInvoiceDetailId
					,dblQtyReceived
					,dblPrice
					,dblAmountDue
					,intItemId
					,intItemUOMId
					,intCompanyLocationId
					,intTicketId
					,dtmTicketDate
					,dtmTransactionDate
					,intCurrencyId
					,intCommodityId
					,dblCost
					,ysnPost
				)			
				SELECT
					ARID.intInvoiceId,
					ARID.intInvoiceDetailId,
					ARID.dblQtyShipped,
					ARID.dblPrice,
					ARID.dblTotal,
					ARID.intItemId,
					ARID.intItemUOMId,
					ARI.intCompanyLocationId,
					ARID.intTicketId,
					ST.dtmTicketDateTime,
					GETDATE(),
					ARID.intSubCurrencyId,
					ITM.intCommodityId,
					ICT.dblCost,
					@Post
				FROM
					tblARInvoiceDetail ARID
				INNER JOIN
					(SELECT [intInvoiceId], [intCompanyLocationId], [intCurrencyId], dtmDate FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@InvoiceIds II
						ON ARI.[intInvoiceId] = II.[intHeaderId]
				LEFT JOIN (select intItemId, intCommodityId from tblICItem with(nolock)) ITM
					on ITM.intItemId = ARID.intItemId
				left join tblICInventoryTransaction ICT
					on ARID.intInvoiceDetailId = ICT.intTransactionId
				left join (select intTicketId, dtmTicketDateTime from tblSCTicket) ST
					on ST.intTicketId = ARID.intTicketId
			/*INSERT INTO tblARInvoiceTransactionHistory
			(
				intInvoiceId
				,dblAmountDue
				,dtmTransactionDate
				,ysnPost
			)
			SELECT
				ARI.intInvoiceId,
				ARI.dblAmountDue,
				GETDATE(),
				@Post
			FROM
				(SELECT [intInvoiceId], [dblAmountDue], [intCurrencyId] FROM tblARInvoice WITH (NOLOCK)) ARI		
			INNER JOIN
				@InvoiceIds II
					ON ARI.[intInvoiceId] = II.[intHeaderId]*/
	end
	else
	begin
		INSERT INTO tblARInvoiceTransactionHistory
				(
					intInvoiceId
					,intInvoiceDetailId
					,dblQtyReceived
					,dblPrice
					,dblAmountDue
					,intItemId
					,intItemUOMId
					,intCompanyLocationId
					,intTicketId
					,dtmTicketDate
					,dtmTransactionDate
					,intCurrencyId
					,intCommodityId
					,dblCost
					,ysnPost
					,dblInvoicePayment
					,dblInvoiceAmountDue
				)			
		SELECT
					ARID.intInvoiceId,
					ARID.intInvoiceDetailId,
					ARID.dblQtyShipped,
					ARID.dblPrice,
					ARID.dblTotal,
					ARID.intItemId,
					ARID.intItemUOMId,
					ARI.intCompanyLocationId,
					ARID.intTicketId,
					ST.dtmTicketDateTime,
					GETDATE(),
					ARID.intSubCurrencyId,
					ITM.intCommodityId,
					ICT.dblCost,
					@Post,
					(case when @Post = 1 then -1 else 0 end ) * isnull(PYM.dblBasePayment, 0),
					(case when @Post = 0 then 1 else 1 end ) * isnull(ARI.dblBaseAmountDue, 0)
				FROM
					tblARInvoiceDetail ARID
				INNER JOIN
					(SELECT [intInvoiceId], [intCompanyLocationId], [intCurrencyId], dtmDate, dblBaseAmountDue FROM tblARInvoice WITH (NOLOCK)) ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
				INNER JOIN
					@InvoiceIds II
						ON ARI.[intInvoiceId] = II.[intHeaderId]
				left join tblARPaymentDetail PYM
						on II.intDetailId = PYM.intPaymentId and PYM.intInvoiceId = II.[intHeaderId]
				LEFT JOIN (select intItemId, intCommodityId from tblICItem with(nolock)) ITM
					on ITM.intItemId = ARID.intItemId
				left join tblICInventoryTransaction ICT
					on ARID.intInvoiceDetailId = ICT.intTransactionId
				left join (select intTicketId, dtmTicketDateTime from tblSCTicket) ST
					on ST.intTicketId = ARID.intTicketId
	end
	

RETURN 0
