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
	FROM			
		tblARInvoiceDetailComponent ARIDC
	INNER JOIN
		(SELECT [intInvoiceDetailId], [intInvoiceId], [intItemId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN
		(SELECT [intInvoiceId] FROM tblARInvoice WITH (NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intTransactionDetailId], [intTransactionId], [intItemId] FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
			ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId]
			AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN
		(SELECT [intItemId], [strType] FROM tblICItem WITH (NOLOCK)) ICI
			ON ARTD.[intItemId] = ICI.[intItemId]
	INNER JOIN
		@InvoiceIds II
			ON ARI.[intInvoiceId] = II.[intHeaderId] 
	WHERE
		ISNULL(II.ysnForDelete, 0) = 1
		AND ARID.[intItemId] <> ARTD.[intItemId]
		AND ICI.[strType] = 'Bundle'		
			
			
	DELETE ARIDC
	FROM			
		tblARInvoiceDetailComponent ARIDC
	LEFT OUTER JOIN
		(SELECT [intInvoiceDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	WHERE 
		ISNULL(ARID.[intInvoiceDetailId],0) = 0			 
					

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
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		(SELECT [intInvoiceId], [intCompanyLocationId] FROM tblARInvoice WITH (NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intComponentItemId], [intItemId], [intCompanyLocationId], [strType], [intItemUnitMeasureId], [dblQuantity], [dblUnitQty] FROM vyuARGetItemComponents WITH (NOLOCK)) ARGIC
			ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		(SELECT [intItemId], [ysnListBundleSeparately] FROM tblICItem WITH (NOLOCK)) ICI
			ON ARID.[intItemId] = ICI.[intItemId]
	INNER JOIN
		@InvoiceIds II
			ON ARI.[intInvoiceId] = II.[intHeaderId]
	WHERE 
		ISNULL(II.ysnForDelete, 0) = 0
		AND NOT EXISTS(SELECT NULL FROM tblARTransactionDetail WHERE [intTransactionId] = ARI.[intInvoiceId] AND [intTransactionDetailId] = ARID.[intInvoiceDetailId] )
		AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
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
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		(SELECT [intInvoiceId], [intCompanyLocationId] FROM tblARInvoice WITH (NOLOCK)) ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		(SELECT [intComponentItemId], [intItemId], [intCompanyLocationId], [strType], [intItemUnitMeasureId], [dblQuantity], [dblUnitQty] FROM vyuARGetItemComponents WITH (NOLOCK)) ARGIC
			ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		(SELECT [intTransactionDetailId], [intTransactionId], [intItemId] FROM tblARTransactionDetail WITH (NOLOCK)) ARTD
			ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId] 
			AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN
		(SELECT [intItemId], [ysnListBundleSeparately] FROM tblICItem WITH (NOLOCK)) ICI
			ON ARID.[intItemId] = ICI.[intItemId]
	INNER JOIN
		@InvoiceIds II
			ON ARI.[intInvoiceId] = II.[intHeaderId]
	WHERE
		ISNULL(II.ysnForDelete, 0) = 0
		AND ARID.[intItemId] <> ARTD.[intItemId]
		AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0	
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')	
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0
						
	 
END

GO
