CREATE PROCEDURE [dbo].[uspARUpdateInvoiceTransactionHistory]
	 @InvoiceIds			InvoiceId	READONLY,
	 @Post					BIT = NULL,
	 @Payment				BIT = 0,
	 @PaymentStaging		PaymentIntegrationStagingTable READONLY,
	 @strSessionId			NVARCHAR(50) = NULL
AS
	--INVOICE
	IF @Payment = 0
		BEGIN
			--SAVE/UPDATE/DELETE
			IF @Post IS NULL
				BEGIN
					IF NOT EXISTS (SELECT TOP 1 1 FROM tblARTransactionDetail a JOIN @InvoiceIds b ON a.intTransactionId = b.intHeaderId)
						BEGIN
							INSERT INTO tblARInvoiceTransactionHistory (
								  intInvoiceId
								, intInvoiceDetailId
								, dblQtyReceived
								, dblPrice
								, dblAmountDue
								, intItemId
								, intItemUOMId
								, intCompanyLocationId
								, intTicketId
								, dtmTicketDate
								, dtmTransactionDate
								, intCurrencyId
								, intCommodityId
								, dblCost
							)			
							SELECT intInvoiceId			= ARID.intInvoiceId
								, intInvoiceDetailId	= ARID.intInvoiceDetailId
								, dblQtyReceived		= ARID.dblQtyShipped
								, dblPrice				= ARID.dblPrice
								, dblAmountDue			= ARID.dblTotal
								, intItemId				= ARID.intItemId
								, intItemUOMId			= ARID.intItemUOMId
								, intCompanyLocationId	= ARI.intCompanyLocationId
								, intTicketId			= ARID.intTicketId
								, dtmTicketDate			= ST.dtmTicketDateTime
								, dtmTransactionDate	= GETDATE()
								, intCurrencyId			= ARID.intSubCurrencyId
								, intCommodityId		= ITM.intCommodityId
								, dblCost				= CAST(0 AS NUMERIC(18, 6))
							FROM tblARInvoiceDetail ARID WITH (NOLOCK)
							INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
							INNER JOIN @InvoiceIds II ON ARI.intInvoiceId = II.intHeaderId
							LEFT JOIN tblICItem ITM WITH (NOLOCK) ON ITM.intItemId = ARID.intItemId							
							LEFT JOIN tblSCTicket ST WITH (NOLOCK) ON ST.intTicketId = ARID.intTicketId
						END
					ELSE
						BEGIN
							INSERT INTO tblARInvoiceTransactionHistory (
								  intInvoiceId
								, intInvoiceDetailId
								, dblQtyReceived
								, dblPrice
								, dblAmountDue
								, intItemId
								, intItemUOMId
								, intCompanyLocationId
								, intTicketId
								, dtmTicketDate
								, dtmTransactionDate
								, intCurrencyId
								, intCommodityId
								, dblCost
							)
							SELECT intInvoiceId			= ARID.intInvoiceId
								, intInvoiceDetailId	= ARID.intInvoiceDetailId
								, dblQtyReceived		= ATD.dblQtyShipped
								, dblPrice				= ATD.dblPrice
								, dblAmountDue			= ATD.dblAmountDue
								, intItemId				= ATD.intItemId
								, intItemUOMId			= ATD.intItemUOMId
								, intCompanyLocationId	= ATD.intCompanyLocationId
								, intTicketId			= ATD.intTicketId
								, dtmTicketDate			= ST.dtmTicketDateTime
								, dtmTransactionDate	= GETDATE()
								, intCurrencyId			= ATD.intCurrencyId
								, intCommodityId		= CASE WHEN ATD.intItemId IS NOT NULL THEN ITM.intCommodityId ELSE NULL END
								, dblCost				= CASE WHEN ATD.dblPrice IS NOT NULL THEN CAST(0 AS NUMERIC(18, 6)) ELSE NULL END
							FROM tblARInvoiceDetail ARID WITH (NOLOCK)
							INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
							INNER JOIN tblARTransactionDetail ATD WITH (NOLOCK) ON ATD.intTransactionDetailId = ARID.intInvoiceDetailId
							INNER JOIN @InvoiceIds II ON ARI.intInvoiceId = II.intHeaderId
							LEFT JOIN tblICItem ITM WITH (NOLOCK) ON ITM.intItemId = ARID.intItemId							
							LEFT JOIN tblSCTicket ST WITH (NOLOCK) ON ST.intTicketId = ARID.intTicketId
							WHERE ATD.dblQtyShipped			<> ARID.dblQtyShipped
							   OR ATD.dblPrice				<> ARID.dblPrice
							   OR ATD.intItemId				<> ARID.intItemId
							   OR ATD.intItemUOMId			<> ARID.intItemUOMId
							   OR ATD.intCompanyLocationId	<> ARI.intCompanyLocationId
							   OR ATD.intCurrencyId			<> ARI.intCurrencyId
							   OR ATD.intTicketId			<> ARID.intTicketId
						END
				END
			--POST/UNPOST	
			ELSE
				BEGIN
					INSERT INTO tblARInvoiceTransactionHistory (
						  intInvoiceId
						, intInvoiceDetailId
						, dblQtyReceived
						, dblPrice
						, dblAmountDue
						, intItemId
						, intItemUOMId
						, intCompanyLocationId
						, intTicketId
						, dtmTicketDate
						, dtmTransactionDate
						, intCurrencyId
						, intCommodityId
						, dblCost
						, ysnPost
					)			
					SELECT intInvoiceId			= ARID.intInvoiceId
						, intInvoiceDetailId	= ARID.intInvoiceDetailId
						, dblQtyReceived		= CASE (ISNULL(@Post, 1)) WHEN 1 THEN ARID.dblQtyShipped ELSE (ARID.dblQtyShipped * -1) END
						, dblPrice				= ARID.dblPrice
						, dblAmountDue			= CASE (ISNULL(@Post, 1)) WHEN 1 THEN ARID.dblTotal ELSE (ARID.dblTotal * -1) END
						, intItemId				= ARID.intItemId
						, intItemUOMId			= ARID.intItemUOMId
						, intCompanyLocationId	= ARI.intCompanyLocationId
						, intTicketId			= ARID.intTicketId
						, dtmTicketDate			= ST.dtmTicketDateTime
						, dtmTransactionDate	= GETDATE()
						, intCurrencyId			= ARID.intSubCurrencyId
						, intCommodityId		= ITM.intCommodityId
						, dblCost				= ICT.dblCost
						, ysnPost				= @Post					
					FROM tblARInvoiceDetail ARID WITH (NOLOCK)
					INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
					INNER JOIN @InvoiceIds II ON ARI.intInvoiceId = II.intHeaderId
					LEFT JOIN tblICItem ITM WITH (NOLOCK) ON ITM.intItemId = ARID.intItemId
					LEFT JOIN (
						SELECT intTransactionId
							 , intTransactionDetailId
							 , dblCost					= SUM(dblCost)
						FROM tblARPostItemsForCosting
						WHERE strSessionId = @strSessionId
						GROUP BY intTransactionId, intTransactionDetailId

						UNION ALL

						SELECT intTransactionId
							 , intTransactionDetailId
							 , dblCost					= SUM(dblCost)
						FROM tblARPostItemsForInTransitCosting
						WHERE strSessionId = @strSessionId
						GROUP BY intTransactionId, intTransactionDetailId

						UNION ALL

						SELECT intTransactionId
							 , intTransactionDetailId
							 , dblCost					= SUM(dblCost)
						FROM tblARPostItemsForStorageCosting
						WHERE strSessionId = @strSessionId
						GROUP BY intTransactionId, intTransactionDetailId
						--SELECT intTransactionId
						--     , intTransactionDetailId
						--	 , dblCost					= SUM(dblCost)
						--FROM tblICInventoryTransaction ICT WITH (NOLOCK)
						--WHERE ysnIsUnposted = 0
						--  AND strTransactionForm IN ('Credit Memo', 'Invoice')
						--GROUP BY intTransactionId, intTransactionDetailId
					) ICT ON ARID.intInvoiceDetailId = ICT.intTransactionDetailId 
						AND ARI.intInvoiceId = ICT.intTransactionId 
					LEFT JOIN tblSCTicket ST WITH (NOLOCK) ON ST.intTicketId = ARID.intTicketId
				END
		END
	--PAYMENT
	ELSE
		BEGIN
			INSERT INTO tblARInvoiceTransactionHistory (
				  intInvoiceId
				, intInvoiceDetailId
				, dblQtyReceived
				, dblPrice
				, dblAmountDue
				, intItemId
				, intItemUOMId
				, intCompanyLocationId
				, intTicketId
				, dtmTicketDate
				, dtmTransactionDate
				, intCurrencyId
				, intCommodityId
				, dblCost
				, ysnPost
				, dblInvoicePayment
				, dblInvoiceTotal
				, dblInvoiceBalance
				, intPaymentId
				, strRecordNumber
			)			
			SELECT intInvoiceId			= ARID.intInvoiceId
				, intInvoiceDetailId	= ARID.intInvoiceDetailId
				, dblQtyReceived		= (CASE WHEN @Post = 1 THEN -1 ELSE 1 END) * CASE WHEN ISNULL(PS.dblBasePayment, 0) <> 0 AND ISNULL(ARID.dblBaseTotal, 0) <> 0 THEN (PS.dblBasePayment / ARID.dblBaseTotal) * (ARID.dblQtyShipped) ELSE 0 END
				, dblPrice				= ARID.dblPrice
				, dblAmountDue			= (CASE WHEN @Post = 1 THEN -1 ELSE 1 END) * CASE WHEN ISNULL(PS.dblBasePayment, 0) <> 0 AND ISNULL(ARID.dblBaseTotal, 0) <> 0 THEN (PS.dblBasePayment / ARID.dblBaseTotal) * (ARID.dblBaseTotal) ELSE 0 END
				, intItemId				= ARID.intItemId
				, intItemUOMId			= ARID.intItemUOMId
				, intCompanyLocationId	= ARI.intCompanyLocationId
				, intTicketId			= ARID.intTicketId
				, dtmTicketDate			= ST.dtmTicketDateTime
				, dtmTransactionDate	= GETDATE()
				, intCurrencyId			= ARID.intSubCurrencyId
				, intCommodityId		= ITM.intCommodityId
				, dblCost				= ICT.dblCost
				, ysnPost				= @Post
				, dblInvoicePayment		= (CASE WHEN @Post = 0 THEN -1 ELSE 1 END) * ISNULL(PS.dblBasePayment, 0)
				, dblInvoiceTotal		= (CASE WHEN @Post = 0 THEN 1 ELSE 1 END ) * isnull(ARID.dblBaseTotal, 0)
				, dblInvoiceBalance		= CASE WHEN ISNULL(PS.dblBasePayment, 0) <> 0 AND ISNULL(ARID.dblBaseTotal, 0) <> 0 THEN (PS.dblBasePayment / ARID.dblBaseTotal) * (ARID.dblBaseTotal) ELSE 0 END
				, intPaymentId			= PS.intId
				, strRecordNumber		= PS.strTransactionNumber
			FROM tblARInvoiceDetail ARID WITH (NOLOCK)
			INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
			JOIN @PaymentStaging PS ON PS.intInvoiceId = ARID.intInvoiceId
			LEFT JOIN tblICItem ITM WITH (NOLOCK) ON ITM.intItemId = ARID.intItemId
			LEFT JOIN tblICInventoryTransaction ICT WITH (NOLOCK) ON ARID.intInvoiceDetailId = ICT.intTransactionId
			LEFT JOIN tblSCTicket ST WITH (NOLOCK) ON ST.intTicketId = ARID.intTicketId
		END
	

RETURN 0
