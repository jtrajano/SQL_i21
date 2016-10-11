CREATE PROCEDURE [dbo].[uspARUpdatePricingHistory]
	 @SourceTransactionId	INT	= 1
	,@TransactionId			INT
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
			tblSOSalesOrderDetail SOSOD
				ON ARPH.intTransactionDetailId = SOSOD.intSalesOrderDetailId
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId 
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND ARPH.[intTransactionId] = @TransactionId
			AND (
					(
						SOSOD.intItemId = ARTD.intItemId		
						AND
						SOSOD.dblPrice <> ARTD.dblPrice 
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
			tblARTransactionDetail ARTD
				ON ARPH.intTransactionDetailId = ARTD.intTransactionDetailId
		INNER JOIN
			tblSOSalesOrder SO
				ON ARTD.intTransactionId = SO.intSalesOrderId
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND ARPH.[intTransactionId] = @TransactionId
			AND ARTD.intTransactionDetailId NOT IN (SELECT intSalesOrderDetailId FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @TransactionId)


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
			,[intTransactionId]			= @TransactionId
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
			tblSOSalesOrder SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId 
		WHERE 
			SO.intSalesOrderId = @TransactionId
			AND SOSOD.intItemId = ARTD.intItemId		
			AND SOSOD.dblPrice <> ARTD.dblPrice 
						
		UNION ALL	

		--Item Changed +new
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= @TransactionId
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
			tblSOSalesOrder SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON SOSOD.intSalesOrderDetailId = ARTD.intTransactionDetailId 
				AND SOSOD.intSalesOrderId = ARTD.intTransactionId 
		WHERE 
			SO.intSalesOrderId = @TransactionId
			AND SOSOD.intItemId <> ARTD.intItemId		

		UNION ALL

		--Added Item
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= @TransactionId
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
			tblSOSalesOrder SO
				ON SOSOD.intSalesOrderId = SO.intSalesOrderId
		WHERE 
			SO.intSalesOrderId = @TransactionId
			AND SOSOD.intSalesOrderDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId)		
	END

IF @SourceTransactionId = 2 -- INVOICE
	BEGIN

		UPDATE  ARPH
		SET
			[ysnApplied] = 0
		FROM
			tblARPricingHistory ARPH
		INNER JOIN
			tblARInvoiceDetail ARID
				ON ARPH.intTransactionDetailId = ARID.[intInvoiceDetailId]
		INNER JOIN
			tblARInvoice ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON ARID.[intInvoiceDetailId] = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId 
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND ARPH.[intTransactionId] = @TransactionId
			AND (
					(
						ARID.intItemId = ARTD.intItemId		
						AND
						ARID.dblPrice <> ARTD.dblPrice 
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
			tblARTransactionDetail ARTD
				ON ARPH.intTransactionDetailId = ARTD.intTransactionDetailId
		INNER JOIN
			tblARInvoice ARI
				ON ARTD.intTransactionId = ARI.intInvoiceId 
		WHERE
			ARPH.[intSourceTransactionId] = @SourceTransactionId
			AND ARPH.[intTransactionId] = @TransactionId
			AND ARTD.intTransactionDetailId NOT IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @TransactionId)

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
			,[intTransactionId]			= @TransactionId
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
			tblARInvoice ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId 
		WHERE 
			ARI.intInvoiceId = @TransactionId
			AND ARID.intItemId = ARTD.intItemId		
			AND ARID.dblPrice <> ARTD.dblPrice 
						
		UNION ALL	

		--Item Changed +new
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= @TransactionId
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
			tblARInvoice ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN
			tblARTransactionDetail ARTD
				ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
				AND ARID.intInvoiceId = ARTD.intTransactionId 
		WHERE 
			ARI.intInvoiceId = @TransactionId
			AND ARID.intItemId <> ARTD.intItemId		

		UNION ALL

		--Added Item
		SELECT
			 [intSourceTransactionId]	= @SourceTransactionId
			,[intTransactionId]			= @TransactionId
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
			tblARInvoice ARI
				ON ARID.intInvoiceId = ARI.intInvoiceId
		WHERE 
			ARI.intInvoiceId = @TransactionId
			AND ARID.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail WHERE intTransactionId = @TransactionId)		
	END
		
	
END