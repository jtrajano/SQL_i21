CREATE PROCEDURE [dbo].[uspARUpdateInvoiceTransactionHistory]
	 @InvoiceIds	InvoiceId	READONLY,
	 @Post		BIT = NULL

AS

	IF @Post IS NULL
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
		)
		SELECT
			ARID.intInvoiceId,
			ARID.intInvoiceDetailId,
			ATD.dblQtyOrdered,
			ATD.dblPrice,
			ATD.dblAmountDue,
			ATD.intItemId,
			ATD.intItemUOMId,
			ATD.intCompanyLocationId,
			NULL,
			NULL,
			GETDATE(),
			ATD.intCurrencyId
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
		WHERE ATD.dblQtyShipped				<> ARID.dblQtyShipped OR
			ATD.dblPrice					<> ARID.dblPrice OR
			ATD.intItemId					<> ARID.intItemId OR
			ATD.intItemUOMId				<> ARID.intItemUOMId OR
			ATD.intCompanyLocationId		<> ARI.intCompanyLocationId OR
			ATD.intCurrencyId				<> ARI.intCurrencyId
	END
	ELSE
		INSERT INTO tblARInvoiceTransactionHistory
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
				ON ARI.[intInvoiceId] = II.[intHeaderId]

RETURN 0
