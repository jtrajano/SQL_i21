CREATE PROCEDURE [dbo].[uspARUpdateLineItemsComponent]
	 @InvoiceIds	InvoiceId	READONLY
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	--DELETE
	DELETE ARIDC
	FROM tblARInvoiceDetailComponent ARIDC
	INNER JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblARTransactionDetail ARTD WITH (NOLOCK) ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId]
														AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN tblICItem ICI WITH (NOLOCK) ON ARTD.[intItemId] = ICI.[intItemId]
	INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId] = II.[intHeaderId] 
	WHERE ISNULL(II.ysnForDelete, 0) = 1
	  AND ARID.[intItemId] <> ARTD.[intItemId]
	  AND ICI.[strType] = 'Bundle'		
			
	DELETE ARIDC
	FROM tblARInvoiceDetailComponent ARIDC
	LEFT OUTER JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	WHERE ISNULL(ARID.[intInvoiceDetailId],0) = 0			 

	--New
	INSERT INTO [tblARInvoiceDetailComponent]
		([intInvoiceDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intInvoiceDetailId]	= ARID.[intInvoiceDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN vyuARGetItemComponents ARGIC WITH (NOLOCK) ON ARID.[intItemId] = ARGIC.[intItemId] 
														 AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN tblICItem ICI WITH (NOLOCK) ON ARID.[intItemId] = ICI.[intItemId]
	INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId] = II.[intHeaderId]
	WHERE ISNULL(II.ysnForDelete, 0) = 0
	  AND NOT EXISTS(SELECT NULL FROM tblARTransactionDetail WHERE [intTransactionId] = ARI.[intInvoiceId] AND [intTransactionDetailId] = ARID.[intInvoiceDetailId] )
	  AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0
	  AND ARGIC.[strType] IN ('Bundle')
	  AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	  AND ISNULL(ARID.[intLoadDetailId], 0) = 0
	  AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0

	--New > Item Changed
	INSERT INTO [tblARInvoiceDetailComponent]
		([intInvoiceDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intInvoiceDetailId]	= ARID.[intInvoiceDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN vyuARGetItemComponents ARGIC WITH (NOLOCK) ON ARID.[intItemId] = ARGIC.[intItemId] 
														 AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN tblARTransactionDetail ARTD WITH (NOLOCK) ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId] 
														AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN tblICItem ICI WITH (NOLOCK) ON ARID.[intItemId] = ICI.[intItemId]
	INNER JOIN @InvoiceIds II ON ARI.[intInvoiceId] = II.[intHeaderId]
	WHERE ISNULL(II.ysnForDelete, 0) = 0
	  AND ARID.[intItemId] <> ARTD.[intItemId]
	  AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0	
	  AND ARGIC.[strType] IN ('Bundle')
	  AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
	  AND ISNULL(ARID.[intLoadDetailId], 0) = 0
	  AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0
	 
END
GO