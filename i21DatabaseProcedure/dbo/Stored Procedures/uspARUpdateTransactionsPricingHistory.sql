CREATE PROCEDURE [dbo].[uspARUpdateTransactionsPricingHistory]
	 @SourceTransactionId	INT			= 1
	,@InvoiceIds			InvoiceId	READONLY
	,@EntityId				INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @DateNow AS DATETIME
SET @DateNow = GETDATE()


IF @SourceTransactionId = 1 -- SALES ORDER
	BEGIN

		UPDATE  ARPH
		SET
			[ysnApplied] = 0
		FROM
			tblARPricingHistory ARPH
		INNER JOIN
			(SELECT intSalesOrderDetailId, intSalesOrderId, intItemId, dblPrice, strPricing FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON ARPH.intTransactionDetailId = SOSOD.intSalesOrderDetailId
		INNER JOIN
			(SELECT intSalesOrderId FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, dblPrice, strPricing FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId
		INNER JOIN
			@InvoiceIds II
				ON ARPH.[intTransactionId] = II.intHeaderId 
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND (
					(
						SOSOD.intItemId = ARTD.intItemId		
						AND
						(SOSOD.dblPrice <> ARTD.dblPrice OR SOSOD.strPricing <> ARTD.strPricing) 
					)
				)

		UPDATE  ARPH
		SET
			 [ysnApplied]	= 0
			,[ysnDeleted]	= 1
		FROM
			tblARPricingHistory ARPH
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON ARPH.intTransactionDetailId = ARTD.intTransactionDetailId
		INNER JOIN
			(SELECT intSalesOrderId FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON ARTD.intTransactionId = SO.intSalesOrderId
		INNER JOIN
			@InvoiceIds II
				ON ARPH.[intTransactionId] = II.intHeaderId
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND NOT EXISTS(SELECT NULL FROM tblSOSalesOrderDetail WITH (NOLOCK) WHERE intSalesOrderId = II.intHeaderId AND intSalesOrderDetailId = ARTD.intTransactionDetailId)


		INSERT INTO tblARPricingHistory
			([intSourceTransactionId]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[intEntityCustomerId]
			,[intItemId]
			,[intOriginalItemId]
			,[dblPrice]
			,[dblOriginalPrice]
			,[strPricing]
			,[strOriginalPricing]
			,[dtmDate] 
			,[ysnApplied]
			,[intEntityId])

			--Price Changed
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= II.intHeaderId 
			,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]
			,[intEntityCustomerId]		= SO.[intEntityCustomerId]
			,[intItemId]				= SOSOD.[intItemId]
			,[intOriginalItemId]		= ARTD.[intItemId]
			,[dblPrice]					= SOSOD.[dblPrice]
			,[dblOriginalPrice]			= ARTD.[dblPrice]
			,[strPricing]				= SOSOD.[strPricing]
			,[strOriginalPricing]		= ARTD.[strPricing]
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblSOSalesOrderDetail SOSOD
		INNER JOIN
			(SELECT [intEntityCustomerId], intSalesOrderId FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, dblPrice, [strPricing] FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId
		INNER JOIN
			@InvoiceIds II
				ON SO.intSalesOrderId = II.intHeaderId 
		WHERE 
			SOSOD.intItemId = ARTD.intItemId		
			AND (SOSOD.dblPrice <> ARTD.dblPrice OR SOSOD.[strPricing] <> ARTD.[strPricing])
			AND NOT (SOSOD.dblPrice = ARTD.dblPrice AND SOSOD.[strPricing] = ARTD.[strPricing])
						
		UNION ALL	

		--Item Changed +new
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= II.intHeaderId
			,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]
			,[intEntityCustomerId]		= SO.[intEntityCustomerId]
			,[intItemId]				= SOSOD.[intItemId]
			,[intOriginalItemId]		= ARTD.[intItemId]
			,[dblPrice]					= SOSOD.[dblPrice]
			,[dblOriginalPrice]			= SOSOD.[dblPrice]
			,[strPricing]				= SOSOD.[strPricing]
			,[strOriginalPricing]		= ARTD.[strPricing]
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblSOSalesOrderDetail SOSOD
		INNER JOIN
			(SELECT [intEntityCustomerId], intSalesOrderId FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, [strPricing] FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId
		INNER JOIN
			@InvoiceIds II
				ON SO.intSalesOrderId = II.intHeaderId 
		WHERE 
			SO.intSalesOrderId = II.intHeaderId
			AND SOSOD.intItemId <> ARTD.intItemId			

		UNION ALL

		--Added Item
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= II.intHeaderId
			,[intTransactionDetailId]	= SOSOD.[intSalesOrderDetailId]
			,[intEntityCustomerId]		= SO.[intEntityCustomerId]
			,[intItemId]				= SOSOD.[intItemId]
			,[intOriginalItemId]		= SOSOD.[intItemId]
			,[dblPrice]					= SOSOD.[dblPrice]
			,[dblOriginalPrice]			= SOSOD.[dblPrice]
			,[strPricing]				= SOSOD.[strPricing]
			,[strOriginalPricing]		= NULL
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblSOSalesOrderDetail SOSOD
		INNER JOIN
			(SELECT [intEntityCustomerId], intSalesOrderId FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			@InvoiceIds II
				ON SO.intSalesOrderId = II.intHeaderId
		WHERE 
			NOT EXISTS(SELECT NULL FROM tblSOSalesOrderDetail WITH (NOLOCK) WHERE tblSOSalesOrderDetail.intSalesOrderId = II.intHeaderId AND tblSOSalesOrderDetail.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId)	
	END

IF @SourceTransactionId = 2 -- INVOICE
	BEGIN

		UPDATE  ARPH
		SET
			[ysnApplied] = 0
		FROM
			tblARPricingHistory ARPH
		INNER JOIN
			(SELECT [intInvoiceDetailId], intInvoiceId, intItemId, dblPrice, strPricing FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON ARPH.intTransactionDetailId = ARID.[intInvoiceDetailId]
		INNER JOIN
			(SELECT intInvoiceId FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, dblPrice, strPricing FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId
		INNER JOIN
			@InvoiceIds II
				ON ARPH.[intTransactionId] = II.intHeaderId  
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND (
					(
						ARID.intItemId = ARTD.intItemId		
						AND
						(ARID.dblPrice <> ARTD.dblPrice OR ARID.strPricing <> ARTD.strPricing)
					)
				--OR
				--	()
				)


		UPDATE  ARPH
		SET
			 [ysnApplied]	= 0
			,[ysnDeleted]	= 1
		FROM
			tblARPricingHistory ARPH
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON ARPH.intTransactionDetailId = ARTD.intTransactionDetailId
		INNER JOIN
			(SELECT intInvoiceId FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARTD.intTransactionId = ARI.intInvoiceId
		INNER JOIN
			@InvoiceIds II
				ON ARPH.[intTransactionId] = II.intHeaderId
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = II.intHeaderId AND intInvoiceDetailId = ARTD.intTransactionDetailId)

		INSERT INTO tblARPricingHistory
			([intSourceTransactionId]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[intEntityCustomerId]
			,[intItemId]
			,[intOriginalItemId]
			,[dblPrice]
			,[dblOriginalPrice]
			,[strPricing]
			,[strOriginalPricing]
			,[dtmDate]
			,[ysnApplied]
			,[intEntityId])

			--Price Changed
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= ARI.intInvoiceId
			,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
			,[intEntityCustomerId]		= ARI.[intEntityCustomerId]
			,[intItemId]				= ARID.[intItemId]
			,[intOriginalItemId]		= ARTD.[intItemId]
			,[dblPrice]					= ARID.[dblPrice]
			,[dblOriginalPrice]			= ARTD.[dblPrice]
			,[strPricing]				= ARID.[strPricing]
			,[strOriginalPricing]		= ARTD.[strPricing]
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblARInvoiceDetail ARID
		INNER JOIN
			(SELECT intInvoiceId, [intEntityCustomerId] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, dblPrice, [strPricing]  FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId 
		INNER JOIN
			@InvoiceIds II
				ON ARI.intInvoiceId = II.intHeaderId
		WHERE 
			ARID.intItemId = ARTD.intItemId		
			AND (ARID.dblPrice <> ARTD.dblPrice OR ARID.[strPricing] <> ARTD.[strPricing])
			AND NOT (ARID.dblPrice = ARTD.dblPrice AND ARID.[strPricing] = ARTD.[strPricing])
						
		UNION ALL	

		--Item Changed +new
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= ARI.intInvoiceId
			,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
			,[intEntityCustomerId]		= ARI.[intEntityCustomerId]
			,[intItemId]				= ARID.[intItemId]
			,[intOriginalItemId]		= ARTD.[intItemId]
			,[dblPrice]					= ARID.[dblPrice]
			,[dblOriginalPrice]			= ARID.[dblPrice]
			,[strPricing]				= ARID.[strPricing]
			,[strOriginalPricing]		= ARTD.[strPricing]
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblARInvoiceDetail ARID
		INNER JOIN
			(SELECT intInvoiceId, [intEntityCustomerId] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			(SELECT intTransactionDetailId, intTransactionId, intItemId, [strPricing] FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
				ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId
		INNER JOIN
			@InvoiceIds II
				ON ARI.intInvoiceId = II.intHeaderId
		WHERE 
			ARID.intItemId <> ARTD.intItemId		

		UNION ALL

		--Added Item
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= ARI.intInvoiceId
			,[intTransactionDetailId]	= ARID.[intInvoiceDetailId]
			,[intEntityCustomerId]		= ARI.[intEntityCustomerId]
			,[intItemId]				= ARID.[intItemId]
			,[intOriginalItemId]		= ARID.[intItemId]
			,[dblPrice]					= ARID.[dblPrice]
			,[dblOriginalPrice]			= ARID.[dblPrice]
			,[strPricing]				= ARID.[strPricing]
			,[strOriginalPricing]		= NULL
			,[dtmDate]					= @DateNow
			,[ysnApplied]				= 1
			,[intEntityId]				= @EntityId
		FROM 
			tblARInvoiceDetail ARID
		INNER JOIN
			(SELECT intInvoiceId, [intEntityCustomerId] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			@InvoiceIds II
				ON ARI.intInvoiceId = II.intHeaderId
		WHERE 
			NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WITH (NOLOCK) WHERE tblARInvoiceDetail.intInvoiceId = II.intHeaderId AND tblARInvoiceDetail.intInvoiceDetailId = ARID.intInvoiceDetailId)	
	END
		
	
END